import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import 'interaction_repository.dart';

class InteractionRepositoryImpl implements InteractionRepository {
  final FirebaseFirestore _firestore;

  InteractionRepositoryImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  CollectionReference _checkinsRef(String groupId) =>
      _firestore.collection('groups').doc(groupId).collection('checkins');

  @override
  Future<void> toggleReaction({
    required String groupId,
    required String checkinId,
    required String userId,
    required String emoji,
  }) async {
    final reactionsRef = _checkinsRef(
      groupId,
    ).doc(checkinId).collection('reactions');

    // Query to check if reaction already exists
    final snapshot = await reactionsRef
        .where('userId', isEqualTo: userId)
        .where('emoji', isEqualTo: emoji)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Delete existing reaction
      await snapshot.docs.first.reference.delete();
    } else {
      // Add new reaction
      await reactionsRef.add({
        'userId': userId,
        'emoji': emoji,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    // Counter denormalization is handled by Cloud Functions
  }

  @override
  Future<List<ReactionModel>> getReactions({
    required String groupId,
    required String checkinId,
  }) async {
    final snapshot = await _checkinsRef(
      groupId,
    ).doc(checkinId).collection('reactions').get();

    return snapshot.docs
        .map((doc) => ReactionModel.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<void> addComment({
    required String groupId,
    required String checkinId,
    required String userId,
    required String text,
  }) async {
    await _checkinsRef(groupId).doc(checkinId).collection('comments').add({
      'userId': userId,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
    // Counter denormalization is handled by Cloud Functions
  }

  @override
  Future<void> deleteComment({
    required String groupId,
    required String checkinId,
    required String commentId,
  }) async {
    await _checkinsRef(
      groupId,
    ).doc(checkinId).collection('comments').doc(commentId).delete();
    // Counter denormalization is handled by Cloud Functions
  }

  @override
  Future<List<CommentModel>> getComments({
    required String groupId,
    required String checkinId,
  }) async {
    final snapshot = await _checkinsRef(groupId)
        .doc(checkinId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => CommentModel.fromFirestore(doc.id, doc.data()))
        .toList();
  }
}
