import 'package:repo_viewer/github/core/domain/github_repo.dart';
import 'package:repo_viewer/github/core/infrastructure/github_repo_dto.dart';

extension DtoListToDomainList on List<GithubRepoDto> {
  List<GithubRepo> toDomain() {
    return map((e) => e.toDomain()).toList();
  }
}
