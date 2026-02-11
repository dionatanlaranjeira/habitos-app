import '../../../global_modules/user/stores/user_store.dart';
import '../../../core/core.dart';
import '../mixins/habit_selection_variables.dart';
import '../models/category_model.dart';
import '../models/habit_model.dart';
import '../repositories/category_repository.dart';
import '../repositories/habit_repository.dart';

class HabitSelectionController with HabitSelectionVariables {
  final HabitRepository _habitRepository;
  final CategoryRepository _categoryRepository;
  final UserStore _userStore;
  final String groupId;

  HabitSelectionController({
    required HabitRepository habitRepository,
    required CategoryRepository categoryRepository,
    required UserStore userStore,
    required this.groupId,
  }) : _habitRepository = habitRepository,
       _categoryRepository = categoryRepository,
       _userStore = userStore {
    loadData();
  }

  String? get userId => _userStore.uid;

  Future<void> loadData() async {
    await Future.wait([
      FutureHandler<List<CategoryModel>>(
        asyncState: categoriesAS,
        futureFunction: _categoryRepository.getCategories(),
      )(),
      FutureHandler<List<HabitModel>>(
        asyncState: habitLibraryAS,
        futureFunction: _habitRepository.getHabitLibrary(),
      )(),
    ]);
  }

  void toggleHabit(String habitId) {
    final currentList = List<String>.from(selectedHabitIds.value);
    if (currentList.contains(habitId)) {
      currentList.remove(habitId);
    } else {
      if (currentList.length < 5) {
        currentList.add(habitId);
      }
    }
    selectedHabitIds.value = currentList;
    Log.info(
      'Habit toggled: $habitId. Current selection: ${currentList.length}',
    );
  }

  Future<bool> confirmSelection() async {
    if (!canConfirm) return false;

    try {
      if (userId == null) return false;

      await FutureHandler<void>(
        asyncState: saveStatusAS,
        futureFunction: _habitRepository.saveMemberHabits(
          groupId: groupId,
          userId: userId!,
          habitIds: selectedHabitIds.value,
        ),
      )();
      return true;
    } catch (_) {
      return false;
    }
  }
}
