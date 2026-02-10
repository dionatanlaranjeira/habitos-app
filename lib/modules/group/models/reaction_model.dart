import 'package:cloud_firestore/cloud_firestore.dart';

class ReactionModel {
  final String id;
  final String userId;
  final String emoji;
  final DateTime createdAt;
  final String? checkinId;

  const ReactionModel({
    required this.id,
    required this.userId,
    required this.emoji,
    required this.createdAt,
    this.checkinId,
  });

  factory ReactionModel.fromFirestore(String id, Map<String, dynamic> data) {
    final createdAt = data['createdAt'];
    return ReactionModel(
      id: id,
      userId: data['userId'] as String? ?? '',
      emoji: data['emoji'] as String? ?? '',
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
      checkinId: data['checkinId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'emoji': emoji,
    'createdAt': Timestamp.fromDate(createdAt),
    if (checkinId != null) 'checkinId': checkinId,
  };
}
