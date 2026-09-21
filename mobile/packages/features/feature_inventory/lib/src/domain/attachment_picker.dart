import 'dart:typed_data';

import 'package:meta/meta.dart';

/// A file chosen by the user, already in memory. The 25 MB contract ceiling
/// makes buffering safe and lets the checksum be computed before the upload.
@immutable
class PickedAttachment {
  const PickedAttachment({
    required this.fileName,
    required this.contentType,
    required this.bytes,
  });

  final String fileName;

  /// MIME type; must be one of `AttachmentPolicy.allowedContentTypes`.
  final String contentType;
  final Uint8List bytes;

  int get sizeBytes => bytes.length;

  @override
  String toString() =>
      'PickedAttachment($fileName, $contentType, $sizeBytes B)';
}

/// File/photo picking boundary, mirroring `BarcodeScanner`: the apps provide
/// the platform implementation (camera on mobile, file input on the web) and
/// the feature package stays plugin free.
abstract interface class AttachmentPicker {
  /// `true` when this platform can pick a file at all.
  bool get isAvailable;

  /// Camera or gallery photo; `null` when the user cancelled.
  Future<PickedAttachment?> pickPhoto();
}

/// Default used in tests and on platforms without a picker: nothing can be
/// chosen, so the UI keeps the attachment block read-only.
class UnsupportedAttachmentPicker implements AttachmentPicker {
  const UnsupportedAttachmentPicker();

  @override
  bool get isAvailable => false;

  @override
  Future<PickedAttachment?> pickPhoto() async => null;
}

/// Picker that always returns the same file; used by widget tests.
class StaticAttachmentPicker implements AttachmentPicker {
  const StaticAttachmentPicker(this.file);

  final PickedAttachment? file;

  @override
  bool get isAvailable => true;

  @override
  Future<PickedAttachment?> pickPhoto() async => file;
}
