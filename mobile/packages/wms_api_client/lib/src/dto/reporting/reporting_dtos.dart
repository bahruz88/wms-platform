import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wms_core/wms_core.dart';

part 'reporting_dtos.freezed.dart';
part 'reporting_dtos.g.dart';

/// One figure on the dashboard. `value` is a decimal string (ADR-008); `isCost` marks the ones the
/// server omits entirely without `master.product.view_cost`.
@freezed
abstract class KpiDto with _$KpiDto {
  const factory KpiDto({
    required String key,
    required String label,
    required String value,
    String? unit,
    String? trend,
    String? previousValue,
    @Default(false) bool isCost,
  }) = _KpiDto;

  const KpiDto._();

  factory KpiDto.fromJson(Map<String, Object?> json) => _$KpiDtoFromJson(json);

  /// The figure as a number, for arithmetic. Returns null when the server withheld it.
  Money? get amount => value.isEmpty ? null : Money.parse(value);

  /// How many decimals the server sent, so the screen neither rounds a price to whole manats nor
  /// prints a count as «42,0000». The precision is the server's decision, not the card's.
  int get decimals {
    final dot = value.indexOf('.');
    if (dot < 0) return 0;
    // Trailing zeros carry no information for a KPI; `12674.87920000` reads as 2 decimals.
    final fraction = value.substring(dot + 1).replaceFirst(RegExp(r'0+$'), '');
    return fraction.length > 4 ? 4 : fraction.length;
  }
}

/// A dashboard alert: what is wrong, how loudly, and how many of them.
@freezed
abstract class DashboardAlertDto with _$DashboardAlertDto {
  const factory DashboardAlertDto({
    required String type,
    required String severity,
    required String title,
    @Default(0) int count,
    String? link,
  }) = _DashboardAlertDto;

  const DashboardAlertDto._();

  factory DashboardAlertDto.fromJson(Map<String, Object?> json) =>
      _$DashboardAlertDtoFromJson(json);
}

/// One point of a dashboard series.
@freezed
abstract class SeriesPointDto with _$SeriesPointDto {
  const factory SeriesPointDto({
    required String label,
    required String value,
  }) = _SeriesPointDto;

  const SeriesPointDto._();

  factory SeriesPointDto.fromJson(Map<String, Object?> json) => _$SeriesPointDtoFromJson(json);
}

/// A named dashboard series (receipts per day, issues per day, …).
@freezed
abstract class DashboardSeriesDto with _$DashboardSeriesDto {
  const factory DashboardSeriesDto({
    required String key,
    required String label,
    @Default(false) bool isCost,
    @Default(<SeriesPointDto>[]) List<SeriesPointDto> points,
  }) = _DashboardSeriesDto;

  const DashboardSeriesDto._();

  factory DashboardSeriesDto.fromJson(Map<String, Object?> json) =>
      _$DashboardSeriesDtoFromJson(json);
}

/// `GET /reporting/dashboard/summary`.
///
/// The server answers with a **list of KPIs**, not a fixed set of counters: which figures a caller
/// gets depends on their permissions, and a cost KPI is left out entirely rather than nulled
/// (spec §16). The previous DTO declared `asOf` plus eight named integers and so could not parse the
/// response at all — its unit test agreed with the DTO, not with the server.
@freezed
abstract class DashboardSummaryDto with _$DashboardSummaryDto {
  const factory DashboardSummaryDto({
    required DateTime generatedAt,
    @Default(<KpiDto>[]) List<KpiDto> kpis,
    @Default(<DashboardAlertDto>[]) List<DashboardAlertDto> alerts,
    @Default(<DashboardSeriesDto>[]) List<DashboardSeriesDto> series,
    Map<String, Object?>? systemHealth,
  }) = _DashboardSummaryDto;

  const DashboardSummaryDto._();

  factory DashboardSummaryDto.fromJson(Map<String, Object?> json) =>
      _$DashboardSummaryDtoFromJson(json);

  /// A KPI by key, or null when this caller was not given it.
  KpiDto? kpi(String key) => kpis.where((k) => k.key == key).firstOrNull;

  /// True when at least one cost figure came through — i.e. the caller holds the cost permission.
  bool get hasCostFigures => kpis.any((k) => k.isCost);
}

/// `GET /reporting/reports`.
@freezed
abstract class ReportDefinitionDto with _$ReportDefinitionDto {
  const factory ReportDefinitionDto({
    required String code,
    required String name,
    required String category,
    String? description,
    @Default(<Object?>[]) List<Object?> parameters,
    @Default(<Object?>[]) List<Object?> columns,
    @Default(<String>[]) List<String> supportedFormats,
    @Default(false) bool requiresCostPermission,
    int? maxSyncRows,
  }) = _ReportDefinitionDto;

  const ReportDefinitionDto._();

  factory ReportDefinitionDto.fromJson(Map<String, Object?> json) =>
      _$ReportDefinitionDtoFromJson(json);
}

/// `rpt_export_job`. `requestedAt` is when it was asked for — the server sends no `createdAt`.
@freezed
abstract class ExportJobDto with _$ExportJobDto {
  const factory ExportJobDto({
    required int id,
    required String reportCode,
    required String status,
    required String format,
    required DateTime requestedAt,
    @Default(0) int progressPct,
    int? rowCount,
    String? fileName,
    int? sizeBytes,
    String? downloadUrl,
    DateTime? downloadUrlExpiresAt,
    DateTime? completedAt,
    DateTime? expiresAt,
    String? statusUrl,
  }) = _ExportJobDto;

  const ExportJobDto._();

  factory ExportJobDto.fromJson(Map<String, Object?> json) => _$ExportJobDtoFromJson(json);

  bool get isDownloadable => status == 'COMPLETED' && downloadUrl != null;
}
