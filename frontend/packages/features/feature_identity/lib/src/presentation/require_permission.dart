import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_design_system/wms_design_system.dart';

/// Renders [child] only when the session holds [permission].
///
/// The default fallback renders nothing, which is what the security rules
/// demand for cost data (spec §16): the column/field must be absent, not
/// masked. Pass [fallback] when an explanation is more useful than silence.
class RequirePermission extends ConsumerWidget {
  const RequirePermission({
    required this.permission,
    required this.child,
    this.fallback,
    super.key,
  });

  /// Shows an explicit «no permission» notice instead of hiding the subtree.
  const RequirePermission.withNotice({
    required this.permission,
    required this.child,
    super.key,
  }) : fallback = const _NoPermissionNotice();

  final String permission;
  final Widget child;
  final Widget? fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowed = ref.watch(hasPermissionProvider(permission));
    if (allowed) return child;
    return fallback ?? const SizedBox.shrink();
  }
}

class _NoPermissionNotice extends StatelessWidget {
  const _NoPermissionNotice();

  @override
  Widget build(BuildContext context) => const WmsAlert(
    title: 'Bu bölmə üçün icazəniz yoxdur',
    message: 'Lazım olduqda administratordan icazə tələb edin.',
  );
}

/// Convenience: `ref.hasPermission(Permissions.poApprove)`.
extension PermissionRef on WidgetRef {
  bool hasPermission(String code) => watch(hasPermissionProvider(code));
}
