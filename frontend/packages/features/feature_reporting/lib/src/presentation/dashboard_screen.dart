import 'package:decimal/decimal.dart';
import 'package:feature_master_data/feature_master_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import 'reporting_providers.dart';

/// Dashboard cards: stock value (permission gated), expiring batches, low
/// stock and pending approvals.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final dashboard = ref.watch(dashboardProvider);
    final canViewCost = ref.watch(
      hasPermissionProvider(Permissions.productViewCost),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navDashboard)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(WmsSpacing.space4),
        child: AsyncView<DashboardSummaryDto>(
          value: dashboard,
          onRetry: () => ref.invalidate(dashboardProvider),
          builder: (data) {
            final stockValueCard = WmsKpiCard.permitted(
              hasPermission: canViewCost && data.stockValue != null,
              build: () => WmsKpiCard(
                label: 'Anbar dəyəri',
                value: WmsFormat.number(data.stockValue?.amount, decimals: 2),
                unit: data.stockValue?.currency ?? 'AZN',
                hint: WmsFormat.dateTime(data.asOf),
              ),
            );
            final cards = <Widget>[
              ?stockValueCard,
              WmsKpiCard(
                label: 'Vaxtı yaxınlaşan partiyalar',
                value: Decimal.fromInt(data.expiringBatches),
                badge: data.expiredBatches > 0
                    ? WmsBadge(
                        text: '${data.expiredBatches} vaxtı keçib',
                        tone: WmsTone.danger,
                      )
                    : null,
                hint: 'expiry_warning_days ərzində',
              ),
              WmsKpiCard(
                label: 'Aşağı qalıq',
                value: Decimal.fromInt(data.lowStockProducts),
                hint: 'reorder_point-dən aşağı məhsullar',
              ),
              WmsKpiCard(
                label: 'Təsdiq gözləyənlər',
                value: Decimal.fromInt(data.pendingApprovals),
                hint: 'PO, tullantı və sayım düzəlişləri',
              ),
              WmsKpiCard(
                label: 'Açıq sifarişlər',
                value: Decimal.fromInt(data.openPurchaseOrders),
                hint: 'Tam qəbul edilməmiş PO-lar',
              ),
              WmsKpiCard(
                label: 'Yolda olan sənədlər',
                value: Decimal.fromInt(data.inTransitIssues),
                hint: 'IN_TRANSIT — filial təsdiqi gözlənilir',
              ),
            ];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Göstəricilər ${WmsFormat.dateTime(data.asOf)} tarixinə',
                  style: WmsTypography.caption.copyWith(color: c.inkMuted),
                ),
                const SizedBox(height: WmsSpacing.space4),
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Max four cards per row (design system rule).
                    final columns = constraints.maxWidth >= 1200
                        ? 4
                        : (constraints.maxWidth >= 860
                              ? 3
                              : (constraints.maxWidth >= 560 ? 2 : 1));
                    const gap = WmsSpacing.space4;
                    final width =
                        (constraints.maxWidth - gap * (columns - 1)) / columns;
                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        for (final card in cards)
                          SizedBox(width: width, child: card),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
