import 'http.dart';

class GlobalException implements Exception {
  Object error;
  StackTrace? stackTrace;

  GlobalException(this.error, this.stackTrace) {
    if (error.runtimeType == HttpException) {
      HttpException httpException = (error as HttpException);

      error = {
        // 'route': Modular.routerDelegate.path,
        'url': httpException.url,
        'message': httpException.message,
        'request': httpException.request,
        'response': httpException.response,
        'statusCode': httpException.statusCode,
      };
    } else {
      error = {
        // 'route': Modular.routerDelegate.path,
        'error': error.toString(),
        'stackTrace': stackTrace.toString(),
      };
    }
  }
}
