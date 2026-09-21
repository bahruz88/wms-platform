// Asserts that the Dart token layer matches docs/design-system/tokens.json
// literally. The JSON is read from disk so a change in the design system
// that is not mirrored here fails the build.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wms_design_system/wms_design_system.dart';

File _tokensFile() {
  var dir = Directory.current;
  while (!Directory('${dir.path}/docs/design-system').existsSync()) {
    final parent = dir.parent;
    if (parent.path == dir.path) {
      fail('docs/design-system not found from ${Directory.current.path}');
    }
    dir = parent;
  }
  return File('${dir.path}/docs/design-system/tokens.json');
}

Map<String, Object?> _json() =>
    jsonDecode(_tokensFile().readAsStringSync()) as Map<String, Object?>;

/// Parses `#rrggbb` or `rgba(r,g,b,a)` from the design tokens.
Color _parseCss(String value) {
  if (value.startsWith('#')) {
    final hex = value.substring(1);
    return Color(int.parse('ff$hex', radix: 16));
  }
  final match = RegExp(r'rgba?\(([^)]+)\)').firstMatch(value);
  if (match == null) fail('unsupported colour: $value');
  final parts = match.group(1)!.split(',').map((e) => e.trim()).toList();
  return Color.fromRGBO(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
    parts.length > 3 ? num.parse(parts[3]).toDouble() : 1.0,
  );
}

double _px(Object? value) =>
    double.parse(value.toString().replaceAll('px', '').trim());

void main() {
  final tokens = _json();

  test('tokens.json is the WMS Enterprise v1 set', () {
    expect(tokens['name'], 'WMS Enterprise');
    expect(tokens['version'], 1);
  });

  group('colours', () {
    final colorTokens = ((tokens['color']! as Map)['tokens']! as List)
        .cast<Map<String, Object?>>();

    /// Resolves `{success}`-style aliases.
    String resolve(String raw, String theme) {
      if (!raw.startsWith('{')) return raw;
      final target = raw.substring(1, raw.length - 1);
      final aliased = colorTokens.firstWhere((t) => t['name'] == target);
      return (aliased['value']! as Map)[theme]! as String;
    }

    test('every colour token exists in Dart with identical light values', () {
      final dart = WmsColors.light.tokenMap;
      expect(colorTokens, hasLength(29));
      expect(dart, hasLength(colorTokens.length));
      for (final token in colorTokens) {
        final name = token['name']! as String;
        final raw = (token['value']! as Map)['light']! as String;
        expect(dart.containsKey(name), isTrue, reason: 'missing token $name');
        expect(
          dart[name],
          _parseCss(resolve(raw, 'light')),
          reason: 'light value mismatch for $name',
        );
      }
      expect(dart.keys.toSet(), colorTokens.map((t) => t['name']).toSet());
    });

    test('every colour token matches the dark values', () {
      final dart = WmsColors.dark.tokenMap;
      for (final token in colorTokens) {
        final name = token['name']! as String;
        final raw = (token['value']! as Map)['dark']! as String;
        expect(
          dart[name],
          _parseCss(resolve(raw, 'dark')),
          reason: 'dark value mismatch for $name',
        );
      }
    });

    test('ledger tones are aliases of success/danger', () {
      expect(WmsColors.light.ledgerIn, WmsColors.light.success);
      expect(WmsColors.light.ledgerOut, WmsColors.light.danger);
      expect(WmsColors.dark.ledgerIn, WmsColors.dark.success);
      expect(WmsColors.dark.ledgerOut, WmsColors.dark.danger);
    });
  });

  group('typography', () {
    final groups = ((tokens['type']! as Map)['groups']! as List)
        .cast<Map<String, Object?>>();

    test(
      'every style matches size, line height, weight and letter spacing',
      () {
        var checked = 0;
        for (final group in groups) {
          final isMono = group['family'] == 'mono';
          for (final style
              in (group['styles']! as List).cast<Map<String, Object?>>()) {
            final name = style['name']! as String;
            final dart = WmsTypography.styleMap[name];
            expect(dart, isNotNull, reason: 'missing text style $name');
            final fontSize = _px(style['fontSize']);
            final lineHeight = _px(style['lineHeight']);
            expect(dart!.fontSize, fontSize, reason: '$name fontSize');
            expect(
              dart.height,
              closeTo(lineHeight / fontSize, 1e-9),
              reason: '$name height',
            );
            expect(
              dart.fontWeight!.value,
              style['fontWeight'],
              reason: '$name fontWeight',
            );
            final ls = style['letterSpacing'] as String?;
            if (ls == null) {
              expect(dart.letterSpacing, isNull, reason: '$name letterSpacing');
            } else {
              final em = double.parse(ls.replaceAll('em', ''));
              expect(
                dart.letterSpacing,
                closeTo(em * fontSize, 1e-9),
                reason: '$name letterSpacing (em -> px)',
              );
            }
            if (isMono) {
              expect(
                dart.fontFeatures,
                contains(const FontFeature.tabularFigures()),
                reason: '$name must use tabular figures',
              );
              expect(dart.fontFamilyFallback, WmsTypography.monoFallback);
              expect(WmsTypography.monoStyles, contains(name));
            } else {
              expect(dart.fontFamilyFallback, WmsTypography.sansFallback);
            }
            checked++;
          }
        }
        expect(checked, 11);
        expect(WmsTypography.styleMap.length, 11);
      },
    );
  });

  test('spacing, radius and opacity match tokens.json', () {
    for (final t
        in ((tokens['spacing']! as Map)['tokens']! as List)
            .cast<Map<String, Object?>>()) {
      expect(
        WmsSpacing.tokenMap[t['name']],
        _px(t['value']),
        reason: '${t['name']}',
      );
    }
    expect(WmsSpacing.tokenMap.length, 7);

    for (final t
        in ((tokens['radius']! as Map)['tokens']! as List)
            .cast<Map<String, Object?>>()) {
      expect(
        WmsRadius.tokenMap[t['name']],
        _px(t['value']),
        reason: '${t['name']}',
      );
    }
    expect(WmsRadius.tokenMap.length, 4);

    for (final t
        in ((tokens['opacity']! as Map)['tokens']! as List)
            .cast<Map<String, Object?>>()) {
      expect(
        WmsOpacity.tokenMap[t['name']],
        double.parse(t['value']! as String),
        reason: '${t['name']}',
      );
    }
  });

  test('shadows match the css values for both themes', () {
    final shadowTokens = ((tokens['shadow']! as Map)['tokens']! as List)
        .cast<Map<String, Object?>>();
    final maps = {
      'light': WmsShadows.light.tokenMap,
      'dark': WmsShadows.dark.tokenMap,
    };
    for (final token in shadowTokens) {
      final name = token['name']! as String;
      for (final theme in maps.keys) {
        final css = (token['value']! as Map)[theme]! as String;
        final parts = RegExp(
          r'^(-?\d+)(?:px)? (-?\d+)(?:px)? (-?\d+)(?:px)? (rgba?\([^)]+\))$',
        ).firstMatch(css.trim());
        expect(parts, isNotNull, reason: 'unparsed shadow $name/$theme: $css');
        final shadow = maps[theme]![name]!.single;
        expect(shadow.offset.dx, double.parse(parts!.group(1)!));
        expect(shadow.offset.dy, double.parse(parts.group(2)!));
        expect(shadow.blurRadius, double.parse(parts.group(3)!));
        expect(shadow.color, _parseCss(parts.group(4)!));
      }
    }
  });

  test('ColorScheme is wired to the token names from FLUTTER-MAPPING', () {
    final scheme = WmsTheme.light().colorScheme;
    const c = WmsColors.light;
    expect(scheme.primary, c.accent);
    expect(scheme.onPrimary, c.onAccent);
    expect(scheme.surface, c.surface);
    expect(scheme.onSurface, c.ink);
    expect(scheme.error, c.danger);
    expect(scheme.onError, c.onDanger);
    expect(scheme.outline, c.borderControl);
    expect(scheme.outlineVariant, c.border);
    expect(scheme.surfaceContainerLowest, c.surfaceCanvas);
    expect(scheme.surfaceContainerLow, c.surfaceSunken);
    expect(scheme.surfaceContainerHigh, c.surfaceRaised);
  });

  test('themes expose the extensions and the dark scheme flips', () {
    final light = WmsTheme.light();
    final dark = WmsTheme.dark();
    expect(light.extension<WmsColors>(), WmsColors.light);
    expect(light.extension<WmsShadows>(), isNotNull);
    expect(dark.extension<WmsColors>(), WmsColors.dark);
    expect(dark.brightness, Brightness.dark);
    expect(light.scaffoldBackgroundColor, WmsColors.light.surfaceCanvas);
  });

  test('breakpoints: compact < 600 <= medium < 1024 <= expanded', () {
    expect(WmsBreakpoints.fromWidth(599), WmsWindowSize.compact);
    expect(WmsBreakpoints.fromWidth(600), WmsWindowSize.medium);
    expect(WmsBreakpoints.fromWidth(1023), WmsWindowSize.medium);
    expect(WmsBreakpoints.fromWidth(1024), WmsWindowSize.expanded);
  });
}
