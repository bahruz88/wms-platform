// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationDto _$NotificationDtoFromJson(Map<String, dynamic> json) =>
    _NotificationDto(
      id: (json['id'] as num).toInt(),
      eventType: json['eventType'] as String,
      severity: json['severity'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      body: json['body'] as String?,
      link: json['link'] as String?,
      entityType: json['entityType'] as String?,
      entityId: (json['entityId'] as num?)?.toInt(),
      locationId: (json['locationId'] as num?)?.toInt(),
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
      eventId: json['eventId'] as String?,
    );

Map<String, dynamic> _$NotificationDtoToJson(_NotificationDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventType': instance.eventType,
      'severity': instance.severity,
      'title': instance.title,
      'createdAt': instance.createdAt.toIso8601String(),
      'isRead': instance.isRead,
      'body': instance.body,
      'link': instance.link,
      'entityType': instance.entityType,
      'entityId': instance.entityId,
      'locationId': instance.locationId,
      'readAt': instance.readAt?.toIso8601String(),
      'eventId': instance.eventId,
    };

_UnreadCountDto _$UnreadCountDtoFromJson(Map<String, dynamic> json) =>
    _UnreadCountDto(
      total: (json['total'] as num?)?.toInt() ?? 0,
      bySeverity:
          (json['bySeverity'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const <String, int>{},
      pendingApprovals: (json['pendingApprovals'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$UnreadCountDtoToJson(_UnreadCountDto instance) =>
    <String, dynamic>{
      'total': instance.total,
      'bySeverity': instance.bySeverity,
      'pendingApprovals': instance.pendingApprovals,
    };
