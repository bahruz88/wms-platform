import 'package:crypto/crypto.dart';
import 'package:wms_core/wms_core.dart';

/// Client-side mirror of the upload rules documented in
/// `contracts/openapi/documents.v1.yaml`: 25 MB ceiling and a closed list of
/// MIME types. Checking here turns a wasted round trip (and a 422 the user
/// cannot act on) into an immediate, localised message; the server stays the
/// authority and re-validates everything.
abstract final class AttachmentPolicy {
  /// 25 MB, exactly as in the contract (`maximum: 26214400`).
  static const int maxSizeBytes = 26214400;

  static const String pdf = 'application/pdf';
  static const String jpeg = 'image/jpeg';
  static const String png = 'image/png';
  static const String xlsx =
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
  static const String docx =
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document';

  /// `AllowedContentType` from the contract.
  static const Set<String> allowedContentTypes = {pdf, jpeg, png, xlsx, docx};

  /// Subset a camera/photo field may produce.
  static const Set<String> photoContentTypes = {jpeg, png};

  static const Map<String, String> _byExtension = {
    'pdf': pdf,
    'jpg': jpeg,
    'jpeg': jpeg,
    'jpe': jpeg,
    'png': png,
    'xlsx': xlsx,
    'docx': docx,
  };

  /// Best guess from the file name; `null` when the extension is unknown.
  static String? contentTypeForFileName(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot < 0 || dot == fileName.length - 1) return null;
    return _byExtension[fileName.substring(dot + 1).toLowerCase()];
  }

  /// Normalises `image/jpeg; charset=binary` to `image/jpeg`.
  static String normalise(String contentType) =>
      contentType.split(';').first.trim().toLowerCase();

  static bool isAllowed(String contentType) =>
      allowedContentTypes.contains(normalise(contentType));

  /// Returns the problem to show, or `null` when the file may be uploaded.
  ///
  /// [allowed] narrows the list further (a waste photo is not a DOCX).
  static ProblemDetails? validate({
    required String fileName,
    required String contentType,
    required int sizeBytes,
    Set<String>? allowed,
  }) {
    final permitted = allowed ?? allowedContentTypes;
    if (sizeBytes <= 0) {
      return ProblemDetails.local(
        code: ProblemCodes.attachmentEmpty,
        title: 'Fayl boşdur',
        detail: '$fileName oxuna bilmədi və ya ölçüsü sıfırdır.',
        status: 422,
      );
    }
    if (sizeBytes > maxSizeBytes) {
      return ProblemDetails.local(
        code: ProblemCodes.attachmentTooLarge,
        title: 'Fayl həddindən böyükdür',
        detail:
            'Yükləmə limiti 25 MB-dır, seçilmiş fayl '
            '${_megabytes(sizeBytes)} MB-dır.',
        status: 422,
      );
    }
    if (!permitted.contains(normalise(contentType))) {
      return ProblemDetails.local(
        code: ProblemCodes.attachmentTypeNotAllowed,
        title: 'Bu fayl tipi qəbul edilmir',
        detail:
            'İcazəli tiplər: ${permitted.map(_shortName).join(', ')}. '
            'Seçilmiş tip: ${normalise(contentType)}.',
        status: 422,
      );
    }
    return null;
  }

  /// Lower-case hex SHA-256 of [bytes] — the value `complete` compares with
  /// the object MinIO actually received.
  static String checksumSha256(List<int> bytes) =>
      sha256.convert(bytes).toString();

  /// Human readable size with one decimal place, comma separated (`1,5 MB`).
  static String _megabytes(int bytes) {
    final tenths = (bytes * 10 + 524288) ~/ 1048576;
    return '${tenths ~/ 10},${tenths % 10}';
  }

  static String _shortName(String contentType) => switch (contentType) {
    pdf => 'PDF',
    jpeg => 'JPEG',
    png => 'PNG',
    xlsx => 'XLSX',
    docx => 'DOCX',
    _ => contentType,
  };
}
