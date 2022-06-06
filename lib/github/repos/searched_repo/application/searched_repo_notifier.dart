import 'package:repo_viewer/github/repos/core/application/paginated_repo_notifier.dart';
import 'package:repo_viewer/github/repos/searched_repo/infrastructure/searched_repos_repository.dart';

class SearchRepoNotifier extends PaginatedRepoNotifier {
  final SearchedReposRepository _searchedReposRepository;

  SearchRepoNotifier(this._searchedReposRepository);

  Future<void> getFirstSearchedRepo(String searchTerm) async {
    super.resetState();
    getSearchedRepo(searchTerm);
  }

  Future<void> getSearchedRepo(String searchTerm) async {
    await super.getNextPage((page) =>
        _searchedReposRepository.getSearchedReposPage(searchTerm, page));
  }
}
