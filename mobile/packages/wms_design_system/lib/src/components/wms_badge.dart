import 'package:flutter/material.dart';

import '../tokens/wms_colors.dart';
import '../tokens/wms_radius.dart';
import '../tokens/wms_spacing.dart';

/// Badge/alert tones. `virtual` is reserved for virtual locations.
enum WmsTone { neutral, accent, success, warning, danger, virtual }

enum WmsBadgeVariant { soft, solid, outline }

/// `.wms-badge`. Text is mandatory — colour alone carries no meaning; the
/// [dot] only accompanies the text. Not clickable.
class WmsBadge extends StatelessWidget {
  const WmsBadge({
    required this.text,
    this.tone = WmsTone.neutral,
    this.variant = WmsBadgeVariant.soft,
    this.dot = false,
    this.icon,
    this.tooltip,
    super.key,
  });

  final String text;
  final WmsTone tone;
  final WmsBadgeVariant variant;
  final bool dot;
  final IconData? icon;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final c = WmsColors.of(context);
    final (background, foreground, border) = _palette(c);
    final style = TextStyle(
      fontSize: 12,
      height: 18 / 12,
      fontWeight: FontWeight.w600,
      color: foreground,
    );
    Widget badge = Container(
      padding: const EdgeInsets.symmetric(
        vertical: 1,
        horizontal: WmsSpacing.space2,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: WmsRadius.smAll,
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: foreground,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: WmsSpacing.space1),
          ],
          if (icon != null) ...[
            Icon(icon, size: 12, color: foreground),
            const SizedBox(width: WmsSpacing.space1),
          ],
          // `white-space: nowrap` in CSS; inside a narrow table cell the
          // label fades instead of overflowing the row.
          Flexible(
            child: Text(
              text,
              style: style,
              softWrap: false,
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
    );
    if (tooltip != null && tooltip!.isNotEmpty) {
      badge = Tooltip(message: tooltip, child: badge);
    }
    return badge;
  }

  (Color, Color, Color) _palette(WmsColors c) {
    final (soft, fg) = switch (tone) {
      WmsTone.neutral => (c.surfaceSunken, c.inkMuted),
      WmsTone.accent => (c.accentSoft, c.accent),
      WmsTone.success => (c.successSoft, c.success),
      WmsTone.warning => (c.warningSoft, c.warning),
      WmsTone.danger => (c.dangerSoft, c.danger),
      WmsTone.virtual => (c.virtualLocationSoft, c.virtualLocation),
    };
    switch (variant) {
      case WmsBadgeVariant.soft:
        return (
          soft,
          fg,
          tone == WmsTone.neutral ? c.border : Colors.transparent,
        );
      case WmsBadgeVariant.solid:
        return switch (tone) {
          WmsTone.accent => (c.accent, c.onAccent, Colors.transparent),
          WmsTone.danger => (c.danger, c.onDanger, Colors.transparent),
          WmsTone.neutral => (c.inkMuted, c.inkInverse, Colors.transparent),
          _ => (fg, c.inkInverse, Colors.transparent),
        };
      case WmsBadgeVariant.outline:
        return (Colors.transparent, fg, fg);
    }
  }
}
