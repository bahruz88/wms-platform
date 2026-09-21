import 'package:flutter/material.dart';

/// Colour tokens of the design system (`tokens.json` → `color.tokens`),
/// exposed as a [ThemeExtension] because several of them (`ledgerIn`,
/// `virtualLocation`, `rowHover`, `surfaceSunken`, `inkMuted`...) have no
/// slot in [ColorScheme].
///
/// Read with `WmsColors.of(context)`.
@immutable
class WmsColors extends ThemeExtension<WmsColors> {
  const WmsColors({
    required this.surfaceCanvas,
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.rowHover,
    required this.scrim,
    required this.border,
    required this.borderControl,
    required this.ink,
    required this.inkMuted,
    required this.inkSubtle,
    required this.inkInverse,
    required this.accent,
    required this.accentHover,
    required this.accentSoft,
    required this.onAccent,
    required this.focusRing,
    required this.success,
    required this.successSoft,
    required this.warning,
    required this.warningSoft,
    required this.danger,
    required this.dangerHover,
    required this.dangerSoft,
    required this.onDanger,
    required this.ledgerIn,
    required this.ledgerOut,
    required this.virtualLocation,
    required this.virtualLocationSoft,
  });

  /// `light` theme values, copied literally from `tokens.json`.
  static const WmsColors light = WmsColors(
    surfaceCanvas: Color(0xFFF6F7F9),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFFFFFFF),
    surfaceSunken: Color(0xFFF1F3F5),
    rowHover: Color(0xFFF1F4F8),
    scrim: Color.fromRGBO(15, 18, 20, 0.55),
    border: Color(0xFFDDE1E6),
    borderControl: Color(0xFF7F878F),
    ink: Color(0xFF16191C),
    inkMuted: Color(0xFF5A636D),
    inkSubtle: Color(0xFF6E7781),
    inkInverse: Color(0xFFFFFFFF),
    accent: Color(0xFF1A5FD0),
    accentHover: Color(0xFF164FB0),
    accentSoft: Color(0xFFE8F0FE),
    onAccent: Color(0xFFFFFFFF),
    focusRing: Color(0xFF1A5FD0),
    success: Color(0xFF146C43),
    successSoft: Color(0xFFE3F2EA),
    warning: Color(0xFF8A5A00),
    warningSoft: Color(0xFFFBF0D9),
    danger: Color(0xFFB3261E),
    dangerHover: Color(0xFF96201A),
    dangerSoft: Color(0xFFFDECEB),
    onDanger: Color(0xFFFFFFFF),
    // ledger-in / ledger-out are aliases of success / danger.
    ledgerIn: Color(0xFF146C43),
    ledgerOut: Color(0xFFB3261E),
    virtualLocation: Color(0xFF6B4BAB),
    virtualLocationSoft: Color(0xFFF0EBFB),
  );

  /// `dark` theme values, copied literally from `tokens.json`.
  static const WmsColors dark = WmsColors(
    surfaceCanvas: Color(0xFF0F1214),
    surface: Color(0xFF171B1E),
    surfaceRaised: Color(0xFF1E2327),
    surfaceSunken: Color(0xFF0B0E10),
    rowHover: Color(0xFF1C2226),
    scrim: Color.fromRGBO(0, 0, 0, 0.65),
    border: Color(0xFF2B3237),
    borderControl: Color(0xFF6B757E),
    ink: Color(0xFFEEF1F4),
    inkMuted: Color(0xFFA3ADB8),
    inkSubtle: Color(0xFF8B959F),
    inkInverse: Color(0xFF0B0E10),
    accent: Color(0xFF4C8DFF),
    accentHover: Color(0xFF6BA0FF),
    accentSoft: Color(0xFF17243C),
    onAccent: Color(0xFF0B1220),
    focusRing: Color(0xFF7AA7FF),
    success: Color(0xFF3FB27F),
    successSoft: Color(0xFF10291F),
    warning: Color(0xFFE0A740),
    warningSoft: Color(0xFF2E2312),
    danger: Color(0xFFFF6B5E),
    dangerHover: Color(0xFFFF8478),
    dangerSoft: Color(0xFF331715),
    onDanger: Color(0xFF1A0B09),
    ledgerIn: Color(0xFF3FB27F),
    ledgerOut: Color(0xFFFF6B5E),
    virtualLocation: Color(0xFFB49CF0),
    virtualLocationSoft: Color(0xFF231A36),
  );

  final Color surfaceCanvas;
  final Color surface;
  final Color surfaceRaised;
  final Color surfaceSunken;
  final Color rowHover;
  final Color scrim;
  final Color border;
  final Color borderControl;
  final Color ink;
  final Color inkMuted;
  final Color inkSubtle;
  final Color inkInverse;
  final Color accent;
  final Color accentHover;
  final Color accentSoft;
  final Color onAccent;
  final Color focusRing;
  final Color success;
  final Color successSoft;
  final Color warning;
  final Color warningSoft;
  final Color danger;
  final Color dangerHover;
  final Color dangerSoft;
  final Color onDanger;
  final Color ledgerIn;
  final Color ledgerOut;
  final Color virtualLocation;
  final Color virtualLocationSoft;

  static WmsColors of(BuildContext context) =>
      Theme.of(context).extension<WmsColors>() ??
      (Theme.of(context).brightness == Brightness.dark ? dark : light);

  /// Token name → colour, used by tests to diff against `tokens.json`.
  Map<String, Color> get tokenMap => {
    'surface-canvas': surfaceCanvas,
    'surface': surface,
    'surface-raised': surfaceRaised,
    'surface-sunken': surfaceSunken,
    'row-hover': rowHover,
    'scrim': scrim,
    'border': border,
    'border-control': borderControl,
    'ink': ink,
    'ink-muted': inkMuted,
    'ink-subtle': inkSubtle,
    'ink-inverse': inkInverse,
    'accent': accent,
    'accent-hover': accentHover,
    'accent-soft': accentSoft,
    'on-accent': onAccent,
    'focus-ring': focusRing,
    'success': success,
    'success-soft': successSoft,
    'warning': warning,
    'warning-soft': warningSoft,
    'danger': danger,
    'danger-hover': dangerHover,
    'danger-soft': dangerSoft,
    'on-danger': onDanger,
    'ledger-in': ledgerIn,
    'ledger-out': ledgerOut,
    'virtual-location': virtualLocation,
    'virtual-location-soft': virtualLocationSoft,
  };

  @override
  WmsColors copyWith({
    Color? surfaceCanvas,
    Color? surface,
    Color? surfaceRaised,
    Color? surfaceSunken,
    Color? rowHover,
    Color? scrim,
    Color? border,
    Color? borderControl,
    Color? ink,
    Color? inkMuted,
    Color? inkSubtle,
    Color? inkInverse,
    Color? accent,
    Color? accentHover,
    Color? accentSoft,
    Color? onAccent,
    Color? focusRing,
    Color? success,
    Color? successSoft,
    Color? warning,
    Color? warningSoft,
    Color? danger,
    Color? dangerHover,
    Color? dangerSoft,
    Color? onDanger,
    Color? ledgerIn,
    Color? ledgerOut,
    Color? virtualLocation,
    Color? virtualLocationSoft,
  }) => WmsColors(
    surfaceCanvas: surfaceCanvas ?? this.surfaceCanvas,
    surface: surface ?? this.surface,
    surfaceRaised: surfaceRaised ?? this.surfaceRaised,
    surfaceSunken: surfaceSunken ?? this.surfaceSunken,
    rowHover: rowHover ?? this.rowHover,
    scrim: scrim ?? this.scrim,
    border: border ?? this.border,
    borderControl: borderControl ?? this.borderControl,
    ink: ink ?? this.ink,
    inkMuted: inkMuted ?? this.inkMuted,
    inkSubtle: inkSubtle ?? this.inkSubtle,
    inkInverse: inkInverse ?? this.inkInverse,
    accent: accent ?? this.accent,
    accentHover: accentHover ?? this.accentHover,
    accentSoft: accentSoft ?? this.accentSoft,
    onAccent: onAccent ?? this.onAccent,
    focusRing: focusRing ?? this.focusRing,
    success: success ?? this.success,
    successSoft: successSoft ?? this.successSoft,
    warning: warning ?? this.warning,
    warningSoft: warningSoft ?? this.warningSoft,
    danger: danger ?? this.danger,
    dangerHover: dangerHover ?? this.dangerHover,
    dangerSoft: dangerSoft ?? this.dangerSoft,
    onDanger: onDanger ?? this.onDanger,
    ledgerIn: ledgerIn ?? this.ledgerIn,
    ledgerOut: ledgerOut ?? this.ledgerOut,
    virtualLocation: virtualLocation ?? this.virtualLocation,
    virtualLocationSoft: virtualLocationSoft ?? this.virtualLocationSoft,
  );

  @override
  WmsColors lerp(ThemeExtension<WmsColors>? other, double t) {
    if (other is! WmsColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t) ?? a;
    return WmsColors(
      surfaceCanvas: l(surfaceCanvas, other.surfaceCanvas),
      surface: l(surface, other.surface),
      surfaceRaised: l(surfaceRaised, other.surfaceRaised),
      surfaceSunken: l(surfaceSunken, other.surfaceSunken),
      rowHover: l(rowHover, other.rowHover),
      scrim: l(scrim, other.scrim),
      border: l(border, other.border),
      borderControl: l(borderControl, other.borderControl),
      ink: l(ink, other.ink),
      inkMuted: l(inkMuted, other.inkMuted),
      inkSubtle: l(inkSubtle, other.inkSubtle),
      inkInverse: l(inkInverse, other.inkInverse),
      accent: l(accent, other.accent),
      accentHover: l(accentHover, other.accentHover),
      accentSoft: l(accentSoft, other.accentSoft),
      onAccent: l(onAccent, other.onAccent),
      focusRing: l(focusRing, other.focusRing),
      success: l(success, other.success),
      successSoft: l(successSoft, other.successSoft),
      warning: l(warning, other.warning),
      warningSoft: l(warningSoft, other.warningSoft),
      danger: l(danger, other.danger),
      dangerHover: l(dangerHover, other.dangerHover),
      dangerSoft: l(dangerSoft, other.dangerSoft),
      onDanger: l(onDanger, other.onDanger),
      ledgerIn: l(ledgerIn, other.ledgerIn),
      ledgerOut: l(ledgerOut, other.ledgerOut),
      virtualLocation: l(virtualLocation, other.virtualLocation),
      virtualLocationSoft: l(virtualLocationSoft, other.virtualLocationSoft),
    );
  }
}
