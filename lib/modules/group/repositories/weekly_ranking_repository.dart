import '../models/models.dart';

abstract class WeeklyRankingRepository {
  Future<WeeklyRankingModel> getWeeklyRanking({required String groupId});
}
