import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'github_headers.freezed.dart';
part 'github_headers.g.dart';

@freezed
abstract class GithubHeaders with _$GithubHeaders {
  const factory GithubHeaders({
    String? etag,
    PaginationLink? link,
  }) = _GithubHeaders;
  factory GithubHeaders.parse(Response response) {
    final link = response.headers['Links']?[0];
    return GithubHeaders(
        etag: response.headers.map['ETag']?[0],
        link: link == null
            ? null
            : PaginationLink.parse(
                link.split(','), response.requestOptions.uri.toString()));
  }
  factory GithubHeaders.fromJson(Map<String, dynamic> json) =>
      _$GithubHeadersFromJson(json);
}

@freezed
abstract class PaginationLink with _$PaginationLink {
  const factory PaginationLink({
    required int maxPage,
  }) = _PaginationLink;

  factory PaginationLink.parse(List<String> values, String requestUrl) {
    return PaginationLink(
      maxPage: _extractPageNumber(
        values.firstWhere(
          (element) => element.contains(values[1]),
          orElse: () => requestUrl,
        ),
      ),
    );
  }

  factory PaginationLink.fromJson(Map<String, dynamic> json) =>
      _$PaginationLinkFromJson(json);

  static int _extractPageNumber(String value) {
    String? urlString = RegExp(
            r'[(http(s)?)://(www.)?a-zA-Z0-9@:%._+~#=]{2,256}.[a-z]{2,6}\b([-a-zA-Z0-9@:%_+.~#?&//=]*)')
        .stringMatch(value);

    return int.parse(Uri.parse(urlString!).queryParameters['page']!);
  }
}
