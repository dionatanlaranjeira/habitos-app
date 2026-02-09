import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  const GroupModel({
    required this.id,
    required this.name,
    required this.code,
    required this.ownerId,
    required this.memberIds,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String code;
  final String ownerId;
  final List<String> memberIds;
  final DateTime createdAt;

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'code': code,
        'ownerId': ownerId,
        'memberIds': memberIds,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory GroupModel.fromFirestore(String id, Map<String, dynamic> data) {
    final createdAt = data['createdAt'];
    return GroupModel(
      id: id,
      name: data['name'] as String? ?? '',
      code: data['code'] as String? ?? '',
      ownerId: data['ownerId'] as String? ?? '',
      memberIds: List<String>.from(data['memberIds'] ?? []),
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
    );
  }
}
