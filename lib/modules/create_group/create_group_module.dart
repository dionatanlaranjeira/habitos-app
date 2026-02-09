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
            create: (_) => CreateGroupRepositoryImpl(),
          ),
          Provider<CreateGroupController>(
            create: (context) => CreateGroupController(
              groupRepository: context.read<GroupRepository>(),
              createGroupRepository: context.read<CreateGroupRepository>(),
              groupStore: context.read<GroupStore>(),
              authStore: context.read<AuthStore>(),
            ),
          ),
        ],
      );
}
