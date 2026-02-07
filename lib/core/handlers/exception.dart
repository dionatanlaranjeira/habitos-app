import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../logger/logger.dart';
import '../exceptions/exceptions.dart';

class ExceptionHandler {
  final Object error;
  final StackTrace? stackTrace;

  ExceptionHandler(this.error, this.stackTrace) {
    Log.error('Exceção capturada', error: error, stackTrace: stackTrace);

    if (Firebase.apps.isNotEmpty) {
      final globalException = GlobalException(error, stackTrace);
      FirebaseCrashlytics.instance.recordError(
        globalException.error,
        globalException.stackTrace,
        printDetails: false,
        fatal: true,
      );
    }
  }
}
