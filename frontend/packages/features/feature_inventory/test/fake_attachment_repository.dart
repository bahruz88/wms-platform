import 'package:feature_inventory/feature_inventory.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

AttachmentDto attachmentFixture({
  int id = 42,
  String fileName = 'tullanti.jpg',
  AttachmentStatus status = AttachmentStatus.ready,
}) => AttachmentDto(
  id: id,
  entityType: AttachmentEntityType.waste,
  attachmentType: AttachmentType.wastePhoto,
  fileName: fileName,
  contentType: 'image/jpeg',
  sizeBytes: 2048,
  status: status,
  uploadedBy: 7,
  uploadedAt: DateTime.utc(2026, 9, 21, 10),
);

/// [AttachmentRepository] that records calls and replays a canned outcome.
///
/// [emitProgress] mimics the byte counter of a real `PUT` so the progress
/// state can be asserted without a socket.
class FakeAttachmentRepository implements AttachmentRepository {
  FakeAttachmentRepository({
    AttachmentDto? attachment,
    this.failure,
    this.emitProgress = true,
  }) : attachment = attachment ?? attachmentFixture();

  final AttachmentDto attachment;
  final Failure? failure;
  final bool emitProgress;

  final List<PickedAttachment> uploads = [];
  final List<int> removed = [];

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
    uploads.add(file);
    final violation = AttachmentPolicy.validate(
      fileName: file.fileName,
      contentType: file.contentType,
      sizeBytes: file.sizeBytes,
      allowed: allowed,
    );
    if (violation != null) {
      return Err<AttachmentDto>(Failure.fromProblem(violation));
    }
    if (emitProgress && onProgress != null) {
      onProgress(file.sizeBytes ~/ 2, file.sizeBytes);
      onProgress(file.sizeBytes, file.sizeBytes);
    }
    final error = failure;
    if (error != null) return Err<AttachmentDto>(error);
    return Ok<AttachmentDto>(attachment);
  }

  @override
  Future<Result<List<AttachmentDto>>> list({
    required AttachmentEntityType entityType,
    required int entityId,
    AttachmentType? attachmentType,
  }) async => Ok<List<AttachmentDto>>([attachment]);

  @override
  Future<Result<void>> remove(int id) async {
    removed.add(id);
    return const Ok<void>(null);
  }
}
