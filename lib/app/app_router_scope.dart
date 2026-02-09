import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:signals/signals_flutter.dart';

import '../core/core.dart';
import '../global_modules/global_modules.dart';
import '../l10n/app_localizations.dart';

class AppRouterScope extends StatefulWidget {
  const AppRouterScope({
    super.key,
    required this.lightTheme,
    required this.darkTheme,
  });

  final ThemeData lightTheme;
  final ThemeData darkTheme;

  @override
  State<AppRouterScope> createState() => _AppRouterScopeState();
}

class _AppRouterScopeState extends State<AppRouterScope> {
  GoRouter? _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _router ??= createAppRouter(context.read<AuthStore>());
  }

  @override
  Widget build(BuildContext context) {
    return Watch((_) {
      final localeStore = context.read<LocaleStore>();
      return MaterialApp.router(
        theme: widget.lightTheme,
        darkTheme: widget.darkTheme,
        debugShowCheckedModeBanner: false,
        title: 'Hábitos',
        locale: localeStore.locale.value,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        routerConfig: _router!,
      );
    });
  }
}
