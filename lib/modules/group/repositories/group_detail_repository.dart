import '../../home/models/group_model.dart';
import '../../home/models/group_member_model.dart';
import '../../../global_modules/user/models/user_model.dart';

abstract class GroupDetailRepository {
  Future<GroupModel?> getGroupById(String groupId);
  Future<List<GroupMemberModel>> getGroupMembers(String groupId);
  Future<List<String>> getMemberHabits({
    required String groupId,
    required String userId,
  });
  Future<UserModel?> getUserById(String userId);
  Future<void> leaveGroup({required String groupId});
}
