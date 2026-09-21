import 'package:dio/dio.dart';

import '../dto/reporting/reporting_dtos.dart';
import 'module_api.dart';

/// `/api/v1/reporting/*`.
class ReportingApi extends ModuleApi {
  ReportingApi(Dio dio) : super(dio, '/reporting');

  /// `GET /reporting/dashboard?locationId=`
  Future<DashboardSummaryDto> getDashboard({int? locationId}) => getObject(
    'dashboard',
    fromJson: DashboardSummaryDto.fromJson,
    query: {'locationId': locationId},
  );

  /// `GET /reporting/reports`
  Future<List<ReportDefinitionDto>> listReports() =>
      getList('reports', fromJson: ReportDefinitionDto.fromJson);

  /// `POST /reporting/exports` - async Excel export (spec §13.4).
  Future<ExportJobDto> requestExport(
    String reportCode, {
    Map<String, Object?> parameters = const {},
  }) => postObject(
    'exports',
    body: {'reportCode': reportCode, 'parameters': parameters},
    fromJson: ExportJobDto.fromJson,
  );

  /// `GET /reporting/exports/{id}`
  Future<ExportJobDto> getExport(String id) =>
      getObject('exports/$id', fromJson: ExportJobDto.fromJson);
}
