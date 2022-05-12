class RestApiException implements Exception {
  final int? code;

  RestApiException(this.code);
}
