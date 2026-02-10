import 'package:cloud_firestore/cloud_firestore.dart';

class ReactionModel {
  final String id;
  final String userId;
  final String emoji;
  final DateTime createdAt;

  const ReactionModel({
    required this.id,
    required this.userId,
    required this.emoji,
    required this.createdAt,
  });

  factory ReactionModel.fromFirestore(String id, Map<String, dynamic> data) {
    final createdAt = data['createdAt'];
    return ReactionModel(
      id: id,
      userId: data['userId'] as String? ?? '',
      emoji: data['emoji'] as String? ?? '',
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'emoji': emoji,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
