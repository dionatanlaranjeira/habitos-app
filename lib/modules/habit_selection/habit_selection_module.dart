import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../global_modules/global_modules.dart';
import 'controllers/habit_selection_controller.dart';
import 'habit_selection_page.dart';
import 'repositories/category_repository.dart';
import 'repositories/category_repository_impl.dart';
import 'repositories/habit_repository.dart';
import 'repositories/habit_repository_impl.dart';

class HabitSelectionModule extends ProviderModule {
  static const String path = '/habit-selection';

  HabitSelectionModule()
    : super(
        path: path,
        page: const HabitSelectionPage(),
        bindings: (state) {
          // Pegando parâmetros passados via extra no GoRouter
          final extra = state.extra as Map<String, dynamic>?;
          final groupId = extra?['groupId'] ?? '';
          final userId = extra?['userId'] ?? '';

          return [
            Provider<HabitRepository>(
              create: (c) =>
                  HabitRepositoryImpl(firestore: c.read<FirestoreAdapter>()),
            ),
            Provider<CategoryRepository>(
              create: (c) =>
                  CategoryRepositoryImpl(firestore: c.read<FirestoreAdapter>()),
            ),
            Provider<HabitSelectionController>(
              create: (c) => HabitSelectionController(
                habitRepository: c.read<HabitRepository>(),
                categoryRepository: c.read<CategoryRepository>(),
                groupRepository: c.read<GroupRepository>(),
                groupId: groupId,
                userId: userId,
              ),
            ),
          ];
        },
      );
}
