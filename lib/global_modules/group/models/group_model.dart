import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  const GroupModel({
    required this.id,
    required this.name,
    required this.code,
    required this.ownerId,
    required this.memberIds,
    required this.createdAt,
    required this.seasonDuration,
    required this.gameMode,
    required this.timezone,
    this.status = 'draft',
    this.seasonStartDate,
  });

  final String id;
  final String name;
  final String code;
  final String ownerId;
  final List<String> memberIds;
  final DateTime createdAt;
  final int seasonDuration;
  final String gameMode;
  final String timezone;
  final String status;
  final DateTime? seasonStartDate;

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'code': code,
    'ownerId': ownerId,
    'memberIds': memberIds,
    'createdAt': Timestamp.fromDate(createdAt),
    'seasonDuration': seasonDuration,
    'gameMode': gameMode,
    'timezone': timezone,
    'status': status,
    'seasonStartDate': seasonStartDate != null
        ? Timestamp.fromDate(seasonStartDate!)
        : null,
  };

  factory GroupModel.fromFirestore(String id, Map<String, dynamic> data) {
    final createdAt = data['createdAt'];
    final startDate = data['seasonStartDate'];
    return GroupModel(
      id: id,
      name: data['name'] as String? ?? '',
      code: data['code'] as String? ?? '',
      ownerId: data['ownerId'] as String? ?? '',
      memberIds: List<String>.from(data['memberIds'] ?? []),
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
      seasonDuration: data['seasonDuration'] as int? ?? 14,
      gameMode: data['gameMode'] as String? ?? 'normal',
      timezone: data['timezone'] as String? ?? 'UTC',
      status: data['status'] as String? ?? 'draft',
      seasonStartDate: startDate is Timestamp ? startDate.toDate() : null,
    );
  }
}
