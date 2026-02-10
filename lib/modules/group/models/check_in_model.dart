import 'package:cloud_firestore/cloud_firestore.dart';

class CheckInModel {
  final String id;
  final String userId;
  final String habitId;
  final String date;
  final String photoUrl;
  final String description;
  final DateTime completedAt;
  final int points;
  final Map<String, int> reactionCounts;
  final int commentCount;

  const CheckInModel({
    required this.id,
    required this.userId,
    required this.habitId,
    required this.date,
    required this.photoUrl,
    required this.completedAt,
    this.description = '',
    this.points = 1,
    this.reactionCounts = const {},
    this.commentCount = 0,
  });

  factory CheckInModel.fromFirestore(String id, Map<String, dynamic> data) {
    final completedAt = data['completedAt'];
    final reactionCountsRaw =
        data['reactionCounts'] as Map<String, dynamic>? ?? {};
    final reactionCounts = reactionCountsRaw.map(
      (key, value) => MapEntry(key, value as int),
    );

    return CheckInModel(
      id: id,
      userId: data['userId'] as String? ?? '',
      habitId: data['habitId'] as String? ?? '',
      date: data['date'] as String? ?? '',
      photoUrl: data['photoUrl'] as String? ?? '',
      description: data['description'] as String? ?? '',
      completedAt: completedAt is Timestamp
          ? completedAt.toDate()
          : DateTime.now(),
      points: data['points'] as int? ?? 1,
      reactionCounts: reactionCounts,
      commentCount: data['commentCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'habitId': habitId,
    'date': date,
    'photoUrl': photoUrl,
    'description': description,
    'completedAt': Timestamp.fromDate(completedAt),
    'points': points,
    'reactionCounts': reactionCounts,
    'commentCount': commentCount,
  };
}
