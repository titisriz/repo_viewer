import 'package:dartz/dartz.dart';
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

  Future<RemoteResponse<String>> getRepoDetailHtml(String repoFullName) async {
    final requestUrl = Uri.https(
      'api.github.com',
      'repos/$repoFullName/readme',
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
      } else if (e.response != null) {
        throw RestApiException(e.response?.statusCode);
      } else {
        rethrow;
      }
    }
  }

//returns `null` if there is no connection occured
  Future<bool?> getStarredStatus(String repoFullName) async {
    final requestUrl = Uri.https(
      'api.github.com',
      'user/starred/$repoFullName',
    );

    try {
      final response = await _dio.getUri(requestUrl,
          options: Options(
            validateStatus: (status) =>
                (status != null && status >= 200 && status < 400) ||
                status == 404,
          ));

      if (response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 404) {
        return false;
      } else {
        throw RestApiException(response.statusCode);
      }
    } on DioError catch (e) {
      if (e.isNoConnectionError) {
        return null;
      } else if (e.response != null) {
        throw RestApiException(e.response?.statusCode);
      } else {
        rethrow;
      }
    }
  }

  Future<Unit?> switchStarredStatus(String repoFullName,
      {required bool isCurrentlyStarred}) async {
    final requestUri = Uri.https(
      'api.github.com',
      'user/starred/$repoFullName',
    );

    try {
      final response = await (isCurrentlyStarred
          ? _dio.deleteUri(requestUri)
          : _dio.putUri(
              requestUri,
              options: Options(
                headers: {'Content-Length': '0'},
              ),
            ));

      if (response.statusCode == 204) {
        return unit;
      } else {
        throw RestApiException(response.statusCode);
      }
    } on DioError catch (e) {
      if (e.isNoConnectionError) {
        return null;
      } else if (e.response != null) {
        throw RestApiException(e.response?.statusCode);
      }
      rethrow;
    }
    return null;
  }
}
