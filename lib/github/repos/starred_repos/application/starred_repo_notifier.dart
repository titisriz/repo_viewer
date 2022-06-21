import 'package:repo_viewer/github/repos/core/application/paginated_repo_notifier.dart';
import 'package:repo_viewer/github/repos/starred_repos/infrastructure/starred_repos_repository.dart';

class StarredRepoNotifier extends PaginatedRepoNotifier {
  final StarredReposRepository _starredReposRepository;
  StarredRepoNotifier(this._starredReposRepository);

  Future<void> getNextStarredReposPage() async {
    super.getNextPage(
        (page) => _starredReposRepository.getStarredReposPage(page));
  }

  Future<void> getFirstStarredReposPage() async {
    super.resetState();
    super.getNextPage(
        (page) => _starredReposRepository.getStarredReposPage(page));
  }
}
