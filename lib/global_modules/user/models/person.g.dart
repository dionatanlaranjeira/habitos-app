// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Person _$PersonFromJson(Map<String, dynamic> json) => _Person(
  name: json['name'] as String?,
  email: json['email'] as String?,
  birthday: json['birthday'] as String?,
  phone: json['phone'] as String?,
  avatarImage: json['avatar_image'] as String?,
);

Map<String, dynamic> _$PersonToJson(_Person instance) => <String, dynamic>{
  'name': instance.name,
  'email': instance.email,
  'birthday': instance.birthday,
  'phone': instance.phone,
  'avatar_image': instance.avatarImage,
};
