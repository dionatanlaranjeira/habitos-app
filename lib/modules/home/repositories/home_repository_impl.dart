import 'package:cloud_firestore/cloud_firestore.dart';

import '../../group/models/check_in_model.dart';
import '../../../core/core.dart';
import '../models/group_model.dart';
import 'home_repository.dart';

const _groupsCollection = 'groups';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({required FirestoreAdapter firestore})
    : _firestore = firestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _ref =>
      _firestore.collection(_groupsCollection);

  @override
  Future<GroupModel?> joinGroupByCode({
    required String code,
    required String userId,
  }) async {
    final group = await getGroupByCode(code);
    if (group == null) return null;

    if (group.memberIds.contains(userId)) return group;

    if (group.memberIds.length >= 10) return null;

    await _ref.doc(group.id).update({
      'memberIds': FieldValue.arrayUnion([userId]),
    });

    return GroupModel(
      id: group.id,
      name: group.name,
      code: group.code,
      ownerId: group.ownerId,
      memberIds: [...group.memberIds, userId],
      createdAt: group.createdAt,
      seasonDuration: group.seasonDuration,
      gameMode: group.gameMode,
      timezone: group.timezone,
      status: group.status,
      seasonStartDate: group.seasonStartDate,
    );
  }

  @override
  Stream<List<GroupModel>> watchGroupsByUser(String userId) {
    return _ref
        .where('memberIds', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => GroupModel.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Future<GroupModel?> getGroupByCode(String code) async {
    final snapshot = await _ref.where('code', isEqualTo: code).limit(1).get();

    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return GroupModel.fromFirestore(doc.id, doc.data());
  }

  @override
  Future<List<String>> getMemberHabits({
    required String groupId,
    required String userId,
  }) async {
    final doc = await _ref.doc(groupId).collection('members').doc(userId).get();

    if (!doc.exists) return [];

    final data = doc.data();
    if (data == null) return [];

    final habits = data['selectedHabitIds'];
    if (habits is List) {
      return habits.map((e) => e.toString()).toList();
    }
    return [];
  }

  @override
  Future<List<CheckInModel>> getUserCheckIns({
    required String userId,
    required DateTime start,
    required DateTime end,
  }) async {
    final startStr = start.toIso8601String().split('T').first;
    final endStr = end.toIso8601String().split('T').first;

    final snapshot = await _firestore
        .collectionGroup('checkins')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: startStr)
        .where('date', isLessThanOrEqualTo: endStr)
        .get();

    return snapshot.docs
        .map((doc) => CheckInModel.fromFirestore(doc.id, doc.data()))
        .toList();
  }
}
