import 'package:flutter/material.dart';

import '../tokens/wms_colors.dart';
import '../tokens/wms_radius.dart';
import '../tokens/wms_spacing.dart';
import 'wms_focus_ring.dart';

/// `.wms-iconbtn` — compact icon-only action. [label] is mandatory because
/// an icon alone must carry a semantic label.
class WmsIconButton extends StatefulWidget {
  const WmsIconButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.size = 16,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final double size;

  @override
  State<WmsIconButton> createState() => _WmsIconButtonState();
}

class _WmsIconButtonState extends State<WmsIconButton> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final c = WmsColors.of(context);
    final enabled = widget.onPressed != null;
    return Semantics(
      button: true,
      label: widget.label,
      enabled: enabled,
      child: Tooltip(
        message: widget.label,
        child: FocusableActionDetector(
          enabled: enabled,
          mouseCursor: SystemMouseCursors.click,
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
            onTap: widget.onPressed,
            behavior: HitTestBehavior.opaque,
            child: WmsFocusRing(
              focused: _focused,
              borderRadius: WmsRadius.smAll,
              child: Container(
                padding: const EdgeInsets.all(WmsSpacing.space1),
                decoration: BoxDecoration(
                  color: _hovered ? c.rowHover : Colors.transparent,
                  borderRadius: WmsRadius.smAll,
                ),
                child: Icon(
                  widget.icon,
                  size: widget.size,
                  color: _hovered ? c.ink : c.inkMuted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
