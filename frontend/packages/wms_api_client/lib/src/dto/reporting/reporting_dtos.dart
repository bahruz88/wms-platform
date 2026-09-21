import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wms_core/wms_core.dart';

part 'reporting_dtos.freezed.dart';
part 'reporting_dtos.g.dart';

/// `GET /reporting/dashboard`. [stockValue] is absent without
/// `master.product.view_cost`.
@freezed
abstract class DashboardSummaryDto with _$DashboardSummaryDto {
  const factory DashboardSummaryDto({
    required DateTime asOf,
    Money? stockValue,
    @Default(0) int expiringBatches,
    @Default(0) int expiredBatches,
    @Default(0) int lowStockProducts,
    @Default(0) int pendingApprovals,
    @Default(0) int openPurchaseOrders,
    @Default(0) int inTransitIssues,
  }) = _DashboardSummaryDto;

  factory DashboardSummaryDto.fromJson(Map<String, Object?> json) =>
      _$DashboardSummaryDtoFromJson(json);
}

/// One of the TOR §29 reports available to the caller.
@freezed
abstract class ReportDefinitionDto with _$ReportDefinitionDto {
  const factory ReportDefinitionDto({
    required String code,
    required String name,
    required String category,
    String? description,
    @Default(<String>[]) List<String> parameters,
    @Default(true) bool supportsExport,
  }) = _ReportDefinitionDto;

  factory ReportDefinitionDto.fromJson(Map<String, Object?> json) =>
      _$ReportDefinitionDtoFromJson(json);
}

/// Async export job (`POST /reporting/exports`).
@freezed
abstract class ExportJobDto with _$ExportJobDto {
  const factory ExportJobDto({
    required String id,
    required String reportCode,
    required String status,
    required DateTime createdAt,
    String? downloadUrl,
    DateTime? completedAt,
    String? error,
  }) = _ExportJobDto;

  const ExportJobDto._();

  factory ExportJobDto.fromJson(Map<String, Object?> json) =>
      _$ExportJobDtoFromJson(json);

  bool get isDone => status == 'COMPLETED';
  bool get isFailed => status == 'FAILED';
}
