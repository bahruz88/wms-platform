import { useState } from 'react';
import { Badge, DataTable, DocStatusBadge, Select, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listBatches, type Batch } from '@api/endpoints';
import { formatDate } from '@core/format';
import { ErrorState, LoadingState, Page, Section } from '@/components/Page';
import { Pager } from '@/components/Pager';

/**
 * Batches — docs/ux/screen-map.md §3.4. Read-only here: `changeBatchStatus` needs
 * `inv.batch.manage` and a mandatory reason code, and `EXPIRED` can never be reversed by hand
 * (only `ExpiryScanner` sets it) — so the status dialog belongs with the mobile keeper flow.
 */
export function BatchesScreen() {
  const [page, setPage] = useState(1);
  const [status, setStatus] = useState<'' | 'ACTIVE' | 'QUARANTINE' | 'BLOCKED' | 'EXPIRED'>('');

  const query = { page, size: 50, ...(status ? { status } : {}) };
  const batches = useApiPage<Batch>(['batches', query], () => listBatches(query), 50);

  const columns: Column<Batch>[] = [
    {
      key: 'batchNo',
      header: 'Partiya',
      render: (row) => <span className="wms-doc-no">{row.batchNo}</span>,
    },
    {
      key: 'sku',
      header: 'SKU',
      render: (row) => <span className="wms-doc-no">{row.product.sku}</span>,
    },
    { key: 'product', header: 'Məhsul', render: (row) => row.product.name },
    { key: 'expiryDate', header: 'Son istifadə', render: (row) => formatDate(row.expiryDate) },
    {
      key: 'daysToExpiry',
      header: 'Qalan gün',
      numeric: true,
      decimals: 0,
      render: (row) =>
        row.daysToExpiry === null || row.daysToExpiry === undefined ? (
          <span className="wms-muted">—</span>
        ) : row.daysToExpiry < 0 ? (
          <Badge tone="danger">{`${Math.abs(row.daysToExpiry)} gün keçib`}</Badge>
        ) : row.daysToExpiry <= 7 ? (
          <Badge tone="danger">{`${row.daysToExpiry} gün`}</Badge>
        ) : (
          String(row.daysToExpiry)
        ),
    },
    { key: 'qtyOnHand', header: 'Qalıq (base)', numeric: true, decimals: 4 },
    { key: 'status', header: 'Status', render: (row) => <DocStatusBadge status={row.status} /> },
    { key: 'receivedAt', header: 'Qəbul', render: (row) => formatDate(row.receivedAt) },
  ];

  return (
    <Page title="Partiyalar" subtitle="FEFO/FIFO sırası, expiry vəziyyəti və partiya blokları">
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
      </div>
      <Section>
        {batches.isLoading ? (
          <LoadingState />
        ) : batches.isError ? (
          <ErrorState error={batches.error} onRetry={() => void batches.refetch()} />
        ) : (
          <>
            <DataTable<Batch>
              columns={columns}
              rows={batches.data?.items ?? []}
              rowKey={(row) => row.id}
              label="Partiya siyahısı"
              empty="Partiya yoxdur. Partiya tələb edən məhsul qəbul edildikdə burada görünəcək."
            />
            {batches.data ? <Pager page={batches.data} onPageChange={setPage} /> : null}
          </>
        )}
      </Section>
    </Page>
  );
}
