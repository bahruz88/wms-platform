import 'dart:convert';

/// Decodes (without verifying) a JWT payload. Verification is the resource
/// server's job; the client only needs claims for display and routing.
abstract final class JwtParser {
  /// Returns the payload claims or throws [FormatException].
  static Map<String, Object?> decode(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const FormatException('JWT must have three segments');
    }
    final payload = utf8.decode(base64Url.decode(_pad(parts[1])));
    final decoded = jsonDecode(payload);
    if (decoded is! Map) {
      throw const FormatException('JWT payload is not an object');
    }
    return decoded.map((k, v) => MapEntry(k.toString(), v));
  }

  static Map<String, Object?>? tryDecode(String? token) {
    if (token == null || token.isEmpty) return null;
    try {
      return decode(token);
    } on FormatException {
      return null;
    }
  }

  /// `exp` claim as UTC [DateTime].
  static DateTime? expiresAt(Map<String, Object?> claims) {
    final exp = claims['exp'];
    final seconds = exp is int ? exp : int.tryParse('$exp');
    if (seconds == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
  }

  /// Keycloak realm roles (`realm_access.roles`).
  static List<String> realmRoles(Map<String, Object?> claims) {
    final access = claims['realm_access'];
    if (access is Map) {
      final roles = access['roles'];
      if (roles is List) return roles.map((e) => e.toString()).toList();
    }
    return const [];
  }

  /// Optional `permissions` claim (list) when the realm maps them; the
  /// authoritative source stays `GET /identity/me`.
  static List<String> permissions(Map<String, Object?> claims) {
    final raw = claims['permissions'];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    if (raw is String) {
      return raw.split(RegExp(r'[,\s]+')).where((e) => e.isNotEmpty).toList();
    }
    return const [];
  }

  static String _pad(String segment) {
    final normalised = segment.replaceAll('-', '+').replaceAll('_', '/');
    final remainder = normalised.length % 4;
    return remainder == 0
        ? normalised
        : normalised.padRight(normalised.length + (4 - remainder), '=');
  }
}
