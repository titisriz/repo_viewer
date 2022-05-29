import 'package:dartz/dartz.dart';
import 'package:repo_viewer/core/domain/fresh.dart';
import 'package:repo_viewer/core/infrastructure/network_exceptions.dart';
import 'package:repo_viewer/github/core/domain/github_failure.dart';
import 'package:repo_viewer/github/repos/core/infrastructure/extensions.dart';
import 'package:repo_viewer/github/repos/searched_repo/infrastructure/searched_repos_remote_service.dart';

import '../../../core/domain/github_repo.dart';

class SearchedReposRepository {
  final SearchedReposRemoteService _remoteService;
  SearchedReposRepository(
    this._remoteService,
  );

  Future<Either<GithubFailure, Fresh<List<GithubRepo>>>> getSearchedReposPage(
    String searchTerm,
    int page,
  ) async {
    try {
      final repoItems =
          await _remoteService.getSearchedReposPage(page, searchTerm);
      return right(repoItems.maybeWhen(
        withNewData: (data, maxPage) => Fresh.yes(
          data.toDomain(),
          isNextpageAvailable: page < maxPage,
        ),
        orElse: () => Fresh.no([], isNextpageAvailable: false),
      ));
    } on RestApiException catch (e) {
      return left(GithubFailure.api(e.errorCode));
    }
  }
}
