import 'package:feature_inventory/feature_inventory.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wms_api_client/wms_api_client.dart';

/// [AttachmentPicker] backed by the device camera (`image_picker`).
///
/// Waste and discrepancy photos are taken on the spot, so the camera is the
/// default source; the gallery stays reachable through [source] for a photo
/// that was taken before the document was started.
///
/// The image is downscaled before upload: a 12 MP phone photo is ~5 MB of
/// evidence nobody zooms into, and warehouse connections are slow. The
/// resulting JPEG stays far below the 25 MB contract ceiling.
class CameraAttachmentPicker implements AttachmentPicker {
  const CameraAttachmentPicker({
    this.source = ImageSource.camera,
    this.maxEdge = 2048,
    this.quality = 85,
    this.picker,
  });

  final ImageSource source;

  /// Longest edge in pixels the photo is resized to.
  final int maxEdge;

  /// JPEG quality (0..100).
  final int quality;

  /// Injected in tests; `null` uses the platform picker.
  final ImagePicker? picker;

  @override
  bool get isAvailable =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  Future<PickedAttachment?> pickPhoto() async {
    if (!isAvailable) return null;
    final file = await (picker ?? ImagePicker()).pickImage(
      source: source,
      maxWidth: maxEdge.toDouble(),
      maxHeight: maxEdge.toDouble(),
      imageQuality: quality,
    );
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    return PickedAttachment(
      fileName: file.name,
      contentType: resolveContentType(file.mimeType, file.name),
      bytes: bytes,
    );
  }

  /// `image_picker` leaves `mimeType` null on several Android OEM cameras;
  /// the extension is then the only hint, and JPEG is the camera default.
  static String resolveContentType(String? mimeType, String fileName) {
    if (mimeType != null && AttachmentPolicy.isAllowed(mimeType)) {
      return AttachmentPolicy.normalise(mimeType);
    }
    return AttachmentPolicy.contentTypeForFileName(fileName) ??
        AttachmentPolicy.jpeg;
  }
}
