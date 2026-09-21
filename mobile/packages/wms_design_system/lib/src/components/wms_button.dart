import 'package:flutter/material.dart';

import '../tokens/wms_colors.dart';
import '../tokens/wms_opacity.dart';
import '../tokens/wms_radius.dart';
import '../tokens/wms_spacing.dart';
import '../tokens/wms_typography.dart';
import 'wms_focus_ring.dart';
import 'wms_spinner.dart';

/// `.wms-btn` variants. One `primary` per screen; `danger` only for
/// irreversible / ledger-touching operations.
enum WmsButtonVariant { primary, secondary, ghost, danger }

/// `md` = 34px min height, `sm` = 28px.
enum WmsButtonSize { md, sm }

/// `.wms-btn`. Text is mandatory and imperative («Post et», «Təsdiqlə»).
/// [loading] disables the button and keeps its width (spinner replaces the
/// label in place). A disabled button must explain why via
/// [disabledReason] (shown as tooltip).
class WmsButton extends StatefulWidget {
  const WmsButton({
    required this.label,
    required this.onPressed,
    this.variant = WmsButtonVariant.secondary,
    this.size = WmsButtonSize.md,
    this.loading = false,
    this.enabled = true,
    this.disabledReason,
    this.iconLeft,
    this.autofocus = false,
    super.key,
  });

  const WmsButton.primary({
    required this.label,
    required this.onPressed,
    this.size = WmsButtonSize.md,
    this.loading = false,
    this.enabled = true,
    this.disabledReason,
    this.iconLeft,
    this.autofocus = false,
    super.key,
  }) : variant = WmsButtonVariant.primary;

  const WmsButton.ghost({
    required this.label,
    required this.onPressed,
    this.size = WmsButtonSize.md,
    this.loading = false,
    this.enabled = true,
    this.disabledReason,
    this.iconLeft,
    this.autofocus = false,
    super.key,
  }) : variant = WmsButtonVariant.ghost;

  const WmsButton.danger({
    required this.label,
    required this.onPressed,
    this.size = WmsButtonSize.md,
    this.loading = false,
    this.enabled = true,
    this.disabledReason,
    this.iconLeft,
    this.autofocus = false,
    super.key,
  }) : variant = WmsButtonVariant.danger;

  final String label;
  final VoidCallback? onPressed;
  final WmsButtonVariant variant;
  final WmsButtonSize size;
  final bool loading;
  final bool enabled;
  final String? disabledReason;
  final IconData? iconLeft;
  final bool autofocus;

  bool get isDisabled => !enabled || loading || onPressed == null;

  @override
  State<WmsButton> createState() => _WmsButtonState();
}

class _WmsButtonState extends State<WmsButton> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final c = WmsColors.of(context);
    final disabled = widget.isDisabled;
    final (background, foreground, border) = _palette(
      c,
      hovered: _hovered && !disabled,
    );
    final minHeight = widget.size == WmsButtonSize.md ? 34.0 : 28.0;
    final padding = widget.size == WmsButtonSize.md
        ? const EdgeInsets.symmetric(
            vertical: WmsSpacing.space2,
            horizontal: WmsSpacing.space3,
          )
        : const EdgeInsets.symmetric(
            vertical: WmsSpacing.space1,
            horizontal: WmsSpacing.space2,
          );
    final textStyle = WmsTypography.bodyStrong.copyWith(
      color: foreground,
      fontSize: widget.size == WmsButtonSize.md ? 14 : 13,
    );

    final label = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.iconLeft != null) ...[
          Icon(widget.iconLeft, size: 16, color: foreground),
          const SizedBox(width: WmsSpacing.space1),
        ],
        Text(widget.label, style: textStyle),
      ],
    );

    Widget content = Stack(
      alignment: Alignment.center,
      children: [
        // Keeps the width stable while loading.
        Opacity(opacity: widget.loading ? 0 : 1, child: label),
        if (widget.loading) WmsSpinner(color: foreground),
      ],
    );

    content = Container(
      constraints: BoxConstraints(minHeight: minHeight),
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: WmsRadius.mdAll,
        border: Border.all(color: border),
      ),
      alignment: Alignment.center,
      child: content,
    );

    Widget button = Semantics(
      button: true,
      enabled: !disabled,
      label: widget.label,
      child: FocusableActionDetector(
        enabled: !disabled,
        autofocus: widget.autofocus,
        mouseCursor: disabled
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.click,
        onShowHoverHighlight: (v) => setState(() => _hovered = v),
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onPressed?.call();
              return null;
            },
          ),
        },
        child: GestureDetector(
          onTap: disabled ? null : widget.onPressed,
          behavior: HitTestBehavior.opaque,
          child: WmsFocusRing(focused: _focused, child: content),
        ),
      ),
    );

    if (disabled) {
      button = Opacity(opacity: WmsOpacity.disabled, child: button);
      final reason = widget.disabledReason;
      if (reason != null && reason.isNotEmpty && !widget.loading) {
        button = Tooltip(message: reason, child: button);
      }
    }
    return button;
  }

  (Color, Color, Color) _palette(WmsColors c, {required bool hovered}) =>
      switch (widget.variant) {
        WmsButtonVariant.primary => (
          hovered ? c.accentHover : c.accent,
          c.onAccent,
          Colors.transparent,
        ),
        WmsButtonVariant.secondary => (
          hovered ? c.rowHover : c.surface,
          c.ink,
          c.borderControl,
        ),
        WmsButtonVariant.ghost => (
          hovered ? c.accentSoft : Colors.transparent,
          c.accent,
          Colors.transparent,
        ),
        WmsButtonVariant.danger => (
          hovered ? c.dangerHover : c.danger,
          c.onDanger,
          Colors.transparent,
        ),
      };
}
