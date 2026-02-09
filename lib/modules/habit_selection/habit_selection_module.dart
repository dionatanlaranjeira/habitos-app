import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../home/repositories/repositories.dart';
import 'controllers/controllers.dart';
import 'habit_selection_page.dart';
import 'repositories/repositories.dart';

class HabitSelectionModule extends ProviderModule {
  static const String path = '/home/habit-selection';

  HabitSelectionModule()
    : super(
        path: 'habit-selection',
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
