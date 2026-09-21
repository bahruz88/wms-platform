import 'package:feature_identity/feature_identity.dart';
import 'package:feature_master_data/feature_master_data.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import '../consumption_providers.dart';
import '../run_detail_view.dart';

/// «İstehlak nəticəsi» — yesterday's calculated consumption for the branch.
///
/// Per product: what the recipes said should have been used (theoretical)
/// against what could actually be taken off the balance (posted). A gap is
/// a **warning, not an error** — the stock ran out, which almost always
/// means a goods receipt was never recorded. The screen says exactly that
/// instead of showing a red number and leaving the branch to guess.
class ConsumptionResultScreen extends ConsumerWidget {
  const ConsumptionResultScreen({this.businessDate, super.key});

  /// Defaults to yesterday: `ConsumptionRunner` posts the previous working
  /// day at 03:00.
  final DateTime? businessDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final date = businessDate ?? yesterdayDate();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.consResult)),
      body: RequirePermission.withNotice(
        permission: Permissions.runCalculate,
        child: _Body(date: date),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locationId = ref.watch(branchLocationIdProvider);
    if (locationId == null) {
      return const WmsEmptyState(
        reason: 'Hesabınıza filial təyin edilməyib.',
        nextStep: 'Administratordan lokasiya bağlanmasını istəyin.',
        icon: Icons.store_outlined,
      );
    }
    final head = ref.watch(branchRunOfDayProvider(date));
    return AsyncView<ConsumptionRunDto?>(
      value: head,
      onRetry: () => ref.invalidate(branchRunOfDayProvider(date)),
      builder: (run) => run == null
          ? WmsEmptyState(
              reason: '${WmsFormat.date(date)} — ${l10n.consEmptyResultReason}',
              nextStep: l10n.consEmptyResultNext,
              icon: Icons.calculate_outlined,
            )
          : ConsumptionRunDetailView(runId: run.id),
    );
  }
}
