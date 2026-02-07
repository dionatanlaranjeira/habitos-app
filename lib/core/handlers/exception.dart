import 'dart:developer';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../../core/core.dart';

class ExceptionHandler {
  final Object error;
  final StackTrace? stackTrace;

  ExceptionHandler(this.error, this.stackTrace) {
    log('==================================================================');
    log('============================= ERROR ==============================');
    log('==================================================================');
    log(error.toString());
    log(stackTrace.toString());

    GlobalException globalException = GlobalException(error, stackTrace);

    FirebaseCrashlytics.instance.recordError(
      globalException.error,
      globalException.stackTrace,
      printDetails: false,
      fatal: true,
    );
  }
}
