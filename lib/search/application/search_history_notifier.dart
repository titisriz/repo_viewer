import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:repo_viewer/search/infrastructure/search_history_repository.dart';

class SearchHistoryNotifier extends StateNotifier<AsyncValue<List<String>>> {
  final SearchHistoryRepository _searchHistoryRepository;
  SearchHistoryNotifier(
    this._searchHistoryRepository,
  ) : super(const AsyncValue.loading());

  void watchSearchTerms({String? searchTerm}) {
    _searchHistoryRepository.watchSearchTerms(filter: searchTerm).listen(
      (event) {
        state = AsyncValue.data(event);
      },
    ).onError(
      (error) {
        state = AsyncValue.error(error);
      },
    );
  }

  Future<void> addSeachTerm(String searchTerm) =>
      _searchHistoryRepository.addSeachTerm(searchTerm);

  Future<void> deleteSeachTerm(String searchTerm) =>
      _searchHistoryRepository.deleteSeachTerm(searchTerm);

  Future<void> upsertSearchTerm(String searchTerm) =>
      _searchHistoryRepository.upsertSearchTerm(searchTerm);
}
