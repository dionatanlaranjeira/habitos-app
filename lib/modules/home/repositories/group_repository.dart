import '../models/group_model.dart';

abstract class GroupRepository {
  Future<GroupModel> createGroup({
    required String name,
    required String ownerId,
    required int seasonDuration,
    required String gameMode,
    required String timezone,
    String status = 'draft',
    DateTime? seasonStartDate,
  });

  Future<GroupModel?> joinGroupByCode({
    required String code,
    required String userId,
  });

  Future<List<GroupModel>> getGroupsByUser(String userId);
  Stream<List<GroupModel>> watchGroupsByUser(String userId);

  Future<GroupModel?> getGroupByCode(String code);

  Future<void> saveMemberHabits({
    required String groupId,
    required String userId,
    required List<String> habitIds,
  });

  Future<List<String>> getMemberHabits({
    required String groupId,
    required String userId,
  });
}
