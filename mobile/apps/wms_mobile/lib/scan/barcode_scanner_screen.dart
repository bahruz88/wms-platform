import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:wms_design_system/wms_design_system.dart';

/// Barcode formats a warehouse actually meets: retail EAN/UPC, logistics
/// Code 128 / ITF-14 and the QR codes on internal labels.
const List<BarcodeFormat> kWarehouseBarcodeFormats = <BarcodeFormat>[
  BarcodeFormat.ean13,
  BarcodeFormat.ean8,
  BarcodeFormat.upcA,
  BarcodeFormat.upcE,
  BarcodeFormat.code128,
  BarcodeFormat.code39,
  BarcodeFormat.itf14,
  BarcodeFormat.qrCode,
];

/// Azerbaijani title + next step for every scanner error code.
///
/// The camera can fail for reasons the keeper can act on (permission) and
/// reasons only a restart fixes; both get a sentence, never a bare icon.
(String, String) barcodeScannerErrorMessage(MobileScannerErrorCode code) =>
    switch (code) {
      MobileScannerErrorCode.permissionDenied => (
        'Kameraya icazə verilməyib',
        'Cihaz parametrlərində WMS Anbar tətbiqinə kamera icazəsi verin. '
            'İcazəsiz barkodu əl ilə daxil edə bilərsiniz.',
      ),
      MobileScannerErrorCode.unsupported => (
        'Bu cihaz skanı dəstəkləmir',
        'Kamera tapılmadı. Barkodu əl ilə daxil edin.',
      ),
      MobileScannerErrorCode.controllerDisposed ||
      MobileScannerErrorCode.controllerUninitialized ||
      MobileScannerErrorCode.controllerNotAttached ||
      MobileScannerErrorCode.controllerInitializing ||
      MobileScannerErrorCode.controllerAlreadyInitialized => (
        'Kamera hazır deyil',
        'Ekranı bağlayıb yenidən açın.',
      ),
      MobileScannerErrorCode.genericError => (
        'Kamera açılmadı',
        'Ekranı bağlayıb yenidən açın və ya barkodu əl ilə daxil edin.',
      ),
    };

/// Full screen camera scanner. Pops with the scanned string, or with `null`
/// when the user backs out (the caller then falls back to manual entry).
///
/// Camera permission is requested by the plugin when the preview starts; a
/// denial arrives as `MobileScannerErrorCode.permissionDenied` and is shown
/// as a `WmsAlert` with the next step spelled out, never as a dead screen.
class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    formats: kWarehouseBarcodeFormats,
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _handled = false;
  bool _torchOn = false;

  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final code = capture.barcodes
        .map((b) => b.rawValue)
        .firstWhere(
          (value) => value != null && value.isNotEmpty,
          orElse: () => null,
        );
    if (code == null) return;
    _handled = true;
    // Haptics, not sound: a warehouse is too loud for a beep (ux/screen-map).
    unawaited(HapticFeedback.mediumImpact());
    Navigator.of(context).pop(code);
  }

  Future<void> _toggleTorch() async {
    await _controller.toggleTorch();
    if (mounted) setState(() => _torchOn = !_torchOn);
  }

  @override
  Widget build(BuildContext context) {
    final c = WmsColors.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barkod skan et'),
        actions: [
          WmsIconButton(
            icon: _torchOn ? Icons.flashlight_on : Icons.flashlight_off,
            label: _torchOn ? 'İşığı söndür' : 'İşığı yandır',
            onPressed: _toggleTorch,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: (context, error) =>
                  _ScannerError(error: error, onManualEntry: _popEmpty),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(WmsSpacing.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Barkodu kameranın ortasına tutun.',
                  textAlign: TextAlign.center,
                  style: WmsTypography.body.copyWith(color: c.inkMuted),
                ),
                const SizedBox(height: WmsSpacing.space3),
                WmsButton(
                  label: 'Əl ilə daxil et',
                  iconLeft: Icons.keyboard_outlined,
                  onPressed: _popEmpty,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _popEmpty() => Navigator.of(context).pop();
}

/// Camera failures in plain Azerbaijani, with the plugin's error code kept
/// visible so support can act on it.
class _ScannerError extends StatelessWidget {
  const _ScannerError({required this.error, required this.onManualEntry});

  final MobileScannerException error;
  final VoidCallback onManualEntry;

  @override
  Widget build(BuildContext context) {
    final (title, message) = barcodeScannerErrorMessage(error.errorCode);
    return ColoredBox(
      color: WmsColors.of(context).surfaceCanvas,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(WmsSpacing.space4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WmsAlert(
                tone: WmsAlertTone.danger,
                title: title,
                message: message,
                code: error.errorCode.name,
              ),
              const SizedBox(height: WmsSpacing.space4),
              WmsButton.primary(
                label: 'Əl ilə daxil et',
                iconLeft: Icons.keyboard_outlined,
                onPressed: onManualEntry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
