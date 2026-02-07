import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../global_modules/global_modules.dart';
import '../../modules/modules.dart';
import '../core.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: SplashModule.path,
    routes: [SplashModule().route],
  );

  static List<SingleChildWidget> get globalProviders => [
        Provider<LocalSecureStorage>(create: (_) => LocalSecureStorageImpl()),
        Provider<FirestoreAdapter>(create: (_) => FirestoreAdapter()),
        Provider<FunctionsAdapter>(create: (_) => FunctionsAdapter()),
        Provider<AuthRepository>(
          create: (_) => AuthRepositoryImpl(),
        ),
        ChangeNotifierProvider<LocaleStore>(
          create: (_) => LocaleStore(ApplicationConfig.prefs),
        ),
        ChangeNotifierProvider<AuthStore>(
          create: (ctx) => AuthStore(ctx.read<AuthRepository>()),
        ),
      ];
}
