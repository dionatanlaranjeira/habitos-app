import 'package:provider/provider.dart';

import '../../core/core.dart';
import 'splash.dart';

class SplashModule extends ProviderModule {
  static const String path = '/splash'; // TODO: Se necessário, ajuste a rota.
  SplashModule()
    : super(
        path: path,
        page: const SplashPage(),
        bindings: (_) => [
          Provider(
            create: (context) => SplashController(
              splashRepository: SplashRepositoryImpl(),
              // TODO: Adicione outras dependências aqui, como o UserStore.
              // userStore: context.read<UserStore>(),
            ),
          ),
        ],
      );
}
