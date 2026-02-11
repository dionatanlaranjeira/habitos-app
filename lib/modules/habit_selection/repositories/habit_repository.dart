import '../models/habit_model.dart';

abstract class HabitRepository {
  Future<List<HabitModel>> getHabitLibrary();
  Future<void> saveMemberHabits({
    required String groupId,
    required String userId,
    required List<String> habitIds,
  });
}
