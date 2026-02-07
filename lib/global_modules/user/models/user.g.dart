// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: (json['id'] as num?)?.toInt(),
  username: json['username'] as String?,
  person: json['person'] == null
      ? null
      : Person.fromJson(json['person'] as Map<String, dynamic>),
  roles: (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList(),
  permissions: (json['permissions'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'person': instance.person,
  'roles': instance.roles,
  'permissions': instance.permissions,
};
