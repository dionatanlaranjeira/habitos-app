import 'package:cloud_firestore/cloud_firestore.dart';

class GroupMemberModel {
  final String userId;
  final List<String> selectedHabitIds;
  final DateTime joinedAt;
  final String status;

  const GroupMemberModel({
    required this.userId,
    required this.selectedHabitIds,
    required this.joinedAt,
    this.status = 'active',
  });

  Map<String, dynamic> toFirestore() => {
    'selectedHabitIds': selectedHabitIds,
    'joinedAt': Timestamp.fromDate(joinedAt),
    'status': status,
  };

  factory GroupMemberModel.fromFirestore(
    String userId,
    Map<String, dynamic> data,
  ) {
    final joinedAt = data['joinedAt'];
    return GroupMemberModel(
      userId: userId,
      selectedHabitIds: List<String>.from(data['selectedHabitIds'] ?? []),
      joinedAt: joinedAt is Timestamp ? joinedAt.toDate() : DateTime.now(),
      status: data['status'] as String? ?? 'active',
    );
  }
}
