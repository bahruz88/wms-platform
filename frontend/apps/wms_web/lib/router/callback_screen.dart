import 'package:feature_identity/feature_identity.dart';
import 'package:feature_reporting/feature_reporting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';

import '../auth/keycloak_auth_web.dart';

/// OIDC redirect landing page (`/callback`).
///
/// Keycloak sends the browser here with `?code=&state=`. The screen hands the
/// URI to [KeycloakAuthWeb.completeRedirect], which re-creates the PKCE flow
/// from the verifier kept in `sessionStorage` and exchanges the code for
/// tokens. On success the user continues to the location they originally
/// asked for; on failure the RFC 7807 `code` stays visible in a `WmsAlert`.
class CallbackScreen extends ConsumerStatefulWidget {
  const CallbackScreen({required this.uri, super.key});

  /// The full callback location, query string included.
  final Uri uri;

  @override
  ConsumerState<CallbackScreen> createState() => _CallbackScreenState();
}

class _CallbackScreenState extends ConsumerState<CallbackScreen> {
  Failure? _failure;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _complete());
  }

  Future<void> _complete() async {
    final repository = ref.read(authRepositoryProvider);
    if (repository is! KeycloakAuthWeb) {
      // Fake/other repository (tests, local dev): nothing to exchange.
      if (mounted) _leave(ReportingRoutes.dashboardPath);
      return;
    }
    final result = await Result.guard(
      () => repository.completeRedirect(widget.uri),
    );
    if (!mounted) return;
    result.fold(
      (signIn) => _leave(signIn.returnTo ?? ReportingRoutes.dashboardPath),
      (failure) => setState(() {
        _failure = failure;
        _done = true;
      }),
    );
  }

  void _leave(String location) {
    setState(() => _done = true);
    // `go` replaces `/callback?code=...` in the address bar, so a reload does
    // not try to redeem a code that Keycloak has already consumed.
    context.go(location);
  }

  @override
  Widget build(BuildContext context) {
    final c = WmsColors.of(context);
    final failure = _failure;
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(WmsSpacing.space5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (failure == null) ...[
                  const Center(child: WmsSpinner(size: 20)),
                  const SizedBox(height: WmsSpacing.space4),
                  Text(
                    _done ? 'Sessiya hazırlanır…' : 'Giriş tamamlanır…',
                    textAlign: TextAlign.center,
                    style: WmsTypography.body.copyWith(color: c.inkMuted),
                  ),
                ] else ...[
                  WmsAlert.fromFailure(failure),
                  const SizedBox(height: WmsSpacing.space4),
                  WmsButton.primary(
                    label: 'Giriş səhifəsinə qayıt',
                    iconLeft: Icons.login_outlined,
                    onPressed: () => context.go(IdentityRoutes.loginPath),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Route name/path of the OIDC redirect landing page.
abstract final class CallbackRoutes {
  static const String name = 'oidc-callback';
  static const String path = '/callback';
}

/// `/callback` lives outside the shell and is reachable without a session.
List<RouteBase> callbackRoutes() => [
  GoRoute(
    name: CallbackRoutes.name,
    path: CallbackRoutes.path,
    builder: (context, state) => CallbackScreen(uri: state.uri),
  ),
];
