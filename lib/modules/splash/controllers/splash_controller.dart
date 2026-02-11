import '../../../core/core.dart';
import '../../../global_modules/global_modules.dart';
import '../../home/home.dart';
import '../../login/login.dart';
import '../splash.dart';

class SplashController with SplashVariables {
  SplashController({required UserStore userStore}) : _userStore = userStore {
    init();
  }

  final UserStore _userStore;

  Future<void> init() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (_userStore.isAuthenticated) {
      AppRouter.router.go(HomeModule.path);
    } else {
      AppRouter.router.go(LoginModule.path);
    }
  }
}
