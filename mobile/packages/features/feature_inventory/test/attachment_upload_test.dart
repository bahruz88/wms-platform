import 'dart:typed_data';

import 'package:feature_inventory/feature_inventory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import 'fake_attachment_repository.dart';

PickedAttachment photo({int bytes = 2048, String name = 'tullanti.jpg'}) =>
    PickedAttachment(
      fileName: name,
      contentType: 'image/jpeg',
      bytes: Uint8List.fromList(List<int>.filled(bytes, 1)),
    );

ProviderContainer container({
  required AttachmentRepository repository,
  AttachmentPicker picker = const UnsupportedAttachmentPicker(),
}) {
  final c = ProviderContainer(
    overrides: [
      attachmentRepositoryProvider.overrideWithValue(repository),
      attachmentPickerProvider.overrideWithValue(picker),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

Widget host({
  required AttachmentRepository repository,
  required AttachmentPicker picker,
  bool required = false,
}) => ProviderScope(
  overrides: [
    attachmentRepositoryProvider.overrideWithValue(repository),
    attachmentPickerProvider.overrideWithValue(picker),
  ],
  child: MaterialApp(
    theme: WmsTheme.light(),
    locale: WmsL10n.defaultLocale,
    supportedLocales: WmsL10n.supportedLocales,
    localizationsDelegates: WmsL10n.delegates,
    home: Scaffold(
      body: AttachmentUploadField(
        entityType: AttachmentEntityType.waste,
        attachmentType: AttachmentType.wastePhoto,
        label: 'Foto',
        required: required,
      ),
    ),
  ),
);

void main() {
  group('AttachmentUploadState', () {
    test('is idle and empty before anything happens', () {
      const state = AttachmentUploadState();
      expect(state.phase, AttachmentUploadPhase.idle);
      expect(state.isBusy, isFalse);
      expect(state.hasAttachment, isFalse);
      expect(state.attachmentIds, isEmpty);
      expect(state.progress, isNull);
      expect(state.transferredLabel, isNull);
    });

    test('progress is only reported during the transfer', () {
      const uploading = AttachmentUploadState(
        phase: AttachmentUploadPhase.uploading,
        sentBytes: 524288,
        totalBytes: 1048576,
      );
      expect(uploading.progress, 0.5);
      expect(uploading.transferredLabel, '0,5 / 1,0 MB');
      expect(uploading.isBusy, isTrue);

      const finishing = AttachmentUploadState(
        phase: AttachmentUploadPhase.finishing,
        sentBytes: 1048576,
        totalBytes: 1048576,
      );
      expect(
        finishing.progress,
        isNull,
        reason: 'indeterminate while the server verifies',
      );
      expect(finishing.isBusy, isTrue);
    });

    test('an unknown total renders an indeterminate bar, not a wrong one', () {
      const state = AttachmentUploadState(
        phase: AttachmentUploadPhase.uploading,
        sentBytes: 10,
      );
      expect(state.progress, isNull);
    });
  });

  group('AttachmentUploadController', () {
    test('a cancelled picker leaves the form untouched', () async {
      final repository = FakeAttachmentRepository();
      final c = container(
        repository: repository,
        picker: const StaticAttachmentPicker(null),
      );
      final provider = attachmentUploadProvider(AttachmentEntityType.waste);

      final result = await c
          .read(provider.notifier)
          .pickAndUpload(attachmentType: AttachmentType.wastePhoto);

      expect(result, isNull);
      expect(repository.uploads, isEmpty);
      expect(c.read(provider).phase, AttachmentUploadPhase.idle);
    });

    test('a successful upload ends in done and carries the id', () async {
      final repository = FakeAttachmentRepository();
      final c = container(
        repository: repository,
        picker: StaticAttachmentPicker(photo()),
      );
      final provider = attachmentUploadProvider(AttachmentEntityType.waste);

      final attachment = await c
          .read(provider.notifier)
          .pickAndUpload(attachmentType: AttachmentType.wastePhoto);

      expect(attachment?.id, 42);
      final state = c.read(provider);
      expect(state.phase, AttachmentUploadPhase.done);
      expect(state.hasAttachment, isTrue);
      expect(state.attachmentIds, [42]);
      expect(state.fileName, 'tullanti.jpg');
      expect(state.failure, isNull);
      expect(repository.uploads.single.sizeBytes, 2048);
    });

    test('the entity type of the family reaches the repository', () async {
      final repository = _RecordingEntityRepository();
      final c = container(
        repository: repository,
        picker: StaticAttachmentPicker(photo()),
      );
      await c
          .read(
            attachmentUploadProvider(AttachmentEntityType.goodsReceipt)
                .notifier,
          )
          .pickAndUpload(attachmentType: AttachmentType.deliveryNote);
      expect(repository.entityTypes, [AttachmentEntityType.goodsReceipt]);
      expect(repository.attachmentTypes, [AttachmentType.deliveryNote]);
    });

    test('a server failure is kept as a Failure with its code', () async {
      final repository = FakeAttachmentRepository(
        failure: ConflictFailure(
          ProblemDetails.local(
            code: 'INVALID_STATE_TRANSITION',
            title: 'Artıq READY',
            status: 409,
          ),
        ),
      );
      final c = container(
        repository: repository,
        picker: StaticAttachmentPicker(photo()),
      );
      final provider = attachmentUploadProvider(AttachmentEntityType.waste);

      await c
          .read(provider.notifier)
          .pickAndUpload(attachmentType: AttachmentType.wastePhoto);

      final state = c.read(provider);
      expect(state.phase, AttachmentUploadPhase.failed);
      expect(
        (state.failure! as ServerFailure).code,
        'INVALID_STATE_TRANSITION',
      );
      expect(state.hasAttachment, isFalse);

      c.read(provider.notifier).clearFailure();
      expect(c.read(provider).failure, isNull);
      expect(c.read(provider).phase, AttachmentUploadPhase.idle);
    });

    test('a file over 25 MB never reaches the network', () async {
      final repository = FakeAttachmentRepository();
      final c = container(
        repository: repository,
        picker: StaticAttachmentPicker(
          photo(bytes: AttachmentPolicy.maxSizeBytes + 1, name: 'big.jpg'),
        ),
      );
      final provider = attachmentUploadProvider(AttachmentEntityType.waste);

      await c
          .read(provider.notifier)
          .pickAndUpload(attachmentType: AttachmentType.wastePhoto);

      final state = c.read(provider);
      expect(state.phase, AttachmentUploadPhase.failed);
      expect(
        (state.failure! as ServerFailure).code,
        ProblemCodes.attachmentTooLarge,
      );
    });

    test(
      'removing an attachment clears it locally and on the server',
      () async {
        final repository = FakeAttachmentRepository();
        final c = container(
          repository: repository,
          picker: StaticAttachmentPicker(photo()),
        );
        final provider = attachmentUploadProvider(AttachmentEntityType.waste);
        await c
            .read(provider.notifier)
            .pickAndUpload(attachmentType: AttachmentType.wastePhoto);

        await c.read(provider.notifier).remove(42);

        expect(c.read(provider).attachmentIds, isEmpty);
        expect(repository.removed, [42]);
      },
    );
  });

  group('AttachmentUploadField', () {
    testWidgets('picking a photo shows the file and its READY state', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          repository: FakeAttachmentRepository(),
          picker: StaticAttachmentPicker(photo()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Foto əlavə et'), findsOneWidget);
      await tester.tap(find.text('Foto əlavə et'));
      await tester.pumpAndSettle();

      expect(find.text('tullanti.jpg'), findsOneWidget);
      expect(find.text('Hazır'), findsOneWidget);
      expect(find.text('Daha bir foto'), findsOneWidget);
    });

    testWidgets('a rejected upload shows the RFC 7807 code in an alert', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          repository: FakeAttachmentRepository(
            failure: ValidationFailure(
              ProblemDetails.local(
                code: 'CHECKSUM_MISMATCH',
                title: 'Checksum uyğun gəlmir',
                status: 422,
              ),
            ),
          ),
          picker: StaticAttachmentPicker(photo()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Foto əlavə et'));
      await tester.pumpAndSettle();

      expect(find.byType(WmsAlert), findsOneWidget);
      expect(find.text('Checksum uyğun gəlmir'), findsOneWidget);
      expect(find.textContaining('CHECKSUM_MISMATCH'), findsOneWidget);
    });

    testWidgets('without a picker the button explains why it is disabled', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          repository: FakeAttachmentRepository(),
          picker: const UnsupportedAttachmentPicker(),
          required: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Foto *'), findsOneWidget);
      final button = tester.widget<WmsButton>(find.byType(WmsButton));
      expect(button.enabled, isFalse);
      expect(button.disabledReason, isNotNull);
    });
  });

  group('PickedAttachment', () {
    test('reports its own size', () {
      final file = photo(bytes: 10);
      expect(file.sizeBytes, 10);
      expect(file.toString(), contains('tullanti.jpg'));
    });

    test('the unsupported picker returns nothing', () async {
      const picker = UnsupportedAttachmentPicker();
      expect(picker.isAvailable, isFalse);
      expect(await picker.pickPhoto(), isNull);
    });
  });
}

class _RecordingEntityRepository extends FakeAttachmentRepository {
  final List<AttachmentEntityType> entityTypes = [];
  final List<AttachmentType> attachmentTypes = [];

  @override
  Future<Result<AttachmentDto>> upload({
    required AttachmentEntityType entityType,
    required AttachmentType attachmentType,
    required PickedAttachment file,
    int? entityId,
    Set<String>? allowed,
    UploadProgress? onProgress,
    CancelToken? cancelToken,
  }) {
    entityTypes.add(entityType);
    attachmentTypes.add(attachmentType);
    return super.upload(
      entityType: entityType,
      attachmentType: attachmentType,
      file: file,
      entityId: entityId,
      allowed: allowed,
      onProgress: onProgress,
      cancelToken: cancelToken,
    );
  }
}
