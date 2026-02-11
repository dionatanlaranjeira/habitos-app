import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

if (!admin.apps.length) {
  admin.initializeApp();
}

interface LocalDate {
  year: number;
  month: number;
  day: number;
}

interface WeeklyRankingEntry {
  userId: string;
  displayName: string;
  points: number;
  weeklyActiveDays: number;
  seasonActiveDays: number;
  seasonZeroDays: number;
  position: number;
}

const db = admin.firestore();
const storage = admin.storage();

function parseDateKey(value: string): LocalDate | null {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) return null;

  const [yearRaw, monthRaw, dayRaw] = value.split("-");
  const year = Number(yearRaw);
  const month = Number(monthRaw);
  const day = Number(dayRaw);

  if (!year || !month || !day) return null;
  return {year, month, day};
}

function formatDateKey(date: LocalDate): string {
  return `${date.year.toString().padStart(4, "0")}-${date.month
    .toString()
    .padStart(2, "0")}-${date.day.toString().padStart(2, "0")}`;
}

function toUtcDate(date: LocalDate): Date {
  return new Date(Date.UTC(date.year, date.month - 1, date.day));
}

function fromUtcDate(date: Date): LocalDate {
  return {
    year: date.getUTCFullYear(),
    month: date.getUTCMonth() + 1,
    day: date.getUTCDate(),
  };
}

function getDateInTimeZone(value: Date, timeZone: string): LocalDate {
  const formatter = new Intl.DateTimeFormat("en-US", {
    timeZone,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  });

  const parts = formatter.formatToParts(value);
  const year = Number(parts.find((part) => part.type === "year")?.value);
  const month = Number(parts.find((part) => part.type === "month")?.value);
  const day = Number(parts.find((part) => part.type === "day")?.value);

  if (!year || !month || !day) {
    return {
      year: value.getUTCFullYear(),
      month: value.getUTCMonth() + 1,
      day: value.getUTCDate(),
    };
  }

  return {year, month, day};
}

function getWeekStartSunday(date: LocalDate): LocalDate {
  const utcDate = toUtcDate(date);
  const dayOfWeek = utcDate.getUTCDay();
  utcDate.setUTCDate(utcDate.getUTCDate() - dayOfWeek);
  return fromUtcDate(utcDate);
}

function addDays(date: LocalDate, days: number): LocalDate {
  const utcDate = toUtcDate(date);
  utcDate.setUTCDate(utcDate.getUTCDate() + days);
  return fromUtcDate(utcDate);
}

function getElapsedSeasonDays(
  seasonStartDate: LocalDate | null,
  referenceDate: LocalDate,
  seasonDuration: number,
): number {
  if (!seasonStartDate) return 0;

  const start = toUtcDate(seasonStartDate).getTime();
  const current = toUtcDate(referenceDate).getTime();
  if (current < start) return 0;

  const diffDays = Math.floor((current - start) / (24 * 60 * 60 * 1000)) + 1;
  return Math.max(0, Math.min(diffDays, seasonDuration));
}

function buildSortKey(entry: WeeklyRankingEntry): string {
  return `${entry.points}|${entry.seasonActiveDays}|${entry.seasonZeroDays}`;
}

function sortRanking(a: WeeklyRankingEntry, b: WeeklyRankingEntry): number {
  if (b.points !== a.points) return b.points - a.points;
  if (b.seasonActiveDays !== a.seasonActiveDays) {
    return b.seasonActiveDays - a.seasonActiveDays;
  }
  if (a.seasonZeroDays !== b.seasonZeroDays) {
    return a.seasonZeroDays - b.seasonZeroDays;
  }
  return a.displayName.localeCompare(b.displayName, "pt-BR");
}

function assignRankingPositions(ranking: WeeklyRankingEntry[]): void {
  let previousKey = "";
  let previousPosition = 0;

  ranking.forEach((entry, index) => {
    const key = buildSortKey(entry);

    if (index === 0) {
      entry.position = 1;
      previousKey = key;
      previousPosition = 1;
      return;
    }

    if (key === previousKey) {
      entry.position = previousPosition;
      return;
    }

    entry.position = index + 1;
    previousKey = key;
    previousPosition = entry.position;
  });
}

function getStoragePathFromPhotoUrl(photoUrl: string): string | null {
  if (!photoUrl) return null;

  if (photoUrl.startsWith("gs://")) {
    const withoutProtocol = photoUrl.replace("gs://", "");
    const firstSlash = withoutProtocol.indexOf("/");
    if (firstSlash < 0) return null;
    return withoutProtocol.substring(firstSlash + 1);
  }

  const marker = "/o/";
  const markerIndex = photoUrl.indexOf(marker);
  if (markerIndex < 0) return null;

  const afterMarker = photoUrl.substring(markerIndex + marker.length);
  const questionMarkIndex = afterMarker.indexOf("?");
  const encodedPath =
    questionMarkIndex >= 0
      ? afterMarker.substring(0, questionMarkIndex)
      : afterMarker;

  try {
    return decodeURIComponent(encodedPath);
  } catch (_) {
    return null;
  }
}

export const onCheckinCreated = functions.firestore
  .document("groups/{groupId}/checkins/{checkinId}")
  .onCreate(async (snapshot, context) => {
    const data = snapshot.data();
    const {groupId} = context.params;

    const userId = String(data.userId ?? "").trim();
    if (!userId) return;

    const groupRef = db.collection("groups").doc(groupId);
    const groupSnap = await groupRef.get();
    if (!groupSnap.exists) return;

    const groupData = groupSnap.data() ?? {};
    const timezone = String(groupData.timezone ?? "UTC");

    const parsedDate = parseDateKey(String(data.date ?? ""));
    const fallbackDate = getDateInTimeZone(new Date(), timezone);
    const checkinDate = parsedDate ?? fallbackDate;
    const checkinDateKey = formatDateKey(checkinDate);

    const points = typeof data.points === "number" ? data.points : 1;

    const weekStart = getWeekStartSunday(checkinDate);
    const weekStartKey = formatDateKey(weekStart);

    const seasonStartTimestamp = groupData.seasonStartDate as
      | admin.firestore.Timestamp
      | undefined;

    const seasonStartDate = seasonStartTimestamp
      ? getDateInTimeZone(seasonStartTimestamp.toDate(), timezone)
      : null;

    const seasonDuration = Number(groupData.seasonDuration ?? 30);
    const elapsedSeasonDays = getElapsedSeasonDays(
      seasonStartDate,
      checkinDate,
      seasonDuration,
    );

    const statsRef = groupRef.collection("season_stats").doc(userId);
    const markerRef = statsRef.collection("active_days").doc(checkinDateKey);

    const weekRef = groupRef.collection("weekly_rankings").doc(weekStartKey);
    const weekEntryRef = weekRef.collection("entries").doc(userId);

    await db.runTransaction(async (tx) => {
      const [statsSnap, markerSnap, entrySnap] = await Promise.all([
        tx.get(statsRef),
        tx.get(markerRef),
        tx.get(weekEntryRef),
      ]);

      const firstCheckinOfDay = !markerSnap.exists;

      const previousSeasonActiveDays = Number(
        statsSnap.data()?.seasonActiveDays ?? 0,
      );
      const seasonActiveDays =
        previousSeasonActiveDays + (firstCheckinOfDay ? 1 : 0);
      const seasonZeroDays = Math.max(0, elapsedSeasonDays - seasonActiveDays);

      if (firstCheckinOfDay) {
        tx.set(markerRef, {
          date: checkinDateKey,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      tx.set(
        statsRef,
        {
          userId,
          seasonActiveDays,
          seasonZeroDays,
          lastActiveDate: checkinDateKey,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        {merge: true},
      );

      const previousPoints = Number(entrySnap.data()?.points ?? 0);
      const previousWeeklyActiveDays = Number(
        entrySnap.data()?.weeklyActiveDays ?? 0,
      );

      const currentPoints = previousPoints + points;
      const currentWeeklyActiveDays =
        previousWeeklyActiveDays + (firstCheckinOfDay ? 1 : 0);

      const snapshotMembersUpdate = {
        userId,
        displayName: "Usuário",
        points: currentPoints,
        weeklyActiveDays: currentWeeklyActiveDays,
        seasonActiveDays,
      };

      tx.set(
        weekRef,
        {
          groupId,
          timezone,
          weekStartDate: weekStartKey,
          weekEndDate: formatDateKey(addDays(weekStart, 6)),
          [`snapshotMembers.${userId}`]: snapshotMembersUpdate,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        {merge: true},
      );

      tx.set(
        weekEntryRef,
        {
          userId,
          points: currentPoints,
          weeklyActiveDays: currentWeeklyActiveDays,
          seasonActiveDays,
          seasonZeroDays,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        {merge: true},
      );
    });
  });

export const onCheckinDeleted = functions.firestore
  .document("groups/{groupId}/checkins/{checkinId}")
  .onDelete(async (snapshot, context) => {
    const data = snapshot.data();
    if (!data) return;

    const {groupId} = context.params;
    const userId = String(data.userId ?? "").trim();
    const dateKey = String(data.date ?? "").trim();
    const points = typeof data.points === "number" ? data.points : 1;

    if (!userId || !dateKey) return;

    const storagePath =
      String(data.storagePath ?? "").trim() ||
      getStoragePathFromPhotoUrl(String(data.photoUrl ?? ""));

    if (storagePath) {
      try {
        await storage.bucket().file(storagePath).delete({ignoreNotFound: true});
      } catch (error) {
        functions.logger.warn("Falha ao remover mídia do check-in", {
          groupId,
          userId,
          storagePath,
          error,
        });
      }
    }

    const groupRef = db.collection("groups").doc(groupId);
    const groupSnap = await groupRef.get();
    if (!groupSnap.exists) return;

    const groupData = groupSnap.data() ?? {};
    const timezone = String(groupData.timezone ?? "UTC");
    const parsedDate = parseDateKey(dateKey) ?? getDateInTimeZone(new Date(), timezone);
    const weekStart = getWeekStartSunday(parsedDate);
    const weekStartKey = formatDateKey(weekStart);

    const seasonStartTimestamp = groupData.seasonStartDate as
      | admin.firestore.Timestamp
      | undefined;
    const seasonStartDate = seasonStartTimestamp
      ? getDateInTimeZone(seasonStartTimestamp.toDate(), timezone)
      : null;
    const seasonDuration = Number(groupData.seasonDuration ?? 30);
    const elapsedSeasonDays = getElapsedSeasonDays(
      seasonStartDate,
      getDateInTimeZone(new Date(), timezone),
      seasonDuration,
    );

    const remainingDaySnapshot = await groupRef
      .collection("checkins")
      .where("userId", "==", userId)
      .where("date", "==", dateKey)
      .limit(1)
      .get();

    const hasRemainingCheckinInDay = !remainingDaySnapshot.empty;

    const statsRef = groupRef.collection("season_stats").doc(userId);
    const markerRef = statsRef.collection("active_days").doc(dateKey);
    const weekRef = groupRef.collection("weekly_rankings").doc(weekStartKey);
    const weekEntryRef = weekRef.collection("entries").doc(userId);

    await db.runTransaction(async (tx) => {
      const [statsSnap, weekEntrySnap] = await Promise.all([
        tx.get(statsRef),
        tx.get(weekEntryRef),
      ]);

      const previousSeasonActiveDays = Number(
        statsSnap.data()?.seasonActiveDays ?? 0,
      );
      const seasonActiveDays = Math.max(
        0,
        previousSeasonActiveDays - (hasRemainingCheckinInDay ? 0 : 1),
      );
      const seasonZeroDays = Math.max(0, elapsedSeasonDays - seasonActiveDays);

      tx.set(
        statsRef,
        {
          seasonActiveDays,
          seasonZeroDays,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        {merge: true},
      );

      if (!hasRemainingCheckinInDay) {
        tx.delete(markerRef);
      }

      const previousPoints = Number(weekEntrySnap.data()?.points ?? 0);
      const previousWeeklyActiveDays = Number(
        weekEntrySnap.data()?.weeklyActiveDays ?? 0,
      );

      const nextPoints = Math.max(0, previousPoints - points);
      const nextWeeklyActiveDays = Math.max(
        0,
        previousWeeklyActiveDays - (hasRemainingCheckinInDay ? 0 : 1),
      );

      if (nextPoints == 0 && nextWeeklyActiveDays == 0) {
        tx.delete(weekEntryRef);
        tx.set(
          weekRef,
          {
            [`snapshotMembers.${userId}`]: admin.firestore.FieldValue.delete(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          },
          {merge: true},
        );
      } else {
        tx.set(
          weekEntryRef,
          {
            points: nextPoints,
            weeklyActiveDays: nextWeeklyActiveDays,
            seasonActiveDays,
            seasonZeroDays,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          },
          {merge: true},
        );

        tx.set(
          weekRef,
          {
            [`snapshotMembers.${userId}.userId`]: userId,
            [`snapshotMembers.${userId}.points`]: nextPoints,
            [`snapshotMembers.${userId}.weeklyActiveDays`]: nextWeeklyActiveDays,
            [`snapshotMembers.${userId}.seasonActiveDays`]: seasonActiveDays,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          },
          {merge: true},
        );
      }
    });
  });

export const getWeeklyGroupRanking = functions.https.onCall(
  async (data, context) => {
    if (!context.auth?.uid) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Autenticação obrigatória.",
      );
    }

    const groupId = String(data?.groupId ?? "").trim();
    if (!groupId) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "groupId é obrigatório.",
      );
    }

    const groupRef = db.collection("groups").doc(groupId);
    const groupSnap = await groupRef.get();

    if (!groupSnap.exists) {
      throw new functions.https.HttpsError("not-found", "Grupo não encontrado.");
    }

    const groupData = groupSnap.data() ?? {};
    const memberIds = (groupData.memberIds as string[] | undefined) ?? [];

    if (!memberIds.includes(context.auth.uid)) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Usuário não pertence ao grupo.",
      );
    }

    const timezone = String(groupData.timezone ?? "UTC");
    const currentDate = getDateInTimeZone(new Date(), timezone);

    const weekStartDate = getWeekStartSunday(currentDate);
    const weekStartKey = formatDateKey(weekStartDate);
    const weekEndKey = formatDateKey(addDays(weekStartDate, 6));

    const seasonStartTimestamp = groupData.seasonStartDate as
      | admin.firestore.Timestamp
      | undefined;

    const seasonStartDate = seasonStartTimestamp
      ? getDateInTimeZone(seasonStartTimestamp.toDate(), timezone)
      : null;

    const seasonDuration = Number(groupData.seasonDuration ?? 30);
    const elapsedSeasonDays = getElapsedSeasonDays(
      seasonStartDate,
      currentDate,
      seasonDuration,
    );

    const weekRef = groupRef.collection("weekly_rankings").doc(weekStartKey);

    const [weekSnap, activeMembersSnap] = await Promise.all([
      weekRef.get(),
      groupRef.collection("members").where("status", "==", "active").get(),
    ]);

    const activeUserIds = activeMembersSnap.docs.map((doc) => doc.id);
    if (activeUserIds.length === 0) {
      return {
        weekStartDate: weekStartKey,
        weekEndDate: weekEndKey,
        timezone,
        generatedAt: new Date().toISOString(),
        totalParticipants: 0,
        top: [],
        myPosition: null,
      };
    }

    const weekData = weekSnap.data() ?? {};
    const snapshotMembers =
      (weekData.snapshotMembers as
        | Record<string, Record<string, unknown>>
        | undefined) ?? {};

    const ranking: WeeklyRankingEntry[] = activeUserIds.map((uid) => {
      const item = snapshotMembers[uid] ?? {};

      const points = Number(item.points ?? 0);
      const weeklyActiveDays = Number(item.weeklyActiveDays ?? 0);
      const seasonActiveDays = Number(item.seasonActiveDays ?? 0);
      const seasonZeroDays = Math.max(0, elapsedSeasonDays - seasonActiveDays);

      return {
        userId: uid,
        displayName: String(item.displayName ?? "Usuário"),
        points,
        weeklyActiveDays,
        seasonActiveDays,
        seasonZeroDays,
        position: 0,
      };
    });

    ranking.sort(sortRanking);
    assignRankingPositions(ranking);

    const myPosition =
      ranking.find((entry) => entry.userId === context.auth?.uid) ?? null;

    return {
      weekStartDate: weekStartKey,
      weekEndDate: weekEndKey,
      timezone,
      generatedAt: new Date().toISOString(),
      totalParticipants: ranking.length,
      top: ranking.slice(0, 10),
      myPosition,
    };
  },
);
