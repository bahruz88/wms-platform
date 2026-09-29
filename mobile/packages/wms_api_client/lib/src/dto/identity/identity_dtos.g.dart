// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserSummaryDto _$UserSummaryDtoFromJson(Map<String, dynamic> json) =>
    _UserSummaryDto(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$UserSummaryDtoToJson(_UserSummaryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'fullName': instance.fullName,
      'email': instance.email,
      'isActive': instance.isActive,
    };

_TenantDto _$TenantDtoFromJson(Map<String, dynamic> json) => _TenantDto(
  id: (json['id'] as num).toInt(),
  code: json['code'] as String,
  name: json['name'] as String,
  defaultCurrency: json['defaultCurrency'] as String? ?? 'AZN',
  timezone: json['timezone'] as String?,
  locale: json['locale'] as String?,
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$TenantDtoToJson(_TenantDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'defaultCurrency': instance.defaultCurrency,
      'timezone': instance.timezone,
      'locale': instance.locale,
      'isActive': instance.isActive,
    };

_CurrentUserDto _$CurrentUserDtoFromJson(Map<String, dynamic> json) =>
    _CurrentUserDto(
      user: UserSummaryDto.fromJson(json['user'] as Map<String, dynamic>),
      tenant: TenantDto.fromJson(json['tenant'] as Map<String, dynamic>),
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
      canViewCost: json['canViewCost'] as bool? ?? false,
      activeDelegations:
          json['activeDelegations'] as List<dynamic>? ?? const <Object?>[],
    );

Map<String, dynamic> _$CurrentUserDtoToJson(_CurrentUserDto instance) =>
    <String, dynamic>{
      'user': instance.user.toJson(),
      'tenant': instance.tenant.toJson(),
      'roles': instance.roles,
      'permissions': instance.permissions,
      'locationIds': instance.locationIds,
      'canViewCost': instance.canViewCost,
      'activeDelegations': instance.activeDelegations,
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
