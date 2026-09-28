// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reporting_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_KpiDto _$KpiDtoFromJson(Map<String, dynamic> json) => _KpiDto(
  key: json['key'] as String,
  label: json['label'] as String,
  value: json['value'] as String,
  unit: json['unit'] as String?,
  trend: json['trend'] as String?,
  previousValue: json['previousValue'] as String?,
  isCost: json['isCost'] as bool? ?? false,
);

Map<String, dynamic> _$KpiDtoToJson(_KpiDto instance) => <String, dynamic>{
  'key': instance.key,
  'label': instance.label,
  'value': instance.value,
  'unit': instance.unit,
  'trend': instance.trend,
  'previousValue': instance.previousValue,
  'isCost': instance.isCost,
};

_DashboardAlertDto _$DashboardAlertDtoFromJson(Map<String, dynamic> json) =>
    _DashboardAlertDto(
      type: json['type'] as String,
      severity: json['severity'] as String,
      title: json['title'] as String,
      count: (json['count'] as num?)?.toInt() ?? 0,
      link: json['link'] as String?,
    );

Map<String, dynamic> _$DashboardAlertDtoToJson(_DashboardAlertDto instance) =>
    <String, dynamic>{
      'type': instance.type,
      'severity': instance.severity,
      'title': instance.title,
      'count': instance.count,
      'link': instance.link,
    };

_SeriesPointDto _$SeriesPointDtoFromJson(Map<String, dynamic> json) =>
    _SeriesPointDto(
      label: json['label'] as String,
      value: json['value'] as String,
    );

Map<String, dynamic> _$SeriesPointDtoToJson(_SeriesPointDto instance) =>
    <String, dynamic>{'label': instance.label, 'value': instance.value};

_DashboardSeriesDto _$DashboardSeriesDtoFromJson(Map<String, dynamic> json) =>
    _DashboardSeriesDto(
      key: json['key'] as String,
      label: json['label'] as String,
      isCost: json['isCost'] as bool? ?? false,
      points:
          (json['points'] as List<dynamic>?)
              ?.map((e) => SeriesPointDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <SeriesPointDto>[],
    );

Map<String, dynamic> _$DashboardSeriesDtoToJson(_DashboardSeriesDto instance) =>
    <String, dynamic>{
      'key': instance.key,
      'label': instance.label,
      'isCost': instance.isCost,
      'points': instance.points.map((e) => e.toJson()).toList(),
    };

_DashboardSummaryDto _$DashboardSummaryDtoFromJson(
  Map<String, dynamic> json,
) => _DashboardSummaryDto(
  generatedAt: DateTime.parse(json['generatedAt'] as String),
  kpis:
      (json['kpis'] as List<dynamic>?)
          ?.map((e) => KpiDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <KpiDto>[],
  alerts:
      (json['alerts'] as List<dynamic>?)
          ?.map((e) => DashboardAlertDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <DashboardAlertDto>[],
  series:
      (json['series'] as List<dynamic>?)
          ?.map((e) => DashboardSeriesDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <DashboardSeriesDto>[],
  systemHealth: json['systemHealth'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$DashboardSummaryDtoToJson(
  _DashboardSummaryDto instance,
) => <String, dynamic>{
  'generatedAt': instance.generatedAt.toIso8601String(),
  'kpis': instance.kpis.map((e) => e.toJson()).toList(),
  'alerts': instance.alerts.map((e) => e.toJson()).toList(),
  'series': instance.series.map((e) => e.toJson()).toList(),
  'systemHealth': instance.systemHealth,
};

_ReportDefinitionDto _$ReportDefinitionDtoFromJson(Map<String, dynamic> json) =>
    _ReportDefinitionDto(
      code: json['code'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      parameters: json['parameters'] as List<dynamic>? ?? const <Object?>[],
      columns: json['columns'] as List<dynamic>? ?? const <Object?>[],
      supportedFormats:
          (json['supportedFormats'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      requiresCostPermission: json['requiresCostPermission'] as bool? ?? false,
      maxSyncRows: (json['maxSyncRows'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ReportDefinitionDtoToJson(
  _ReportDefinitionDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'name': instance.name,
  'category': instance.category,
  'description': instance.description,
  'parameters': instance.parameters,
  'columns': instance.columns,
  'supportedFormats': instance.supportedFormats,
  'requiresCostPermission': instance.requiresCostPermission,
  'maxSyncRows': instance.maxSyncRows,
};

_ExportJobDto _$ExportJobDtoFromJson(Map<String, dynamic> json) =>
    _ExportJobDto(
      id: (json['id'] as num).toInt(),
      reportCode: json['reportCode'] as String,
      status: json['status'] as String,
      format: json['format'] as String,
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      progressPct: (json['progressPct'] as num?)?.toInt() ?? 0,
      rowCount: (json['rowCount'] as num?)?.toInt(),
      fileName: json['fileName'] as String?,
      sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
      downloadUrl: json['downloadUrl'] as String?,
      downloadUrlExpiresAt: json['downloadUrlExpiresAt'] == null
          ? null
          : DateTime.parse(json['downloadUrlExpiresAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      statusUrl: json['statusUrl'] as String?,
    );

Map<String, dynamic> _$ExportJobDtoToJson(_ExportJobDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reportCode': instance.reportCode,
      'status': instance.status,
      'format': instance.format,
      'requestedAt': instance.requestedAt.toIso8601String(),
      'progressPct': instance.progressPct,
      'rowCount': instance.rowCount,
      'fileName': instance.fileName,
      'sizeBytes': instance.sizeBytes,
      'downloadUrl': instance.downloadUrl,
      'downloadUrlExpiresAt': instance.downloadUrlExpiresAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'statusUrl': instance.statusUrl,
    };
