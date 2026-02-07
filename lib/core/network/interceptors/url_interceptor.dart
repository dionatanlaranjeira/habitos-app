import 'package:dio/dio.dart';

import '../../../core/core.dart';
import '../../../shared/shared.dart';

class UrlInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.baseUrl = Environments.param(Params.baseUrl) ?? '';
    handler.next(options);
  }
}
