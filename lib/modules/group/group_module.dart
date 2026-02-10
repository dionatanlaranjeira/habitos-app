import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../global_modules/auth/stores/auth_store.dart';
import '../../global_modules/user/repositories/user_repository.dart';
import '../home/repositories/repositories.dart';
import '../habit_selection/repositories/repositories.dart';
import 'controllers/controllers.dart';
import 'group_page.dart';
import 'repositories/repositories.dart';

class GroupModule extends ProviderModule {
  static const String path = '/home/group/:groupId';

  GroupModule()
    : super(
        path: 'group/:groupId',
        page: const GroupPage(),
        bindings: (state) {
          final groupId = state.pathParameters['groupId']!;
          return [
            Provider<StorageRepository>(
              create: (_) =>
                  StorageRepositoryImpl(storage: FirebaseStorage.instance),
            ),
            Provider<CheckInRepository>(
              create: (context) => CheckInRepositoryImpl(
                firestore: context.read<FirestoreAdapter>(),
                storageRepository: context.read<StorageRepository>(),
              ),
            ),
            Provider<InteractionRepository>(
              create: (context) => InteractionRepositoryImpl(
                firestore: context.read<FirestoreAdapter>().instance,
              ),
            ),
            Provider<GroupController>(
              create: (context) => GroupController(
                groupId: groupId,
                groupRepository: context.read<GroupRepository>(),
                checkInRepository: context.read<CheckInRepository>(),
                habitRepository: context.read<HabitRepository>(),
                userRepository: context.read<UserRepository>(),
                interactionRepository: context.read<InteractionRepository>(),
                authStore: context.read<AuthStore>(),
              ),
            ),
          ];
        },
      );
}
