import 'dart:async';

import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/core.dart';

void main() {
  FlavorConfig.appFlavor = Flavor.prd;
  runZonedGuarded(
    () {
      FlutterError.onError = (FlutterErrorDetails details) {
        ExceptionHandler(details.exception, details.stack);
      };
      runApp(const AppBootstrap());
    },
    (error, stackTrace) {
      ExceptionHandler(error, stackTrace);
    },
  );
}
