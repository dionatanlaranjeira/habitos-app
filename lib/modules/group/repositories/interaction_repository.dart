import '../models/models.dart';

abstract class InteractionRepository {
  /// Toggle a reaction (emoji) for a specific check-in.
  /// The Cloud Function will handle updating the counts.
  Future<void> toggleReaction({
    required String groupId,
    required String checkinId,
    required String userId,
    required String emoji,
  });

  /// Get all reactions for a specific check-in.
  Future<List<ReactionModel>> getReactions({
    required String groupId,
    required String checkinId,
  });

  /// Get all reactions by a specific user for a given date.
  Future<List<ReactionModel>> getReactionsByUserAndDate({
    required String groupId,
    required String userId,
    required String date,
  });

  /// Add a comment to a check-in.
  /// The Cloud Function will handle updating the comment count.
  Future<void> addComment({
    required String groupId,
    required String checkinId,
    required String userId,
    required String text,
  });

  /// Delete a comment from a check-in.
  Future<void> deleteComment({
    required String groupId,
    required String checkinId,
    required String commentId,
  });

  /// Get all comments for a specific check-in, ordered by date.
  Future<List<CommentModel>> getComments({
    required String groupId,
    required String checkinId,
  });
}
