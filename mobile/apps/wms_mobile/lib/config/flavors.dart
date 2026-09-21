import 'package:wms_core/wms_core.dart';

/// Build flavour, selected with `--dart-define=FLAVOR=dev|stg|prod`.
enum Flavor {
  dev('dev', 'WMS Anbar (dev)'),
  stg('stg', 'WMS Anbar (stg)'),
  prod('prod', 'WMS Anbar');

  const Flavor(this.key, this.appTitle);

  final String key;
  final String appTitle;

  static Flavor fromKey(String key) =>
      values.firstWhere((f) => f.key == key, orElse: () => Flavor.dev);
}

/// Resolved app configuration: environment + flavour.
class AppConfig {
  const AppConfig({required this.env, required this.flavor});

  /// Reads everything from `--dart-define` (see `AppEnv`).
  factory AppConfig.fromEnvironment() {
    const env = AppEnv.fromEnvironment;
    return AppConfig(env: env, flavor: Flavor.fromKey(env.flavor));
  }

  final AppEnv env;
  final Flavor flavor;

  /// Keycloak client id; falls back to the mobile client from CONVENTIONS.md.
  String get clientId =>
      env.keycloakClientId.isEmpty ? 'wms-mobile' : env.keycloakClientId;

  /// Deep link scheme / redirect used by the Authorization Code + PKCE flow.
  static const String redirectScheme = 'az.wms.mobile';
  static const String redirectUrl = '$redirectScheme://callback';

  /// Shown in the app bar of non-production builds.
  String? get banner => flavor == Flavor.prod ? null : flavor.key;

  AppEnv get validated {
    env.validate();
    return env;
  }
}
