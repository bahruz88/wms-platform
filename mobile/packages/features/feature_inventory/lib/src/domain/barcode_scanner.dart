/// Barcode scanning boundary. The mobile app provides a camera-backed
/// implementation later; no camera plugin is added at this stage so the web
/// build and the tests stay dependency-free.
abstract interface class BarcodeScanner {
  /// `true` when the platform can scan (camera present and permitted).
  bool get isAvailable;

  /// Opens the scanner and resolves with the scanned code, or `null` when
  /// the user cancelled.
  Future<String?> scan();
}

/// Default implementation used by the web app and in tests: scanning is not
/// available, so the UI falls back to manual barcode entry.
class UnsupportedBarcodeScanner implements BarcodeScanner {
  const UnsupportedBarcodeScanner();

  @override
  bool get isAvailable => false;

  @override
  Future<String?> scan() async => null;
}
