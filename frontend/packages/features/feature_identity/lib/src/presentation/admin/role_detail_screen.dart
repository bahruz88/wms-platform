import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import '../require_permission.dart';
import 'admin_async_view.dart';
import 'admin_providers.dart';
import 'role_list_screen.dart';

/// Admin → Rollar → detal: `GET /identity/roles/{id}` with its permission
/// codes, grouped by module and with the critical ones flagged (SPEC §7.1).
class AdminRoleDetailScreen extends ConsumerWidget {
  const AdminRoleDetailScreen({required this.roleId, super.key});

  final int roleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final role = ref.watch(roleDetailProvider(roleId));
    final catalogue = ref.watch(permissionCatalogueProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.labelRoles)),
      body: RequirePermission.withNotice(
        permission: Permissions.userManage,
        child: AdminAsyncView<RoleDto>(
          value: role,
          onRetry: () => ref.invalidate(roleDetailProvider(roleId)),
          builder: (data) {
            final descriptions = <String, String>{
              for (final p in catalogue.value ?? const <PermissionDto>[])
                if (p.description != null) p.code: p.description!,
            };
            final grouped = groupByModule(data.permissions);
            return ListView(
              padding: const EdgeInsets.all(WmsSpacing.space4),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data.name,
                        style: WmsTypography.display.copyWith(color: c.ink),
                      ),
                    ),
                    if (data.isSystem)
                      const WmsBadge(text: 'Sistem', tone: WmsTone.accent),
                  ],
                ),
                const SizedBox(height: WmsSpacing.space2),
                Text(
                  data.code,
                  style: WmsTypography.docNo.copyWith(color: c.inkMuted),
                ),
                const SizedBox(height: WmsSpacing.space4),
                if (data.permissions.isEmpty)
                  const WmsEmptyState(
                    reason: 'Bu rola icazə bağlanmayıb.',
                    nextStep:
                        'İcazələr identity API-nin rol endpoint-i ilə '
                        'təyin edilir.',
                  )
                else
                  for (final entry in grouped.entries) ...[
                    Text(
                      entry.key,
                      style: WmsTypography.title.copyWith(color: c.ink),
                    ),
                    const SizedBox(height: WmsSpacing.space2),
                    Wrap(
                      spacing: WmsSpacing.space2,
                      runSpacing: WmsSpacing.space2,
                      children: [
                        for (final code in entry.value)
                          WmsBadge(
                            text: code,
                            tone:
                                AdminRoleListScreen.criticalCodes.contains(code)
                                ? WmsTone.warning
                                : WmsTone.neutral,
                            icon:
                                AdminRoleListScreen.criticalCodes.contains(code)
                                ? Icons.warning_amber_outlined
                                : null,
                            tooltip: descriptions[code],
                          ),
                      ],
                    ),
                    const SizedBox(height: WmsSpacing.space4),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }

  /// `inv.receipt.create` → module `inv`. Codes keep their wire form; only
  /// the grouping header is derived.
  static Map<String, List<String>> groupByModule(List<String> permissions) {
    final grouped = <String, List<String>>{};
    for (final code in [...permissions]..sort()) {
      final module = code.contains('.') ? code.split('.').first : 'digər';
      grouped.putIfAbsent(module, () => <String>[]).add(code);
    }
    return grouped;
  }
}
