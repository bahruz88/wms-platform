import 'package:meta/meta.dart';

/// Build-time configuration injected with `--dart-define` (CONVENTIONS.md):
///
/// ```sh
/// --dart-define=API_BASE_URL=http://localhost:5001
/// --dart-define=KEYCLOAK_ISSUER=http://localhost:8180/realms/wms
/// --dart-define=KEYCLOAK_CLIENT_ID=wms-web   # or wms-mobile
/// --dart-define=FLAVOR=dev                   # dev | stg | prod
/// ```
///
/// The defaults below match this machine's `deploy/.env` (5000/8080/3306 were
/// already taken, so the gateway listens on 5001 and Keycloak on 8180); any
/// deployment can still point them back at the standard ports via
/// `--dart-define`.
@immutable
class AppEnv {
  const AppEnv({
    required this.apiBaseUrl,
    required this.keycloakIssuer,
    required this.keycloakClientId,
    required this.flavor,
  });

  /// The environment resolved from `String.fromEnvironment` at compile time.
  static const AppEnv fromEnvironment = AppEnv(
    apiBaseUrl: String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:5001',
    ),
    keycloakIssuer: String.fromEnvironment(
      'KEYCLOAK_ISSUER',
      defaultValue: 'http://localhost:8180/realms/wms',
    ),
    keycloakClientId: String.fromEnvironment('KEYCLOAK_CLIENT_ID'),
    flavor: String.fromEnvironment('FLAVOR', defaultValue: 'dev'),
  );

  /// Gateway base URL, e.g. `http://localhost:5000` (no trailing slash).
  final String apiBaseUrl;

  /// Keycloak realm issuer, e.g. `http://localhost:8080/realms/wms`.
  final String keycloakIssuer;

  /// Public OIDC client id: `wms-web` or `wms-mobile`.
  final String keycloakClientId;

  /// `dev` | `stg` | `prod`.
  final String flavor;

  bool get isProd => flavor == 'prod';
  bool get isDev => flavor == 'dev';

  /// `/api/v1` prefix appended to [apiBaseUrl].
  String get apiV1 => '${_trimSlash(apiBaseUrl)}/api/v1';

  /// Throws a [StateError] listing the missing defines, so misconfiguration
  /// surfaces at startup instead of as a confusing 401 later.
  void validate() {
    final missing = <String>[
      if (apiBaseUrl.isEmpty) 'API_BASE_URL',
      if (keycloakIssuer.isEmpty) 'KEYCLOAK_ISSUER',
      if (keycloakClientId.isEmpty) 'KEYCLOAK_CLIENT_ID',
    ];
    if (missing.isNotEmpty) {
      throw StateError('Missing --dart-define: ${missing.join(', ')}');
    }
  }

  AppEnv copyWith({
    String? apiBaseUrl,
    String? keycloakIssuer,
    String? keycloakClientId,
    String? flavor,
  }) => AppEnv(
    apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
    keycloakIssuer: keycloakIssuer ?? this.keycloakIssuer,
    keycloakClientId: keycloakClientId ?? this.keycloakClientId,
    flavor: flavor ?? this.flavor,
  );

  static String _trimSlash(String url) =>
      url.endsWith('/') ? url.substring(0, url.length - 1) : url;

  @override
  String toString() =>
      'AppEnv(flavor: $flavor, api: $apiBaseUrl, issuer: $keycloakIssuer, '
      'client: $keycloakClientId)';
}
