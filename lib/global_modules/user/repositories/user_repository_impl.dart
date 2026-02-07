import 'package:dio/dio.dart';

import '../../../core/core.dart';
import '../../global_modules.dart';

class UserRepositoryImpl extends UserRepository {
  final HttpAdapter _httpAdapter;

  UserRepositoryImpl({required HttpAdapter httpAdapter})
    : _httpAdapter = httpAdapter;

  @override
  Future<FetchUserResponseDto> getUser() async {
    final response = await _httpAdapter.get(
      '/v1/auth/token',
      options: Options(extra: {'show-message': false}),
    );
    return FetchUserResponseDto.fromJson(response.data['data']);
  }

  @override
  Future<RefreshTokenResponseDto> refreshToken(String? refreshToken) async {
    final response = await _httpAdapter.post(
      '/v1/auth/token/refresh',
      options: Options(extra: {'show-message': false}),
      data: {'refresh_token': refreshToken},
    );
    return RefreshTokenResponseDto.fromJson(response.data['data']);
  }
}
