import 'package:logger/logger.dart';

import '../config/config.dart';

class Log {
  Log._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 3,
      errorMethodCount: 8,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: _logLevel,
  );

  static Level get _logLevel {
    switch (FlavorConfig.appFlavor) {
      case Flavor.dev:
        return Level.debug;
      case Flavor.hom:
        return Level.info;
      case Flavor.prd:
        return Level.warning;
    }
  }

  /// Debug — inspecionar valores em desenvolvimento
  static void debug(String message, [dynamic data]) {
    _logger.d(message, error: data);
  }

  /// Info — eventos relevantes (navegação, ciclo de vida)
  static void info(String message, [dynamic data]) {
    _logger.i(message, error: data);
  }

  /// Warning — situações inesperadas que não são erros
  static void warning(String message, [dynamic data]) {
    _logger.w(message, error: data);
  }

  /// Error — falhas com exception e stackTrace
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Fatal — erros críticos que comprometem o app
  static void fatal(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}
