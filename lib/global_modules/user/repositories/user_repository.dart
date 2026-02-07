import '../../global_modules.dart';

abstract class UserRepository {
  Future<FetchUserResponseDto> getUser();

  Future<RefreshTokenResponseDto> refreshToken(String? refreshToken);
}
