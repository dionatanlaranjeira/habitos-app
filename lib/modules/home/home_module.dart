import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../global_modules/global_modules.dart';
import 'home.dart';

class HomeModule extends ProviderModule {
  static const String path = '/home';

  HomeModule({super.routes})
    : super(
        path: path,
        page: const HomePage(),
        bindings: (_) => [
          Provider(
            create: (ctx) => HomeController(
              groupRepository: ctx.read<GroupRepository>(),
              groupStore: ctx.read<GroupStore>(),
              authStore: ctx.read<AuthStore>(),
            ),
          ),
        ],
      );
}
