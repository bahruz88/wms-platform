import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import 'identity_providers.dart';

/// Sign-in screen. The actual OIDC flow lives in the app-provided
/// `AuthRepository` (Keycloak Authorization Code + PKCE); this screen only
/// triggers it and renders the failure.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({this.title, super.key});

  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final state = ref.watch(loginControllerProvider);
    final failure = state.error is AppException
        ? (state.error! as AppException).failure
        : null;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(WmsSpacing.space5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.inventory_2_outlined, size: 32, color: c.accent),
                const SizedBox(height: WmsSpacing.space4),
                Text(
                  title ?? l10n.appTitleWeb,
                  style: WmsTypography.display.copyWith(color: c.ink),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: WmsSpacing.space2),
                Text(
                  l10n.loginSubtitle,
                  style: WmsTypography.body.copyWith(color: c.inkMuted),
                  textAlign: TextAlign.center,
                ),
                if (failure != null) ...[
                  const SizedBox(height: WmsSpacing.space4),
                  WmsAlert.fromFailure(failure),
                ],
                const SizedBox(height: WmsSpacing.space5),
                WmsButton.primary(
                  label: l10n.actionLogin,
                  loading: state.isLoading,
                  iconLeft: Icons.login_outlined,
                  onPressed: () =>
                      ref.read(loginControllerProvider.notifier).login(),
                ),
                const SizedBox(height: WmsSpacing.space4),
                Text(
                  AppEnv.fromEnvironment.keycloakIssuer,
                  style: WmsTypography.figureSm.copyWith(color: c.inkSubtle),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
