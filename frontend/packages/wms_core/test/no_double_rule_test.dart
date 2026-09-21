// Enforces the workspace rule from analysis_options.yaml: quantities and
// money are Decimal-backed, never `double`. Scans the Dart sources of every
// package that handles domain data. The design system and apps are excluded
// because Flutter layout APIs legitimately use double for sizes.
import 'dart:io';

import 'package:test/test.dart';

const _scannedPackages = <String>[
  'packages/wms_core',
  'packages/wms_api_client',
  'packages/wms_auth',
  'packages/features/feature_consumption',
  'packages/features/feature_identity',
  'packages/features/feature_master_data',
  'packages/features/feature_inventory',
  'packages/features/feature_procurement',
  'packages/features/feature_reporting',
  'packages/features/feature_notifications',
];

final _doubleToken = RegExp(r'\bdouble\b');
final _lineComment = RegExp(r'//.*$');

Directory _workspaceRoot() {
  var dir = Directory.current;
  while (!File('${dir.path}/pubspec.yaml').existsSync() ||
      !File('${dir.path}/melos.yaml').existsSync()) {
    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw StateError('workspace root not found from ${Directory.current}');
    }
    dir = parent;
  }
  return dir;
}

void main() {
  test('no `double` in domain/data packages (decimal rule)', () {
    final root = _workspaceRoot();
    final offenders = <String>[];
    for (final pkg in _scannedPackages) {
      final lib = Directory('${root.path}/$pkg/lib');
      if (!lib.existsSync()) continue;
      final files = lib
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));
      for (final file in files) {
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final code = lines[i].replaceAll(_lineComment, '');
          if (_doubleToken.hasMatch(code)) {
            offenders.add('${file.path}:${i + 1}: ${lines[i].trim()}');
          }
        }
      }
    }
    expect(
      offenders,
      isEmpty,
      reason:
          'Use Quantity/Money/Decimal instead of double:\n'
          '${offenders.join('\n')}',
    );
  });
}
