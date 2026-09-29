import 'package:freezed_annotation/freezed_annotation.dart';

part 'identity_dtos.freezed.dart';
part 'identity_dtos.g.dart';

/// `UserSummary` — who the caller is, as `Me` embeds it.
@freezed
abstract class UserSummaryDto with _$UserSummaryDto {
  const factory UserSummaryDto({
    required int id,
    required String username,
    required String fullName,
    String? email,
    @Default(true) bool isActive,
  }) = _UserSummaryDto;

  const UserSummaryDto._();

  factory UserSummaryDto.fromJson(Map<String, Object?> json) => _$UserSummaryDtoFromJson(json);
}

/// `Tenant` — the company the caller belongs to, and the currency every base amount is in.
@freezed
abstract class TenantDto with _$TenantDto {
  const factory TenantDto({
    required int id,
    required String code,
    required String name,
    @Default('AZN') String defaultCurrency,
    String? timezone,
    String? locale,
    @Default(true) bool isActive,
  }) = _TenantDto;

  const TenantDto._();

  factory TenantDto.fromJson(Map<String, Object?> json) => _$TenantDtoFromJson(json);
}

/// `GET /identity/me` — the contract's `Me`.
///
/// The user and the tenant arrive as nested objects, not flattened onto the response. The previous
/// DTO expected `id`/`tenantId`/`username` at the top level and so threw on every sign-in; no test
/// noticed, because the drift check matches DTOs to schemas by name and `CurrentUserDto` does not
/// look like `Me`.
///
/// `canViewCost` is sent explicitly rather than left for the client to infer from `permissions`:
/// the server is the side that decides, and every cost figure it omits follows from this one flag
/// (spec §16).
@freezed
abstract class CurrentUserDto with _$CurrentUserDto {
  const factory CurrentUserDto({
    required UserSummaryDto user,
    required TenantDto tenant,
    @Default(<String>[]) List<String> roles,
    @Default(<String>[]) List<String> permissions,
    @Default(<int>[]) List<int> locationIds,
    @Default(false) bool canViewCost,
    @Default(<Object?>[]) List<Object?> activeDelegations,
  }) = _CurrentUserDto;

  const CurrentUserDto._();

  factory CurrentUserDto.fromJson(Map<String, Object?> json) =>
      _$CurrentUserDtoFromJson(json);

  /// Shorthands, so a screen does not have to know the response is nested.
  int get id => user.id;
  int get tenantId => tenant.id;
  String get username => user.username;
  String get fullName => user.fullName;
  String? get email => user.email;

  /// An empty location list means every location — the one place where less grants more (spec §16).
  bool get seesEveryLocation => locationIds.isEmpty;

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
    // Marks a permission that can move stock or money; the role editor warns before granting it.
    @Default(false) bool isCritical,
  }) = _PermissionDto;

  factory PermissionDto.fromJson(Map<String, Object?> json) =>
      _$PermissionDtoFromJson(json);
}
