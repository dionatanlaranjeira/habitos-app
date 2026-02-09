import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../global_modules/global_modules.dart';
import 'controllers/group_controller.dart';
import 'group_page.dart';

class GroupModule extends ProviderModule {
  static const String path = '/group/:groupId';

  GroupModule()
    : super(
        path: path,
        page: const GroupPage(),
        bindings: (state) {
          final groupId = state.pathParameters['groupId']!;
          return [
            Provider<GroupController>(
              create: (context) => GroupController(
                groupRepository: context.read<GroupRepository>(),
                groupId: groupId,
              ),
            ),
          ];
        },
      );
}
