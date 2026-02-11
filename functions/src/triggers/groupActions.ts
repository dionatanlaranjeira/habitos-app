import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

async function deleteSubcollection(
  query: FirebaseFirestore.Query,
  batchSize = 400,
): Promise<void> {
  while (true) {
    const snapshot = await query.limit(batchSize).get();
    if (snapshot.empty) return;

    const batch = db.batch();
    snapshot.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();

    if (snapshot.size < batchSize) return;
  }
}

async function deleteCheckinWithChildren(
  checkinRef: FirebaseFirestore.DocumentReference,
): Promise<void> {
  await deleteSubcollection(checkinRef.collection("reactions"));
  await deleteSubcollection(checkinRef.collection("comments"));
  await checkinRef.delete();
}

export const deleteCheckIn = functions.https.onCall(async (data, context) => {
  const requesterUid = context.auth?.uid;
  if (!requesterUid) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Autenticação obrigatória.",
    );
  }

  const groupId = String(data?.groupId ?? "").trim();
  const checkinId = String(data?.checkinId ?? "").trim();

  if (!groupId || !checkinId) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "groupId e checkinId são obrigatórios.",
    );
  }

  const groupRef = db.collection("groups").doc(groupId);
  const [groupSnap, checkinSnap] = await Promise.all([
    groupRef.get(),
    groupRef.collection("checkins").doc(checkinId).get(),
  ]);

  if (!groupSnap.exists) {
    throw new functions.https.HttpsError("not-found", "Grupo não encontrado.");
  }

  if (!checkinSnap.exists) {
    throw new functions.https.HttpsError(
      "not-found",
      "Check-in não encontrado.",
    );
  }

  const groupData = groupSnap.data() ?? {};
  const ownerId = String(groupData.ownerId ?? "");
  const checkinData = checkinSnap.data() ?? {};
  const checkinOwnerId = String(checkinData.userId ?? "");

  const canDelete = requesterUid === checkinOwnerId || requesterUid === ownerId;
  if (!canDelete) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Sem permissão para excluir este check-in.",
    );
  }

  await deleteCheckinWithChildren(checkinSnap.ref);

  return {success: true};
});

export const leaveGroup = functions.https.onCall(async (data, context) => {
  const requesterUid = context.auth?.uid;
  if (!requesterUid) {
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
  const ownerId = String(groupData.ownerId ?? "");
  const memberIds = (groupData.memberIds as string[] | undefined) ?? [];

  if (!memberIds.includes(requesterUid)) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "Usuário não é membro deste grupo.",
    );
  }

  if (requesterUid === ownerId) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "O criador do grupo não pode sair sem transferir administração.",
    );
  }

  const checkinsQuery = groupRef
    .collection("checkins")
    .where("userId", "==", requesterUid);

  const checkinsSnapshot = await checkinsQuery.get();
  for (const checkinDoc of checkinsSnapshot.docs) {
    await deleteCheckinWithChildren(checkinDoc.ref);
  }

  const weeklyRankingSnapshot = await groupRef.collection("weekly_rankings").get();
  if (!weeklyRankingSnapshot.empty) {
    let batch = db.batch();
    let ops = 0;

    for (const weekDoc of weeklyRankingSnapshot.docs) {
      batch.update(weekDoc.ref, {
        [`snapshotMembers.${requesterUid}`]: admin.firestore.FieldValue.delete(),
      });
      ops += 1;

      batch.delete(weekDoc.ref.collection("entries").doc(requesterUid));
      ops += 1;

      if (ops >= 400) {
        await batch.commit();
        batch = db.batch();
        ops = 0;
      }
    }

    if (ops > 0) {
      await batch.commit();
    }
  }

  const seasonStatsRef = groupRef.collection("season_stats").doc(requesterUid);
  await deleteSubcollection(seasonStatsRef.collection("active_days"));
  await seasonStatsRef.delete().catch(() => undefined);

  await Promise.all([
    groupRef.update({
      memberIds: admin.firestore.FieldValue.arrayRemove(requesterUid),
    }),
    groupRef.collection("members").doc(requesterUid).set(
      {
        status: "left",
        leftAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      {merge: true},
    ),
  ]);

  return {success: true};
});
