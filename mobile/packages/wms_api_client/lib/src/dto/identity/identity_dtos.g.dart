// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CurrentUserDto _$CurrentUserDtoFromJson(Map<String, dynamic> json) =>
    _CurrentUserDto(
      id: (json['id'] as num).toInt(),
      tenantId: (json['tenantId'] as num).toInt(),
      username: json['username'] as String,
      fullName: json['fullName'] as String,
      externalId: json['externalId'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      roles:
          (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      permissions:
          (json['permissions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      locationIds:
          (json['locationIds'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const <int>[],
    );

Map<String, dynamic> _$CurrentUserDtoToJson(_CurrentUserDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'username': instance.username,
      'fullName': instance.fullName,
      'externalId': instance.externalId,
      'email': instance.email,
      'phone': instance.phone,
      'roles': instance.roles,
      'permissions': instance.permissions,
      'locationIds': instance.locationIds,
    };

_AuditFieldsDto _$AuditFieldsDtoFromJson(Map<String, dynamic> json) =>
    _AuditFieldsDto(
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      createdBy: (json['createdBy'] as num?)?.toInt(),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      updatedBy: (json['updatedBy'] as num?)?.toInt(),
      rowVersion: (json['rowVersion'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$AuditFieldsDtoToJson(_AuditFieldsDto instance) =>
    <String, dynamic>{
      'createdAt': instance.createdAt?.toIso8601String(),
      'createdBy': instance.createdBy,
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'updatedBy': instance.updatedBy,
      'rowVersion': instance.rowVersion,
    };

_RoleSummaryDto _$RoleSummaryDtoFromJson(Map<String, dynamic> json) =>
    _RoleSummaryDto(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String,
      name: json['name'] as String,
      isSystem: json['isSystem'] as bool? ?? false,
    );

Map<String, dynamic> _$RoleSummaryDtoToJson(_RoleSummaryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'isSystem': instance.isSystem,
    };

_UserDto _$UserDtoFromJson(Map<String, dynamic> json) => _UserDto(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
  fullName: json['fullName'] as String,
  externalId: json['externalId'] as String?,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  roles:
      (json['roles'] as List<dynamic>?)
          ?.map((e) => RoleSummaryDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <RoleSummaryDto>[],
  locationIds:
      (json['locationIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const <int>[],
  audit: json['audit'] == null
      ? null
      : AuditFieldsDto.fromJson(json['audit'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserDtoToJson(_UserDto instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'fullName': instance.fullName,
  'externalId': instance.externalId,
  'email': instance.email,
  'phone': instance.phone,
  'isActive': instance.isActive,
  'roles': instance.roles.map((e) => e.toJson()).toList(),
  'locationIds': instance.locationIds,
  'audit': instance.audit?.toJson(),
};

_RoleDto _$RoleDtoFromJson(Map<String, dynamic> json) => _RoleDto(
  id: (json['id'] as num).toInt(),
  code: json['code'] as String,
  name: json['name'] as String,
  isSystem: json['isSystem'] as bool? ?? false,
  permissions:
      (json['permissions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
);

Map<String, dynamic> _$RoleDtoToJson(_RoleDto instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'name': instance.name,
  'isSystem': instance.isSystem,
  'permissions': instance.permissions,
};

_PermissionDto _$PermissionDtoFromJson(Map<String, dynamic> json) =>
    _PermissionDto(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String,
      module: json['module'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$PermissionDtoToJson(_PermissionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'module': instance.module,
      'description': instance.description,
    };
