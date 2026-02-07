import 'package:adaptive_theme/adaptive_theme.dart';

import '../core/core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
          return MaterialApp.router(
            theme: light,
            darkTheme: dark,
            debugShowCheckedModeBanner: false,
            title: UiConfig.title,
            locale: const Locale('pt', 'BR'),
            supportedLocales: const [Locale('pt', 'BR')],
            routerConfig: AppRouter.router,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}
