import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../global_modules/global_modules.dart';
import 'controllers/controllers.dart';
import 'profile_page.dart';

class ProfileModule extends ProviderModule {
  static const String path = '/profile';

  ProfileModule()
    : super(
        path: path,
        page: const ProfilePage(),
        bindings: (ctx) => [
          Provider<ProfileController>(
            create: (ctx) => ProfileController(
              ctx.read<UserRepository>(),
              ctx.read<UserStore>(),
            ),
            dispose: (_, controller) => controller.dispose(),
          ),
        ],
      );
}
