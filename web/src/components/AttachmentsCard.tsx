import { useRef, useState } from 'react';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { Alert, Badge, Button, DataTable, Select, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import {
  completeAttachment,
  deleteAttachment,
  getAttachmentDownloadUrl,
  listAttachments,
  presignAttachment,
  type AllowedContentType,
  type Attachment,
  type AttachmentEntityType,
  type AttachmentType,
} from '@api/endpoints';
import { useAuth } from '@auth/index';
import { formatDateTime } from '@core/format';
import { Card, ErrorState, LoadingState } from './Page';

/**
 * Document attachments — the delivery note behind a receipt, the photo behind a waste line.
 *
 * The contract's upload is three steps and the middle one does not go through the gateway:
 * `POST /documents/attachments/presign` signs a MinIO `PUT`, the browser uploads the bytes
 * straight to MinIO, then `POST /attachments/{id}/complete` hands the server a SHA-256 it
 * verifies against the stored object before the row leaves `PENDING`. Nothing here trusts the
 * browser's word that the upload happened: a row that is not `READY` is shown as not ready.
 *
 * A waste reason code with `requiresPhoto` is the reason this matters — the document cannot be
 * approved without one, and until now there was nowhere to put it.
 */

/** `AllowedContentType` — the contract's closed list; anything else is refused before upload. */
const ACCEPTED: Record<string, AllowedContentType> = {
  pdf: 'application/pdf',
  jpg: 'image/jpeg',
  jpeg: 'image/jpeg',
  png: 'image/png',
  xlsx: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  docx: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
};

const MAX_BYTES = 26_214_400;

const TYPE_LABELS: Partial<Record<AttachmentType, string>> = {
  QUOTATION: 'Təklif',
  INVOICE: 'Faktura',
  DELIVERY_NOTE: 'Qaimə',
  CERTIFICATE: 'Sertifikat',
  TEMP_PHOTO: 'Temperatur fotosu',
  WASTE_PHOTO: 'Tullantı fotosu',
  DISCREPANCY_PHOTO: 'Fərq fotosu',
  PRODUCT_IMAGE: 'Məhsul şəkli',
  CONTRACT: 'Müqavilə',
  OTHER: 'Digər',
};

const STATUS_TONE: Record<Attachment['status'], 'success' | 'warning' | 'danger' | 'neutral'> = {
  READY: 'success',
  PENDING: 'warning',
  SCANNING: 'warning',
  REJECTED: 'danger',
};

const STATUS_LABELS: Record<Attachment['status'], string> = {
  READY: 'Hazır',
  PENDING: 'Yüklənir',
  SCANNING: 'Virus yoxlanır',
  REJECTED: 'Rədd edildi',
};

/** `crypto.subtle` is present on `https` and on `localhost`; absent, the upload is not offered. */
async function sha256Hex(file: File): Promise<string> {
  const digest = await crypto.subtle.digest('SHA-256', await file.arrayBuffer());
  return [...new Uint8Array(digest)].map((b) => b.toString(16).padStart(2, '0')).join('');
}

export function contentTypeOf(fileName: string): AllowedContentType | null {
  const ext = fileName.split('.').pop()?.toLowerCase() ?? '';
  return ACCEPTED[ext] ?? null;
}

/** The reason an upload is refused before it starts, or `null` when it may proceed. */
export function rejectReason(file: { name: string; size: number }): string | null {
  if (!contentTypeOf(file.name)) {
    return `«${file.name}» qəbul edilmir — yalnız PDF, JPEG, PNG, XLSX və DOCX yüklənir.`;
  }
  if (file.size > MAX_BYTES) {
    return `«${file.name}» 25 MB həddini aşır (${Math.round(file.size / 1024 / 1024)} MB).`;
  }
  if (file.size === 0) return `«${file.name}» boşdur.`;
  return null;
}

export interface AttachmentsCardProps {
  entityType: AttachmentEntityType;
  entityId: number;
  /** The kinds this document accepts; the first is the default. */
  attachmentTypes: AttachmentType[];
  /** Shown when the document requires at least one file and has none. */
  requiredNote?: string;
}

export function AttachmentsCard({
  entityType,
  entityId,
  attachmentTypes,
  requiredNote,
}: AttachmentsCardProps) {
  const { can } = useAuth();
  const queryClient = useQueryClient();
  const fileInput = useRef<HTMLInputElement>(null);
  const [attachmentType, setAttachmentType] = useState<AttachmentType>(
    attachmentTypes[0] ?? 'OTHER',
  );
  const [refused, setRefused] = useState<string | null>(null);

  const canUpload = can('doc.attachment.upload');
  const canDelete = can('doc.attachment.delete') || can('doc.attachment.manage');
  const secure = typeof crypto !== 'undefined' && typeof crypto.subtle?.digest === 'function';

  const key = ['attachments', entityType, entityId] as const;
  const attachments = useApiPage<Attachment>(
    key,
    () => listAttachments({ entityType, entityId }),
    100,
    { retry: false },
  );

  const invalidate = () => void queryClient.invalidateQueries({ queryKey: key });

  /** presign → PUT to MinIO → complete. The bytes never pass through the gateway. */
  const upload = useMutation({
    mutationFn: async (file: File) => {
      const contentType = contentTypeOf(file.name);
      if (!contentType) throw new Error('Fayl tipi qəbul edilmir.');
      const checksum = await sha256Hex(file);
      const presigned = await presignAttachment({
        entityType,
        entityId,
        attachmentType,
        fileName: file.name,
        contentType,
        sizeBytes: file.size,
        checksumSha256: checksum,
      });
      // The bytes are sent as a `Blob` read out of the file up front rather than as the `File`
      // itself: a `File` is a live handle on the picked entry, and the input it came from is
      // reset as soon as the upload starts (so the same file can be chosen twice). Handing
      // `fetch` a detached copy keeps those two facts from meeting.
      const bytes = await file.arrayBuffer();
      const response = await fetch(presigned.uploadUrl, {
        method: 'PUT',
        headers: presigned.uploadHeaders,
        body: new Blob([bytes], { type: contentType }),
      });
      if (!response.ok) {
        throw new Error(
          `MinIO yükləməni qəbul etmədi (${response.status}). Obyekt anbarı əlçatmaz ola bilər.`,
        );
      }
      return completeAttachment(presigned.attachmentId, checksum);
    },
    onSuccess: invalidate,
  });

  const remove = useMutation({ mutationFn: deleteAttachment, onSuccess: invalidate });

  const open = useMutation({
    mutationFn: async (id: number) => getAttachmentDownloadUrl(id, true),
    onSuccess: (result) => window.open(result.downloadUrl, '_blank', 'noopener'),
  });

  const pick = (file: File | undefined) => {
    if (!file) return;
    const reason = rejectReason(file);
    setRefused(reason);
    if (!reason) upload.mutate(file);
    if (fileInput.current) fileInput.current.value = '';
  };

  const rows = attachments.data?.items ?? [];

  const columns: Column<Attachment>[] = [
    {
      key: 'fileName',
      header: 'Fayl',
      render: (row) => (
        <div>
          <div className="wms-cell__name">{row.fileName}</div>
          <div className="wms-cell__sku wms-num">
            {row.contentType} · {Math.max(1, Math.round(row.sizeBytes / 1024))} KB
          </div>
        </div>
      ),
    },
    {
      key: 'attachmentType',
      header: 'Növ',
      width: '170px',
      render: (row) => (
        <Badge tone="neutral">{TYPE_LABELS[row.attachmentType] ?? row.attachmentType}</Badge>
      ),
    },
    {
      key: 'status',
      header: 'Vəziyyət',
      width: '150px',
      render: (row) => (
        <Badge
          tone={STATUS_TONE[row.status]}
          dot={row.status !== 'READY'}
          title={row.scanResult ?? undefined}
        >
          {STATUS_LABELS[row.status]}
        </Badge>
      ),
    },
    {
      key: 'uploadedAt',
      header: 'Yüklənib',
      width: '160px',
      render: (row) => <span className="wms-num wms-small">{formatDateTime(row.uploadedAt)}</span>,
    },
    {
      key: 'act',
      header: '',
      width: '170px',
      render: (row) => (
        <div className="wms-row">
          <Button
            size="sm"
            variant="ghost"
            disabled={row.status !== 'READY' || open.isPending}
            title={row.status !== 'READY' ? 'Yalnız `READY` əlavə açılır' : undefined}
            onClick={() => open.mutate(row.id)}
          >
            Aç
          </Button>
          {canDelete ? (
            <Button
              size="sm"
              variant="ghost"
              loading={remove.isPending}
              onClick={() => remove.mutate(row.id)}
            >
              Sil
            </Button>
          ) : null}
        </div>
      ),
    },
  ];

  return (
    <Card
      title="Əlavələr"
      subtitle={`${rows.length} fayl · maksimum 25 MB · PDF, JPEG, PNG, XLSX, DOCX`}
      flush
      actions={
        canUpload && secure ? (
          <div className="wms-row">
            {attachmentTypes.length > 1 ? (
              <Select
                value={attachmentType}
                options={attachmentTypes.map((t) => ({
                  value: t,
                  label: TYPE_LABELS[t] ?? t,
                }))}
                onChange={(e) => setAttachmentType(e.target.value as AttachmentType)}
              />
            ) : null}
            <input
              ref={fileInput}
              type="file"
              hidden
              accept=".pdf,.jpg,.jpeg,.png,.xlsx,.docx"
              onChange={(e) => pick(e.target.files?.[0])}
            />
            <Button
              size="sm"
              variant="primary"
              loading={upload.isPending}
              onClick={() => fileInput.current?.click()}
            >
              Fayl yüklə
            </Button>
          </div>
        ) : (
          <Button
            size="sm"
            disabled
            title={
              canUpload
                ? 'Brauzer `crypto.subtle` təqdim etmir — checksum hesablana bilmir (HTTPS tələb olunur)'
                : '`doc.attachment.upload` icazəniz yoxdur'
            }
          >
            Fayl yüklə
          </Button>
        )
      }
    >
      {refused ? (
        <div className="wms-card__body">
          <Alert tone="warning" title="Fayl qəbul edilmədi" code="VALIDATION_FAILED">
            {refused}
          </Alert>
        </div>
      ) : null}

      {upload.isError ? (
        <div className="wms-card__body">
          <ErrorState error={upload.error} />
        </div>
      ) : null}
      {remove.isError ? (
        <div className="wms-card__body">
          <ErrorState error={remove.error} />
        </div>
      ) : null}
      {open.isError ? (
        <div className="wms-card__body">
          <ErrorState error={open.error} />
        </div>
      ) : null}

      {requiredNote && rows.length === 0 && !attachments.isLoading && !attachments.isError ? (
        <div className="wms-card__body">
          <Alert tone="warning" title="Əlavə tələb olunur" code="VALIDATION_FAILED">
            {requiredNote}
          </Alert>
        </div>
      ) : null}

      {attachments.isLoading ? (
        <LoadingState />
      ) : attachments.isError ? (
        <div className="wms-card__body">
          <ErrorState error={attachments.error} onRetry={() => void attachments.refetch()} />
        </div>
      ) : (
        <DataTable<Attachment>
          columns={columns}
          rows={rows}
          rowKey={(row) => row.id}
          label="Sənədin əlavələri"
          empty="Əlavə yoxdur. Qaimə, faktura və ya foto «Fayl yüklə» ilə əlavə edilir."
        />
      )}
    </Card>
  );
}
