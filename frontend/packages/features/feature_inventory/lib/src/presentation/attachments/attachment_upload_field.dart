import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';

import 'attachment_upload_controller.dart';

/// Attachment block of a document form: pick, progress, error, file list.
///
/// The upload goes straight to object storage through a presigned URL
/// (`documents.v1.yaml`); this widget only reflects
/// [AttachmentUploadController]'s state. Server problems are rendered with
/// `WmsAlert`, so the RFC 7807 `code` stays on screen.
class AttachmentUploadField extends ConsumerWidget {
  const AttachmentUploadField({
    required this.entityType,
    required this.attachmentType,
    required this.label,
    this.required = false,
    this.hint,
    this.entityId,
    super.key,
  });

  final AttachmentEntityType entityType;
  final AttachmentType attachmentType;
  final String label;

  /// Marks the block as mandatory (`reason_code.requires_photo`).
  final bool required;
  final String? hint;

  /// `null` before the document exists; the ids are linked on create.
  final int? entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = WmsColors.of(context);
    final provider = attachmentUploadProvider(entityType);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final picker = ref.watch(attachmentPickerProvider);
    final unsatisfied = required && !state.hasAttachment;

    return Container(
      padding: WmsSpacing.cardPadding,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: WmsRadius.lgAll,
        border: Border.all(color: unsatisfied ? c.warning : c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.photo_camera_outlined,
                size: 16,
                color: state.hasAttachment ? c.success : c.inkMuted,
              ),
              const SizedBox(width: WmsSpacing.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      required ? '$label *' : label,
                      style: WmsTypography.bodyStrong.copyWith(color: c.ink),
                    ),
                    Text(
                      hint ?? _defaultHint(state.hasAttachment),
                      style: WmsTypography.caption.copyWith(color: c.inkMuted),
                    ),
                  ],
                ),
              ),
              WmsButton(
                label: state.hasAttachment ? 'Daha bir foto' : 'Foto əlavə et',
                size: WmsButtonSize.sm,
                iconLeft: Icons.add_a_photo_outlined,
                loading: state.isBusy,
                enabled: picker.isAvailable && !state.isBusy,
                disabledReason: picker.isAvailable
                    ? null
                    : 'Bu platformada fayl seçmək mümkün deyil',
                onPressed: () => controller.pickAndUpload(
                  attachmentType: attachmentType,
                  entityId: entityId,
                ),
              ),
            ],
          ),
          if (state.isBusy) ...[
            const SizedBox(height: WmsSpacing.space3),
            _UploadProgress(state: state),
          ],
          if (state.failure != null) ...[
            const SizedBox(height: WmsSpacing.space3),
            WmsAlert.fromFailure(
              state.failure!,
              onClose: controller.clearFailure,
            ),
          ],
          for (final attachment in state.uploaded) ...[
            const SizedBox(height: WmsSpacing.space2),
            _UploadedRow(
              attachment: attachment,
              onRemove: state.isBusy
                  ? null
                  : () => controller.remove(attachment.id),
            ),
          ],
        ],
      ),
    );
  }

  static String _defaultHint(bool hasAttachment) => hasAttachment
      ? 'Sənəd yaradılarkən fayl ona bağlanır.'
      : 'JPEG və ya PNG, ən çox 25 MB.';
}

class _UploadProgress extends StatelessWidget {
  const _UploadProgress({required this.state});

  final AttachmentUploadState state;

  @override
  Widget build(BuildContext context) {
    final c = WmsColors.of(context);
    final label = switch (state.phase) {
      AttachmentUploadPhase.preparing => 'Fayl hazırlanır…',
      AttachmentUploadPhase.uploading =>
        state.transferredLabel ?? 'Fayl göndərilir…',
      AttachmentUploadPhase.finishing => 'Server yoxlayır (checksum, skan)…',
      _ => '',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: WmsRadius.smAll,
          child: LinearProgressIndicator(
            value: state.progress?.toDouble(),
            minHeight: 6,
            backgroundColor: c.surfaceSunken,
            color: c.accent,
          ),
        ),
        const SizedBox(height: WmsSpacing.space1),
        Row(
          children: [
            Expanded(
              child: Text(
                state.fileName ?? '',
                overflow: TextOverflow.ellipsis,
                style: WmsTypography.caption.copyWith(color: c.inkMuted),
              ),
            ),
            Text(
              label,
              style: WmsTypography.figureSm.copyWith(color: c.inkMuted),
            ),
          ],
        ),
      ],
    );
  }
}

class _UploadedRow extends StatelessWidget {
  const _UploadedRow({required this.attachment, this.onRemove});

  final AttachmentDto attachment;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final c = WmsColors.of(context);
    return Row(
      children: [
        Icon(Icons.attachment_outlined, size: 16, color: c.inkMuted),
        const SizedBox(width: WmsSpacing.space2),
        Expanded(
          child: Text(
            attachment.fileName,
            overflow: TextOverflow.ellipsis,
            style: WmsTypography.body.copyWith(color: c.ink),
          ),
        ),
        const SizedBox(width: WmsSpacing.space2),
        WmsBadge(
          text: _statusLabel(attachment.status),
          tone: switch (attachment.status) {
            AttachmentStatus.ready => WmsTone.success,
            AttachmentStatus.rejected => WmsTone.danger,
            AttachmentStatus.pending ||
            AttachmentStatus.scanning => WmsTone.warning,
          },
        ),
        const SizedBox(width: WmsSpacing.space2),
        WmsIconButton(
          icon: Icons.delete_outline,
          label: 'Faylı sil',
          onPressed: onRemove,
        ),
      ],
    );
  }

  static String _statusLabel(AttachmentStatus status) => switch (status) {
    AttachmentStatus.pending => 'Gözləyir',
    AttachmentStatus.scanning => 'Yoxlanılır',
    AttachmentStatus.ready => 'Hazır',
    AttachmentStatus.rejected => 'Rədd edildi',
  };
}
