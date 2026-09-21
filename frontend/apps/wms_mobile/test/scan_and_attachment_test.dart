import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_mobile/attachments/camera_attachment_picker.dart';
import 'package:wms_mobile/scan/barcode_scanner_screen.dart';
import 'package:wms_mobile/scan/mobile_barcode_scanner.dart';

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  group('MobileBarcodeScanner', () {
    test('is available on the two platforms the app ships to', () {
      final scanner = MobileBarcodeScanner(
        navigatorKey: GlobalKey<NavigatorState>(),
      );
      for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
        debugDefaultTargetPlatformOverride = platform;
        expect(scanner.isAvailable, isTrue, reason: '$platform');
      }
      for (final platform in [
        TargetPlatform.macOS,
        TargetPlatform.windows,
        TargetPlatform.linux,
      ]) {
        debugDefaultTargetPlatformOverride = platform;
        expect(scanner.isAvailable, isFalse, reason: '$platform');
      }
    });

    test('without a camera it yields nothing, so manual entry stays', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      final scanner = MobileBarcodeScanner(
        navigatorKey: GlobalKey<NavigatorState>(),
      );
      expect(await scanner.scan(), isNull);
    });

    test('an unmounted navigator cancels instead of throwing', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final scanner = MobileBarcodeScanner(
        navigatorKey: GlobalKey<NavigatorState>(),
      );
      expect(await scanner.scan(), isNull);
    });

    testWidgets('blank scan results are treated as a cancel', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final key = GlobalKey<NavigatorState>();
      final scanner = MobileBarcodeScanner(navigatorKey: key);
      await tester.pumpWidget(
        MaterialApp(navigatorKey: key, home: const SizedBox.shrink()),
      );

      final pending = scanner.scan();
      await tester.pump();
      // The scanner route pops with an empty string (nothing decoded).
      key.currentState!.pop('   ');
      await tester.pumpAndSettle();

      final code = await pending;
      // The invariant check runs before tearDown, so reset it here.
      debugDefaultTargetPlatformOverride = null;
      expect(code, isNull);
    });
  });

  group('barcode formats', () {
    test('cover retail, logistics and internal labels', () {
      expect(
        kWarehouseBarcodeFormats,
        containsAll(<BarcodeFormat>[
          BarcodeFormat.ean13,
          BarcodeFormat.ean8,
          BarcodeFormat.code128,
          BarcodeFormat.qrCode,
        ]),
      );
    });
  });

  group('scanner error messages', () {
    test('every error code has an Azerbaijani sentence', () {
      for (final code in MobileScannerErrorCode.values) {
        final (title, message) = barcodeScannerErrorMessage(code);
        expect(title, isNotEmpty, reason: code.name);
        expect(message, isNotEmpty, reason: code.name);
        // Interface text is never upper-cased (i → I is wrong in Azerbaijani).
        expect(title, isNot(title.toUpperCase()), reason: code.name);
      }
    });

    test('a denied camera names the setting and the fallback', () {
      final (title, message) = barcodeScannerErrorMessage(
        MobileScannerErrorCode.permissionDenied,
      );
      expect(title, 'Kameraya icazə verilməyib');
      expect(message, contains('kamera icazəsi'));
      expect(message, contains('əl ilə'));
    });
  });

  group('CameraAttachmentPicker', () {
    test('is a mobile only picker', () {
      const picker = CameraAttachmentPicker();
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(picker.isAvailable, isTrue);
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      expect(picker.isAvailable, isFalse);
    });

    test('falls back to the extension, then to JPEG', () {
      expect(
        CameraAttachmentPicker.resolveContentType('image/png', 'a.png'),
        AttachmentPolicy.png,
      );
      // Some Android cameras report no MIME type at all.
      expect(
        CameraAttachmentPicker.resolveContentType(null, 'photo.PNG'),
        AttachmentPolicy.png,
      );
      expect(
        CameraAttachmentPicker.resolveContentType(null, 'IMG_0001'),
        AttachmentPolicy.jpeg,
      );
      // A type the contract does not allow must not be passed through.
      expect(
        CameraAttachmentPicker.resolveContentType('image/heic', 'x.heic'),
        AttachmentPolicy.jpeg,
      );
    });

    test('downscales before upload to keep the transfer small', () {
      const picker = CameraAttachmentPicker();
      expect(picker.maxEdge, lessThanOrEqualTo(4096));
      expect(picker.quality, inInclusiveRange(60, 100));
    });
  });
}
