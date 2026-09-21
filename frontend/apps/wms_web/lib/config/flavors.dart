import 'package:wms_core/wms_core.dart';

/// Build flavour, selected with `--dart-define=FLAVOR=dev|stg|prod`.
enum Flavor {
  dev('dev', 'WMS Satınalma və Anbar (dev)'),
  stg('stg', 'WMS Satınalma və Anbar (stg)'),
  prod('prod', 'WMS Satınalma və Anbar');

  const Flavor(this.key, this.appTitle);

  final String key;
  final String appTitle;

  static Flavor fromKey(String key) =>
      values.firstWhere((f) => f.key == key, orElse: () => Flavor.dev);
}

/// Resolved app configuration: environment + flavour.
class AppConfig {
  const AppConfig({required this.env, required this.flavor});

  factory AppConfig.fromEnvironment() {
    const env = AppEnv.fromEnvironment;
    return AppConfig(env: env, flavor: Flavor.fromKey(env.flavor));
  }

  final AppEnv env;
  final Flavor flavor;

  /// Keycloak client id; falls back to the web client from CONVENTIONS.md.
  String get clientId =>
      env.keycloakClientId.isEmpty ? 'wms-web' : env.keycloakClientId;

  String? get banner => flavor == Flavor.prod ? null : flavor.key;
}
