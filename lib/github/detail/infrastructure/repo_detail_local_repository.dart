import 'package:repo_viewer/core/infrastructure/sembast_database.dart';
import 'package:repo_viewer/github/detail/infrastructure/github_repo_detail_dto.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/timestamp.dart';

class RepoDetailLocalRepository {
  final SembastDatabase _sembastDatabase;
  final _store = stringMapStoreFactory.store('repoDetail');
  final int cacheSize = 50;

  RepoDetailLocalRepository(this._sembastDatabase);

  Future<void> upsertRepoDetail(GithubRepoDetailDto repoDetailDto) async {
    await _store.record(repoDetailDto.fullName).put(
          _sembastDatabase.instance,
          repoDetailDto.toSembast(),
        );
    final allKeys = await _store.findKeys(
      _sembastDatabase.instance,
      finder: Finder(
        sortOrders: [
          SortOrder(GithubRepoDetailDto.lastUsedFieldName),
        ],
      ),
    );

    if (allKeys.length > cacheSize) {
      final keysToRemove = allKeys.sublist(cacheSize);

      for (final key in keysToRemove) {
        await _store.record(key).delete(_sembastDatabase.instance);
      }
    }
  }

  Future<GithubRepoDetailDto?> getRepoDetail(String fullName) async {
    final record = _store.record(fullName);
    await record.update(
      _sembastDatabase.instance,
      {
        GithubRepoDetailDto.lastUsedFieldName: Timestamp.now(),
      },
    );

    final recordSnapshot = await record.getSnapshot(_sembastDatabase.instance);
    if (recordSnapshot == null) {
      return null;
    }
    return GithubRepoDetailDto.fromSembast(recordSnapshot);
  }
}
