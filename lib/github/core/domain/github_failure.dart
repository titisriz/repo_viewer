import 'package:freezed_annotation/freezed_annotation.dart';
part 'github_failure.freezed.dart';

@freezed
abstract class GithubFailure with _$GithubFailure {
  const factory GithubFailure.api(int? errorCode) = _Api;
}
