import 'package:dio/dio.dart';
import 'package:repo_viewer/core/infrastructure/dio_extensions.dart';
import 'package:repo_viewer/core/infrastructure/network_exceptions.dart';

import 'package:repo_viewer/core/infrastructure/remote_response.dart';
import 'package:repo_viewer/github/core/infrastructure/github_headers.dart';
import 'package:repo_viewer/github/core/infrastructure/github_headers_cache.dart';
import 'package:repo_viewer/github/core/infrastructure/github_repo_dto.dart';
import 'package:repo_viewer/github/core/infrastructure/pagination_config.dart';

class StarredReposRemoteService {
  final Dio _dio;
  final GithubHeadersCache _githubHeadersCache;

  StarredReposRemoteService(
    this._dio,
    this._githubHeadersCache,
  );

  Future<RemoteResponse<List<GithubRepoDto>>> getStarredReposPage(
      int page) async {
    final requestUrl = Uri.https(
      'api.github.com',
      'user/starred',
      {
        'page': '$page',
        'per_page': '$PaginationConfig.itemsPerpage',
      },
    );

    final previousHeaders = await _githubHeadersCache.getHeaders(requestUrl);

    try {
      final response = await _dio.getUri(
        requestUrl,
        options: Options(
          headers: {
            'If-None-Match': previousHeaders?.etag ?? '',
          },
        ),
      );
      if (response.statusCode == 304) {
        return RemoteResponse.notModified(
            maxPage: previousHeaders?.link?.maxPage ?? 0);
      } else if (response.statusCode == 200) {
        final headers = GithubHeaders.parse(response);
        await _githubHeadersCache.saveHeaders(requestUrl, headers);

        final convertedData = (response.data as List<dynamic>)
            .map((e) => GithubRepoDto.fromJson(e))
            .toList();

        return RemoteResponse.withNewData(convertedData,
            maxPage: headers.link?.maxPage ?? 1);
      } else {
        throw RestApiException(response.statusCode);
      }
    } on DioError catch (e) {
      if (e.isNoConnectionError) {
        return RemoteResponse.noConnection(
            maxPage: previousHeaders?.link?.maxPage ?? 0);
      } else if (e.response != null) {
        throw RestApiException(e.response?.statusCode);
      } else {
        rethrow;
      }
    }
  }
}
