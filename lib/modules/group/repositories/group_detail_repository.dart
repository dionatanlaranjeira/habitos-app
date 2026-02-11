import '../../home/models/group_model.dart';
import '../../home/models/group_member_model.dart';

abstract class GroupDetailRepository {
  Future<GroupModel?> getGroupById(String groupId);
  Future<List<GroupMemberModel>> getGroupMembers(String groupId);
  Future<List<String>> getMemberHabits({
    required String groupId,
    required String userId,
  });
  Future<String?> getUserName(String userId);
  Future<void> leaveGroup({required String groupId});
}
