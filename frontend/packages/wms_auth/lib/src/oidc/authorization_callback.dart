import 'package:meta/meta.dart';

/// Result of reading an OIDC redirect URI.
///
/// Keycloak answers the Authorization Code flow on the query string
/// (`?code=&state=&iss=&session_state=`) and reports failures the same way
/// (`?error=&error_description=&state=`). Implicit-style fragments are parsed
/// as well so a misconfigured client is reported instead of silently ignored.
@immutable
sealed class AuthorizationCallback {
  const AuthorizationCallback();

  /// Reads [uri] and classifies it. Query parameters win over the fragment.
  factory AuthorizationCallback.parse(Uri uri) {
    final params = <String, String>{
      ...uri.queryParameters,
      ...?_fragmentParameters(uri.fragment),
    };
    final error = params['error'];
    if (error != null && error.isNotEmpty) {
      return AuthorizationError(
        error: error,
        description: _clean(params['error_description']),
        state: params['state'],
      );
    }
    final code = params['code'];
    if (code != null && code.isNotEmpty) {
      return AuthorizationCode(
        code: code,
        state: params['state'],
        issuer: params['iss'],
        sessionState: params['session_state'],
      );
    }
    return const NoAuthorizationResponse();
  }

  /// `true` when the URI carries something the app must act on.
  bool get isRedirectResponse => this is! NoAuthorizationResponse;

  static Map<String, String>? _fragmentParameters(String fragment) {
    if (fragment.isEmpty || !fragment.contains('=')) return null;
    return Uri.splitQueryString(fragment);
  }

  /// Keycloak percent-encodes spaces as `+` in `error_description`.
  static String? _clean(String? value) {
    if (value == null || value.isEmpty) return null;
    return value.replaceAll('+', ' ');
  }
}

/// No `code` and no `error`: an ordinary page load.
final class NoAuthorizationResponse extends AuthorizationCallback {
  const NoAuthorizationResponse();

  @override
  bool operator ==(Object other) => other is NoAuthorizationResponse;

  @override
  int get hashCode => (NoAuthorizationResponse).hashCode;

  @override
  String toString() => 'NoAuthorizationResponse()';
}

/// Successful authorization; the code still has to be exchanged.
final class AuthorizationCode extends AuthorizationCallback {
  const AuthorizationCode({
    required this.code,
    this.state,
    this.issuer,
    this.sessionState,
  });

  final String code;
  final String? state;

  /// `iss` (RFC 9207) — must match the configured issuer when present.
  final String? issuer;
  final String? sessionState;

  /// Guards against a forged or stale callback (CSRF / replay).
  bool matchesState(String? expected) =>
      expected != null && expected.isNotEmpty && state == expected;

  /// RFC 9207 issuer check; `true` when the provider did not send `iss`.
  bool matchesIssuer(String expected) => issuer == null || issuer == expected;

  @override
  bool operator ==(Object other) =>
      other is AuthorizationCode && other.code == code && other.state == state;

  @override
  int get hashCode => Object.hash(code, state);

  @override
  String toString() => 'AuthorizationCode(state: $state)';
}

/// The provider refused the request (`access_denied`, `login_required`...).
final class AuthorizationError extends AuthorizationCallback {
  const AuthorizationError({required this.error, this.description, this.state});

  final String error;
  final String? description;
  final String? state;

  @override
  bool operator ==(Object other) =>
      other is AuthorizationError &&
      other.error == error &&
      other.description == description;

  @override
  int get hashCode => Object.hash(error, description);

  @override
  String toString() => 'AuthorizationError($error)';
}
