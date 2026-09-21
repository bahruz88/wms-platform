import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

/// Read-model access: dashboard summary, report catalogue and async exports.
abstract interface class ReportingRepository {
  Future<Result<DashboardSummaryDto>> dashboard({int? locationId});

  Future<Result<List<ReportDefinitionDto>>> reports();

  /// Exports run asynchronously (spec §13.4); poll with [exportJob].
  Future<Result<ExportJobDto>> requestExport(
    String reportCode, {
    Map<String, Object?> parameters,
  });

  Future<Result<ExportJobDto>> exportJob(String id);
}
