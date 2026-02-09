import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/core.dart';
import '../models/group_model.dart';
import 'group_repository.dart';

const _groupsCollection = 'groups';

class GroupRepositoryImpl implements GroupRepository {
  GroupRepositoryImpl({required FirestoreAdapter firestore})
    : _firestore = firestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _ref =>
      _firestore.collection(_groupsCollection);

  @override
  Future<GroupModel> createGroup({
    required String name,
    required String ownerId,
    required int seasonDuration,
    required String gameMode,
    required String timezone,
    String status = 'draft',
    DateTime? seasonStartDate,
  }) async {
    final code = _generateCode();
    final docRef = _ref.doc();
    final group = GroupModel(
      id: docRef.id,
      name: name,
      code: code,
      ownerId: ownerId,
      memberIds: [ownerId],
      createdAt: DateTime.now(),
      seasonDuration: seasonDuration,
      gameMode: gameMode,
      timezone: timezone,
      status: status,
      seasonStartDate: seasonStartDate,
    );
    await docRef.set(group.toFirestore());
    return group;
  }

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
  Future<List<GroupModel>> getGroupsByUser(String userId) async {
    final snapshot = await _ref
        .where('memberIds', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => GroupModel.fromFirestore(doc.id, doc.data()))
        .toList();
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
  Future<void> saveMemberHabits({
    required String groupId,
    required String userId,
    required List<String> habitIds,
  }) async {
    final memberRef = _ref.doc(groupId).collection('members').doc(userId);

    await memberRef.set({
      'selectedHabitIds': habitIds,
      'joinedAt': FieldValue.serverTimestamp(),
      'status': 'active',
    });
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

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random.secure();
    return List.generate(6, (index) => chars[rng.nextInt(chars.length)]).join();
  }
}
