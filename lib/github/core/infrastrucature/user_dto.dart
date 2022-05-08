import 'package:freezed_annotation/freezed_annotation.dart';
part 'user_dto.freezed.dart';

@freezed
abstract class UserDto with _$UserDto {
  const UserDto._();
  const factory UserDto({
    required String name,
    required String avatarUrl,
  }) = _UserDto;

  factory UserDto.fromMap(Map<String, dynamic> json) {
    return UserDto(
      name: json['login'] as String,
      avatarUrl: json['avatar_url'] as String,
    );
  }
}
