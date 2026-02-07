import 'dart:async';

import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/core.dart';

void main() async {
  FlavorConfig.appFlavor = Flavor.dev;
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      FlutterError.onError = (FlutterErrorDetails details) {
        ExceptionHandler(details.exception, details.stack);
      };
      runApp(AppWidget());
    },
    (error, stackTrace) {
      ExceptionHandler(error, stackTrace);
    },
  );
}
