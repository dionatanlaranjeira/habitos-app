import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../global_modules/global_modules.dart';
import '../core.dart';

class AppRouter {
  static GoRouter? _router;
  static GoRouter get router => _router!;

  static void setRouter(GoRouter r) => _router = r;

  static List<SingleChildWidget> get globalProviders => [
        Provider<LocalSecureStorage>(create: (_) => LocalSecureStorageImpl()),
        Provider<FirestoreAdapter>(create: (_) => FirestoreAdapter()),
        Provider<FunctionsAdapter>(create: (_) => FunctionsAdapter()),
        Provider<AuthRepository>(
          create: (_) => AuthRepositoryImpl(),
        ),
        Provider<UserRepository>(
          create: (ctx) =>
              UserRepositoryImpl(firestore: ctx.read<FirestoreAdapter>()),
        ),
        Provider<GroupRepository>(
          create: (ctx) =>
              GroupRepositoryImpl(firestore: ctx.read<FirestoreAdapter>()),
        ),
        Provider<LocaleStore>(
          create: (_) => LocaleStore(ApplicationConfig.prefs),
        ),
        Provider<AuthStore>(
          create: (ctx) => AuthStore(ctx.read<AuthRepository>()),
        ),
        Provider<UserStore>(
          create: (ctx) => UserStore(
            ctx.read<UserRepository>(),
            ctx.read<AuthStore>(),
          ),
        ),
        Provider<GroupStore>(
          create: (ctx) => GroupStore(
            ctx.read<GroupRepository>(),
            ctx.read<AuthStore>(),
          ),
        ),
      ];
}
