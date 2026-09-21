/// Pure Dart core of the WMS frontend: value objects, result types, error
/// models, enums mirrored from the spec, permission codes and environment.
///
/// This package must stay free of Flutter dependencies.
library;

export 'src/auth/permissions.dart';
export 'src/enums/attachment_enums.dart';
export 'src/enums/batch_status.dart';
export 'src/enums/consumption_enums.dart';
export 'src/enums/count_status.dart';
export 'src/enums/doc_type.dart';
export 'src/enums/document_enums.dart';
export 'src/enums/location_type.dart';
export 'src/enums/po_status.dart';
export 'src/enums/product_type.dart';
export 'src/enums/reason_group.dart';
export 'src/env/app_env.dart';
export 'src/errors/app_exception.dart';
export 'src/errors/problem_details.dart';
export 'src/observability/crash_reporter.dart';
export 'src/paging/page.dart';
export 'src/result/failure.dart';
export 'src/result/result.dart';
export 'src/tenant/tenant_context.dart';
export 'src/values/decimal_rounding.dart';
export 'src/values/money.dart';
export 'src/values/quantity.dart';
