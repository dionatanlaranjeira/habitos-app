import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

abstract class ProviderModule {
  final String _path;
  final Widget _page;
  final List<SingleChildWidget>? Function(GoRouterState state) _bindings;
  final List<GoRoute> _routes;

  ProviderModule({
    required String path,
    required Widget page,
    required List<SingleChildWidget>? Function(GoRouterState state) bindings,
    List<GoRoute> routes = const [],
  }) : _path = path,
       _page = page,
       _bindings = bindings,
       _routes = routes;
  GoRoute get route => GoRoute(
    path: _path,
    builder: (context, state) {
      final providers = _bindings(state);
      if (providers == null || providers.isEmpty) {
        return _page;
      }
      return MultiProvider(providers: providers, child: _page);
    },
    routes: _routes,
  );
}
