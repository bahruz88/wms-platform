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
  Future<Result<ReportDefinitionDto>> report(String code) =>
      Result.guard(() => _api.getReport(code));

  @override
  Future<Result<ReportResultPageDto>> runReport(
    String code, {
    Map<String, Object?> parameters = const {},
    PageRequest page = const PageRequest(),
    String? sort,
  }) => Result.guard(
    () => _api.runReport(code, parameters: parameters, page: page, sort: sort),
  );

  @override
  Future<Result<ExportJobDto>> requestExport(
    String reportCode, {
    String format = 'XLSX',
    Map<String, Object?> parameters = const {},
  }) => Result.guard(
    () => _api.requestExport(
      reportCode,
      format: format,
      parameters: parameters,
    ),
  );

  @override
  Future<Result<Page<ExportJobDto>>> exportJobs({
    String? status,
    PageRequest page = const PageRequest(),
  }) => Result.guard(() => _api.listExports(status: status, page: page));

  @override
  Future<Result<ExportJobDto>> exportJob(int id) =>
      Result.guard(() => _api.getExport(id));

  @override
  Future<Result<void>> cancelExport(int id) =>
      Result.guard(() => _api.cancelExport(id));
}
