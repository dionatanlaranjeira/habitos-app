import '../../group/models/check_in_model.dart';
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

  Future<List<CheckInModel>> getUserCheckIns({
    required String userId,
    required DateTime start,
    required DateTime end,
  });
}
