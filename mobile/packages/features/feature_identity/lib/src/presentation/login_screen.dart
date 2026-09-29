import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import 'identity_providers.dart';

/// Sign-in screen: the credentials are typed here, in the app.
///
/// There is no browser step. The app used to hand the sign-in to Keycloak's own
/// page through a Custom Tab, which is what RFC 8252 recommends for a native
/// app; it was replaced on request. What the app-provided `AuthRepository` does
/// with these two fields is its business — on mobile it is Keycloak's Direct
/// Access Grant.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({this.title, super.key});

  final String? title;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final FocusNode _passwordFocus = FocusNode();
  // Only shown once a submit has been attempted, so the form does not scold
  // anyone for fields they have not reached yet.
  bool _submitted = false;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _username.text.trim().isNotEmpty && _password.text.isNotEmpty;

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_canSubmit) return;
    await ref
        .read(loginControllerProvider.notifier)
        .login(username: _username.text.trim(), password: _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final state = ref.watch(loginControllerProvider);
    final failure = state.error is AppException
        ? (state.error! as AppException).failure
        : null;
    final busy = state.isLoading;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(WmsSpacing.space5),
            child: AutofillGroup(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 32, color: c.accent),
                  const SizedBox(height: WmsSpacing.space4),
                  Text(
                    widget.title ?? l10n.appTitleWeb,
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
                  WmsTextField(
                    controller: _username,
                    label: l10n.labelUsername,
                    required: true,
                    enabled: !busy,
                    autofocus: true,
                    autofillHints: const [AutofillHints.username],
                    textInputAction: TextInputAction.next,
                    error: _submitted && _username.text.trim().isEmpty
                        ? l10n.validationRequired
                        : null,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _passwordFocus.requestFocus(),
                  ),
                  const SizedBox(height: WmsSpacing.space3),
                  WmsTextField(
                    controller: _password,
                    focusNode: _passwordFocus,
                    label: l10n.labelPassword,
                    required: true,
                    enabled: !busy,
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    textInputAction: TextInputAction.done,
                    error: _submitted && _password.text.isEmpty
                        ? l10n.validationRequired
                        : null,
                    onChanged: (_) => setState(() {}),
                    // Enter submits, so the form works from a scanner gun's
                    // keyboard wedge as well as from the on-screen keyboard.
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: WmsSpacing.space5),
                  WmsButton.primary(
                    label: l10n.actionLogin,
                    loading: busy,
                    iconLeft: Icons.login_outlined,
                    enabled: _canSubmit && !busy,
                    disabledReason: l10n.validationRequired,
                    onPressed: _submit,
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
      ),
    );
  }
}
