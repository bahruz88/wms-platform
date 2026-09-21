import 'package:feature_identity/feature_identity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

import '../../data/attachment_repository_impl.dart';
import '../../domain/attachment_picker.dart';
import '../../domain/attachment_repository.dart';

final attachmentRepositoryProvider = Provider<AttachmentRepository>(
  (ref) => AttachmentRepositoryImpl(ref.watch(apiClientProvider).documents),
);

/// Overridden by the apps with a camera (mobile) or file input (web) picker.
final attachmentPickerProvider = Provider<AttachmentPicker>(
  (ref) => const UnsupportedAttachmentPicker(),
);

/// Where an upload currently is. The three server steps are separate phases
/// because only the middle one has a byte count to show.
enum AttachmentUploadPhase {
  idle,

  /// Reading the file and checking size/type before any request.
  preparing,

  /// `PUT` to the presigned storage URL.
  uploading,

  /// `POST /attachments/{id}/complete` (checksum + virus scan).
  finishing,

  /// Server answered `READY` (or `SCANNING`, which is still in flight).
  done,

  failed,
}

/// Progress and outcome of the attachment block on a form.
@immutable
class AttachmentUploadState {
  const AttachmentUploadState({
    this.phase = AttachmentUploadPhase.idle,
    this.fileName,
    this.sentBytes = 0,
    this.totalBytes = 0,
    this.failure,
    this.uploaded = const <AttachmentDto>[],
  });

  final AttachmentUploadPhase phase;
  final String? fileName;
  final int sentBytes;
  final int totalBytes;
  final Failure? failure;

  /// Attachments that reached the server in this form session; their ids go
  /// into the document body (`attachmentIds`).
  final List<AttachmentDto> uploaded;

  bool get isBusy =>
      phase == AttachmentUploadPhase.preparing ||
      phase == AttachmentUploadPhase.uploading ||
      phase == AttachmentUploadPhase.finishing;

  bool get hasAttachment => uploaded.isNotEmpty;

  List<int> get attachmentIds => [for (final a in uploaded) a.id];

  /// 0..1 for the progress bar; `null` while the total is unknown, which
  /// renders an indeterminate bar instead of a wrong one.
  num? get progress {
    if (phase != AttachmentUploadPhase.uploading || totalBytes <= 0) {
      return null;
    }
    return sentBytes / totalBytes;
  }

  /// `12,4 / 25,0 MB` style label, or `null` outside the transfer.
  String? get transferredLabel {
    if (phase != AttachmentUploadPhase.uploading || totalBytes <= 0) {
      return null;
    }
    return '${_mb(sentBytes)} / ${_mb(totalBytes)} MB';
  }

  AttachmentUploadState copyWith({
    AttachmentUploadPhase? phase,
    String? fileName,
    int? sentBytes,
    int? totalBytes,
    Failure? failure,
    List<AttachmentDto>? uploaded,
    bool clearFailure = false,
  }) => AttachmentUploadState(
    phase: phase ?? this.phase,
    fileName: fileName ?? this.fileName,
    sentBytes: sentBytes ?? this.sentBytes,
    totalBytes: totalBytes ?? this.totalBytes,
    failure: clearFailure ? null : (failure ?? this.failure),
    uploaded: uploaded ?? this.uploaded,
  );

  static String _mb(int bytes) {
    final tenths = (bytes * 10 + 524288) ~/ 1048576;
    return '${tenths ~/ 10},${tenths % 10}';
  }
}

/// Drives pick → validate → presign → `PUT` → complete for one form.
///
/// The family key is the document type the files belong to, so a waste form
/// and a receipt form on the same screen stack do not share state.
final attachmentUploadProvider =
    NotifierProvider.family<
      AttachmentUploadController,
      AttachmentUploadState,
      AttachmentEntityType
    >(AttachmentUploadController.new);

class AttachmentUploadController extends Notifier<AttachmentUploadState> {
  AttachmentUploadController(this.entityType);

  /// Document type the files are attached to (`WASTE`, `GOODS_RECEIPT`...).
  final AttachmentEntityType entityType;

  @override
  AttachmentUploadState build() => const AttachmentUploadState();

  /// Picks a photo and uploads it. Safe to call twice: a second call while
  /// busy is ignored.
  Future<AttachmentDto?> pickAndUpload({
    required AttachmentType attachmentType,
    int? entityId,
    Set<String>? allowed,
  }) async {
    if (state.isBusy) return null;
    final picker = ref.read(attachmentPickerProvider);
    state = state.copyWith(
      phase: AttachmentUploadPhase.preparing,
      clearFailure: true,
    );
    final file = await picker.pickPhoto();
    if (file == null) {
      state = state.copyWith(phase: AttachmentUploadPhase.idle);
      return null;
    }
    state = state.copyWith(
      phase: AttachmentUploadPhase.uploading,
      fileName: file.fileName,
      sentBytes: 0,
      totalBytes: file.sizeBytes,
    );
    final result = await ref
        .read(attachmentRepositoryProvider)
        .upload(
          entityType: entityType,
          attachmentType: attachmentType,
          entityId: entityId,
          file: file,
          allowed: allowed ?? AttachmentPolicy.photoContentTypes,
          onProgress: (sent, total) {
            if (state.phase != AttachmentUploadPhase.uploading) return;
            state = state.copyWith(
              sentBytes: sent,
              totalBytes: total > 0 ? total : file.sizeBytes,
            );
            if (sent >= total && total > 0) {
              state = state.copyWith(phase: AttachmentUploadPhase.finishing);
            }
          },
        );
    return result.fold(
      (attachment) {
        state = state.copyWith(
          phase: AttachmentUploadPhase.done,
          uploaded: [...state.uploaded, attachment],
          clearFailure: true,
        );
        return attachment;
      },
      (failure) {
        // Upload failures are worth a breadcrumb: they usually mean MinIO or
        // its CORS configuration, not user error.
        ref
            .read(crashReporterProvider)
            .log(
              'attachment upload failed',
              extra: {'entityType': entityType.wire, 'failure': failure.kind},
            );
        state = state.copyWith(
          phase: AttachmentUploadPhase.failed,
          failure: failure,
        );
        return null;
      },
    );
  }

  /// Drops an already uploaded attachment from the form (and the server).
  Future<void> remove(int id) async {
    state = state.copyWith(
      uploaded: [
        for (final a in state.uploaded)
          if (a.id != id) a,
      ],
      phase: AttachmentUploadPhase.idle,
      clearFailure: true,
    );
    await ref.read(attachmentRepositoryProvider).remove(id);
  }

  void clearFailure() => state = state.copyWith(
    phase: AttachmentUploadPhase.idle,
    clearFailure: true,
  );

  /// Forgets the uploaded files without deleting them on the server.
  ///
  /// Called once the document has been created: from then on the ids belong
  /// to the document, not to the form, and a new draft must start empty.
  void reset() => state = const AttachmentUploadState();
}
