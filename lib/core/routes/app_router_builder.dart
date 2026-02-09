import 'package:go_router/go_router.dart';

import '../../global_modules/global_modules.dart';
import 'app_router.dart';
import '../../modules/modules.dart';

GoRouter createAppRouter(AuthStore authStore) {
  final router = GoRouter(
    initialLocation: SplashModule.path,
    refreshListenable: authStore.currentUser,
    redirect: (context, state) {
      final isAuth = authStore.isAuthenticated;
      final location = state.matchedLocation;
      final isAuthRoute = location == LoginModule.path || location == RegisterModule.path;
      final isSplash = location == SplashModule.path;

      if (isSplash) return null;
      if (isAuth && isAuthRoute) return HomeModule.path;
      if (!isAuth && !isAuthRoute) return LoginModule.path;
      return null;
    },
    routes: [
      SplashModule().route,
      LoginModule().route,
      RegisterModule().route,
      HomeModule().route,
    ],
  );
  AppRouter.setRouter(router);
  return router;
}
