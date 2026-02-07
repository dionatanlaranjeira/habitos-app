import '../../../core/core.dart';
import '../splash.dart';

class SplashController with SplashVariables {
  final SplashRepository _splashRepository;

  SplashController({required SplashRepository splashRepository})
    : _splashRepository = splashRepository {
    init();
  }

  Future<void> init() async {
    await ApplicationConfig().configureApp();
  }
}
