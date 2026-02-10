import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

if (!admin.apps.length) {
    admin.initializeApp();
}

/**
 * Triggered when a comment is created.
 * Path: groups/{groupId}/checkins/{checkinId}/comments/{commentId}
 */
export const onCommentCreated = functions.firestore
    .document("groups/{groupId}/checkins/{checkinId}/comments/{commentId}")
    .onCreate(async (snapshot, context) => {
        const { groupId, checkinId } = context.params;

        const checkinRef = admin.firestore()
            .collection("groups")
            .doc(groupId)
            .collection("checkins")
            .doc(checkinId);

        await checkinRef.update({
            commentCount: admin.firestore.FieldValue.increment(1),
        });
    });

/**
 * Triggered when a comment is deleted.
 */
export const onCommentDeleted = functions.firestore
    .document("groups/{groupId}/checkins/{checkinId}/comments/{commentId}")
    .onDelete(async (snapshot, context) => {
        const { groupId, checkinId } = context.params;

        const checkinRef = admin.firestore()
            .collection("groups")
            .doc(groupId)
            .collection("checkins")
            .doc(checkinId);

        await checkinRef.update({
            commentCount: admin.firestore.FieldValue.increment(-1),
        });
    });
