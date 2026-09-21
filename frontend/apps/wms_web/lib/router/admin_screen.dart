import 'package:feature_identity/feature_identity.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

/// Admin section route names/paths. The individual screens live in the
/// feature packages (`feature_identity` for users/roles, `feature_inventory`
/// for `inv_setting`); this file only composes them under `/admin`.
abstract final class AdminRoutes {
  static const String rootName = 'admin';
  static const String rootPath = '/admin';
}

List<RouteBase> adminRoutes() => [
  GoRoute(
    name: AdminRoutes.rootName,
    path: AdminRoutes.rootPath,
    builder: (context, state) => const AdminScreen(),
  ),
  ...identityAdminRoutes(),
  ...inventorySettingsRoutes(),
];

/// Admin landing page: the three sections an administrator manages.
/// Everything below is gated on `iam.user.manage`, both here and inside each
/// screen, so a deep link cannot bypass the check.
class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navAdmin)),
      body: RequirePermission.withNotice(
        permission: Permissions.userManage,
        child: ListView(
          padding: const EdgeInsets.all(WmsSpacing.space4),
          children: [
            Text(
              l10n.navAdmin,
              style: WmsTypography.display.copyWith(color: c.ink),
            ),
            const SizedBox(height: WmsSpacing.space4),
            _AdminCard(
              title: l10n.labelUsers,
              description:
                  'İstifadəçi siyahısı, Keycloak subject bağlantısı, '
                  'rollar və lokasiya girişi.',
              icon: Icons.people_outline,
              onOpen: () => context.go(IdentityRoutes.adminUsersPath),
            ),
            _AdminCard(
              title: l10n.labelRoles,
              description:
                  'Rol → icazə matrisi (iam_role_permission); '
                  'kritik icazələr nişanlanır.',
              icon: Icons.verified_user_outlined,
              onOpen: () => context.go(IdentityRoutes.adminRolesPath),
            ),
            _AdminCard(
              title: l10n.labelSettings,
              description:
                  'inv_setting: expiry həddləri, tolerans faizləri, '
                  'costing metodu.',
              icon: Icons.settings_outlined,
              onOpen: () => context.go(InventoryRoutes.settingsPath),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  const _AdminCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onOpen,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final c = WmsColors.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: WmsSpacing.space3),
      padding: WmsSpacing.cardPadding,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: WmsRadius.lgAll,
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: c.inkMuted),
          const SizedBox(width: WmsSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: WmsTypography.title.copyWith(color: c.ink)),
                const SizedBox(height: WmsSpacing.space1),
                Text(
                  description,
                  style: WmsTypography.caption.copyWith(color: c.inkMuted),
                ),
              ],
            ),
          ),
          WmsButton(
            label: l10nOpen,
            size: WmsButtonSize.sm,
            iconLeft: Icons.arrow_forward,
            onPressed: onOpen,
          ),
        ],
      ),
    );
  }

  /// The action word is the same on all three cards.
  static const String l10nOpen = 'Aç';
}
