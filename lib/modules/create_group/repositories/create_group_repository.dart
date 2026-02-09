import '../models/models.dart';

abstract class CreateGroupRepository {
  Future<List<GameModeModel>> getGameModes();
  Future<List<SeasonDurationModel>> getSeasonDurations();
}
