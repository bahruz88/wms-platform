import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

import 'attachment_picker.dart';

/// Attachment boundary for the inventory screens (documents.v1.yaml).
abstract interface class AttachmentRepository {
  /// Runs the full presign → `PUT` → complete sequence and returns the
  /// `READY` attachment.
  ///
  /// [onProgress] reports the bytes already sent to storage; [allowed]
  /// narrows the accepted MIME types (a waste photo is JPEG/PNG only).
  Future<Result<AttachmentDto>> upload({
    required AttachmentEntityType entityType,
    required AttachmentType attachmentType,
    required PickedAttachment file,
    int? entityId,
    Set<String>? allowed,
    UploadProgress? onProgress,
    CancelToken? cancelToken,
  });

  /// `READY` attachments of a document.
  Future<Result<List<AttachmentDto>>> list({
    required AttachmentEntityType entityType,
    required int entityId,
    AttachmentType? attachmentType,
  });

  Future<Result<void>> remove(int id);
}
