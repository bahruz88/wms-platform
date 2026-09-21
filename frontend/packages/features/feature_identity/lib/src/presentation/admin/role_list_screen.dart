import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import '../../navigation.dart';
import '../require_permission.dart';
import 'admin_async_view.dart';
import 'admin_providers.dart';

/// Admin → Rollar: `GET /identity/roles` (not paged, few per tenant).
class AdminRoleListScreen extends ConsumerWidget {
  const AdminRoleListScreen({this.onOpenRole, super.key});

  /// Overridden in tests; by default the row opens `/admin/roles/{id}`.
  final void Function(BuildContext context, int roleId)? onOpenRole;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final roles = ref.watch(roleListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.labelRoles)),
      body: RequirePermission.withNotice(
        permission: Permissions.userManage,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(WmsSpacing.space4),
          child: AdminAsyncView<List<RoleDto>>(
            value: roles,
            onRetry: () => ref.invalidate(roleListProvider),
            builder: (items) => WmsDataTable<RoleDto>(
              rowKey: (row, _) => row.id,
              emptyReason: 'Bu tenant üçün rol tapılmadı.',
              emptyNextStep: 'Sistem rolları realm ilə birlikdə gəlir.',
              onRowTap: (row, _) => _open(context, row.id),
              columns: [
                WmsColumn(
                  key: 'code',
                  header: 'Kod',
                  width: 220,
                  render: (row, _) => Text(
                    row.code,
                    style: WmsTypography.docNo.copyWith(
                      color: WmsColors.of(context).ink,
                    ),
                  ),
                ),
                WmsColumn(
                  key: 'name',
                  header: 'Ad',
                  flex: 3,
                  cell: (row) => row.name,
                ),
                WmsColumn(
                  key: 'kind',
                  header: 'Növ',
                  width: 130,
                  render: (row, _) => row.isSystem
                      ? const WmsBadge(text: 'Sistem', tone: WmsTone.accent)
                      : const WmsBadge(text: 'Xüsusi'),
                ),
                WmsColumn(
                  key: 'permissions',
                  header: 'İcazə sayı',
                  width: 120,
                  numeric: true,
                  cell: (row) => '${row.permissions.length}',
                ),
                WmsColumn(
                  key: 'critical',
                  header: 'Kritik icazə',
                  width: 150,
                  render: (row, _) => criticalCount(row) == 0
                      ? const SizedBox.shrink()
                      : WmsBadge(
                          text: '${criticalCount(row)} kritik',
                          tone: WmsTone.warning,
                          icon: Icons.warning_amber_outlined,
                          tooltip: criticalPermissions(row).join(', '),
                        ),
                ),
              ],
              rows: items,
            ),
          ),
        ),
      ),
    );
  }

  /// Permissions the spec calls out as critical (§7.1): cost visibility,
  /// approvals and reversal. They are flagged in the list so an admin sees
  /// the weight of a role before opening it.
  static const Set<String> criticalCodes = {
    Permissions.productViewCost,
    Permissions.adjustmentApprove,
    Permissions.wasteApprove,
    Permissions.poApprove,
    Permissions.movementReverse,
  };

  static List<String> criticalPermissions(RoleDto role) => [
    for (final p in role.permissions)
      if (criticalCodes.contains(p)) p,
  ];

  static int criticalCount(RoleDto role) => criticalPermissions(role).length;

  void _open(BuildContext context, int id) {
    final handler = onOpenRole;
    if (handler != null) {
      handler(context, id);
      return;
    }
    context.go(IdentityRoutes.adminRoleDetail(id));
  }
}
