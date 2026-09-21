import 'package:meta/meta.dart';

/// RFC 7807 `application/problem+json` body with the WMS `code` extension
/// (spec §13.3).
@immutable
class ProblemDetails {
  const ProblemDetails({
    this.type,
    this.title,
    this.status,
    this.code,
    this.detail,
    this.traceId,
    this.errors = const {},
  });

  /// Parses a decoded JSON object. Unknown keys are ignored, missing keys are
  /// tolerated so that non-conforming error bodies still produce a value.
  factory ProblemDetails.fromJson(Map<String, Object?> json) {
    final rawErrors = json['errors'];
    final errors = <String, List<String>>{};
    if (rawErrors is Map) {
      rawErrors.forEach((key, value) {
        final messages = <String>[];
        if (value is List) {
          messages.addAll(value.map((e) => e.toString()));
        } else if (value != null) {
          messages.add(value.toString());
        }
        errors[key.toString()] = messages;
      });
    }
    final status = json['status'];
    return ProblemDetails(
      type: json['type'] as String?,
      title: json['title'] as String?,
      status: status is int ? status : int.tryParse('$status'),
      code: json['code'] as String?,
      detail: json['detail'] as String?,
      traceId: json['traceId'] as String?,
      errors: errors,
    );
  }

  /// Builds a synthetic problem for transport level failures.
  factory ProblemDetails.local({
    required String code,
    required String title,
    String? detail,
    int? status,
  }) => ProblemDetails(
    type: 'about:blank',
    title: title,
    status: status,
    code: code,
    detail: detail,
  );

  final String? type;
  final String? title;
  final int? status;

  /// Machine readable code: `INSUFFICIENT_STOCK`, `LOCATION_FROZEN`,
  /// `STALE_VERSION`, `VALIDATION_ERROR`...
  final String? code;
  final String? detail;
  final String? traceId;

  /// Field level validation errors, keyed by JSON path (`lines[2].qty`).
  final Map<String, List<String>> errors;

  bool get hasFieldErrors => errors.isNotEmpty;

  /// Messages for a given field path, or an empty list.
  List<String> fieldErrors(String path) => errors[path] ?? const [];

  Map<String, Object?> toJson() => {
    if (type != null) 'type': type,
    if (title != null) 'title': title,
    if (status != null) 'status': status,
    if (code != null) 'code': code,
    if (detail != null) 'detail': detail,
    if (traceId != null) 'traceId': traceId,
    if (errors.isNotEmpty) 'errors': errors,
  };

  /// Best human readable message.
  String get message => detail ?? title ?? code ?? 'Unknown error';

  @override
  String toString() =>
      'ProblemDetails(status: $status, code: $code, title: $title)';
}

/// Well-known error codes returned by the backend.
abstract final class ProblemCodes {
  static const String insufficientStock = 'INSUFFICIENT_STOCK';
  static const String locationFrozen = 'LOCATION_FROZEN';
  static const String staleVersion = 'STALE_VERSION';
  static const String validationError = 'VALIDATION_ERROR';
  static const String notFound = 'NOT_FOUND';
  static const String forbidden = 'FORBIDDEN';
  static const String unauthorized = 'UNAUTHORIZED';
  static const String fxRateMissing = 'FX_RATE_MISSING';
  static const String batchBlocked = 'BATCH_BLOCKED';
  static const String toleranceExceeded = 'TOLERANCE_EXCEEDED';
  static const String invalidStateTransition = 'INVALID_STATE_TRANSITION';
  static const String idempotentReplay = 'IDEMPOTENT_REPLAY';

  // Consumption module (`consumption.v1.yaml`, ADR-012).
  /// A sub-recipe refers back to its own menu item (`A → B → A`).
  static const String recipeCycle = 'RECIPE_CYCLE';

  /// Sub-recipe nesting is deeper than 5 levels.
  static const String recipeDepthExceeded = 'RECIPE_DEPTH_EXCEEDED';

  /// A version without component lines cannot be activated.
  static const String recipeEmpty = 'RECIPE_EMPTY';

  /// `validFrom` would move behind an already posted consumption document.
  static const String periodClosed = 'PERIOD_CLOSED';

  /// One document per `(location, businessDate)`.
  static const String duplicateBusinessDate = 'DUPLICATE_BUSINESS_DATE';

  /// No `master_product_uom` factor for the sales date.
  static const String uomFactorMissing = 'UOM_FACTOR_MISSING';

  /// CSV upload above 5 MB.
  static const String fileTooLarge = 'FILE_TOO_LARGE';

  // Client-side (transport) codes.
  static const String network = 'NETWORK_ERROR';
  static const String attachmentTooLarge = 'ATTACHMENT_TOO_LARGE';
  static const String attachmentTypeNotAllowed = 'ATTACHMENT_TYPE_NOT_ALLOWED';
  static const String attachmentEmpty = 'ATTACHMENT_EMPTY';
  static const String storageUploadFailed = 'STORAGE_UPLOAD_FAILED';
  static const String timeout = 'TIMEOUT';
  static const String cancelled = 'CANCELLED';
  static const String unexpected = 'UNEXPECTED';
}
