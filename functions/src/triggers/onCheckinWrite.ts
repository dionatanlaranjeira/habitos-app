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
  checkinDate: LocalDate,
  seasonDuration: number,
): number {
  if (!seasonStartDate) return 0;

  const start = toUtcDate(seasonStartDate).getTime();
  const current = toUtcDate(checkinDate).getTime();

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

      tx.set(
        weekRef,
        {
          groupId,
          timezone,
          weekStartDate: weekStartKey,
          weekEndDate: formatDateKey(addDays(weekStart, 6)),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        {merge: true},
      );

      tx.set(
        weekEntryRef,
        {
          userId,
          points: previousPoints + points,
          weeklyActiveDays:
            previousWeeklyActiveDays + (firstCheckinOfDay ? 1 : 0),
          seasonActiveDays,
          seasonZeroDays,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        {merge: true},
      );
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

    const activeMembersSnap = await groupRef
      .collection("members")
      .where("status", "==", "active")
      .get();

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

    const weekEntriesSnap = await groupRef
      .collection("weekly_rankings")
      .doc(weekStartKey)
      .collection("entries")
      .get();

    const entriesByUserId = new Map<string, FirebaseFirestore.DocumentData>();
    weekEntriesSnap.docs.forEach((doc) => {
      entriesByUserId.set(doc.id, doc.data());
    });

    const statsSnaps = await Promise.all(
      activeUserIds.map((uid) => groupRef.collection("season_stats").doc(uid).get()),
    );

    const statsByUserId = new Map<string, FirebaseFirestore.DocumentData>();
    statsSnaps.forEach((doc) => {
      if (doc.exists) {
        statsByUserId.set(doc.id, doc.data() ?? {});
      }
    });

    const userSnaps = await Promise.all(
      activeUserIds.map((uid) => db.collection("users").doc(uid).get()),
    );

    const nameByUserId = new Map<string, string>();
    userSnaps.forEach((doc) => {
      const name = String((doc.data() ?? {}).name ?? "").trim();
      nameByUserId.set(doc.id, name || "Usuário");
    });

    const ranking: WeeklyRankingEntry[] = activeUserIds.map((uid) => {
      const entry = entriesByUserId.get(uid) ?? {};
      const stats = statsByUserId.get(uid) ?? {};

      const points = Number(entry.points ?? 0);
      const weeklyActiveDays = Number(entry.weeklyActiveDays ?? 0);

      const seasonActiveDays = Number(
        entry.seasonActiveDays ?? stats.seasonActiveDays ?? 0,
      );

      const seasonZeroDays = Number(
        entry.seasonZeroDays ??
          stats.seasonZeroDays ??
          Math.max(0, elapsedSeasonDays - seasonActiveDays),
      );

      return {
        userId: uid,
        displayName: nameByUserId.get(uid) ?? "Usuário",
        points,
        weeklyActiveDays,
        seasonActiveDays,
        seasonZeroDays,
        position: 0,
      };
    });

    ranking.sort(sortRanking);

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
