import 'package:feature_master_data/feature_master_data.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import 'notifications_providers.dart';

/// In-app notification list with an unread filter.
class NotificationListScreen extends ConsumerWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final notifications = ref.watch(notificationListProvider);
    final unreadOnly = ref.watch(unreadOnlyProvider);
    final unread = ref.watch(unreadBadgeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navNotifications),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: WmsSpacing.space3),
            child: Row(
              children: [
                if (unread > 0)
                  WmsBadge(
                    text: l10n.labelUnreadCount(unread),
                    tone: WmsTone.danger,
                    variant: WmsBadgeVariant.solid,
                  ),
                const SizedBox(width: WmsSpacing.space2),
                WmsButton(
                  label: unreadOnly ? l10n.labelAll : l10n.labelUnread,
                  size: WmsButtonSize.sm,
                  onPressed: () =>
                      ref.read(unreadOnlyProvider.notifier).toggle(),
                ),
                const SizedBox(width: WmsSpacing.space2),
                WmsButton(
                  label: 'Hamısını oxunmuş et',
                  size: WmsButtonSize.sm,
                  enabled: unread > 0,
                  disabledReason: 'Oxunmamış bildiriş yoxdur',
                  onPressed: () =>
                      ref.read(notificationListProvider.notifier).markAllRead(),
                ),
              ],
            ),
          ),
        ],
      ),
      body: AsyncView<Page<NotificationDto>>(
        value: notifications,
        onRetry: () => ref.invalidate(notificationListProvider),
        builder: (page) {
          if (page.items.isEmpty) {
            return WmsEmptyState(
              reason: l10n.emptyNotifications,
              nextStep: 'Yeni hadisə olduqda burada görünəcək.',
              icon: Icons.notifications_none_outlined,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(WmsSpacing.space4),
            itemCount: page.items.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: WmsSpacing.space2),
            itemBuilder: (context, index) {
              final item = page.items[index];
              return InkWell(
                onTap: item.isRead
                    ? null
                    : () => ref
                          .read(notificationListProvider.notifier)
                          .markRead(item.id),
                borderRadius: WmsRadius.lgAll,
                child: Container(
                  padding: WmsSpacing.cardPadding,
                  decoration: BoxDecoration(
                    color: item.isRead ? c.surface : c.accentSoft,
                    borderRadius: WmsRadius.lgAll,
                    border: Border.all(color: c.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        item.isRead
                            ? Icons.notifications_none_outlined
                            : Icons.notifications_active_outlined,
                        size: 16,
                        color: item.isRead ? c.inkMuted : c.accent,
                      ),
                      const SizedBox(width: WmsSpacing.space3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: WmsTypography.bodyStrong.copyWith(
                                      color: c.ink,
                                    ),
                                  ),
                                ),
                                if (item.docType != null)
                                  WmsBadge(text: item.docType!),
                              ],
                            ),
                            if (item.body != null) ...[
                              const SizedBox(height: WmsSpacing.space1),
                              Text(
                                item.body!,
                                style: WmsTypography.body.copyWith(
                                  color: c.ink,
                                ),
                              ),
                            ],
                            const SizedBox(height: WmsSpacing.space1),
                            Text(
                              WmsFormat.dateTime(item.createdAt),
                              style: WmsTypography.figureSm.copyWith(
                                color: c.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
