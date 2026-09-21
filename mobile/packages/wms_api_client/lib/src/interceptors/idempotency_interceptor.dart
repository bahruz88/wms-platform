import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

/// Adds `Idempotency-Key: <GUID>` to every POST that does not already carry
/// one (spec §13.2). Retries reuse the same [RequestOptions], therefore the
/// same key, which is exactly what makes the retry safe.
class IdempotencyInterceptor extends Interceptor {
  IdempotencyInterceptor({String Function()? keyGenerator})
    : _keyGenerator = keyGenerator ?? const Uuid().v4;

  static const String headerName = 'Idempotency-Key';

  final String Function() _keyGenerator;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final method = options.method.toUpperCase();
    final hasKey = options.headers.keys.any(
      (k) => k.toLowerCase() == headerName.toLowerCase(),
    );
    if ((method == 'POST' || method == 'PUT' || method == 'PATCH') && !hasKey) {
      options.headers[headerName] = _keyGenerator();
    }
    handler.next(options);
  }
}
