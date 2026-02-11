import 'package:provider/provider.dart';
import '../../../core/core.dart';
import '../../../global_modules/global_modules.dart';
import 'controllers/controllers.dart';
import 'create_group_page.dart';
import 'repositories/repositories.dart';

class CreateGroupModule extends ProviderModule {
  static const String path = '/home/create-group';

  CreateGroupModule()
    : super(
        path: 'create-group',
        page: const CreateGroupPage(),
        bindings: (state) => [
          Provider<CreateGroupRepository>(
            create: (ctx) => CreateGroupRepositoryImpl(
              firestore: ctx.read<FirestoreAdapter>(),
            ),
          ),
          Provider<CreateGroupController>(
            create: (ctx) => CreateGroupController(
              createGroupRepository: ctx.read<CreateGroupRepository>(),
              userStore: ctx.read<UserStore>(),
            ),
          ),
        ],
      );
}
