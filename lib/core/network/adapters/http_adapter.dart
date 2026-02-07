import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../../core.dart';

class HttpAdapter extends DioForNative {
  HttpAdapter() {
    _configureOptions();
    _configureInterceptors();
  }

  void _configureOptions() {
    options.contentType = Headers.jsonContentType;
    options.sendTimeout = const Duration(seconds: 30);
    options.receiveTimeout = const Duration(seconds: 30);
    options.connectTimeout = const Duration(seconds: 30);
    options.headers = {'accept': Headers.jsonContentType};
  }

  void _configureInterceptors() {
    interceptors.addAll([
      UrlInterceptor(),
      MessageInterceptor(),
      LoggerInterceptor(),
      AuthInterceptor(),
      RefreshInterceptor(this),
    ]);
  }
}
