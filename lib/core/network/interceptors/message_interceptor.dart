import 'package:dio/dio.dart';
import 'package:synchronized/synchronized.dart';

import '../../../shared/shared.dart';

class MessageInterceptor extends QueuedInterceptor {
  final Lock _lock = Lock();

  DateTime? _lastNoConnectionMessageTimestamp;

  final Duration _messageCooldown = const Duration(seconds: 5);

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final hasMessage = response.data is Map && response.data['message'] != null;
    final showMessage = response.requestOptions.extra['show-message'] ?? true;
    if (hasMessage && showMessage) {
      Messages.success(response.data['message']);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final showMessage = err.requestOptions.extra['show-message'] ?? true;
    final noConnectionError =
        err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout;

    String? getMessage(DioException e) {
      try {
        return e.response?.data['errors'].values
            .expand((e) => e as List)
            .join('\n');
      } catch (_) {
        try {
          return e.response?.data['message'];
        } catch (_) {}
      }
      return null;
    }

    if (noConnectionError) {
      _lock.synchronized(() {
        final now = DateTime.now();
        bool shouldShowMessage = false;

        if (_lastNoConnectionMessageTimestamp == null) {
          shouldShowMessage = true;
        } else {
          final difference = now.difference(_lastNoConnectionMessageTimestamp!);
          if (difference > _messageCooldown) {
            shouldShowMessage = true;
          }
        }

        if (shouldShowMessage) {
          Messages.error(
            "Houve um problema na sua conexão, por favor conecte a uma rede e tente novamente!",
          );
          _lastNoConnectionMessageTimestamp = now;
        }
      });
    }

    if (showMessage && !noConnectionError) {
      Messages.error(getMessage(err));
    }

    handler.next(err);
  }
}
