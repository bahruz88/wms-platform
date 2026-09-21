import 'package:dio/dio.dart';

import '../client/token_provider.dart';

/// Attaches `Authorization: Bearer <token>` and transparently retries once
/// after a successful refresh on 401. Uses [QueuedInterceptor] so that
/// concurrent 401s trigger a single refresh.
///
/// Set `options.extra[skipAuthKey] = true` for anonymous requests.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({required this._tokenProvider, required this._dio});

  static const String skipAuthKey = 'wms.skipAuth';
  static const String retriedKey = 'wms.retried';

  final TokenProvider _tokenProvider;
  final Dio _dio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[skipAuthKey] == true) {
      handler.next(options);
      return;
    }
    final token = await _tokenProvider.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final is401 = err.response?.statusCode == 401;
    if (!is401 ||
        options.extra[skipAuthKey] == true ||
        options.extra[retriedKey] == true) {
      handler.next(err);
      return;
    }
    final refreshed = await _tokenProvider.refresh();
    if (!refreshed) {
      await _tokenProvider.onUnauthorized();
      handler.next(err);
      return;
    }
    final token = await _tokenProvider.getAccessToken();
    options.extra[retriedKey] = true;
    options.headers['Authorization'] = 'Bearer $token';
    try {
      final response = await _dio.fetch<Object?>(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}
