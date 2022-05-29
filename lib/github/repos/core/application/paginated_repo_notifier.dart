import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/core/domain/fresh.dart';
import 'package:repo_viewer/github/core/domain/github_failure.dart';
import 'package:repo_viewer/github/core/domain/github_repo.dart';
import 'package:repo_viewer/github/core/infrastructure/pagination_config.dart';

part 'paginated_repo_notifier.freezed.dart';

@freezed
class PaginatedRepoState with _$PaginatedRepoState {
  const factory PaginatedRepoState.initial(
    Fresh<List<GithubRepo>> repos,
  ) = _Initial;
  const factory PaginatedRepoState.loadInProgress(
    Fresh<List<GithubRepo>> repos,
    int itemsPerpage,
  ) = _LoadInProgress;
  const factory PaginatedRepoState.loadSuccess(Fresh<List<GithubRepo>> repos,
      {required bool isNextPageAvailable}) = _LoadSuccess;
  const factory PaginatedRepoState.loadFailure(
      Fresh<List<GithubRepo>> repos, GithubFailure failure) = _LoadFailure;
}

class PaginatedRepoNotifier extends StateNotifier<PaginatedRepoState> {
  int _page = 1;

  PaginatedRepoNotifier() : super(PaginatedRepoState.initial(Fresh.yes([])));

  @protected
  Future<void> getNextPage(
      Future<Either<GithubFailure, Fresh<List<GithubRepo>>>> Function(int page)
          getter) async {
    state = PaginatedRepoState.loadInProgress(
        state.repos, PaginationConfig.itemsPerpage);
    final failureOrRepos = await getter(_page);
    state = failureOrRepos.fold(
      (l) => PaginatedRepoState.loadFailure(state.repos, l),
      (r) {
        _page += 1;
        return PaginatedRepoState.loadSuccess(
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
