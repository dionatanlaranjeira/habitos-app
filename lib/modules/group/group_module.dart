import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../home/repositories/repositories.dart';
import 'controllers/controllers.dart';
import 'group_page.dart';

class GroupModule extends ProviderModule {
  static const String path = '/home/group/:groupId';

  GroupModule()
    : super(
        path: 'group/:groupId',
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
