import 'package:feature_identity/feature_identity.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_core/wms_core.dart';

import 'app.dart';
import 'attachments/camera_attachment_picker.dart';
import 'auth/keycloak_auth_mobile.dart';
import 'config/flavors.dart';
import 'observability/error_handlers.dart';
import 'router/app_router.dart';
import 'scan/mobile_barcode_scanner.dart';

/// Composition root: crash reporting, auth repository, API client and the
/// camera scanner; restores the stored session and runs the app inside a
/// guarded error zone.
Future<void> bootstrap({
  AppConfig? config,
  CrashReporter? crashReporter,
}) async {
  final resolved = config ?? AppConfig.fromEnvironment();
  final reporter = crashReporter ?? LoggingCrashReporter();
  await runGuardedWithReporter(() async {
    WidgetsFlutterBinding.ensureInitialized();
    installErrorHandlers(reporter);

    // The redirect URL defaults to AppConfig.redirectUrl
    // (az.wms.mobile://callback), which the Android manifest placeholder
    // and the iOS CFBundleURLTypes entry declare.
    final authRepository = KeycloakAuthMobile(
      issuer: resolved.env.keycloakIssuer,
      clientId: resolved.clientId,
      store: SecureTokenStore(),
    );
    final restored = await authRepository.restore();
    if (restored != null) {
      reporter.setUser(userId: restored.userId, tenantId: restored.tenantId);
    }

    final apiClient = WmsApiClient(
      baseUrl: resolved.env.apiBaseUrl,
      tokenProvider: SessionTokenProvider(authRepository),
    );

    runApp(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          apiClientProvider.overrideWithValue(apiClient),
          crashReporterProvider.overrideWithValue(reporter),
          barcodeScannerProvider.overrideWithValue(
            MobileBarcodeScanner(navigatorKey: rootNavigatorKey),
          ),
          attachmentPickerProvider.overrideWithValue(
            const CameraAttachmentPicker(),
          ),
        ],
        child: WmsMobileApp(config: resolved),
      ),
    );
  }, reporter);
}
