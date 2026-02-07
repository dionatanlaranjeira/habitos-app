import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';

class LoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log('Request: ${options.uri}');
    if (options.data != null && options.data is Map) {
      log('Request: ${jsonEncode(options.data)}');
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Variável para armazenar o log dos dados da requisição
    String requestDataLog;

    // Verifica se os dados da requisição são do tipo FormData
    if (err.requestOptions.data is FormData) {
      final formData = err.requestOptions.data as FormData;
      // Mapeia os campos de texto para uma string legível
      final fields = formData.fields
          .map((e) => '${e.key}: "${e.value}"')
          .join(', ');
      // Mapeia os arquivos para uma string legível
      final files = formData.files
          .map((e) => '${e.key}: ${e.value.filename}')
          .join(', ');

      requestDataLog = '[FormData] => Fields: {$fields}, Files: {$files}';
    } else {
      // Se não for FormData, tenta encodar como JSON (com segurança)
      try {
        requestDataLog = jsonEncode(err.requestOptions.data);
      } catch (e) {
        requestDataLog =
            'Não foi possível converter para JSON. Tipo: ${err.requestOptions.data.runtimeType}';
      }
    }

    log('''
      
      ==================== 🐛 DIO ERROR 🐛 ====================

      [URL]: ${err.requestOptions.uri} 

      [STATUS CODE]: ${err.response?.statusCode ?? 'N/A'}

      [REQUEST DATA]: $requestDataLog

      [RESPONSE BODY]: ${err.response?.data ?? 'N/A'}

      [TOKEN] ${err.requestOptions.headers['Authorization']}
      
      =========================================================
      ''');

    handler.next(err);
  }
}
