import 'package:flutter/material.dart';

import '../tokens/wms_colors.dart';
import '../tokens/wms_radius.dart';
import '../tokens/wms_shadows.dart';
import '../tokens/wms_spacing.dart';
import '../tokens/wms_typography.dart';
import 'wms_button.dart';
import 'wms_icon_button.dart';

enum WmsDialogSize {
  /// `max-width: 520px`.
  md,

  /// `max-width: 760px` — only for tables or two-column content.
  lg,
}

/// `.wms-dialog` — confirmation, mandatory reason, small form. Multi-line
/// document editing belongs on its own page, not in a modal.
///
/// Footer order: confirm on the right, cancel to its left. A destructive
/// confirm is `danger` and stays disabled until the required field is
/// filled. Never open a modal on top of a modal.
class WmsDialog extends StatelessWidget {
  const WmsDialog({
    required this.title,
    required this.child,
    this.subtitle,
    this.size = WmsDialogSize.md,
    this.onClose,
    this.actions = const [],
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final WmsDialogSize size;

  /// When null the dialog can only be dismissed through the footer buttons
  /// (use that when there is a risk of losing entered data).
  final VoidCallback? onClose;

  /// Footer buttons, left to right; put the confirm action last.
  final List<Widget> actions;

  double get maxWidth => size == WmsDialogSize.md ? 520 : 760;

  /// Shows [dialog] with the design system scrim. Never call this while
  /// another dialog is open — no modal on top of a modal.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget dialog,
    bool barrierDismissible = true,
  }) => showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: WmsColors.of(context).scrim,
    builder: (_) => dialog,
  );

  @override
  Widget build(BuildContext context) {
    final c = WmsColors.of(context);
    final shadows = WmsShadows.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
        vertical: WmsSpacing.space6,
        horizontal: WmsSpacing.space4,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: c.surfaceRaised,
            borderRadius: WmsRadius.lgAll,
            border: Border.all(color: c.border),
            boxShadow: shadows.overlay,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  WmsSpacing.space5,
                  WmsSpacing.space5,
                  WmsSpacing.space5,
                  WmsSpacing.space3,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: WmsTypography.titleLg.copyWith(color: c.ink),
                          ),
                          if (subtitle != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: WmsSpacing.space1,
                              ),
                              child: Text(
                                subtitle!,
                                style: WmsTypography.caption.copyWith(
                                  color: c.inkMuted,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (onClose != null) ...[
                      const SizedBox(width: WmsSpacing.space3),
                      WmsIconButton(
                        icon: Icons.close,
                        label: 'Bağla',
                        onPressed: onClose,
                      ),
                    ],
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    WmsSpacing.space5,
                    0,
                    WmsSpacing.space5,
                    WmsSpacing.space5,
                  ),
                  child: DefaultTextStyle(
                    style: WmsTypography.body.copyWith(color: c.ink),
                    child: child,
                  ),
                ),
              ),
              if (actions.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: WmsSpacing.space3,
                    horizontal: WmsSpacing.space5,
                  ),
                  decoration: BoxDecoration(
                    color: c.surfaceSunken,
                    border: Border(top: BorderSide(color: c.border)),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(WmsRadius.lg),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      for (var i = 0; i < actions.length; i++) ...[
                        if (i > 0) const SizedBox(width: WmsSpacing.space2),
                        actions[i],
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Confirmation dialog. The confirm button carries the operation name
/// («Storno et»), never «OK», and stays disabled while [confirmEnabled] is
/// false (e.g. a mandatory reason has not been filled in).
class WmsConfirmDialog extends StatelessWidget {
  const WmsConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.cancelLabel = 'İmtina',
    this.destructive = false,
    this.confirmEnabled = true,
    this.disabledReason,
    this.child,
    this.onConfirm,
    super.key,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool destructive;
  final bool confirmEnabled;
  final String? disabledReason;

  /// Extra content, e.g. the mandatory reason field.
  final Widget? child;
  final VoidCallback? onConfirm;

  /// Returns `true` when the user confirmed.
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmLabel,
    String cancelLabel = 'İmtina',
    bool destructive = false,
  }) async {
    final result = await WmsDialog.show<bool>(
      context: context,
      dialog: WmsConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        destructive: destructive,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final c = WmsColors.of(context);
    return WmsDialog(
      title: title,
      onClose: () => Navigator.of(context).pop(false),
      actions: [
        WmsButton(
          label: cancelLabel,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        WmsButton(
          label: confirmLabel,
          variant: destructive
              ? WmsButtonVariant.danger
              : WmsButtonVariant.primary,
          enabled: confirmEnabled,
          disabledReason: disabledReason,
          onPressed: () {
            onConfirm?.call();
            Navigator.of(context).pop(true);
          },
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: WmsTypography.body.copyWith(color: c.ink)),
          if (child != null) ...[
            const SizedBox(height: WmsSpacing.space4),
            child!,
          ],
        ],
      ),
    );
  }
}
