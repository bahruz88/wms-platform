import 'package:flutter/material.dart' hide Page;
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

/// Admin → İstifadəçilər: `GET /identity/users`, one row per `iam_user`.
///
/// Read only: creating a user means creating it in Keycloak first
/// (`UserCreate.externalId` = subject), which is an admin console job.
class AdminUserListScreen extends ConsumerWidget {
  const AdminUserListScreen({this.onOpenUser, super.key});

  /// Overridden in tests; by default the row opens `/admin/users/{id}`.
  final void Function(BuildContext context, int userId)? onOpenUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final users = ref.watch(userListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.labelUsers)),
      body: RequirePermission.withNotice(
        permission: Permissions.userManage,
        child: ListView(
          padding: const EdgeInsets.all(WmsSpacing.space4),
          children: [
            SizedBox(
              width: 360,
              child: WmsTextField(
                label: l10n.actionSearch,
                placeholder: 'İstifadəçi adı, ad və ya e-mail',
                onSubmitted: (value) => ref
                    .read(userSearchProvider.notifier)
                    .setSearch(value.trim()),
              ),
            ),
            const SizedBox(height: WmsSpacing.space4),
            AdminAsyncView<Page<UserDto>>(
              value: users,
              onRetry: () => ref.invalidate(userListProvider),
              builder: (page) => WmsDataTable<UserDto>(
                rowKey: (row, _) => row.id,
                emptyReason: 'Bu filtrə uyğun istifadəçi yoxdur.',
                emptyNextStep:
                    'Axtarışı təmizləyin və ya Keycloak-da istifadəçi yaradın.',
                onRowTap: (row, _) => _open(context, row.id),
                columns: [
                  WmsColumn(
                    key: 'username',
                    header: 'İstifadəçi adı',
                    width: 160,
                    render: (row, _) => Text(
                      row.username,
                      style: WmsTypography.docNo.copyWith(
                        color: WmsColors.of(context).ink,
                      ),
                    ),
                  ),
                  WmsColumn(
                    key: 'fullName',
                    header: 'Ad, soyad',
                    flex: 3,
                    cell: (row) => row.fullName,
                  ),
                  WmsColumn(
                    key: 'email',
                    header: 'E-mail',
                    flex: 3,
                    cell: (row) => row.email ?? '—',
                  ),
                  WmsColumn(
                    key: 'roles',
                    header: l10n.labelRoles,
                    flex: 3,
                    cell: (row) => row.roles.isEmpty ? '—' : row.roleCodes,
                  ),
                  WmsColumn(
                    key: 'locations',
                    header: l10n.labelLocations,
                    width: 160,
                    cell: (row) => row.hasAllLocations
                        ? 'bütün lokasiyalar'
                        : '${row.locationIds.length} lokasiya',
                  ),
                  WmsColumn(
                    key: 'isActive',
                    header: l10n.labelStatus,
                    width: 110,
                    render: (row, _) => row.isActive
                        ? const WmsBadge(text: 'Aktiv', tone: WmsTone.success)
                        : const WmsBadge(text: 'Deaktiv'),
                  ),
                ],
                rows: page.items,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, int id) {
    final handler = onOpenUser;
    if (handler != null) {
      handler(context, id);
      return;
    }
    context.go(IdentityRoutes.adminUserDetail(id));
  }
}
