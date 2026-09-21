import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import '../tokens/wms_colors.dart';
import '../tokens/wms_radius.dart';
import '../tokens/wms_shadows.dart';
import '../tokens/wms_spacing.dart';
import '../tokens/wms_typography.dart';

/// Material 3 [ThemeData] bound to the design tokens.
///
/// `ColorScheme` mapping (FLUTTER-MAPPING.md §1): `primary`=accent,
/// `onPrimary`=on-accent, `surface`=surface, `onSurface`=ink, `error`=danger,
/// `onError`=on-danger, `outline`=border-control, `outlineVariant`=border,
/// `surfaceContainerLowest`=surface-canvas, `surfaceContainerLow`=surface-sunken,
/// `surfaceContainerHigh`=surface-raised.
abstract final class WmsTheme {
  static ThemeData light() =>
      _build(Brightness.light, WmsColors.light, WmsShadows.light);

  static ThemeData dark() =>
      _build(Brightness.dark, WmsColors.dark, WmsShadows.dark);

  static ColorScheme colorScheme(Brightness brightness, WmsColors c) =>
      ColorScheme(
        brightness: brightness,
        primary: c.accent,
        onPrimary: c.onAccent,
        primaryContainer: c.accentSoft,
        onPrimaryContainer: c.accent,
        secondary: c.accent,
        onSecondary: c.onAccent,
        secondaryContainer: c.accentSoft,
        onSecondaryContainer: c.accent,
        tertiary: c.virtualLocation,
        onTertiary: c.inkInverse,
        tertiaryContainer: c.virtualLocationSoft,
        onTertiaryContainer: c.virtualLocation,
        error: c.danger,
        onError: c.onDanger,
        errorContainer: c.dangerSoft,
        onErrorContainer: c.danger,
        surface: c.surface,
        onSurface: c.ink,
        onSurfaceVariant: c.inkMuted,
        surfaceContainerLowest: c.surfaceCanvas,
        surfaceContainerLow: c.surfaceSunken,
        surfaceContainer: c.surface,
        surfaceContainerHigh: c.surfaceRaised,
        surfaceContainerHighest: c.surfaceRaised,
        outline: c.borderControl,
        outlineVariant: c.border,
        shadow: Colors.black,
        scrim: c.scrim,
        inverseSurface: c.ink,
        onInverseSurface: c.inkInverse,
        inversePrimary: c.accentSoft,
      );

  static TextTheme textTheme(WmsColors c) {
    TextStyle s(TextStyle base, {Color? color}) =>
        base.copyWith(color: color ?? c.ink);
    return TextTheme(
      displaySmall: s(WmsTypography.display),
      headlineSmall: s(WmsTypography.display),
      titleLarge: s(WmsTypography.titleLg),
      titleMedium: s(WmsTypography.title),
      titleSmall: s(WmsTypography.bodyStrong),
      bodyLarge: s(WmsTypography.body),
      bodyMedium: s(WmsTypography.body),
      bodySmall: s(WmsTypography.caption, color: c.inkMuted),
      labelLarge: s(WmsTypography.bodyStrong),
      labelMedium: s(WmsTypography.label),
      labelSmall: s(WmsTypography.label, color: c.inkMuted),
    );
  }

  static ThemeData _build(
    Brightness brightness,
    WmsColors c,
    WmsShadows shadows,
  ) {
    final scheme = colorScheme(brightness, c);
    final text = textTheme(c);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.surfaceCanvas,
      canvasColor: c.surface,
      cardColor: c.surface,
      dividerColor: c.border,
      focusColor: c.focusRing,
      hoverColor: c.rowHover,
      splashFactory: NoSplash.splashFactory,
      textTheme: text,
      extensions: [c, shadows],
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        foregroundColor: c.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: Border(bottom: BorderSide(color: c.border)),
        titleTextStyle: WmsTypography.titleLg.copyWith(color: c.ink),
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: WmsRadius.lgAll,
          side: BorderSide(color: c.border),
        ),
      ),
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: c.surface,
        contentPadding: WmsSpacing.control,
        hintStyle: WmsTypography.body.copyWith(color: c.inkSubtle),
        labelStyle: WmsTypography.label.copyWith(color: c.ink),
        helperStyle: WmsTypography.caption.copyWith(color: c.inkMuted),
        errorStyle: WmsTypography.caption.copyWith(color: c.danger),
        border: OutlineInputBorder(
          borderRadius: WmsRadius.mdAll,
          borderSide: BorderSide(color: c.borderControl),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: WmsRadius.mdAll,
          borderSide: BorderSide(color: c.borderControl),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: WmsRadius.mdAll,
          borderSide: BorderSide(color: c.focusRing, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: WmsRadius.mdAll,
          borderSide: BorderSide(color: c.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: WmsRadius.mdAll,
          borderSide: BorderSide(color: c.danger, width: 2),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surfaceRaised,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: WmsRadius.lgAll,
          side: BorderSide(color: c.border),
        ),
        titleTextStyle: WmsTypography.titleLg.copyWith(color: c.ink),
        contentTextStyle: WmsTypography.body.copyWith(color: c.ink),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        indicatorColor: c.accentSoft,
        elevation: 0,
        labelTextStyle: WidgetStatePropertyAll(
          WmsTypography.label.copyWith(color: c.ink),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 20,
            color: states.contains(WidgetState.selected)
                ? c.accent
                : c.inkMuted,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: c.surface,
        indicatorColor: c.accentSoft,
        elevation: 0,
        selectedIconTheme: IconThemeData(size: 20, color: c.accent),
        unselectedIconTheme: IconThemeData(size: 20, color: c.inkMuted),
        selectedLabelTextStyle: WmsTypography.bodyStrong.copyWith(color: c.ink),
        unselectedLabelTextStyle: WmsTypography.body.copyWith(
          color: c.inkMuted,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: c.ink, borderRadius: WmsRadius.smAll),
        textStyle: WmsTypography.caption.copyWith(color: c.inkInverse),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.ink,
        contentTextStyle: WmsTypography.body.copyWith(color: c.inkInverse),
        shape: const RoundedRectangleBorder(borderRadius: WmsRadius.mdAll),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: c.inkMuted,
        textColor: c.ink,
        dense: true,
      ),
      iconTheme: IconThemeData(size: 16, color: c.ink),
      chipTheme: ChipThemeData(
        backgroundColor: c.surfaceSunken,
        side: BorderSide(color: c.border),
        labelStyle: WmsTypography.label.copyWith(color: c.inkMuted),
        shape: const RoundedRectangleBorder(borderRadius: WmsRadius.smAll),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
