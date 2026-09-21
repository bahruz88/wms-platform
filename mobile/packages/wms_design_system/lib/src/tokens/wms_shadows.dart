import 'package:flutter/material.dart';

/// Shadows (`tokens.json` → `shadow`). Only for overlays: cards and tables
/// are separated by borders, never by shadows.
@immutable
class WmsShadows extends ThemeExtension<WmsShadows> {
  const WmsShadows({required this.sm, required this.md, required this.overlay});

  /// `0 1px 2px rgba(16,24,32,0.08)` etc.
  static const WmsShadows light = WmsShadows(
    sm: [
      BoxShadow(
        offset: Offset(0, 1),
        blurRadius: 2,
        color: Color.fromRGBO(16, 24, 32, 0.08),
      ),
    ],
    md: [
      BoxShadow(
        offset: Offset(0, 4),
        blurRadius: 12,
        color: Color.fromRGBO(16, 24, 32, 0.10),
      ),
    ],
    overlay: [
      BoxShadow(
        offset: Offset(0, 16),
        blurRadius: 40,
        color: Color.fromRGBO(16, 24, 32, 0.18),
      ),
    ],
  );

  static const WmsShadows dark = WmsShadows(
    sm: [
      BoxShadow(
        offset: Offset(0, 1),
        blurRadius: 2,
        color: Color.fromRGBO(0, 0, 0, 0.55),
      ),
    ],
    md: [
      BoxShadow(
        offset: Offset(0, 4),
        blurRadius: 12,
        color: Color.fromRGBO(0, 0, 0, 0.6),
      ),
    ],
    overlay: [
      BoxShadow(
        offset: Offset(0, 16),
        blurRadius: 40,
        color: Color.fromRGBO(0, 0, 0, 0.7),
      ),
    ],
  );

  /// Sticky table header and toolbar.
  final List<BoxShadow> sm;

  /// Dropdown, popover, autocomplete list.
  final List<BoxShadow> md;

  /// Modal window.
  final List<BoxShadow> overlay;

  static WmsShadows of(BuildContext context) =>
      Theme.of(context).extension<WmsShadows>() ??
      (Theme.of(context).brightness == Brightness.dark ? dark : light);

  Map<String, List<BoxShadow>> get tokenMap => {
    'shadow-sm': sm,
    'shadow-md': md,
    'shadow-overlay': overlay,
  };

  @override
  WmsShadows copyWith({
    List<BoxShadow>? sm,
    List<BoxShadow>? md,
    List<BoxShadow>? overlay,
  }) => WmsShadows(
    sm: sm ?? this.sm,
    md: md ?? this.md,
    overlay: overlay ?? this.overlay,
  );

  @override
  WmsShadows lerp(ThemeExtension<WmsShadows>? other, double t) {
    if (other is! WmsShadows) return this;
    return WmsShadows(
      sm: BoxShadow.lerpList(sm, other.sm, t) ?? sm,
      md: BoxShadow.lerpList(md, other.md, t) ?? md,
      overlay: BoxShadow.lerpList(overlay, other.overlay, t) ?? overlay,
    );
  }
}
