import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:wms_core/wms_core.dart';

import '../dto/documents/documents_dtos.dart';
import 'module_api.dart';

/// Progress of the direct-to-storage `PUT` (`sent` / `total` bytes).
typedef UploadProgress = void Function(int sent, int total);

/// `/api/v1/documents/*` - attachment metadata plus the three step upload
/// documented in `documents.v1.yaml`:
///
/// 1. [presign] creates the `PENDING` row and returns a MinIO `PUT` URL,
/// 2. [uploadBytes] sends the file **directly** to storage (never through
///    the API),
/// 3. [complete] verifies size/checksum and flips the row to `READY`.
class DocumentsApi extends ModuleApi {
  DocumentsApi(Dio dio, {Dio? storageClient})
    : _storage = storageClient ?? Dio(),
      super(dio, '/documents');

  /// Separate Dio for the presigned `PUT`: the gateway interceptors (bearer
  /// token, `Idempotency-Key`, problem+json) must not touch a storage URL -
  /// extra headers break the S3 signature and leak the token to MinIO.
  final Dio _storage;

  /// `GET /documents/attachments?entityType=&entityId=&attachmentType=`
  Future<List<AttachmentDto>> listAttachments({
    required AttachmentEntityType entityType,
    required int entityId,
    AttachmentType? attachmentType,
  }) => getList(
    'attachments',
    fromJson: AttachmentDto.fromJson,
    query: {
      'entityType': entityType,
      'entityId': entityId,
      'attachmentType': attachmentType,
    },
  );

  /// `GET /documents/attachments/{id}`
  Future<AttachmentDto> getAttachment(int id) =>
      getObject('attachments/$id', fromJson: AttachmentDto.fromJson);

  /// `POST /documents/attachments/presign`
  Future<PresignAttachmentResponse> presign(PresignAttachmentRequest body) =>
      postObject(
        'attachments/presign',
        body: body.toJson(),
        fromJson: PresignAttachmentResponse.fromJson,
      );

  /// `POST /documents/attachments/{id}/complete`
  Future<AttachmentDto> complete(int id, CompleteAttachmentRequest body) =>
      postObject(
        'attachments/$id/complete',
        body: body.toJson(),
        fromJson: AttachmentDto.fromJson,
      );

  /// `DELETE /documents/attachments/{id}`
  Future<void> deleteAttachment(int id) => deleteVoid('attachments/$id');

  /// `GET /documents/attachments/{id}/download-url?inline=`
  Future<AttachmentDownloadUrlDto> downloadUrl(int id, {bool inline = false}) =>
      getObject(
        'attachments/$id/download-url',
        fromJson: AttachmentDownloadUrlDto.fromJson,
        query: {'inline': inline},
      );

  /// Uploads [bytes] to the presigned URL and returns the storage `ETag`.
  ///
  /// `presigned.uploadHeaders` are sent unchanged - the signature covers
  /// them. Progress is reported through [onProgress] so the UI can show a
  /// determinate bar for a 25 MB photo on a warehouse connection.
  Future<String?> uploadBytes({
    required PresignAttachmentResponse presigned,
    required Uint8List bytes,
    UploadProgress? onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _storage.requestUri<void>(
        Uri.parse(presigned.uploadUrl),
        data: bytes,
        cancelToken: cancelToken,
        onSendProgress: onProgress,
        options: Options(
          method: presigned.method,
          headers: {...presigned.uploadHeaders},
          // MinIO answers with an empty body; do not try to decode it.
          responseType: ResponseType.plain,
          // Signed URLs carry their own auth, redirects would drop it.
          followRedirects: false,
          validateStatus: (status) => status != null && status < 300,
        ),
      );
      final etag = response.headers.value('etag');
      return etag?.replaceAll('"', '');
    } on DioException catch (e) {
      throw AppException(_storageFailure(e));
    }
  }

  /// Storage errors are not problem+json, so they are mapped explicitly and
  /// keep a visible `code` for the alert.
  static Failure _storageFailure(DioException e) {
    if (e.type == DioExceptionType.cancel) return const CancelledFailure();
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const NetworkFailure(
        message: 'Fayl serverinə bağlantı vaxtı bitdi',
        isTimeout: true,
      );
    }
    final status = e.response?.statusCode;
    if (status == null) {
      return NetworkFailure(
        message: 'Fayl serverinə bağlanmaq olmadı: ${e.message}',
      );
    }
    return ServerFailure(
      ProblemDetails.local(
        code: ProblemCodes.storageUploadFailed,
        title: 'Fayl saxlanc serverinə yüklənmədi',
        detail:
            'MinIO $status qaytardı. Presign vaxtı keçmiş ola bilər, '
            'faylı yenidən seçin.',
        status: status,
      ),
    );
  }
}
