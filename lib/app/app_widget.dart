import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/core.dart';
import '../global_modules/global_modules.dart';
import '../l10n/app_localizations.dart';
import '../shared/shared.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppRouter.globalProviders,
      child: AdaptiveTheme(
        light: UiConfig.lightTheme,
        initial: AdaptiveThemeMode.light,
        dark: UiConfig.darkTheme,
        builder: (light, dark) {
          return Consumer<LocaleStore>(
            builder: (context, localeStore, _) {
              return MaterialApp.router(
                theme: light,
                darkTheme: dark,
                debugShowCheckedModeBanner: false,
                title: 'Hábitos',
                locale: localeStore.locale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                routerConfig: AppRouter.router,
              );
            },
          );
        },
      ),
    );
  }
}
