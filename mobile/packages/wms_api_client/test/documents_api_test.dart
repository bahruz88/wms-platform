import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

import 'fake_adapter.dart';

DocumentsApi _api(FakeAdapter gateway, FakeAdapter storage) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost:5001/api/v1'))
    ..httpClientAdapter = gateway;
  final storageDio = Dio()..httpClientAdapter = storage;
  return DocumentsApi(dio, storageClient: storageDio);
}

Map<String, Object?> _presignBody({
  String url = 'http://localhost:9000/wms-attachments/t1/WASTE/abc.jpg?sig=1',
}) => {
  'attachmentId': 42,
  'uploadUrl': url,
  'method': 'PUT',
  'uploadHeaders': {'Content-Type': 'image/jpeg', 'x-amz-meta-tenant': '1'},
  'expiresAt': '2026-09-21T10:15:00Z',
  'maxSizeBytes': 26214400,
};

Map<String, Object?> _attachmentBody({String status = 'READY'}) => {
  'id': 42,
  'entityType': 'WASTE',
  'entityId': null,
  'attachmentType': 'WASTE_PHOTO',
  'fileName': 'tullanti.jpg',
  'contentType': 'image/jpeg',
  'sizeBytes': 2048,
  'checksumSha256': 'a' * 64,
  'status': status,
  'scanResult': 'CLEAN',
  'uploadedBy': 7,
  'uploadedAt': '2026-09-21T10:00:00Z',
  'thumbnailAvailable': true,
};

void main() {
  group('AttachmentPolicy', () {
    test('accepts every content type of the contract', () {
      expect(AttachmentPolicy.allowedContentTypes, hasLength(5));
      for (final type in AttachmentPolicy.allowedContentTypes) {
        expect(
          AttachmentPolicy.validate(
            fileName: 'f',
            contentType: type,
            sizeBytes: 10,
          ),
          isNull,
          reason: type,
        );
      }
    });

    test('25 MB is the boundary, one byte more is refused', () {
      expect(AttachmentPolicy.maxSizeBytes, 26214400);
      expect(
        AttachmentPolicy.validate(
          fileName: 'scan.pdf',
          contentType: AttachmentPolicy.pdf,
          sizeBytes: AttachmentPolicy.maxSizeBytes,
        ),
        isNull,
      );
      final problem = AttachmentPolicy.validate(
        fileName: 'scan.pdf',
        contentType: AttachmentPolicy.pdf,
        sizeBytes: AttachmentPolicy.maxSizeBytes + 1,
      );
      expect(problem?.code, ProblemCodes.attachmentTooLarge);
      expect(problem?.status, 422);
      // The message must say the real size, with a comma decimal separator.
      expect(problem?.detail, contains('25 MB'));
      expect(problem?.detail, contains('25,0'));
    });

    test('an empty file is refused before any request', () {
      final problem = AttachmentPolicy.validate(
        fileName: 'empty.png',
        contentType: AttachmentPolicy.png,
        sizeBytes: 0,
      );
      expect(problem?.code, ProblemCodes.attachmentEmpty);
    });

    test('a disallowed type is refused and the allowed ones are named', () {
      final problem = AttachmentPolicy.validate(
        fileName: 'clip.mp4',
        contentType: 'video/mp4',
        sizeBytes: 100,
      );
      expect(problem?.code, ProblemCodes.attachmentTypeNotAllowed);
      expect(problem?.detail, contains('PDF'));
      expect(problem?.detail, contains('video/mp4'));
    });

    test('a photo field narrows the list to JPEG and PNG', () {
      expect(
        AttachmentPolicy.validate(
          fileName: 'doc.pdf',
          contentType: AttachmentPolicy.pdf,
          sizeBytes: 100,
          allowed: AttachmentPolicy.photoContentTypes,
        )?.code,
        ProblemCodes.attachmentTypeNotAllowed,
      );
      expect(
        AttachmentPolicy.validate(
          fileName: 'photo.jpg',
          contentType: AttachmentPolicy.jpeg,
          sizeBytes: 100,
          allowed: AttachmentPolicy.photoContentTypes,
        ),
        isNull,
      );
    });

    test('content type is normalised and guessed from the extension', () {
      expect(
        AttachmentPolicy.normalise('IMAGE/JPEG; charset=binary'),
        'image/jpeg',
      );
      expect(AttachmentPolicy.isAllowed('image/JPEG'), isTrue);
      expect(AttachmentPolicy.contentTypeForFileName('a.JPG'), 'image/jpeg');
      expect(AttachmentPolicy.contentTypeForFileName('a.png'), 'image/png');
      expect(
        AttachmentPolicy.contentTypeForFileName('a.xlsx'),
        AttachmentPolicy.xlsx,
      );
      expect(
        AttachmentPolicy.contentTypeForFileName('a.docx'),
        AttachmentPolicy.docx,
      );
      expect(AttachmentPolicy.contentTypeForFileName('noext'), isNull);
      expect(AttachmentPolicy.contentTypeForFileName('a.mp4'), isNull);
    });

    test('checksum is lower case hex SHA-256 (NIST vector)', () {
      expect(
        AttachmentPolicy.checksumSha256(utf8.encode('abc')),
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
      );
      expect(AttachmentPolicy.checksumSha256(<int>[]), hasLength(64));
    });
  });

  group('DocumentsApi', () {
    test(
      'presign posts the contract body to /documents/attachments/presign',
      () async {
        final gateway = FakeAdapter()..enqueueJson(_presignBody(), status: 201);
        final api = _api(gateway, FakeAdapter());

        final response = await api.presign(
          const PresignAttachmentRequest(
            entityType: AttachmentEntityType.waste,
            attachmentType: AttachmentType.wastePhoto,
            fileName: 'tullanti.jpg',
            contentType: 'image/jpeg',
            sizeBytes: 2048,
            checksumSha256: 'ff',
          ),
        );

        final request = gateway.requests.single;
        expect(request.method, 'POST');
        expect(request.path, '/documents/attachments/presign');
        final body = request.data! as Map<String, Object?>;
        expect(body['entityType'], 'WASTE');
        expect(body['attachmentType'], 'WASTE_PHOTO');
        expect(body['sizeBytes'], 2048);
        expect(body['checksumSha256'], 'ff');

        expect(response.attachmentId, 42);
        expect(response.method, 'PUT');
        expect(response.maxSizeBytes, AttachmentPolicy.maxSizeBytes);
        expect(response.uploadHeaders['Content-Type'], 'image/jpeg');
        expect(
          response.isExpired(now: DateTime.utc(2026, 9, 21, 10, 20)),
          isTrue,
        );
        expect(
          response.isExpired(now: DateTime.utc(2026, 9, 21, 10, 10)),
          isFalse,
        );
      },
    );

    test('uploadBytes PUTs to storage with the signed headers only', () async {
      final storage = FakeAdapter()
        ..enqueueJson(null, contentType: 'application/xml');
      final api = _api(FakeAdapter(), storage);
      final presigned = PresignAttachmentResponse.fromJson(_presignBody());
      final progress = <List<int>>[];

      await api.uploadBytes(
        presigned: presigned,
        bytes: Uint8List.fromList(List<int>.filled(4096, 7)),
        onProgress: (sent, total) => progress.add([sent, total]),
      );

      final request = storage.requests.single;
      expect(request.method, 'PUT');
      expect(request.uri.toString(), presigned.uploadUrl);
      expect(request.headers['Content-Type'], 'image/jpeg');
      expect(request.headers['x-amz-meta-tenant'], '1');
      // No gateway concerns must leak to the object store.
      expect(request.headers.containsKey('Authorization'), isFalse);
      expect(request.headers.containsKey('Idempotency-Key'), isFalse);
      expect(progress, isNotEmpty);
      expect(progress.last, [4096, 4096]);
      expect(storage.sentBodies.single, hasLength(4096));
    });

    test('a storage rejection becomes a Failure with a visible code', () async {
      final storage = FakeAdapter()
        ..enqueueJson({'error': 'SignatureDoesNotMatch'}, status: 403);
      final api = _api(FakeAdapter(), storage);

      await expectLater(
        api.uploadBytes(
          presigned: PresignAttachmentResponse.fromJson(_presignBody()),
          bytes: Uint8List.fromList(const [1, 2, 3]),
        ),
        throwsA(
          isA<AppException>().having(
            (e) => (e.failure as ServerFailure).code,
            'code',
            ProblemCodes.storageUploadFailed,
          ),
        ),
      );
    });

    test('a storage timeout becomes a NetworkFailure', () async {
      final storage = FakeAdapter()..enqueueTimeout();
      final api = _api(FakeAdapter(), storage);

      await expectLater(
        api.uploadBytes(
          presigned: PresignAttachmentResponse.fromJson(_presignBody()),
          bytes: Uint8List.fromList(const [1]),
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.failure,
            'failure',
            isA<NetworkFailure>(),
          ),
        ),
      );
    });

    test(
      'complete sends the checksum and parses the READY attachment',
      () async {
        final gateway = FakeAdapter()..enqueueJson(_attachmentBody());
        final api = _api(gateway, FakeAdapter());

        final attachment = await api.complete(
          42,
          CompleteAttachmentRequest(checksumSha256: 'b' * 64, etag: 'etag-1'),
        );

        final request = gateway.requests.single;
        expect(request.path, '/documents/attachments/42/complete');
        final body = request.data! as Map<String, Object?>;
        expect(body['checksumSha256'], 'b' * 64);
        expect(body['etag'], 'etag-1');

        expect(attachment.id, 42);
        expect(attachment.status, AttachmentStatus.ready);
        expect(attachment.isReady, isTrue);
        expect(attachment.isRejected, isFalse);
        expect(attachment.entityType, AttachmentEntityType.waste);
        expect(attachment.attachmentType, AttachmentType.wastePhoto);
        expect(attachment.entityId, isNull);
        expect(attachment.thumbnailAvailable, isTrue);
      },
    );

    test('a rejected attachment is reported as such', () async {
      final gateway = FakeAdapter()
        ..enqueueJson(_attachmentBody(status: 'REJECTED'));
      final api = _api(gateway, FakeAdapter());
      final attachment = await api.getAttachment(42);
      expect(attachment.isReady, isFalse);
      expect(attachment.isRejected, isTrue);
      expect(attachment.status.isPending, isFalse);
    });

    test(
      'listAttachments passes the wire enum names as query parameters',
      () async {
        final gateway = FakeAdapter()..enqueueJson([_attachmentBody()]);
        final api = _api(gateway, FakeAdapter());

        final items = await api.listAttachments(
          entityType: AttachmentEntityType.goodsReceipt,
          entityId: 11,
          attachmentType: AttachmentType.deliveryNote,
        );

        final query = gateway.requests.single.queryParameters;
        expect(query['entityType'], 'GOODS_RECEIPT');
        expect(query['entityId'], 11);
        expect(query['attachmentType'], 'DELIVERY_NOTE');
        expect(items, hasLength(1));
      },
    );

    test('download-url and delete hit the documented routes', () async {
      final gateway = FakeAdapter()
        ..enqueueJson({
          'downloadUrl': 'http://localhost:9000/x?sig=2',
          'expiresAt': '2026-09-21T10:05:00Z',
          'fileName': 'tullanti.jpg',
          'contentType': 'image/jpeg',
          'sizeBytes': 2048,
        })
        ..enqueueJson(null, status: 204);
      final api = _api(gateway, FakeAdapter());

      final url = await api.downloadUrl(42, inline: true);
      expect(url.downloadUrl, contains('sig=2'));
      expect(
        gateway.requests.first.path,
        '/documents/attachments/42/download-url',
      );
      expect(gateway.requests.first.queryParameters['inline'], isTrue);

      await api.deleteAttachment(42);
      expect(gateway.requests.last.method, 'DELETE');
      expect(gateway.requests.last.path, '/documents/attachments/42');
    });
  });

  test('WmsApiClient exposes the documents module', () {
    final client = WmsApiClient(
      baseUrl: 'http://localhost:5001',
      tokenProvider: StaticTokenProvider('t'),
      enableLogging: false,
    );
    addTearDown(() => client.close(force: true));
    expect(client.documents, isA<DocumentsApi>());
    // The storage client must stay free of the gateway interceptors.
    expect(client.storageClient.interceptors.length, lessThan(2));
  });
}
