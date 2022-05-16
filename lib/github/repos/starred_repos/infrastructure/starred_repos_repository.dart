import 'package:dartz/dartz.dart';
import 'package:repo_viewer/core/domain/fresh.dart';
import 'package:repo_viewer/core/infrastructure/network_exceptions.dart';
import 'package:repo_viewer/github/core/domain/github_failure.dart';
import 'package:repo_viewer/github/core/domain/github_repo.dart';
import 'package:repo_viewer/github/core/infrastructure/github_repo_dto.dart';
import 'package:repo_viewer/github/repos/starred_repos/infrastructure/starred_repos_local_service.dart';
import 'package:repo_viewer/github/repos/starred_repos/infrastructure/starred_repos_remote_service.dart';

class StarredRepository {
  final StarredReposRemoteService _remoteService;
  final StarredReposLocalService _localService;

  StarredRepository(this._remoteService, this._localService);

  Future<Either<GithubFailure, Fresh<List<GithubRepo>>>> getStarredReposPage(
    int page,
  ) async {
    try {
      final remotePageItems = await _remoteService.getStarredReposPage(page);
      return right(
        await remotePageItems.when(
          noConnection: (maxPage) async => Fresh.no(
              await _localService.getPage(page).then((_) => _.toDomain()),
              isNextpageAvailable: page < maxPage),
          notModified: (maxPage) async => Fresh.yes(
            await _localService.getPage(page).then((_) => _.toDomain()),
            isNextpageAvailable: page < maxPage,
          ),
          withNewData: (data, maxPage) async {
            _localService.upsertPage(data, page);
            return Fresh.yes(data.toDomain(),
                isNextpageAvailable: page < maxPage);
          },
        ),
      );
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