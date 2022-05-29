import 'package:dio/dio.dart';

import 'package:repo_viewer/core/infrastructure/remote_response.dart';
import 'package:repo_viewer/github/core/infrastructure/github_headers_cache.dart';
import 'package:repo_viewer/github/core/infrastructure/github_repo_dto.dart';
import 'package:repo_viewer/github/core/infrastructure/pagination_config.dart';
import 'package:repo_viewer/github/repos/core/infrastructure/repos_remote_service.dart';

class SearchedReposRemoteService extends ReposRemoteService {
  SearchedReposRemoteService(
    Dio dio,
    GithubHeadersCache githubHeadersCache,
  ) : super(dio, githubHeadersCache);

  Future<RemoteResponse<List<GithubRepoDto>>> getSearchedReposPage(
    int page,
    String searchTerm,
  ) =>
      super.getPage(
          requestUrl: Uri.https(
            'api.github.com',
            '/search/repositories',
            {
              'q': searchTerm,
              'page': '$page',
              'per_page': '${PaginationConfig.itemsPerpage}',
            },
          ),
          jsonDataSelector: (json) => json['item'] as List<dynamic>);
}
