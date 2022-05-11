import 'package:sembast/sembast.dart';

import 'package:repo_viewer/core/infrastructure/sembast_database.dart';
import 'package:repo_viewer/github/core/infrastructure/github_headers.dart';

class GithubHeadersCache {
  final SembastDatabase _sembastDatabase;

  GithubHeadersCache(
    this._sembastDatabase,
  );

  final store = stringMapStoreFactory.store('headers');

  Future<void> saveHeaders(Uri uri, GithubHeaders githubHeaders) async {
    await store.record(uri.toString()).put(
          _sembastDatabase.instance,
          githubHeaders.toJson(),
        );
  }

  Future<GithubHeaders?> getHeaders(Uri uri) async {
    final json =
        await store.record(uri.toString()).get(_sembastDatabase.instance);
    return json == null ? null : GithubHeaders.fromJson(json);
  }

  Future<void> deleteHeaders(Uri uri) async {
    await store.record(uri.toString()).delete(_sembastDatabase.instance);
  }
}
