import 'package:feature_consumption/feature_consumption.dart';
import 'package:feature_identity/feature_identity.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_core/wms_core.dart';

import 'app.dart';
import 'attachments/file_input_attachment_picker.dart';
import 'attachments/file_input_csv_picker.dart';
import 'auth/browser.dart';
import 'auth/keycloak_auth_web.dart';
import 'auth/window_browser.dart';
import 'config/flavors.dart';
import 'observability/error_handlers.dart';

/// Composition root of the web app: crash reporting, OIDC repository, API
/// client and the guarded error zone.
///
/// The OIDC redirect is **not** completed here: `/callback` is a real route
/// (`CallbackScreen`) so the exchange has a UI and an error surface.
Future<void> bootstrap({
  AppConfig? config,
  CrashReporter? crashReporter,
  Browser? browser,
}) async {
  final resolved = config ?? AppConfig.fromEnvironment();
  final reporter = crashReporter ?? LoggingCrashReporter();
  await runGuardedWithReporter(() async {
    WidgetsFlutterBinding.ensureInitialized();
    installErrorHandlers(reporter);
    // Path URLs (no `#`): the registered redirect URI is
    // `<origin>/callback` and OAuth forbids a fragment in redirect_uri.
    // nginx serves index.html for unknown paths (deploy/docker/nginx.conf).
    usePathUrlStrategy();

    final resolvedBrowser = browser ?? const WindowBrowser();
    final authRepository = KeycloakAuthWeb(
      issuer: resolved.env.keycloakIssuer,
      clientId: resolved.clientId,
      redirectUri: KeycloakAuthWeb.originOf(resolvedBrowser.currentUri),
      browser: resolvedBrowser,
      store: SecureTokenStore(),
      pendingStore: const SessionStoragePendingAuthorizationStore(),
    );
    // A stored session survives a reload; the access token is renewed from
    // the refresh token by SessionTokenProvider/SilentRefreshScheduler.
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
          attachmentPickerProvider.overrideWithValue(
            const FileInputAttachmentPicker(),
          ),
          csvFilePickerProvider.overrideWithValue(const FileInputCsvPicker()),
        ],
        child: WmsWebApp(config: resolved),
      ),
    );
  }, reporter);
}
