import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/core/shared/providers.dart';
import 'package:repo_viewer/github/core/infrastructure/github_headers_cache.dart';
import 'package:repo_viewer/github/repos/core/application/paginated_repo_notifier.dart';
import 'package:repo_viewer/github/repos/searched_repo/application/searched_repo_notifier.dart';
import 'package:repo_viewer/github/repos/searched_repo/infrastructure/searched_repos_remote_service.dart';
import 'package:repo_viewer/github/repos/searched_repo/infrastructure/searched_repos_repository.dart';
import 'package:repo_viewer/github/repos/starred_repos/application/starred_repo_notifier.dart';
import 'package:repo_viewer/github/repos/starred_repos/infrastructure/starred_repos_local_service.dart';
import 'package:repo_viewer/github/repos/starred_repos/infrastructure/starred_repos_remote_service.dart';
import 'package:repo_viewer/github/repos/starred_repos/infrastructure/starred_repos_repository.dart';

final githubHeaderCacheProvider = Provider(
  (ref) => GithubHeadersCache(ref.watch(sembastProvider)),
);

final starredReposLocalServiceProvider = Provider(
  (ref) => StarredReposLocalService(ref.watch(sembastProvider)),
);
final starredReposRemoteServiceProvider = Provider(
  (ref) => StarredReposRemoteService(
    ref.watch(dioProvider),
    ref.watch(githubHeaderCacheProvider),
  ),
);

final starredReposRepositoryProvider = Provider(
  (ref) => StarredReposRepository(
    ref.watch(starredReposRemoteServiceProvider),
    ref.watch(starredReposLocalServiceProvider),
  ),
);

final starredRepoNotifierProvider =
    StateNotifierProvider.autoDispose<StarredRepoNotifier, PaginatedRepoState>(
        (ref) => StarredRepoNotifier(
              ref.watch(starredReposRepositoryProvider),
            ));

final searchedReposRemoteServiceProvider = Provider(
  (ref) => SearchedReposRemoteService(
    ref.watch(dioProvider),
    ref.watch(githubHeaderCacheProvider),
  ),
);

final searchedReposRepositoryProvider = Provider(
  (ref) => SearchedReposRepository(
    ref.watch(searchedReposRemoteServiceProvider),
  ),
);

final searchedRepoNotifierProvider =
    StateNotifierProvider.autoDispose<SearchRepoNotifier, PaginatedRepoState>(
        (ref) => SearchRepoNotifier(
              ref.watch(searchedReposRepositoryProvider),
            ));
