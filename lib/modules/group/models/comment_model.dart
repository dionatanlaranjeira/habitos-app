import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String userId;
  final String text;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.userId,
    required this.text,
    required this.createdAt,
  });

  factory CommentModel.fromFirestore(String id, Map<String, dynamic> data) {
    final createdAt = data['createdAt'];
    return CommentModel(
      id: id,
      userId: data['userId'] as String? ?? '',
      text: data['text'] as String? ?? '',
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'text': text,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
