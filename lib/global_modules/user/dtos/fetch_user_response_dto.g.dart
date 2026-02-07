// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fetch_user_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FetchUserResponseDto _$FetchUserResponseDtoFromJson(
  Map<String, dynamic> json,
) => _FetchUserResponseDto(
  accessToken: json['access_token'] as String,
  refreshToken: json['refresh_token'] as String,
  user: User.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$FetchUserResponseDtoToJson(
  _FetchUserResponseDto instance,
) => <String, dynamic>{
  'access_token': instance.accessToken,
  'refresh_token': instance.refreshToken,
  'user': instance.user,
};
