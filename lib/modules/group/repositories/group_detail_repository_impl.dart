import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/core.dart';
import '../../home/models/group_member_model.dart';
import '../../home/models/group_model.dart';
import 'group_detail_repository.dart';

class GroupDetailRepositoryImpl implements GroupDetailRepository {
  final FirebaseFirestore _firestore;

  GroupDetailRepositoryImpl({required FirestoreAdapter firestore})
    : _firestore = firestore.instance;

  @override
  Future<GroupModel?> getGroupById(String groupId) async {
    final doc = await _firestore.collection('groups').doc(groupId).get();
    if (!doc.exists || doc.data() == null) return null;
    return GroupModel.fromFirestore(doc.id, doc.data()!);
  }

  @override
  Future<List<GroupMemberModel>> getGroupMembers(String groupId) async {
    final snapshot = await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .get();
    return snapshot.docs
        .map((doc) => GroupMemberModel.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<List<String>> getMemberHabits({
    required String groupId,
    required String userId,
  }) async {
    final doc = await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .doc(userId)
        .get();

    if (!doc.exists || doc.data() == null) return [];

    final data = doc.data()!;
    final habitIds = data['habitIds'] as List<dynamic>?;
    return habitIds?.map((e) => e.toString()).toList() ?? [];
  }

  @override
  Future<String?> getUserName(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data()?['name'] as String?;
  }
}
