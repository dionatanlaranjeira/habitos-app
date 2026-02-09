import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../global_modules/global_modules.dart';
import 'register.dart';

class RegisterModule extends ProviderModule {
  static const String path = '/register';

  RegisterModule()
      : super(
          path: path,
          page: const RegisterPage(),
          bindings: (context) => [
            Provider(
              create: (ctx) => RegisterController(
                authRepository: ctx.read<AuthRepository>(),
                userRepository: ctx.read<UserRepository>(),
              ),
            ),
          ],
        );
}
