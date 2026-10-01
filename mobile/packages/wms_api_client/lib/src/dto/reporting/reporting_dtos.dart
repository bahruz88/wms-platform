import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wms_core/wms_core.dart';

import '../../json/date_only_converter.dart';

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
    // The server compares with the previous period itself and sends the percentage, not a `trend`
    // word and a `previousValue` — the two fields this DTO used to declare were never sent, so no
    // card ever showed a trend.
    Decimal? trendPct,
    @Default('NORMAL') String severity,
    /// In-app path to drill through to, e.g. `/inventory/batches?expiryBefore=…`.
    String? link,
    @Default(false) bool isCost,
  }) = _KpiDto;

  const KpiDto._();

  factory KpiDto.fromJson(Map<String, Object?> json) => _$KpiDtoFromJson(json);

  /// The figure as a number, for arithmetic. Returns null when the server withheld it.
  Money? get amount => value.isEmpty ? null : Money.parse(value);

  bool get isCritical => severity == 'CRITICAL';
  bool get isWarning => severity == 'WARNING';

  /// `true` when the figure moved up against the previous period, `false` when it moved down, and
  /// null when there is nothing to compare against.
  bool? get isUp => trendPct == null
      ? null
      : trendPct! > Decimal.zero
          ? true
          : trendPct! < Decimal.zero
              ? false
              : null;

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

/// One point of a dashboard series: a day and the figure for that day.
///
/// The x axis is a date, not a free-text label — the server sends `date`, and the chart formats it
/// itself so the axis follows the app locale rather than the server's.
@freezed
abstract class SeriesPointDto with _$SeriesPointDto {
  const factory SeriesPointDto({
    @DateOnlyConverter() required DateTime date,
    required Decimal value,
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
    String? unit,
    @Default(<SeriesPointDto>[]) List<SeriesPointDto> points,
  }) = _DashboardSeriesDto;

  const DashboardSeriesDto._();

  factory DashboardSeriesDto.fromJson(Map<String, Object?> json) =>
      _$DashboardSeriesDtoFromJson(json);
}

/// Current stock value of one product category — the product's own (leaf) category; the screen
/// builds the tree itself. `categoryId` is null for products the catalogue did not return, so their
/// value is shown as uncategorised instead of being lost. `value` is a decimal string (ADR-008).
@freezed
abstract class DashboardCategoryValueDto with _$DashboardCategoryValueDto {
  const factory DashboardCategoryValueDto({
    int? categoryId,
    required String value,
  }) = _DashboardCategoryValueDto;

  const DashboardCategoryValueDto._();

  factory DashboardCategoryValueDto.fromJson(Map<String, Object?> json) =>
      _$DashboardCategoryValueDtoFromJson(json);

  /// The value as a number, for arithmetic.
  Money get amount => Money.parse(value);
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
    // Stock value per product category. Null — not empty — when the caller lacks
    // `master.product.view_cost`: the server leaves the field out rather than sending zeros.
    List<DashboardCategoryValueDto>? categoryValues,
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
    @Default(<ReportColumnDto>[]) List<ReportColumnDto> columns,
    @Default(<String>[]) List<String> supportedFormats,
    @Default(false) bool requiresCostPermission,
    /// The report's number in TOR §29, for tracing a figure back to what was asked for.
    String? torRef,
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
    // Why a FAILED job failed. Without it a failed export showed no reason at all.
    String? errorMessage,
    DateTime? completedAt,
    DateTime? expiresAt,
    String? statusUrl,
  }) = _ExportJobDto;

  const ExportJobDto._();

  factory ExportJobDto.fromJson(Map<String, Object?> json) => _$ExportJobDtoFromJson(json);

  bool get isDownloadable => status == 'COMPLETED' && downloadUrl != null;
}

/// `ReportColumn` — one column of a report, as the server chose to return it.
///
/// A cost column is absent from `columns` entirely when the caller lacks `master.product.view_cost`,
/// so the screen renders whatever arrives rather than filtering a fixed list itself.
@freezed
abstract class ReportColumnDto with _$ReportColumnDto {
  const factory ReportColumnDto({
    required String key,
    required String label,
    required String type,
    @Default(false) bool isCost,
    @Default('LEFT') String align,
    int? width,
  }) = _ReportColumnDto;

  const ReportColumnDto._();

  factory ReportColumnDto.fromJson(Map<String, Object?> json) => _$ReportColumnDtoFromJson(json);

  /// Numeric column types arrive as strings (ADR-008) and are right-aligned by convention.
  bool get isNumeric => type == 'DECIMAL' || type == 'MONEY' || type == 'PERCENT' || type == 'INT';
}

/// `ReportResultPage` — the answer to `runReport`.
///
/// Rows are positional arrays, not objects: one value per entry in [columns], in that order. The
/// contract does it that way to keep the payload small, so reading a cell means indexing [columns].
@freezed
abstract class ReportResultPageDto with _$ReportResultPageDto {
  const factory ReportResultPageDto({
    required String code,
    required DateTime generatedAt,
    @Default(<ReportColumnDto>[]) List<ReportColumnDto> columns,
    // Nullable rather than defaulted: freezed cannot build a default for a nested generic, so the
    // empty case is handled by the `rows` getter below.
    @JsonKey(name: 'rows') List<List<Object?>>? rawRows,
    Map<String, String>? totals,
    DateTime? dataAsOf,
    // `PageMeta` of common.v1.yaml: three fields, and `total` is the row count, not a page count.
    @Default(0) int page,
    @Default(0) int size,
    @Default(0) int total,
  }) = _ReportResultPageDto;

  const ReportResultPageDto._();

  factory ReportResultPageDto.fromJson(Map<String, Object?> json) =>
      _$ReportResultPageDtoFromJson(json);

  /// The result rows, positional per [columns].
  List<List<Object?>> get rows => rawRows ?? const <List<Object?>>[];

  /// The value at [rowIndex] under the column named [key], or null when the column was not returned.
  Object? cell(int rowIndex, String key) {
    final column = columns.indexWhere((c) => c.key == key);
    if (column < 0 || rowIndex >= rows.length) return null;
    final row = rows[rowIndex];
    return column < row.length ? row[column] : null;
  }

  /// The read model behind a report lags the ledger by up to a minute, so a screen that shows
  /// figures says when they were true.
  DateTime get asOf => dataAsOf ?? generatedAt;
}
