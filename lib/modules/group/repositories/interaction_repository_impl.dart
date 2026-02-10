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

    // Buscar TODAS as reações do usuário neste check-in
    final existingSnapshot = await reactionsRef
        .where('userId', isEqualTo: userId)
        .get();

    final existingEmoji = existingSnapshot.docs.isNotEmpty
        ? existingSnapshot.docs.first.data()['emoji'] as String?
        : null;

    // 1. Deletar reação existente (se houver)
    for (final doc in existingSnapshot.docs) {
      await doc.reference.delete();
    }

    // 2. Se é um emoji diferente do atual, adicionar novo
    // Se é o mesmo emoji, apenas removeu (untoggle)
    if (emoji != existingEmoji) {
      await reactionsRef.add({
        'userId': userId,
        'emoji': emoji,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    // Counter denormalization is handled by Cloud Functions triggers
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

  @override
  Future<List<ReactionModel>> getReactionsByUserAndDate({
    required String groupId,
    required String userId,
    required String date,
  }) async {
    // Note: For a real production app, we would add 'date' to the reaction document
    // to make this query efficient via collectionGroup.
    // For now, we fetch the check-ins for that date first, then their reactions.
    final checkinsSnapshot = await _checkinsRef(
      groupId,
    ).where('date', isEqualTo: date).get();

    final List<ReactionModel> allUserReactions = [];

    for (var checkinDoc in checkinsSnapshot.docs) {
      final reactionSnapshot = await checkinDoc.reference
          .collection('reactions')
          .where('userId', isEqualTo: userId)
          .get();

      for (var reactionDoc in reactionSnapshot.docs) {
        allUserReactions.add(
          ReactionModel.fromFirestore(reactionDoc.id, {
            ...reactionDoc.data(),
            'checkinId': checkinDoc.id,
          }),
        );
      }
    }

    return allUserReactions;
  }
}
