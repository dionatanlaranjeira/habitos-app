import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

// Substitua pelos seus imports corretos
import '../../../global_modules/global_modules.dart';
import '../../../shared/shared.dart';
import '../../core.dart';

class RefreshInterceptor extends Interceptor {
  final HttpAdapter _httpAdapter;
  Completer<void>? _completer;

  // Chave para o contador de retentativas
  static const _retryCountKey = 'retry_count';
  // Define o número máximo de retentativas para UMA requisição específica.
  // '1' significa que após o refresh, ele tentará a chamada mais uma vez. Se falhar de novo, ele desiste.
  static const int maxRetries = 1;

  RefreshInterceptor(this._httpAdapter);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final localSecureStorage = currentContext.read<LocalSecureStorage>();
    final requestOptions = err.requestOptions;

    int currentRetries = requestOptions.extra[_retryCountKey] ?? 0;

    final refreshToken = await localSecureStorage.read(
      LSConstants.refreshToken,
    );

    if (refreshToken == null) {
      return handler.next(err);
    }

    // 1. PONTO DE PARADA DE SEGURANÇA
    // Se esta requisição já tentou o suficiente, nós a rejeitamos para evitar um loop.
    if (currentRetries >= maxRetries) {
      return handler.next(err);
    }

    // Se o erro não for 401, não há o que fazer aqui.
    if (err.response?.statusCode != HttpStatus.unauthorized) {
      return handler.next(err);
    }

    // 2. LÓGICA DO COMPLETER (O PORTÃO)
    // Gerencia as múltiplas requisições concorrentes.
    if (_completer == null) {
      // Se o portão está aberto, esta é a requisição "líder".
      // Ela fecha o portão e inicia o processo de refresh.
      _completer = Completer<void>();

      try {
        // Lógica para buscar e salvar o novo token
        final userStore = currentContext.read<UserStore>();

        await userStore.refreshToken();

        // Abre o portão com sucesso
        _completer!.complete();
      } catch (e) {
        // Se o refresh falhar, abre o portão com erro
        _completer!.completeError(e);

        // Repassa o erro para a requisição líder
        final error = DioException(requestOptions: requestOptions, error: e);
        return handler.next(error);
      }
    }

    // 3. LÓGICA DE NOVA TENTATIVA
    // Todas as requisições (a líder e as seguidoras) esperam aqui.
    try {
      await _completer!.future;

      final userStore = currentContext.read<UserStore>();
      final newAccessToken = await userStore.getAccessToken();
      requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

      // Incrementa o contador ANTES de tentar novamente
      currentRetries++;
      requestOptions.extra[_retryCountKey] = currentRetries;
      final response = await _httpAdapter.fetch(requestOptions);

      // Se teve sucesso, resolve a requisição original com a nova resposta.
      return handler.resolve(response);
    } on DioException catch (e) {
      // Se a nova tentativa falhar, o erro é repassado. A próxima vez que
      // o `onError` for chamado para esta requisição, o contador no topo
      // irá barrar o loop.
      return handler.next(e);
    } finally {
      // Reseta o completer para que futuras falhas de 401 possam acionar o processo novamente.
      _completer = null;
    }
  }
}
