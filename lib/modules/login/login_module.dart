import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../global_modules/global_modules.dart';
import 'login.dart';

class LoginModule extends ProviderModule {
  static const String path = '/login';

  LoginModule()
      : super(
          path: path,
          page: const LoginPage(),
          bindings: (context) => [
            Provider(
              create: (ctx) => LoginController(
                authRepository: ctx.read<AuthRepository>(),
                userRepository: ctx.read<UserRepository>(),
              ),
            ),
          ],
        );
}
