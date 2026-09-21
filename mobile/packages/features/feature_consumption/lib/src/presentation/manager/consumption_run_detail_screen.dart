import 'package:feature_identity/feature_identity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_l10n/wms_l10n.dart';

import '../run_detail_view.dart';

/// One consumption document opened from «İstehlak jurnalı».
///
/// Read only on purpose: a posted document is never edited, the correction
/// is a reversal, and that action lives in the journal next to its
/// permission gate.
class ConsumptionRunDetailScreen extends ConsumerWidget {
  const ConsumptionRunDetailScreen({required this.runId, super.key});

  final int runId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.consJournal)),
      body: RequirePermission.withNotice(
        permission: Permissions.runCalculate,
        child: ConsumptionRunDetailView(runId: runId),
      ),
    );
  }
}
