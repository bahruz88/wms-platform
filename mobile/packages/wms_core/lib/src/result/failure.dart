import 'package:meta/meta.dart';

import '../errors/problem_details.dart';

/// Domain/application level failure. Business errors are values, not
/// exceptions (spec appendix A: `Result<T>` pattern).
@immutable
sealed class Failure {
  const Failure(this.message);

  /// Maps a server [ProblemDetails] to the matching [Failure] subtype using
  /// the HTTP status (and `code` for 409 conflicts).
  factory Failure.fromProblem(ProblemDetails problem) {
    final status = problem.status;
    return switch (status) {
      400 || 422 => ValidationFailure(problem),
      401 => UnauthorizedFailure(problem),
      403 => ForbiddenFailure(problem),
      404 => NotFoundFailure(problem),
      409 => ConflictFailure(problem),
      _ => ServerFailure(problem),
    };
  }

  final String message;

  /// Short kind label used in logs and tests.
  String get kind => switch (this) {
    NetworkFailure() => 'NetworkFailure',
    CancelledFailure() => 'CancelledFailure',
    ValidationFailure() => 'ValidationFailure',
    UnauthorizedFailure() => 'UnauthorizedFailure',
    ForbiddenFailure() => 'ForbiddenFailure',
    NotFoundFailure() => 'NotFoundFailure',
    ConflictFailure() => 'ConflictFailure',
    ServerFailure() => 'ServerFailure',
    UnexpectedFailure() => 'UnexpectedFailure',
  };

  @override
  String toString() => '$kind($message)';
}

/// No connectivity, DNS failure, TLS error or timeout.
final class NetworkFailure extends Failure {
  const NetworkFailure({String? message, this.isTimeout = false})
    : super(message ?? 'Network error');

  final bool isTimeout;
}

/// The request was cancelled by the caller.
final class CancelledFailure extends Failure {
  const CancelledFailure() : super('Request cancelled');
}

/// Any failure carrying an RFC 7807 problem from the API.
class ServerFailure extends Failure {
  ServerFailure(this.problem) : super(problem.message);

  final ProblemDetails problem;

  int? get status => problem.status;
  String? get code => problem.code;
}

/// 400 / 422 with optional field errors.
final class ValidationFailure extends ServerFailure {
  ValidationFailure(super.problem);

  Map<String, List<String>> get fieldErrors => problem.errors;
}

/// 401 - token missing/expired; the auth layer should refresh or sign out.
final class UnauthorizedFailure extends ServerFailure {
  UnauthorizedFailure(super.problem);
}

/// 403 - the user lacks a permission (e.g. `proc.po.approve`).
final class ForbiddenFailure extends ServerFailure {
  ForbiddenFailure(super.problem);
}

/// 404.
final class NotFoundFailure extends ServerFailure {
  NotFoundFailure(super.problem);
}

/// 409 - `INSUFFICIENT_STOCK`, `LOCATION_FROZEN`, `STALE_VERSION`...
final class ConflictFailure extends ServerFailure {
  ConflictFailure(super.problem);

  bool get isStaleVersion => code == ProblemCodes.staleVersion;
  bool get isLocationFrozen => code == ProblemCodes.locationFrozen;
  bool get isInsufficientStock => code == ProblemCodes.insufficientStock;
}

/// Programming errors / unknown exceptions surfaced as a failure.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure({String? message, this.error, this.stackTrace})
    : super(message ?? 'Unexpected error');

  final Object? error;
  final StackTrace? stackTrace;
}
