import 'package:dio/dio.dart';
import '../../../global_modules/global_modules.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/shared.dart';
import '../../core.dart';

class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final LocalSecureStorage localSecureStorage = currentContext
        .read<LocalSecureStorage>();
    final accessToken = await localSecureStorage.read(LSConstants.accessToken);
    final needAuth = options.extra['need-auth'];

    final isRefresh = options.path.contains('refresh');

    if (needAuth != false || !isRefresh) {
      options.headers['Authorization'] = 'Bearer $accessToken';
      debugPrint('token: $accessToken');
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    UserStore userStore = currentContext.read<UserStore>();
    final bool isRefreshRequest = err.requestOptions.path.contains('refresh');
    if (isRefreshRequest) {
      userStore.logout();
    }
    handler.next(err);
  }
}
