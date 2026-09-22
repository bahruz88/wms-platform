import { useState } from 'react';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import {
  Alert,
  Badge,
  Button,
  DataTable,
  Dialog,
  DocStatusBadge,
  Select,
  TextField,
  type Column,
} from '@ds/index';
import { useApiPage } from '@api/hooks';
import { changeBatchStatus, listBatches, type Batch } from '@api/endpoints';
import { settingsUnavailableNote, useInventorySettings } from '@api/settings';
import { useAuth } from '@auth/index';
import { formatDate, formatNumber } from '@core/format';
import { Card, ErrorState, LoadingState, Page, ProductCell } from '@/components/Page';
import { Pager } from '@/components/Pager';
import { ReasonCodePicker } from '@/components/ReasonCodePicker';

/**
 * Batches — docs/ux/screen-map.md §3.4, in the artboards' list rhythm: a 72px header, a filter
 * card, then one framed table.
 *
 * The status dialog belongs here as well as on mobile: blocking or quarantining a batch is a
 * quality decision taken at a desk as often as at a shelf, and `POST /batches/{id}/status` is
 * served. Two rules from §3.4 are enforced before the request goes out, so the user is told
 * rather than 409'd:
 *
 *   · the reason code is mandatory — it goes through `ReasonCodePicker`, which explains itself
 *     when the reason-code list is unavailable instead of rendering an empty dropdown;
 *   · `EXPIRED` is never set or cleared by hand — only `ExpiryScanner` writes it, so an expired
 *     batch has no action and the option is not offered.
 */

/** The statuses a person may set. `EXPIRED` is deliberately absent (screen-map §3.4). */
export const MANUAL_BATCH_STATUSES = ['ACTIVE', 'BLOCKED', 'QUARANTINE'] as const;
export type ManualBatchStatus = (typeof MANUAL_BATCH_STATUSES)[number];

/** True when a person may change this batch's status at all. */
export function isManuallyChangeable(status: string): boolean {
  return status !== 'EXPIRED';
}

export function BatchesScreen() {
  const { can } = useAuth();
  // The expiry badges used to compare against 7 and 30 written into this file. They are tenant
  // settings (TOR §36) and are read as such: when a threshold is not in the answer the badge is
  // not drawn at all, because a colour is a claim about the tenant's configuration.
  const settings = useInventorySettings('batches');
  const warningDays = settings.get('expiry_warning_days');
  const criticalDays = settings.get('expiry_critical_days');
  const queryClient = useQueryClient();
  const [page, setPage] = useState(1);
  const [status, setStatus] = useState<'' | 'ACTIVE' | 'QUARANTINE' | 'BLOCKED' | 'EXPIRED'>('');
  const [batchNo, setBatchNo] = useState('');
  const [target, setTarget] = useState<Batch | null>(null);
  const [nextStatus, setNextStatus] = useState<ManualBatchStatus>('BLOCKED');
  const [reasonCodeId, setReasonCodeId] = useState('');
  const [note, setNote] = useState('');

  const query = {
    page,
    size: 50,
    ...(status ? { status } : {}),
    ...(batchNo.trim() ? { batchNo: batchNo.trim() } : {}),
  };
  const batches = useApiPage<Batch>(['batches', query], () => listBatches(query), 50);

  const change = useMutation({
    mutationFn: () =>
      changeBatchStatus(
        Number(target?.id ?? 0),
        target?.rowVersion ?? 1,
        nextStatus,
        Number(reasonCodeId),
        note.trim() || undefined,
      ),
    onSuccess: () => {
      setTarget(null);
      setReasonCodeId('');
      setNote('');
      void queryClient.invalidateQueries({ queryKey: ['batches'] });
    },
  });

  const openDialog = (row: Batch) => {
    setTarget(row);
    setNextStatus(row.status === 'ACTIVE' ? 'BLOCKED' : 'ACTIVE');
    setReasonCodeId('');
    setNote('');
    change.reset();
  };

  const columns: Column<Batch>[] = [
    {
      key: 'batchNo',
      header: 'Partiya',
      width: '150px',
      render: (row) => <span className="wms-doc-no">{row.batchNo}</span>,
    },
    {
      key: 'product',
      header: 'Məhsul',
      render: (row) => <ProductCell name={row.product.name} sku={row.product.sku} />,
    },
    {
      key: 'expiryDate',
      header: 'Son istifadə',
      width: '130px',
      render: (row) => <span className="wms-num wms-small">{formatDate(row.expiryDate)}</span>,
    },
    {
      key: 'daysToExpiry',
      header: 'Qalan gün',
      width: '130px',
      numeric: true,
      decimals: 0,
      render: (row) =>
        row.daysToExpiry === null || row.daysToExpiry === undefined ? (
          <span className="wms-muted">—</span>
        ) : row.daysToExpiry < 0 ? (
          <Badge tone="danger" dot>{`${Math.abs(row.daysToExpiry)} gün keçib`}</Badge>
        ) : criticalDays !== null && row.daysToExpiry <= criticalDays ? (
          <Badge
            tone="danger"
            dot
            title={`expiry_critical_days = ${criticalDays}`}
          >{`${row.daysToExpiry} gün`}</Badge>
        ) : warningDays !== null && row.daysToExpiry <= warningDays ? (
          <Badge
            tone="warning"
            dot
            title={`expiry_warning_days = ${warningDays}`}
          >{`${row.daysToExpiry} gün`}</Badge>
        ) : (
          formatNumber(row.daysToExpiry, 0)
        ),
    },
    { key: 'qtyOnHand', header: 'Qalıq (base)', width: '150px', numeric: true, decimals: 4 },
    {
      key: 'status',
      header: 'Status',
      width: '140px',
      render: (row) => <DocStatusBadge status={row.status} />,
    },
    {
      key: 'receivedAt',
      header: 'Qəbul',
      width: '120px',
      render: (row) => <span className="wms-num wms-small">{formatDate(row.receivedAt)}</span>,
    },
    {
      key: 'act',
      header: '',
      width: '140px',
      permission: 'inv.batch.manage',
      render: (row) =>
        isManuallyChangeable(row.status) ? (
          <Button size="sm" onClick={() => openDialog(row)}>
            Status dəyiş
          </Button>
        ) : (
          <Button size="sm" disabled title="EXPIRED statusu əl ilə dəyişdirilmir (§3.4)">
            Status dəyiş
          </Button>
        ),
    },
  ];

  return (
    <Page title="Partiyalar" subtitle="FEFO/FIFO sırası, expiry vəziyyəti və partiya blokları">
      {settings.unavailable ? (
        <Alert
          tone="warning"
          title="Expiry hədləri tenant parametrindən oxunmadı"
          code={settings.code ?? undefined}
        >
          {settingsUnavailableNote(settings.status)}
        </Alert>
      ) : null}

      <Card>
        <div className="wms-toolbar">
          <Select
            label="Status"
            value={status}
            placeholder="Bütün statuslar"
            options={[
              { value: 'ACTIVE', label: 'Aktiv' },
              { value: 'QUARANTINE', label: 'Karantində' },
              { value: 'BLOCKED', label: 'Bloklanıb' },
              { value: 'EXPIRED', label: 'Vaxtı keçib' },
            ]}
            onChange={(e) => {
              setStatus(e.target.value as typeof status);
              setPage(1);
            }}
          />
          <TextField
            label="Partiya nömrəsi"
            mono
            value={batchNo}
            placeholder="BSB-2602-B"
            onChange={(e) => {
              setBatchNo(e.target.value);
              setPage(1);
            }}
          />
          <div className="wms-toolbar__spacer" />
        </div>
      </Card>

      {batches.isLoading ? (
        <LoadingState />
      ) : batches.isError ? (
        <ErrorState error={batches.error} onRetry={() => void batches.refetch()} />
      ) : (
        <Card
          title="Partiyalar"
          subtitle={`Sıralama FEFO üzrə — son istifadə tarixi yaxın olan üstdədir · xəbərdarlıq ${warningDays} gün, kritik ${criticalDays} gün`}
          flush
          footer={batches.data ? <Pager page={batches.data} onPageChange={setPage} /> : undefined}
        >
          <DataTable<Batch>
            columns={columns}
            rows={batches.data?.items ?? []}
            permissions={can('inv.batch.manage') ? ['inv.batch.manage'] : []}
            rowKey={(row) => row.id}
            label="Partiya siyahısı"
            empty="Partiya yoxdur. Partiya tələb edən məhsul qəbul edildikdə burada görünəcək."
          />
        </Card>
      )}

      <Dialog
        open={target !== null}
        title="Partiyanın statusunu dəyişim?"
        subtitle="Status dəyişikliyi audit jurnalına düşür və balansın istifadəyə yararlı hissəsini dəyişir."
        onClose={change.isPending ? undefined : () => setTarget(null)}
        footer={
          <>
            <Button
              disabled={change.isPending}
              title={change.isPending ? 'Sorğu göndərilir' : undefined}
              onClick={() => setTarget(null)}
            >
              İmtina
            </Button>
            <Button
              variant={nextStatus === 'ACTIVE' ? 'primary' : 'danger'}
              loading={change.isPending}
              disabled={!reasonCodeId}
              title={!reasonCodeId ? 'Səbəb kodu məcburidir' : undefined}
              onClick={() => change.mutate()}
            >
              Statusu dəyiş
            </Button>
          </>
        }
      >
        <div className="wms-stack">
          {change.isError ? <ErrorState error={change.error} /> : null}
          <span>
            <span className="wms-doc-no">{target?.batchNo}</span> — {target?.product.name}. Hazırkı
            status: <span className="wms-num">{target?.status}</span>.
          </span>
          <Select
            label="Yeni status"
            required
            value={nextStatus}
            options={[
              { value: 'ACTIVE', label: 'Aktiv — istifadəyə açılır' },
              { value: 'BLOCKED', label: 'Bloklanıb — məxaric edilmir' },
              { value: 'QUARANTINE', label: 'Karantində — yoxlama gözləyir' },
            ]}
            hint="`EXPIRED` siyahıda yoxdur: onu yalnız ExpiryScanner qoyur və geri götürür."
            onChange={(e) => setNextStatus(e.target.value as ManualBatchStatus)}
          />
          <ReasonCodePicker
            reasonGroup="ADJUSTMENT"
            cacheKey="batch-status"
            value={reasonCodeId}
            onChange={setReasonCodeId}
          />
          <TextField
            label="Qeyd"
            value={note}
            hint="Nə üçün dəyişdirilir — audit jurnalında görünür."
            onChange={(e) => setNote(e.target.value)}
          />
          {nextStatus !== 'ACTIVE' ? (
            <Alert tone="warning" title="Bloklanmış partiya məxaric edilmir">
              Bu partiya üzərindən yeni məxaric və transfer yazılmayacaq; mövcud sənədlər dəyişmir.
            </Alert>
          ) : null}
        </div>
      </Dialog>
    </Page>
  );
}
