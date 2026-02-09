import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/core.dart';
import '../shared/shared.dart';
import 'app_router_scope.dart';

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
        builder: (light, dark) => AppRouterScope(
          lightTheme: light,
          darkTheme: dark,
        ),
      ),
    );
  }
}
