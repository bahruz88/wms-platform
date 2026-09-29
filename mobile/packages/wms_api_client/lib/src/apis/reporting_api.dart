import 'package:dio/dio.dart';
import 'package:wms_core/wms_core.dart';

import '../dto/reporting/reporting_dtos.dart';
import 'module_api.dart';

/// `/api/v1/reporting/*`.
class ReportingApi extends ModuleApi {
  ReportingApi(Dio dio) : super(dio, '/reporting');

  /// `GET /reporting/dashboard/summary?locationId=`
  Future<DashboardSummaryDto> getDashboard({int? locationId}) => getObject(
    'dashboard/summary',
    fromJson: DashboardSummaryDto.fromJson,
    query: {'locationId': locationId},
  );

  /// `GET /reporting/reports`
  Future<List<ReportDefinitionDto>> listReports() =>
      getList('reports', fromJson: ReportDefinitionDto.fromJson);

  /// `GET /reporting/reports/{code}`
  Future<ReportDefinitionDto> getReport(String code) =>
      getObject('reports/$code', fromJson: ReportDefinitionDto.fromJson);

  /// `POST /reporting/reports/{code}/run` — synchronous, paged, max `size` 200.
  ///
  /// A POST that creates nothing: the contract still demands an `Idempotency-Key`, and repeating a
  /// key simply runs the report again.
  Future<ReportResultPageDto> runReport(
    String code, {
    Map<String, Object?> parameters = const {},
    PageRequest page = const PageRequest(),
    String? sort,
  }) => postObject(
    'reports/$code/run',
    body: {
      'parameters': parameters,
      'page': page.page,
      'size': page.size,
      'sort': ?sort,
    },
    fromJson: ReportResultPageDto.fromJson,
  );

  /// `GET /reporting/exports?status=` — the caller's own jobs from the last 30 days.
  Future<Page<ExportJobDto>> listExports({
    String? status,
    PageRequest page = const PageRequest(),
  }) => getPage(
    'exports',
    fromJson: ExportJobDto.fromJson,
    page: page,
    query: {'status': status},
  );

  /// `POST /reporting/exports` — async Excel export (spec §13.4).
  Future<ExportJobDto> requestExport(
    String reportCode, {
    String format = 'XLSX',
    Map<String, Object?> parameters = const {},
    String? fileName,
  }) => postObject(
    'exports',
    body: {
      'reportCode': reportCode,
      'format': format,
      'parameters': parameters,
      'fileName': ?fileName,
    },
    fromJson: ExportJobDto.fromJson,
  );

  /// `GET /reporting/exports/{id}`
  Future<ExportJobDto> getExport(int id) =>
      getObject('exports/$id', fromJson: ExportJobDto.fromJson);

  /// `DELETE /reporting/exports/{id}` — cancels a job that is still queued or running.
  Future<void> cancelExport(int id) => deleteVoid('exports/$id');
}
