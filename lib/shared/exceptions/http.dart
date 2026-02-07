import 'package:dio/dio.dart';

class HttpException implements Exception {
  final String? url;
  final DioException? dioException;
  final dynamic data;

  HttpException({
    required this.url,
    required this.dioException,
    this.data,
  });

  @override
  String toString() {
    return 'HTTP Exception: $url\n'
        'statusCode: ${dioException?.response?.statusCode}\n'
        'Data: $data';
  }

  String? get message {
    try {
      return dioException?.response?.data['data']['errors'].values
          .expand((e) => e as List)
          .join('\n');
    } catch (_) {
      try {
        return dioException?.response?.data['message'];
      } catch (_) {}
    }

    return null;
  }

  int? get statusCode => dioException?.response?.statusCode;

  Map<String, dynamic>? get request => dioException?.requestOptions.data;

  Map<String, dynamic>? get response => dioException?.response?.data;
}
