import 'package:repo_viewer/core/infrastructure/sembast_database.dart';
import 'package:sembast/sembast.dart';

class SearchHistoryRepository {
  final SembastDatabase _sembastDatabase;
  final _store = StoreRef<int, String>('searchHistory');
  static const int historyLength = 10;

  SearchHistoryRepository(this._sembastDatabase);

  Stream<List<String>> watchSearchTerms({String? filter}) {
    return _store
        .query(
          finder: filter != null && filter.isNotEmpty
              ? Finder(
                  filter: Filter.custom(
                    (record) => (record as String).startsWith(filter),
                  ),
                )
              : null,
        )
        .onSnapshots(_sembastDatabase.instance)
        .map((records) => records.reversed.map((e) => e.value).toList());
  }

  Future<void> addSeachTerm(String term) =>
      _addSearchTerm(_sembastDatabase.instance, term);

  Future<void> deleteSeachTerm(String term) =>
      _deleteSearchTerm(_sembastDatabase.instance, term);

  Future<void> upsertSearchTerm(String searchTerm) async {
    await _sembastDatabase.instance.transaction(
      (transaction) {
        _deleteSearchTerm(transaction, searchTerm);
        _addSearchTerm(transaction, searchTerm);
      },
    );
  }

  Future<void> _addSearchTerm(
      DatabaseClient dbClient, String searchTerm) async {
    final key = await _store.findKey(dbClient);
    if (key != null) {
      upsertSearchTerm(searchTerm);
      return;
    }

    await _store.add(_sembastDatabase.instance, searchTerm);
    final count = await _store.count(_sembastDatabase.instance);
    if (count > historyLength) {
      await _store.delete(
        _sembastDatabase.instance,
        finder: Finder(
          limit: historyLength - count,
        ),
      );
    }
  }

  Future<void> _deleteSearchTerm(
      DatabaseClient dbClient, String searchTerm) async {
    await _store.delete(
      _sembastDatabase.instance,
      finder: Finder(
        filter: Filter.custom((record) => record.value == searchTerm),
      ),
    );
  }
}
