import 'package:dartz/dartz.dart';
import 'package:repo_viewer/core/domain/fresh.dart';
import 'package:repo_viewer/core/infrastructure/network_exceptions.dart';
import 'package:repo_viewer/github/core/domain/github_failure.dart';
import 'package:repo_viewer/github/core/domain/github_repo.dart';
import 'package:repo_viewer/github/core/infrastructure/github_repo_dto.dart';
import 'package:repo_viewer/github/repos/starred_repos/infrastructure/starred_repos_remote_service.dart';

class StarredRepository {
  final StarredReposRemoteService _remoteService;

  StarredRepository(this._remoteService);
  //TODO :local service

  Future<Either<GithubFailure, Fresh<List<GithubRepo>>>> getStarredReposPage(
    int page,
  ) async {
    try {
      final remotePageItems = await _remoteService.getStarredReposPage(page);
      return right(remotePageItems.when(
        //TODO :local service
        noConnection: (maxPage) =>
            Fresh.no([], isNextpageAvailable: page < maxPage),
        //TODO :local service
        notModified: (maxPage) =>
            Fresh.yes([], isNextpageAvailable: page < maxPage),

        //TODO : local service save data
        withNewData: (data, maxPage) =>
            Fresh.yes(data.toDomain(), isNextpageAvailable: page < maxPage),
      ));
    } on RestApiException catch (e) {
      return left(GithubFailure.api(e.errorCode));
    }
  }
}

extension DtoListToDomainList on List<GithubRepoDto> {
  List<GithubRepo> toDomain() {
    return map((e) => e.toDomain()).toList();
  }
}
