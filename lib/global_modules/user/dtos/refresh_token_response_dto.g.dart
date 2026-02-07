// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refresh_token_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RefreshTokenResponseDto _$RefreshTokenResponseDtoFromJson(
  Map<String, dynamic> json,
) => _RefreshTokenResponseDto(
  accessToken: json['access_token'] as String,
  refreshToken: json['refresh_token'] as String,
);

Map<String, dynamic> _$RefreshTokenResponseDtoToJson(
  _RefreshTokenResponseDto instance,
) => <String, dynamic>{
  'access_token': instance.accessToken,
  'refresh_token': instance.refreshToken,
};
