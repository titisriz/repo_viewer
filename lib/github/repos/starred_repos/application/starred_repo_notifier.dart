import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/core/domain/fresh.dart';
import 'package:repo_viewer/github/core/domain/github_failure.dart';
import 'package:repo_viewer/github/core/domain/github_repo.dart';
import 'package:repo_viewer/github/core/infrastructure/pagination_config.dart';
import 'package:repo_viewer/github/repos/starred_repos/infrastructure/starred_repos_repository.dart';

part 'starred_repo_notifier.freezed.dart';

@freezed
abstract class StarredRepoState with _$StarredRepoState {
  const factory StarredRepoState.initial(
    Fresh<List<GithubRepo>> repos,
  ) = _Initial;
  const factory StarredRepoState.loadInProgress(
    Fresh<List<GithubRepo>> repos,
    int itemsPerpage,
  ) = _LoadInProgress;
  const factory StarredRepoState.loadSuccess(Fresh<List<GithubRepo>> repos,
      {required bool isNextPageAvailable}) = _LoadSuccess;
  const factory StarredRepoState.loadFailure(
      Fresh<List<GithubRepo>> repos, GithubFailure failure) = _LoadFailure;
}

class StarredRepoNotifier extends StateNotifier<StarredRepoState> {
  final StarredRepository _starredReposRepository;
  StarredRepoNotifier(this._starredReposRepository)
      : super(StarredRepoState.initial(Fresh.yes([])));

  int _page = 1;

  Future<void> getNextStarredReposPage() async {
    state = StarredRepoState.loadInProgress(
        state.repos, PaginationConfig.itemsPerpage);
    final failureOrRepos =
        await _starredReposRepository.getStarredReposPage(_page);
    state = failureOrRepos.fold(
      (l) => StarredRepoState.loadFailure(state.repos, l),
      (r) {
        _page += 1;
        return StarredRepoState.loadSuccess(
          r.copyWith(
            entity: [
              ...state.repos.entity,
              ...r.entity,
            ],
          ),
          isNextPageAvailable: r.isNextPageAvailable ?? false,
        );
      },
    );
  }
}
