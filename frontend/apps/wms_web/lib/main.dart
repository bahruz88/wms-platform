import 'bootstrap.dart';

/// Entry point. Configuration comes from `--dart-define`:
///
/// ```sh
/// flutter run -d chrome --web-port 3001 \
///   --dart-define=API_BASE_URL=http://localhost:5001 \
///   --dart-define=KEYCLOAK_ISSUER=http://localhost:8180/realms/wms \
///   --dart-define=KEYCLOAK_CLIENT_ID=wms-web
/// ```
Future<void> main() => bootstrap();
