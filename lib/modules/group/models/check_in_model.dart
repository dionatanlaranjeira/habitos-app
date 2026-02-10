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

  const CheckInModel({
    required this.id,
    required this.userId,
    required this.habitId,
    required this.date,
    required this.photoUrl,
    required this.completedAt,
    this.description = '',
    this.points = 1,
  });

  factory CheckInModel.fromFirestore(String id, Map<String, dynamic> data) {
    final completedAt = data['completedAt'];
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
  };
}
