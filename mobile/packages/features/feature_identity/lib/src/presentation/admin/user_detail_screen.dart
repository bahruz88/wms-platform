import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import '../require_permission.dart';
import 'admin_async_view.dart';
import 'admin_providers.dart';

/// Admin → İstifadəçilər → detal: `GET /identity/users/{id}`.
///
/// Read only. Roles and locations are changed through
/// `PUT /identity/users/{id}/roles` and `.../locations`, which carry SoD
/// rules (a `WAREHOUSE_KEEPER` may not hold `master.product.view_cost`) and
/// optimistic locking; that editor is not part of this screen.
class AdminUserDetailScreen extends ConsumerWidget {
  const AdminUserDetailScreen({required this.userId, super.key});

  final int userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final user = ref.watch(userDetailProvider(userId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.labelUsers)),
      body: RequirePermission.withNotice(
        permission: Permissions.userManage,
        child: AdminAsyncView<UserDto>(
          value: user,
          onRetry: () => ref.invalidate(userDetailProvider(userId)),
          builder: (data) {
            final createdAt = data.audit?.createdAt;
            return ListView(
              padding: const EdgeInsets.all(WmsSpacing.space4),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data.fullName,
                        style: WmsTypography.display.copyWith(color: c.ink),
                      ),
                    ),
                    if (data.isActive)
                      const WmsBadge(text: 'Aktiv', tone: WmsTone.success)
                    else
                      const WmsBadge(text: 'Deaktiv'),
                  ],
                ),
                const SizedBox(height: WmsSpacing.space4),
                Container(
                  padding: WmsSpacing.cardPadding,
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: WmsRadius.lgAll,
                    border: Border.all(color: c.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AdminDetailRow(
                        label: 'İstifadəçi adı',
                        child: Text(
                          data.username,
                          style: WmsTypography.docNo.copyWith(color: c.ink),
                        ),
                      ),
                      AdminDetailRow(label: 'E-mail', value: data.email),
                      AdminDetailRow(label: 'Telefon', value: data.phone),
                      AdminDetailRow(
                        label: 'Keycloak subject',
                        child: Text(
                          data.externalId ?? '—',
                          style: WmsTypography.docNo.copyWith(
                            color: c.inkMuted,
                          ),
                        ),
                      ),
                      AdminDetailRow(
                        label: l10n.labelRoles,
                        child: data.roles.isEmpty
                            ? Text(
                                'Rol təyin edilməyib',
                                style: WmsTypography.body.copyWith(
                                  color: c.inkMuted,
                                ),
                              )
                            : Wrap(
                                spacing: WmsSpacing.space2,
                                runSpacing: WmsSpacing.space2,
                                children: [
                                  for (final role in data.roles)
                                    WmsBadge(
                                      text: role.code,
                                      tone: role.isSystem
                                          ? WmsTone.accent
                                          : WmsTone.neutral,
                                      tooltip: role.name,
                                    ),
                                ],
                              ),
                      ),
                      AdminDetailRow(
                        label: l10n.labelLocations,
                        value: data.hasAllLocations
                            ? 'Məhdudiyyət yoxdur — bütün lokasiyalar'
                            : data.locationIds.join(', '),
                      ),
                      AdminDetailRow(
                        label: 'Versiya (rowVersion)',
                        child: Text(
                          '${data.rowVersion}',
                          style: WmsTypography.figure.copyWith(color: c.ink),
                        ),
                      ),
                      if (createdAt != null)
                        AdminDetailRow(
                          label: 'Yaradılıb',
                          value: WmsFormat.dateTime(createdAt),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: WmsSpacing.space4),
                Text(
                  'Rol və lokasiya təyinatı identity API-nin ayrıca '
                  'endpoint-ləri ilə aparılır (SoD yoxlaması serverdədir).',
                  style: WmsTypography.caption.copyWith(color: c.inkMuted),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
