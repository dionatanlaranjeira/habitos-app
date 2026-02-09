import '../models/habit_model.dart';

abstract class HabitRepository {
  Future<List<HabitModel>> getHabitLibrary();
}
