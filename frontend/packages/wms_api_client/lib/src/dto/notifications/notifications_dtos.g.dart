// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationDto _$NotificationDtoFromJson(Map<String, dynamic> json) =>
    _NotificationDto(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      body: json['body'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      docType: json['docType'] as String?,
      docId: (json['docId'] as num?)?.toInt(),
      deepLink: json['deepLink'] as String?,
    );

Map<String, dynamic> _$NotificationDtoToJson(_NotificationDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'title': instance.title,
      'createdAt': instance.createdAt.toIso8601String(),
      'body': instance.body,
      'isRead': instance.isRead,
      'docType': instance.docType,
      'docId': instance.docId,
      'deepLink': instance.deepLink,
    };

_UnreadCountDto _$UnreadCountDtoFromJson(Map<String, dynamic> json) =>
    _UnreadCountDto(count: (json['count'] as num?)?.toInt() ?? 0);

Map<String, dynamic> _$UnreadCountDtoToJson(_UnreadCountDto instance) =>
    <String, dynamic>{'count': instance.count};
