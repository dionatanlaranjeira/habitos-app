import 'package:flutter/widgets.dart';
import '../../core/core.dart';

BuildContext get currentContext =>
    AppRouter.router.routerDelegate.navigatorKey.currentContext!;
