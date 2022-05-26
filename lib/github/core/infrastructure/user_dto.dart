import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:repo_viewer/github/core/domain/user.dart';
part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

@freezed
class UserDto with _$UserDto {
  const UserDto._();
  const factory UserDto({
    @JsonKey(name: 'login') required String name,
    @JsonKey(name: 'avatar_url') required String avatarUrl,
  }) = _UserDto;

  // factory UserDto.fromJsonManual(Map<String, dynamic> json) {
  //   return UserDto(
  //     name: json['login'] as String,
  //     avatarUrl: json['avatar_url'] as String,
  //   );
  // }

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  // @overridelll
  // Map<String, dynamic> toJson() => _$UserDtoToJson(this);

  factory UserDto.fromDomain(User _) {
    return UserDto(name: _.name, avatarUrl: _.avatarUrl);
  }

  User toDomain() {
    return User(name: name, avatarUrl: avatarUrl);
  }
}
