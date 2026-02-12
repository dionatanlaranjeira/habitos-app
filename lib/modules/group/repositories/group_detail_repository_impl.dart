import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../../core/core.dart';
import '../../home/models/group_member_model.dart';
import '../../home/models/group_model.dart';
import '../../../global_modules/user/models/user_model.dart';
import 'group_detail_repository.dart';

class GroupDetailRepositoryImpl implements GroupDetailRepository {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  GroupDetailRepositoryImpl({
    required FirestoreAdapter firestore,
    required FunctionsAdapter functionsAdapter,
  }) : _firestore = firestore.instance,
       _functions = functionsAdapter.instance;

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
    final habitIds = data['selectedHabitIds'] as List<dynamic>?;
    return habitIds?.map((e) => e.toString()).toList() ?? [];
  }

  @override
  Future<UserModel?> getUserById(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromFirestore(doc.id, doc.data()!);
  }

  @override
  Future<void> leaveGroup({required String groupId}) async {
    final callable = _functions.httpsCallable('leaveGroup');
    await callable.call(<String, dynamic>{'groupId': groupId});
  }
}
