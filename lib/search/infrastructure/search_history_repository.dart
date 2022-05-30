import 'package:repo_viewer/core/infrastructure/sembast_database.dart';
import 'package:sembast/sembast.dart';

class SearchHistoryRepository {
  final SembastDatabase _sembastDatabase;
  final _store = StoreRef<int, String>('searchHistory');

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
        .map((records) => records.map((e) => e.value).toList());
  }
}
