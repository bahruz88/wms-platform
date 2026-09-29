import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

/// Read-model access: dashboard summary, report catalogue, synchronous runs and async exports.
abstract interface class ReportingRepository {
  Future<Result<DashboardSummaryDto>> dashboard({int? locationId});

  Future<Result<List<ReportDefinitionDto>>> reports();

  Future<Result<ReportDefinitionDto>> report(String code);

  /// Runs a report on the spot. Capped at 200 rows by the contract — anything wider belongs in an
  /// export.
  Future<Result<ReportResultPageDto>> runReport(
    String code, {
    Map<String, Object?> parameters,
    PageRequest page,
    String? sort,
  });

  /// Exports run asynchronously (spec §13.4); poll with [exportJob].
  Future<Result<ExportJobDto>> requestExport(
    String reportCode, {
    String format,
    Map<String, Object?> parameters,
  });

  Future<Result<Page<ExportJobDto>>> exportJobs({
    String? status,
    PageRequest page,
  });

  Future<Result<ExportJobDto>> exportJob(int id);

  /// Only a queued or running job can be cancelled; the server answers 409 otherwise.
  Future<Result<void>> cancelExport(int id);
}
