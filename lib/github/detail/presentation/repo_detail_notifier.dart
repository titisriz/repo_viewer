import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/core/domain/fresh.dart';

import 'package:repo_viewer/github/core/domain/github_failure.dart';
import 'package:repo_viewer/github/detail/domain/github_repo_detail.dart';
import 'package:repo_viewer/github/detail/infrastructure/repo_detail_repository.dart';

part 'repo_detail_notifier.freezed.dart';

@freezed
abstract class RepoDetailState with _$RepoDetailState {
  const factory RepoDetailState.initial({
    @Default(false) bool isStarredStatusHasChanged,
  }) = _Initial;

  const factory RepoDetailState.loadInProgress({
    @Default(false) bool isStarredStatusHasChanged,
  }) = _LoadinProgress;

  const factory RepoDetailState.loadSuccess(
    Fresh<GithubRepoDetail?> githubRepoDetail, {
    @Default(false) bool isStarredStatusHasChanged,
  }) = _LoadSuccess;

  const factory RepoDetailState.loadFailure(
    GithubFailure githubFailure, {
    @Default(false) bool isStarredStatusHasChanged,
  }) = _LoadFailure;
}

class RepoDetailNotifier extends StateNotifier<RepoDetailState> {
  final RepoDetailRepository _detailRepository;

  RepoDetailNotifier(this._detailRepository)
      : super(const RepoDetailState.initial());

  Future<void> getRepoDetail(String repoFullName) async {
    state = const RepoDetailState.loadInProgress();
    final repoDetail = await _detailRepository.getRepoDetail(repoFullName);
    state = repoDetail.fold(
      (l) => RepoDetailState.loadFailure(l),
      (r) => RepoDetailState.loadSuccess(r),
    );
  }

  Future<void> switchStarredStatus() async {
    //change state,
    //call repo
    //change state
    state.maybeMap(
      orElse: () {},
      loadSuccess: (currentState) async {
        final stateCopy = currentState.copyWith();
        final GithubRepoDetail? repoDetail =
            currentState.githubRepoDetail.entity;

        if (repoDetail != null) {
          state = currentState.copyWith.githubRepoDetail(
            entity: repoDetail.copyWith(isStarred: !repoDetail.isStarred),
          );

          final failureOrSuccess =
              await _detailRepository.switchStarredStatus(repoDetail);

          failureOrSuccess.fold(
            (l) => state = stateCopy,
            (r) => r == null
                ? state = stateCopy
                : state = state.copyWith(isStarredStatusHasChanged: true),
          );
        }
      },
    );
  }
}
