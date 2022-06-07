import 'package:dio/dio.dart';
import 'package:repo_viewer/core/infrastructure/dio_extensions.dart';
import 'package:repo_viewer/core/infrastructure/network_exceptions.dart';
import 'package:repo_viewer/core/infrastructure/remote_response.dart';
import 'package:repo_viewer/github/core/infrastructure/github_headers.dart';
import 'package:repo_viewer/github/core/infrastructure/github_headers_cache.dart';

class RepoDetailRemoteRepository {
  final Dio _dio;
  final GithubHeadersCache _githubHeadersCache;

  RepoDetailRemoteRepository(this._dio, this._githubHeadersCache);

  Future<RemoteResponse<String>> getRepoDetailHtml(String fullName) async {
    final requestUrl = Uri.https(
      'api.github.com',
      'repos',
    );
    final previousHeaders = await _githubHeadersCache.getHeaders(requestUrl);

    try {
      final response = await _dio.getUri(
        requestUrl,
        options: Options(
            headers: {'If-None-Match': previousHeaders?.etag ?? ''},
            responseType: ResponseType.plain),
      );
      if (response.statusCode == 304) {
        return const RemoteResponse.notModified(maxPage: 0);
      } else if (response.statusCode == 200) {
        var githubHeaders = GithubHeaders.parse(response);
        await _githubHeadersCache.saveHeaders(requestUrl, githubHeaders);
        var html = response.data;
        return RemoteResponse.withNewData(html, maxPage: 0);
      } else {
        throw RestApiException(response.statusCode);
      }
    } on DioError catch (e) {
      if (e.isNoConnectionError) {
        return const RemoteResponse.noConnection();
      } else {
        rethrow;
      }
    }
  }
}
