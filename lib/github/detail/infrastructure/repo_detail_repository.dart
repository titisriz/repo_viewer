import 'package:dartz/dartz.dart';
import 'package:repo_viewer/core/domain/fresh.dart';

import 'package:repo_viewer/core/infrastructure/network_exceptions.dart';
import 'package:repo_viewer/github/core/domain/github_failure.dart';
import 'package:repo_viewer/github/core/infrastructure/github_headers_cache.dart';
import 'package:repo_viewer/github/detail/domain/github_repo_detail.dart';
import 'package:repo_viewer/github/detail/infrastructure/repo_detail_local_repository.dart';
import 'package:repo_viewer/github/detail/infrastructure/repo_detail_remote_repository.dart';

class RepoDetailRepository {
  final RepoDetailLocalRepository _localRepository;
  final RepoDetailRemoteRepository _remoteRepository;
  final GithubHeadersCache _githubHeadersCache;

  RepoDetailRepository(
    this._localRepository,
    this._remoteRepository,
    this._githubHeadersCache,
  );

  Future<Either<GithubFailure, Unit?>> switchStarredStatus(
    GithubRepoDetail githubRepoDetail,
  ) async {
    try {
      final actionCompleted = await _remoteRepository.switchStarredStatus(
          githubRepoDetail.fullName,
          isCurrentlyStarred: githubRepoDetail.isStarred);
      return right(actionCompleted);
    } on RestApiException catch (e) {
      return left(GithubFailure.api(e.errorCode));
    }
  }

  Future<Either<GithubFailure, Fresh<GithubRepoDetail?>>> getRepoDetailHtml(
    String repoFullName,
  ) async {
    try {
      final repoDetailHtmlResponse =
          await _remoteRepository.getRepoDetailHtml(repoFullName);
      return right(await repoDetailHtmlResponse.when(
        noConnection: () async => Fresh.no(
          await _localRepository
              .getRepoDetail(repoFullName)
              .then((value) => value?.toDomain()),
        ),
        notModified: (_) async {
          final repoDetail = await _localRepository.getRepoDetail(repoFullName);
          final starredStatus =
              await _remoteRepository.getStarredStatus(repoFullName);
          return Fresh.no(repoDetail
              ?.copyWith(isStarred: starredStatus ?? false)
              .toDomain());
        },
        withNewData: (html, _) async {
          final starredStatus =
              await _remoteRepository.getStarredStatus(repoFullName);
          return Fresh.yes(GithubRepoDetail(
            fullName: repoFullName,
            html: html,
            isStarred: starredStatus ?? false,
          ));
        },
      ));
    } on RestApiException catch (e) {
      return left(GithubFailure.api(e.errorCode));
    }
  }
}
