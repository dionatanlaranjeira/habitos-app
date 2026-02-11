import '../models/models.dart';

abstract class CreateGroupRepository {
  Future<List<GameModeModel>> getGameModes();
  Future<List<SeasonDurationModel>> getSeasonDurations();

  Future<GroupModel> createGroup({
    required String name,
    required String ownerId,
    required int seasonDuration,
    required String gameMode,
    required String timezone,
    String status = 'draft',
    DateTime? seasonStartDate,
  });
}
