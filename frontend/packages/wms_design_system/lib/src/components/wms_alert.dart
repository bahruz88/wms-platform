import 'package:flutter/material.dart';
import 'package:wms_core/wms_core.dart';

import '../tokens/wms_colors.dart';
import '../tokens/wms_radius.dart';
import '../tokens/wms_spacing.dart';
import '../tokens/wms_typography.dart';
import 'wms_icon_button.dart';

enum WmsAlertTone { info, success, warning, danger }

/// `.wms-alert` — document-level message. RFC 7807 responses are copied
/// verbatim: `title` → title, `detail` → body, `code`/`traceId` small and
/// muted but never hidden (support works with the code). `danger` is
/// announced as a live region.
class WmsAlert extends StatelessWidget {
  const WmsAlert({
    this.tone = WmsAlertTone.info,
    this.title,
    this.message,
    this.child,
    this.code,
    this.traceId,
    this.onClose,
    super.key,
  });

  /// Builds a `danger` alert from a server problem, verbatim.
  factory WmsAlert.fromProblem(
    ProblemDetails problem, {
    WmsAlertTone tone = WmsAlertTone.danger,
    VoidCallback? onClose,
    Key? key,
  }) => WmsAlert(
    tone: tone,
    title: problem.title ?? problem.code ?? 'Xəta',
    message: problem.detail,
    code: problem.code,
    traceId: problem.traceId,
    onClose: onClose,
    key: key,
  );

  /// Maps any [Failure] to an alert (network failures get a generic title).
  factory WmsAlert.fromFailure(
    Failure failure, {
    VoidCallback? onClose,
    Key? key,
  }) => switch (failure) {
    ServerFailure(:final problem) => WmsAlert.fromProblem(
      problem,
      onClose: onClose,
      key: key,
    ),
    NetworkFailure(:final isTimeout) => WmsAlert(
      tone: WmsAlertTone.danger,
      title: isTimeout ? 'Server cavab vermədi' : 'Şəbəkə xətası',
      message: 'Bağlantını yoxlayın və yenidən cəhd edin.',
      code: isTimeout ? ProblemCodes.timeout : ProblemCodes.network,
      onClose: onClose,
      key: key,
    ),
    CancelledFailure() => WmsAlert(
      tone: WmsAlertTone.warning,
      title: 'Sorğu ləğv edildi',
      code: ProblemCodes.cancelled,
      onClose: onClose,
      key: key,
    ),
    UnexpectedFailure(:final message) => WmsAlert(
      tone: WmsAlertTone.danger,
      title: 'Gözlənilməz xəta',
      message: message,
      code: ProblemCodes.unexpected,
      onClose: onClose,
      key: key,
    ),
  };

  final WmsAlertTone tone;
  final String? title;
  final String? message;
  final Widget? child;
  final String? code;
  final String? traceId;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final c = WmsColors.of(context);
    final (background, foreground, icon) = switch (tone) {
      WmsAlertTone.info => (c.accentSoft, c.accent, Icons.info_outline),
      WmsAlertTone.success => (
        c.successSoft,
        c.success,
        Icons.check_circle_outline,
      ),
      WmsAlertTone.warning => (
        c.warningSoft,
        c.warning,
        Icons.warning_amber_outlined,
      ),
      WmsAlertTone.danger => (c.dangerSoft, c.danger, Icons.error_outline),
    };
    final codeLine = [
      if (code != null && code!.isNotEmpty) code!,
      if (traceId != null && traceId!.isNotEmpty) 'trace $traceId',
    ].join(' · ');

    final body = Container(
      padding: const EdgeInsets.symmetric(
        vertical: WmsSpacing.space3,
        horizontal: WmsSpacing.space4,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: WmsRadius.mdAll,
        border: Border.all(color: foreground),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 16, color: foreground),
          ),
          const SizedBox(width: WmsSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: WmsTypography.bodyStrong.copyWith(color: foreground),
                  ),
                if (message != null && message!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: WmsSpacing.space1),
                    child: Text(
                      message!,
                      style: WmsTypography.body.copyWith(color: c.ink),
                    ),
                  ),
                if (child != null)
                  Padding(
                    padding: const EdgeInsets.only(top: WmsSpacing.space1),
                    child: DefaultTextStyle(
                      style: WmsTypography.body.copyWith(color: c.ink),
                      child: child!,
                    ),
                  ),
                if (codeLine.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: WmsSpacing.space2),
                    child: Text(
                      codeLine,
                      style: WmsTypography.figureSm.copyWith(color: c.inkMuted),
                    ),
                  ),
              ],
            ),
          ),
          if (onClose != null) ...[
            const SizedBox(width: WmsSpacing.space2),
            WmsIconButton(
              icon: Icons.close,
              label: 'Bağla',
              onPressed: onClose,
            ),
          ],
        ],
      ),
    );
    return Semantics(
      liveRegion: tone == WmsAlertTone.danger,
      container: true,
      child: body,
    );
  }
}
