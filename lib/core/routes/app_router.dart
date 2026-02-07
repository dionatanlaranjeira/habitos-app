import 'package:provider/provider.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/single_child_widget.dart';

import '../../global_modules/global_modules.dart';
import '../../modules/modules.dart';
import '../../core/core.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: SplashModule.path,
    routes: [SplashModule().route],
  );

  static final List<SingleChildWidget> globalProviders = [
    Provider<LocalSecureStorage>(create: (_) => LocalSecureStorageImpl()),
    Provider<HttpAdapter>(create: (_) => HttpAdapter()),
    Provider(
      create: (context) => UserStore(
        userRepository: UserRepositoryImpl(
          httpAdapter: context.read<HttpAdapter>(),
        ),
        localSecureStorage: context.read<LocalSecureStorage>(),
      ),
    ),
  ];
}
