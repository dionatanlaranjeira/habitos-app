import 'package:freezed_annotation/freezed_annotation.dart';

import '../../global_modules.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User {
  factory User({
    int? id,
    String? username,
    Person? person,
    List<String>? roles,
    List<String>? permissions,
  }) = _User;
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
