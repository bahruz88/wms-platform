import 'package:freezed_annotation/freezed_annotation.dart';

part 'identity_dtos.freezed.dart';
part 'identity_dtos.g.dart';

/// `GET /identity/me` - the caller's profile, roles, effective permissions
/// and location restrictions (`iam_user_location`).
@freezed
abstract class CurrentUserDto with _$CurrentUserDto {
  const factory CurrentUserDto({
    required int id,
    required int tenantId,
    required String username,
    required String fullName,
    String? externalId,
    String? email,
    String? phone,
    @Default(<String>[]) List<String> roles,
    @Default(<String>[]) List<String> permissions,
    @Default(<int>[]) List<int> locationIds,
  }) = _CurrentUserDto;

  const CurrentUserDto._();

  factory CurrentUserDto.fromJson(Map<String, Object?> json) =>
      _$CurrentUserDtoFromJson(json);

  bool hasPermission(String code) => permissions.contains(code);
}

/// `AuditFields` from common.v1.yaml (SPEC §6.2).
@freezed
abstract class AuditFieldsDto with _$AuditFieldsDto {
  const factory AuditFieldsDto({
    DateTime? createdAt,
    int? createdBy,
    DateTime? updatedAt,
    int? updatedBy,
    @Default(1) int rowVersion,
  }) = _AuditFieldsDto;

  factory AuditFieldsDto.fromJson(Map<String, Object?> json) =>
      _$AuditFieldsDtoFromJson(json);
}

/// `RoleSummary` - the shape roles take inside a [UserDto].
@freezed
abstract class RoleSummaryDto with _$RoleSummaryDto {
  const factory RoleSummaryDto({
    required int id,
    required String code,
    required String name,
    @Default(false) bool isSystem,
  }) = _RoleSummaryDto;

  factory RoleSummaryDto.fromJson(Map<String, Object?> json) =>
      _$RoleSummaryDtoFromJson(json);
}

/// `iam_user`. `locationIds` empty means "every location" (SPEC §16).
@freezed
abstract class UserDto with _$UserDto {
  const factory UserDto({
    required int id,
    required String username,
    required String fullName,

    /// Keycloak subject (`sub`); the link between the realm and the tenant.
    String? externalId,
    String? email,
    String? phone,
    @Default(true) bool isActive,
    @Default(<RoleSummaryDto>[]) List<RoleSummaryDto> roles,
    @Default(<int>[]) List<int> locationIds,
    AuditFieldsDto? audit,
  }) = _UserDto;

  const UserDto._();

  factory UserDto.fromJson(Map<String, Object?> json) =>
      _$UserDtoFromJson(json);

  int get rowVersion => audit?.rowVersion ?? 1;

  /// `ADMIN · WAREHOUSE_KEEPER` for a table cell.
  String get roleCodes => roles.map((r) => r.code).join(' · ');

  /// Empty `locationIds` means the user is not restricted.
  bool get hasAllLocations => locationIds.isEmpty;
}

/// `iam_role` with its permission codes (`Role` = `RoleSummary` + perms).
@freezed
abstract class RoleDto with _$RoleDto {
  const factory RoleDto({
    required int id,
    required String code,
    required String name,
    @Default(false) bool isSystem,
    @Default(<String>[]) List<String> permissions,
  }) = _RoleDto;

  factory RoleDto.fromJson(Map<String, Object?> json) =>
      _$RoleDtoFromJson(json);
}

/// `iam_permission` catalogue entry (`GET /identity/permissions`).
@freezed
abstract class PermissionDto with _$PermissionDto {
  const factory PermissionDto({
    required int id,
    required String code,
    required String module,
    String? description,
  }) = _PermissionDto;

  factory PermissionDto.fromJson(Map<String, Object?> json) =>
      _$PermissionDtoFromJson(json);
}
