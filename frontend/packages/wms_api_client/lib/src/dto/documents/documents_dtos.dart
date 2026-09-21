import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wms_core/wms_core.dart';

part 'documents_dtos.freezed.dart';
part 'documents_dtos.g.dart';

/// `common_attachment` row (documents.v1.yaml `Attachment`).
@freezed
abstract class AttachmentDto with _$AttachmentDto {
  const factory AttachmentDto({
    required int id,
    required AttachmentEntityType entityType,
    required AttachmentType attachmentType,
    required String fileName,
    required String contentType,
    required int sizeBytes,
    required AttachmentStatus status,
    required int uploadedBy,
    required DateTime uploadedAt,

    /// `null` until the document the file belongs to exists.
    int? entityId,
    String? checksumSha256,

    /// ClamAV outcome: `CLEAN`, `INFECTED:<signature>`, `SKIPPED`.
    String? scanResult,
    @Default(false) bool thumbnailAvailable,
  }) = _AttachmentDto;

  const AttachmentDto._();

  factory AttachmentDto.fromJson(Map<String, Object?> json) =>
      _$AttachmentDtoFromJson(json);

  /// Only `READY` attachments may be referenced by a document.
  bool get isReady => status.isReady;

  bool get isRejected => status == AttachmentStatus.rejected;
}

/// `POST /documents/attachments/presign` body.
@freezed
abstract class PresignAttachmentRequest with _$PresignAttachmentRequest {
  const factory PresignAttachmentRequest({
    required AttachmentEntityType entityType,
    required AttachmentType attachmentType,
    required String fileName,
    required String contentType,
    required int sizeBytes,
    int? entityId,
    String? checksumSha256,
  }) = _PresignAttachmentRequest;

  factory PresignAttachmentRequest.fromJson(Map<String, Object?> json) =>
      _$PresignAttachmentRequestFromJson(json);
}

/// `POST /documents/attachments/presign` response: the MinIO `PUT` target.
@freezed
abstract class PresignAttachmentResponse with _$PresignAttachmentResponse {
  const factory PresignAttachmentResponse({
    required int attachmentId,
    required String uploadUrl,
    required DateTime expiresAt,
    required int maxSizeBytes,
    @Default('PUT') String method,

    /// Headers that must be sent **unchanged** with the `PUT`, otherwise the
    /// presigned signature does not match.
    @Default(<String, String>{}) Map<String, String> uploadHeaders,
  }) = _PresignAttachmentResponse;

  const PresignAttachmentResponse._();

  factory PresignAttachmentResponse.fromJson(Map<String, Object?> json) =>
      _$PresignAttachmentResponseFromJson(json);

  /// The presign is valid for 15 minutes; an expired one must be re-requested.
  bool isExpired({DateTime? now}) =>
      (now ?? DateTime.now()).toUtc().isAfter(expiresAt.toUtc());
}

/// `POST /documents/attachments/{id}/complete` body.
@freezed
abstract class CompleteAttachmentRequest with _$CompleteAttachmentRequest {
  const factory CompleteAttachmentRequest({
    required String checksumSha256,
    String? etag,
  }) = _CompleteAttachmentRequest;

  factory CompleteAttachmentRequest.fromJson(Map<String, Object?> json) =>
      _$CompleteAttachmentRequestFromJson(json);
}

/// `GET /documents/attachments/{id}/download-url` response.
@freezed
abstract class AttachmentDownloadUrlDto with _$AttachmentDownloadUrlDto {
  const factory AttachmentDownloadUrlDto({
    required String downloadUrl,
    required DateTime expiresAt,
    required String fileName,
    required String contentType,
    required int sizeBytes,
  }) = _AttachmentDownloadUrlDto;

  factory AttachmentDownloadUrlDto.fromJson(Map<String, Object?> json) =>
      _$AttachmentDownloadUrlDtoFromJson(json);
}
