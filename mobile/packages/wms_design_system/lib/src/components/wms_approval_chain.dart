import 'package:flutter/material.dart';
import 'package:wms_core/wms_core.dart';

import '../format/wms_format.dart';
import '../tokens/wms_colors.dart';
import '../tokens/wms_opacity.dart';
import '../tokens/wms_spacing.dart';
import '../tokens/wms_typography.dart';
import 'wms_badge.dart';

/// One `proc_approval_step` row.
@immutable
class WmsApprovalStep {
  const WmsApprovalStep({
    required this.stepNo,
    required this.role,
    this.user,
    this.decision = ApprovalStatus.pending,
    this.decidedAt,
    this.comment,
    this.delegatedFrom,
  });

  final int stepNo;

  /// Role code as stored (`PROCUREMENT_MANAGER`) — shown verbatim on purpose:
  /// the permission model uses the same code.
  final String role;
  final String? user;
  final ApprovalStatus decision;
  final DateTime? decidedAt;
  final String? comment;

  /// Set when someone approved on behalf of another user (`iam_delegation`).
  final String? delegatedFrom;

  bool get isPending => decision == ApprovalStatus.pending;
}

/// `.wms-chain` — the approval trail of a document.
///
/// * every step is shown, including the ones not reached yet (dimmed with
///   `opacity-pending`) — the user must know how many stages remain;
/// * the current step gets a warning-toned clock node;
/// * delegation is spelled out (`Delegasiya: <ad>`), never hidden;
/// * approve/reject buttons live in the document toolbar, not here.
class WmsApprovalChain extends StatelessWidget {
  const WmsApprovalChain({required this.steps, this.currentStep, super.key});

  final List<WmsApprovalStep> steps;

  /// `proc_approval_instance.current_step`; defaults to the first pending one.
  final int? currentStep;

  static const String delegationPrefix = 'Delegasiya: ';

  int? get effectiveCurrentStep {
    if (currentStep != null) return currentStep;
    for (final step in steps) {
      if (step.isPending) return step.stepNo;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final c = WmsColors.of(context);
    final current = effectiveCurrentStep;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < steps.length; i++)
          _Step(
            step: steps[i],
            isCurrent: steps[i].stepNo == current,
            isLast: i == steps.length - 1,
            colors: c,
          ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.step,
    required this.isCurrent,
    required this.isLast,
    required this.colors,
  });

  final WmsApprovalStep step;
  final bool isCurrent;
  final bool isLast;
  final WmsColors colors;

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final (nodeBg, nodeBorder, nodeFg, icon) = switch (step.decision) {
      ApprovalStatus.approved => (
        c.successSoft,
        c.success,
        c.success,
        Icons.check,
      ),
      ApprovalStatus.rejected => (
        c.dangerSoft,
        c.danger,
        c.danger,
        Icons.close,
      ),
      ApprovalStatus.cancelled => (
        c.surfaceSunken,
        c.borderControl,
        c.inkMuted,
        Icons.remove,
      ),
      ApprovalStatus.pending =>
        isCurrent
            ? (c.warningSoft, c.warning, c.warning, Icons.schedule_outlined)
            : (c.surface, c.borderControl, c.inkMuted, null),
    };

    Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(step.role, style: WmsTypography.label.copyWith(color: c.inkMuted)),
        const SizedBox(height: 2),
        Wrap(
          spacing: WmsSpacing.space2,
          runSpacing: WmsSpacing.space1,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              step.user ?? 'Təyin edilməyib',
              style: WmsTypography.bodyStrong.copyWith(color: c.ink),
            ),
            WmsBadge(
              text: _decisionLabel(step.decision, isCurrent: isCurrent),
              tone: switch (step.decision) {
                ApprovalStatus.approved => WmsTone.success,
                ApprovalStatus.rejected => WmsTone.danger,
                ApprovalStatus.cancelled => WmsTone.neutral,
                ApprovalStatus.pending =>
                  isCurrent ? WmsTone.warning : WmsTone.neutral,
              },
              tooltip: step.decision.wire,
            ),
            if (step.decidedAt != null)
              Text(
                WmsFormat.dateTime(step.decidedAt),
                style: WmsTypography.figureSm.copyWith(color: c.inkMuted),
              ),
            if (step.delegatedFrom != null)
              WmsBadge(
                text:
                    '${WmsApprovalChain.delegationPrefix}${step.delegatedFrom}',
                tone: WmsTone.accent,
              ),
          ],
        ),
        if (step.comment != null && step.comment!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: WmsSpacing.space1),
            child: Text(
              step.comment!,
              style: WmsTypography.caption.copyWith(color: c.inkMuted),
            ),
          ),
      ],
    );

    if (step.isPending && !isCurrent) {
      body = Opacity(opacity: WmsOpacity.pending, child: body);
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: nodeBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: nodeBorder),
                  ),
                  alignment: Alignment.center,
                  child: icon != null
                      ? Icon(icon, size: 12, color: nodeFg)
                      : Text(
                          '${step.stepNo}',
                          style: WmsTypography.label.copyWith(color: nodeFg),
                        ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      constraints: const BoxConstraints(
                        minHeight: WmsSpacing.space4,
                      ),
                      color: c.borderControl,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: WmsSpacing.space3),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : WmsSpacing.space4),
              child: body,
            ),
          ),
        ],
      ),
    );
  }

  static String _decisionLabel(
    ApprovalStatus status, {
    required bool isCurrent,
  }) => switch (status) {
    ApprovalStatus.approved => 'Təsdiqlənib',
    ApprovalStatus.rejected => 'Rədd edilib',
    ApprovalStatus.cancelled => 'Ləğv edilib',
    ApprovalStatus.pending => isCurrent ? 'Qərar gözlənilir' : 'Gözləyir',
  };
}
