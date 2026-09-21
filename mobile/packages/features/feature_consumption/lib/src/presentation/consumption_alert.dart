import 'package:flutter/material.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import '../domain/consumption_problem_hints.dart';

/// Every server error of this feature goes through here, which means it
/// goes through [WmsAlert] with the RFC 7807 `code` visible.
///
/// For the codes this module owns (`RECIPE_CYCLE`, `RECIPE_DEPTH_EXCEEDED`,
/// `RECIPE_EMPTY`, `PERIOD_CLOSED`, …) a «what now» line is added under the
/// server's own message; the server text itself is never rewritten.
class ConsumptionAlert extends StatelessWidget {
  const ConsumptionAlert({required this.failure, this.onClose, super.key});

  final Failure failure;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final problem = problemOf(failure);
    final hint = consumptionProblemHint(problem?.code, l10n);
    if (problem == null || hint == null) {
      return WmsAlert.fromFailure(failure, onClose: onClose);
    }
    return WmsAlert(
      tone: WmsAlertTone.danger,
      title: problem.title ?? problem.code,
      message: problem.detail,
      code: problem.code,
      traceId: problem.traceId,
      onClose: onClose,
      child: Text(hint),
    );
  }
}
