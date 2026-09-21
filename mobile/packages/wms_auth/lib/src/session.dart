import 'package:meta/meta.dart';
import 'package:wms_core/wms_core.dart';

import 'jwt_parser.dart';

/// Authenticated session. Immutable; the repository publishes a new instance
/// on refresh or when permissions are loaded from `/identity/me`.
@immutable
class Session {
  const Session({
    required this.accessToken,
    required this.userId,
    required this.username,
    required this.tenantId,
    this.refreshToken,
    this.idToken,
    this.expiresAt,
    this.roles = const [],
    this.permissions = const {},
    this.fullName,
    this.email,
    this.locationIds = const [],
  });

  /// Builds a session from raw OIDC tokens by parsing the access token.
  /// Throws [FormatException] when the token is not a JWT or lacks the
  /// mandatory `tenant_id` claim (CONVENTIONS.md).
  factory Session.fromTokens({
    required String accessToken,
    String? refreshToken,
    String? idToken,
    DateTime? expiresAt,
  }) {
    final claims = JwtParser.decode(accessToken);
    final tenant = TenantContext.fromClaims(claims);
    if (tenant == null) {
      throw const FormatException('Access token has no tenant_id claim');
    }
    return Session(
      accessToken: accessToken,
      refreshToken: refreshToken,
      idToken: idToken,
      expiresAt: expiresAt ?? JwtParser.expiresAt(claims),
      userId: claims['sub']?.toString() ?? '',
      username: claims['preferred_username']?.toString() ?? '',
      fullName: claims['name']?.toString(),
      email: claims['email']?.toString(),
      tenantId: tenant.tenantId,
      roles: JwtParser.realmRoles(claims),
      permissions: JwtParser.permissions(claims).toSet(),
    );
  }

  factory Session.fromJson(Map<String, Object?> json) => Session(
    accessToken: json['accessToken']! as String,
    refreshToken: json['refreshToken'] as String?,
    idToken: json['idToken'] as String?,
    expiresAt: json['expiresAt'] is String
        ? DateTime.tryParse(json['expiresAt']! as String)
        : null,
    userId: json['userId']?.toString() ?? '',
    username: json['username']?.toString() ?? '',
    fullName: json['fullName'] as String?,
    email: json['email'] as String?,
    tenantId: (json['tenantId'] as num?)?.toInt() ?? 0,
    roles:
        (json['roles'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    permissions:
        (json['permissions'] as List?)?.map((e) => e.toString()).toSet() ??
        const {},
    locationIds:
        (json['locationIds'] as List?)
            ?.map((e) => (e as num).toInt())
            .toList() ??
        const [],
  );

  final String accessToken;
  final String? refreshToken;
  final String? idToken;
  final DateTime? expiresAt;

  /// Keycloak subject (`sub`).
  final String userId;
  final String username;
  final String? fullName;
  final String? email;
  final int tenantId;
  final List<String> roles;

  /// Effective permission codes; empty until `/identity/me` is loaded.
  final Set<String> permissions;

  /// `iam_user_location` restriction; empty means unrestricted.
  final List<int> locationIds;

  TenantContext get tenant => TenantContext(tenantId: tenantId);

  /// `true` when the access token expires within [leeway].
  bool isExpired({
    Duration leeway = const Duration(seconds: 30),
    DateTime? now,
  }) {
    final exp = expiresAt;
    if (exp == null) return false;
    return (now ?? DateTime.now().toUtc()).add(leeway).isAfter(exp);
  }

  bool hasPermission(String code) => permissions.contains(code);
  bool hasAnyPermission(Iterable<String> codes) =>
      codes.any(permissions.contains);
  bool hasRole(String role) => roles.contains(role);

  String get displayName =>
      (fullName?.trim().isNotEmpty ?? false) ? fullName!.trim() : username;

  Session copyWith({
    String? accessToken,
    String? refreshToken,
    String? idToken,
    DateTime? expiresAt,
    List<String>? roles,
    Set<String>? permissions,
    String? fullName,
    String? email,
    List<int>? locationIds,
  }) => Session(
    accessToken: accessToken ?? this.accessToken,
    refreshToken: refreshToken ?? this.refreshToken,
    idToken: idToken ?? this.idToken,
    expiresAt: expiresAt ?? this.expiresAt,
    userId: userId,
    username: username,
    tenantId: tenantId,
    roles: roles ?? this.roles,
    permissions: permissions ?? this.permissions,
    fullName: fullName ?? this.fullName,
    email: email ?? this.email,
    locationIds: locationIds ?? this.locationIds,
  );

  Map<String, Object?> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'idToken': idToken,
    'expiresAt': expiresAt?.toUtc().toIso8601String(),
    'userId': userId,
    'username': username,
    'fullName': fullName,
    'email': email,
    'tenantId': tenantId,
    'roles': roles,
    'permissions': permissions.toList(),
    'locationIds': locationIds,
  };

  @override
  bool operator ==(Object other) =>
      other is Session &&
      other.accessToken == accessToken &&
      other.refreshToken == refreshToken &&
      other.userId == userId &&
      other.tenantId == tenantId &&
      other.permissions.length == permissions.length &&
      other.permissions.containsAll(permissions);

  @override
  int get hashCode => Object.hash(accessToken, refreshToken, userId, tenantId);

  @override
  String toString() =>
      'Session(user: $username, tenant: $tenantId, roles: $roles, exp: $expiresAt)';
}
