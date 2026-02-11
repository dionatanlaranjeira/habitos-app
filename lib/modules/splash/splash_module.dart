import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../global_modules/global_modules.dart';
import 'splash.dart';

class SplashModule extends ProviderModule {
  static const String path = '/splash';

  SplashModule()
    : super(
        path: path,
        page: const SplashPage(),
        bindings: (context) => [
          Provider(
            create: (ctx) => SplashController(userStore: ctx.read<UserStore>()),
          ),
        ],
      );
}
