import 'package:feature_inventory/feature_inventory.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'barcode_scanner_screen.dart';

/// Camera-backed [BarcodeScanner] for Android and iOS, implemented with
/// `mobile_scanner`.
///
/// The plugin is a dependency of the mobile app only, so the web bundle never
/// pulls a camera plugin in. Manual barcode entry stays available everywhere:
/// [scan] returns `null` when the user backs out, when the camera is missing
/// and when the permission is denied - the screens treat all three the same
/// and keep the text field.
class MobileBarcodeScanner implements BarcodeScanner {
  const MobileBarcodeScanner({required this.navigatorKey});

  /// Root navigator of the app; [BarcodeScanner.scan] has no `BuildContext`,
  /// so the scanner route is pushed through this key.
  final GlobalKey<NavigatorState> navigatorKey;

  /// Platforms where `mobile_scanner` has a camera implementation we ship.
  static bool get isSupportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  bool get isAvailable => isSupportedPlatform;

  @override
  Future<String?> scan() async {
    if (!isAvailable) return null;
    final navigator = navigatorKey.currentState;
    if (navigator == null) return null;
    final code = await navigator.push<String>(
      MaterialPageRoute<String>(
        builder: (_) => const BarcodeScannerScreen(),
        fullscreenDialog: true,
      ),
    );
    final trimmed = code?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}
