import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

import '../domain/attachment_picker.dart';
import '../domain/attachment_repository.dart';

/// [AttachmentRepository] over [DocumentsApi].
///
/// The three steps of `documents.v1.yaml` are kept in one call because they
/// are meaningless apart: a `PENDING` row without its object is rubbish the
/// `AttachmentOrphanCleaner` job has to sweep up.
class AttachmentRepositoryImpl implements AttachmentRepository {
  AttachmentRepositoryImpl(this._api);

  final DocumentsApi _api;

  @override
  Future<Result<AttachmentDto>> upload({
    required AttachmentEntityType entityType,
    required AttachmentType attachmentType,
    required PickedAttachment file,
    int? entityId,
    Set<String>? allowed,
    UploadProgress? onProgress,
    CancelToken? cancelToken,
  }) async {
    // 0. Client side gate (25 MB, allowed MIME types) - the server repeats it.
    final violation = AttachmentPolicy.validate(
      fileName: file.fileName,
      contentType: file.contentType,
      sizeBytes: file.sizeBytes,
      allowed: allowed,
    );
    if (violation != null) {
      return Err<AttachmentDto>(Failure.fromProblem(violation));
    }
    final checksum = AttachmentPolicy.checksumSha256(file.bytes);

    return Result.guard(() async {
      // 1. Metadata + presigned PUT (valid 15 minutes).
      final presigned = await _api.presign(
        PresignAttachmentRequest(
          entityType: entityType,
          attachmentType: attachmentType,
          entityId: entityId,
          fileName: file.fileName,
          contentType: AttachmentPolicy.normalise(file.contentType),
          sizeBytes: file.sizeBytes,
          checksumSha256: checksum,
        ),
      );
      // 2. Straight to storage; the API never sees the bytes (SPEC §3).
      final etag = await _api.uploadBytes(
        presigned: presigned,
        bytes: file.bytes,
        onProgress: onProgress,
        cancelToken: cancelToken,
      );
      // 3. Server verifies size + checksum and queues the virus scan.
      return _api.complete(
        presigned.attachmentId,
        CompleteAttachmentRequest(checksumSha256: checksum, etag: etag),
      );
    });
  }

  @override
  Future<Result<List<AttachmentDto>>> list({
    required AttachmentEntityType entityType,
    required int entityId,
    AttachmentType? attachmentType,
  }) => Result.guard(
    () => _api.listAttachments(
      entityType: entityType,
      entityId: entityId,
      attachmentType: attachmentType,
    ),
  );

  @override
  Future<Result<void>> remove(int id) =>
      Result.guard(() => _api.deleteAttachment(id));
}
