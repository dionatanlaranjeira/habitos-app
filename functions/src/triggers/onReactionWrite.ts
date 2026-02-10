import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

if (!admin.apps.length) {
    admin.initializeApp();
}

/**
 * Triggered when a reaction is created.
 * Path: groups/{groupId}/checkins/{checkinId}/reactions/{reactionId}
 */
export const onReactionCreated = functions.firestore
    .document("groups/{groupId}/checkins/{checkinId}/reactions/{reactionId}")
    .onCreate(async (snapshot, context) => {
        const data = snapshot.data();
        const emoji = data.emoji;
        const { groupId, checkinId } = context.params;

        if (!emoji) return;

        const checkinRef = admin.firestore()
            .collection("groups")
            .doc(groupId)
            .collection("checkins")
            .doc(checkinId);

        // Update the reactionCounts map in the check-in document
        await checkinRef.update({
            [`reactionCounts.${emoji}`]: admin.firestore.FieldValue.increment(1),
        });
    });

/**
 * Triggered when a reaction is deleted.
 */
export const onReactionDeleted = functions.firestore
    .document("groups/{groupId}/checkins/{checkinId}/reactions/{reactionId}")
    .onDelete(async (snapshot, context) => {
        const data = snapshot.data();
        const emoji = data.emoji;
        const { groupId, checkinId } = context.params;

        if (!emoji) return;

        const checkinRef = admin.firestore()
            .collection("groups")
            .doc(groupId)
            .collection("checkins")
            .doc(checkinId);

        // Decrement the counter
        await checkinRef.update({
            [`reactionCounts.${emoji}`]: admin.firestore.FieldValue.increment(-1),
        });

        // Optional: Clean up empty keys (not strictly necessary but cleaner)
        // To do this reliably, we'd need to check the value after decrement,
        // which requires a transaction or a separate check.
        // For simplicity in MVP, we'll keep the key with 0.
    });
