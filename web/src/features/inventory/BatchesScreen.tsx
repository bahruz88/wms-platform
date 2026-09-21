import { useState } from 'react';
import { Badge, DataTable, DocStatusBadge, Select, TextField, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listBatches, type Batch } from '@api/endpoints';
import { formatDate, formatNumber } from '@core/format';
import { Card, ErrorState, LoadingState, Page, ProductCell } from '@/components/Page';
import { Pager } from '@/components/Pager';

/**
 * Batches — docs/ux/screen-map.md §3.4, in the artboards' list rhythm: a 72px header, a filter
 * card, then one framed table.
 *
 * Read-only here: `changeBatchStatus` needs `inv.batch.manage` and a mandatory reason code, and
 * `EXPIRED` can never be reversed by hand (only `ExpiryScanner` sets it), so the status dialog
 * belongs with the mobile keeper flow.
 */
export function BatchesScreen() {
  const [page, setPage] = useState(1);
  const [status, setStatus] = useState<'' | 'ACTIVE' | 'QUARANTINE' | 'BLOCKED' | 'EXPIRED'>('');
  const [batchNo, setBatchNo] = useState('');

  const query = {
    page,
    size: 50,
    ...(status ? { status } : {}),
    ...(batchNo.trim() ? { batchNo: batchNo.trim() } : {}),
  };
  const batches = useApiPage<Batch>(['batches', query], () => listBatches(query), 50);

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
        ) : row.daysToExpiry <= 7 ? (
          <Badge tone="danger" dot>{`${row.daysToExpiry} gün`}</Badge>
        ) : row.daysToExpiry <= 30 ? (
          <Badge tone="warning" dot>{`${row.daysToExpiry} gün`}</Badge>
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
  ];

  return (
    <Page title="Partiyalar" subtitle="FEFO/FIFO sırası, expiry vəziyyəti və partiya blokları">
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
          subtitle="Sıralama FEFO üzrə — son istifadə tarixi yaxın olan üstdədir"
          flush
          footer={batches.data ? <Pager page={batches.data} onPageChange={setPage} /> : undefined}
        >
          <DataTable<Batch>
            columns={columns}
            rows={batches.data?.items ?? []}
            rowKey={(row) => row.id}
            label="Partiya siyahısı"
            empty="Partiya yoxdur. Partiya tələb edən məhsul qəbul edildikdə burada görünəcək."
          />
        </Card>
      )}
    </Page>
  );
}
