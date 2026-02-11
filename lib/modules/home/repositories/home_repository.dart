import '../models/group_model.dart';

abstract class HomeRepository {
  Future<GroupModel?> joinGroupByCode({
    required String code,
    required String userId,
  });

  Stream<List<GroupModel>> watchGroupsByUser(String userId);

  Future<GroupModel?> getGroupByCode(String code);

  Future<List<String>> getMemberHabits({
    required String groupId,
    required String userId,
  });
}
