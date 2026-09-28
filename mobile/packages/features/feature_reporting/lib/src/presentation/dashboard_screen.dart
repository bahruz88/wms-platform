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
            /*
             * The server answers with a list of KPIs, not a fixed set of counters: which figures a
             * caller gets depends on their permissions, and a cost figure is left out entirely
             * rather than nulled (spec §16). So the cards are built from whatever arrived, and a
             * KPI the caller was not given simply has no card — nothing here invents a zero.
             */
            // The server already leaves cost KPIs out without `master.product.view_cost`. The
            // client filters them too: defence in depth, and the only thing standing between a
            // stale cache and a cost figure on a keeper's screen (design system «Qiymət icazəyə
            // bağlıdır», SPEC §16).
            final cards = <Widget>[
              for (final kpi in data.kpis.where((k) => canViewCost || !k.isCost))
                WmsKpiCard(
                  label: kpi.label,
                  value: kpi.amount?.amount ?? Decimal.zero,
                  decimals: kpi.decimals,
                  unit: kpi.unit,
                  hint: kpi.previousValue == null
                      ? null
                      : 'əvvəlki dövr: ${kpi.previousValue}',
                ),
            ];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // The server withholds cost KPIs rather than nulling them, so without the permission
                // the panel is simply shorter. Saying so beats letting a shorter panel look broken.
                // The alerts come composed by the server, which is the only side that knows the
                // tenant's thresholds — `expiry_warning_days`, `reorder_point`. The screen used to
                // build this text itself out of two KPI counters and so could not say «103 partiya
                // 30 gün içində» without guessing the window.
                if (data.alerts.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: WmsSpacing.space3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final alert in data.alerts)
                          Padding(
                            padding: const EdgeInsets.only(bottom: WmsSpacing.space2),
                            child: Row(
                              children: [
                                WmsBadge(
                                  text: alert.count > 0
                                      ? alert.count.toString()
                                      : alert.severity,
                                  tone: alert.severity == 'CRITICAL'
                                      ? WmsTone.danger
                                      : WmsTone.warning,
                                ),
                                const SizedBox(width: WmsSpacing.space2),
                                Expanded(
                                  child: Text(
                                    alert.title,
                                    style: WmsTypography.body.copyWith(color: c.ink),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                if (!canViewCost)
                  Padding(
                    padding: const EdgeInsets.only(bottom: WmsSpacing.space3),
                    child: Text(
                      'Maya və dəyər göstəriciləri sizin icazənizə bağlıdır və göstərilmir.',
                      style: WmsTypography.caption.copyWith(color: c.inkMuted),
                    ),
                  ),
                Text(
                  'Göstəricilər ${WmsFormat.dateTime(data.generatedAt)} tarixinə',
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
