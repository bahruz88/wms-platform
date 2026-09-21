import 'dart:developer' as developer;

import 'package:dio/dio.dart';

/// Minimal request/response logger for debug builds. Never logs bodies of
/// authorization calls and truncates large payloads. Not added in release
/// builds (see `WmsApiClient.enableLogging`).
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({
    void Function(String message)? log,
    this.maxBodyChars = 800,
  }) : _log = log ?? ((m) => developer.log(m, name: 'wms.http'));

  final void Function(String message) _log;
  final int maxBodyChars;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _log('→ ${options.method} ${options.uri}${_body(options.data)}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<Object?> response,
    ResponseInterceptorHandler handler,
  ) {
    _log(
      '← ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.uri}${_body(response.data)}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log(
      '✕ ${err.response?.statusCode ?? err.type.name} '
      '${err.requestOptions.method} ${err.requestOptions.uri} '
      '${err.error ?? err.message ?? ''}',
    );
    handler.next(err);
  }

  String _body(Object? data) {
    if (data == null) return '';
    final text = data.toString();
    final clipped = text.length > maxBodyChars
        ? '${text.substring(0, maxBodyChars)}…'
        : text;
    return '\n  $clipped';
  }
}
