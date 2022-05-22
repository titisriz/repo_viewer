import 'package:repo_viewer/core/infrastructure/sembast_database.dart';
import 'package:repo_viewer/github/core/infrastructure/github_repo_dto.dart';
import 'package:repo_viewer/github/core/infrastructure/pagination_config.dart';
import 'package:sembast/sembast.dart';
import 'package:collection/collection.dart';

class StarredReposLocalService {
  final SembastDatabase _sembastDatabase;
  StarredReposLocalService(
    this._sembastDatabase,
  );
  final _store = intMapStoreFactory.store('starredRepos');

  Future<void> upsertPage(List<GithubRepoDto> dtos, int page) async {
    final sembastPage = page - 1;
    _store
        .records(
          dtos
              .mapIndexed((index, element) =>
                  index + PaginationConfig.itemsPerpage * sembastPage)
              .toList(),
        )
        .put(
          _sembastDatabase.instance,
          dtos.map((e) => e.toJson()).toList(),
        );
  }

  Future<List<GithubRepoDto>> getPage(int page) async {
    final sembastPage = page - 1;
    final records = await _store.find(
      _sembastDatabase.instance,
      finder: Finder(
        limit: PaginationConfig.itemsPerpage,
        offset: PaginationConfig.itemsPerpage * sembastPage,
      ),
    );
    return records.map((e) => GithubRepoDto.fromJson(e.value)).toList();
  }
}
