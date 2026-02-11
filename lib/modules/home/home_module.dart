import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../global_modules/global_modules.dart';
import 'home.dart';

class HomeModule extends ProviderModule {
  static const String path = '/home';

  HomeModule({super.routes})
    : super(
        path: path,
        page: const HomePage(),
        bindings: (_) => [
          Provider<HomeRepository>(
            create: (ctx) =>
                HomeRepositoryImpl(firestore: ctx.read<FirestoreAdapter>()),
          ),
          Provider<HomeController>(
            create: (ctx) => HomeController(
              homeRepository: ctx.read<HomeRepository>(),
              userStore: ctx.read<UserStore>(),
            ),
          ),
        ],
      );
}
