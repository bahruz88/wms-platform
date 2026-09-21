import 'package:dio/dio.dart';
import 'package:wms_core/wms_core.dart';

/// Maps transport errors to [AppException]/[Failure]:
///
/// * `application/problem+json` bodies → [ProblemDetails] → status-specific
///   [ServerFailure] subtypes (409 `INSUFFICIENT_STOCK` → [ConflictFailure]...)
/// * timeouts / connection errors → [NetworkFailure]
/// * cancellation → [CancelledFailure]
///
/// The [AppException] is placed in [DioException.error]; `ModuleApi` unwraps
/// it so callers only ever see [AppException] (and `Result.guard` turns it
/// into `Err`).
class ProblemDetailsInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.error is AppException) {
      handler.next(err);
      return;
    }
    handler.next(err.copyWith(error: toAppException(err)));
  }

  /// Pure mapping, exposed for tests and for callers that bypass Dio.
  static AppException toAppException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return AppException(
          NetworkFailure(message: err.message, isTimeout: true),
        );
      case DioExceptionType.connectionError:
        return AppException(NetworkFailure(message: err.message));
      case DioExceptionType.cancel:
        return const AppException(CancelledFailure());
      case DioExceptionType.badCertificate:
        return AppException(
          NetworkFailure(message: err.message ?? 'Bad certificate'),
        );
      case DioExceptionType.badResponse:
        return AppException.fromProblem(problemFromResponse(err.response));
      case DioExceptionType.unknown:
        return AppException(
          NetworkFailure(message: err.message ?? err.error?.toString()),
        );
    }
  }

  /// Decodes a problem+json body, falling back to a synthetic problem built
  /// from the HTTP status so the UI always gets a [ProblemDetails].
  static ProblemDetails problemFromResponse(Response<Object?>? response) {
    final status = response?.statusCode;
    final data = response?.data;
    if (data is Map) {
      final map = data.map((k, v) => MapEntry(k.toString(), v));
      final looksLikeProblem =
          map.containsKey('title') ||
          map.containsKey('code') ||
          map.containsKey('status') ||
          _isProblemJson(response);
      if (looksLikeProblem) {
        final parsed = ProblemDetails.fromJson(map);
        return parsed.status == null && status != null
            ? ProblemDetails(
                type: parsed.type,
                title: parsed.title,
                status: status,
                code: parsed.code,
                detail: parsed.detail,
                traceId: parsed.traceId,
                errors: parsed.errors,
              )
            : parsed;
      }
    }
    return ProblemDetails.local(
      code: switch (status) {
        401 => ProblemCodes.unauthorized,
        403 => ProblemCodes.forbidden,
        404 => ProblemCodes.notFound,
        _ => 'HTTP_${status ?? 0}',
      },
      title: response?.statusMessage ?? 'HTTP ${status ?? 0}',
      status: status,
      detail: data is String && data.isNotEmpty ? data : null,
    );
  }

  static bool _isProblemJson(Response<Object?>? response) {
    final contentType = response?.headers.value('content-type') ?? '';
    return contentType.contains('application/problem+json');
  }
}
