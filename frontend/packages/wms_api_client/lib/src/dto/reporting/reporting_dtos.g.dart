// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reporting_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DashboardSummaryDto _$DashboardSummaryDtoFromJson(Map<String, dynamic> json) =>
    _DashboardSummaryDto(
      asOf: DateTime.parse(json['asOf'] as String),
      stockValue: json['stockValue'] == null
          ? null
          : Money.fromJson(json['stockValue'] as String),
      expiringBatches: (json['expiringBatches'] as num?)?.toInt() ?? 0,
      expiredBatches: (json['expiredBatches'] as num?)?.toInt() ?? 0,
      lowStockProducts: (json['lowStockProducts'] as num?)?.toInt() ?? 0,
      pendingApprovals: (json['pendingApprovals'] as num?)?.toInt() ?? 0,
      openPurchaseOrders: (json['openPurchaseOrders'] as num?)?.toInt() ?? 0,
      inTransitIssues: (json['inTransitIssues'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$DashboardSummaryDtoToJson(
  _DashboardSummaryDto instance,
) => <String, dynamic>{
  'asOf': instance.asOf.toIso8601String(),
  'stockValue': instance.stockValue?.toJson(),
  'expiringBatches': instance.expiringBatches,
  'expiredBatches': instance.expiredBatches,
  'lowStockProducts': instance.lowStockProducts,
  'pendingApprovals': instance.pendingApprovals,
  'openPurchaseOrders': instance.openPurchaseOrders,
  'inTransitIssues': instance.inTransitIssues,
};

_ReportDefinitionDto _$ReportDefinitionDtoFromJson(Map<String, dynamic> json) =>
    _ReportDefinitionDto(
      code: json['code'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      parameters:
          (json['parameters'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      supportsExport: json['supportsExport'] as bool? ?? true,
    );

Map<String, dynamic> _$ReportDefinitionDtoToJson(
  _ReportDefinitionDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'name': instance.name,
  'category': instance.category,
  'description': instance.description,
  'parameters': instance.parameters,
  'supportsExport': instance.supportsExport,
};

_ExportJobDto _$ExportJobDtoFromJson(Map<String, dynamic> json) =>
    _ExportJobDto(
      id: json['id'] as String,
      reportCode: json['reportCode'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      downloadUrl: json['downloadUrl'] as String?,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      error: json['error'] as String?,
    );

Map<String, dynamic> _$ExportJobDtoToJson(_ExportJobDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reportCode': instance.reportCode,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
      'downloadUrl': instance.downloadUrl,
      'completedAt': instance.completedAt?.toIso8601String(),
      'error': instance.error,
    };
