import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

import '../domain/reporting_repository.dart';

class ReportingRepositoryImpl implements ReportingRepository {
  ReportingRepositoryImpl(this._api);

  final ReportingApi _api;

  @override
  Future<Result<DashboardSummaryDto>> dashboard({int? locationId}) =>
      Result.guard(() => _api.getDashboard(locationId: locationId));

  @override
  Future<Result<List<ReportDefinitionDto>>> reports() =>
      Result.guard(_api.listReports);

  @override
  Future<Result<ExportJobDto>> requestExport(
    String reportCode, {
    Map<String, Object?> parameters = const {},
  }) => Result.guard(
    () => _api.requestExport(reportCode, parameters: parameters),
  );

  @override
  Future<Result<ExportJobDto>> exportJob(String id) =>
      Result.guard(() => _api.getExport(id));
}
