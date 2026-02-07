import 'package:freezed_annotation/freezed_annotation.dart';

import '../../global_modules.dart';

part 'fetch_user_response_dto.freezed.dart';
part 'fetch_user_response_dto.g.dart';

@freezed
abstract class FetchUserResponseDto with _$FetchUserResponseDto {
  factory FetchUserResponseDto({
    required String accessToken,
    required String refreshToken,
    required User user,
  }) = _FetchUserResponseDto;
  factory FetchUserResponseDto.fromJson(Map<String, dynamic> json) =>
      _$FetchUserResponseDtoFromJson(json);
}
