import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import {
  Badge,
  Button,
  DataTable,
  DocStatusBadge,
  Select,
  TextField,
  type Column,
} from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listGoodsReceipts, type GoodsReceiptSummary } from '@api/endpoints';
import { useAuth } from '@auth/index';
import { formatDate } from '@core/format';
import { Card, ErrorState, LoadingState, Page } from '@/components/Page';
import { Pager } from '@/components/Pager';

/**
 * Goods receipts — the list behind the artboard's «Qəbul» entry.
 *
 * `GET /inventory/goods-receipts` is routed and answering, so the "open a document by id"
 * workaround this screen used to carry — and the notice that told the user the list endpoint was
 * not open — are gone. What is left is the artboards' list rhythm: a filter card, then one
 * framed table whose document numbers are the links.
 */
export function GoodsReceiptsScreen() {
  const navigate = useNavigate();
  const { can } = useAuth();
  const [page, setPage] = useState(1);
  const [status, setStatus] = useState<'' | 'DRAFT' | 'POSTED' | 'CANCELLED'>('');
  const [supplierName, setSupplierName] = useState('');

  const query = { page, size: 50, ...(status ? { status } : {}) };
  const receipts = useApiPage<GoodsReceiptSummary>(
    ['goods-receipts', query],
    () => listGoodsReceipts(query),
    50,
  );

  // The contract has no supplier-name filter on this operation, so the narrowing is done on the
  // page that was fetched and the empty state says which filter produced it.
  const needle = supplierName.trim().toLocaleLowerCase('az');
  const rows = (receipts.data?.items ?? []).filter((row) =>
    needle ? (row.supplierName ?? '').toLocaleLowerCase('az').includes(needle) : true,
  );

  const columns: Column<GoodsReceiptSummary>[] = [
    {
      key: 'docNo',
      header: 'Sənəd',
      width: '160px',
      render: (row) => (
        <Link to={`/inventory/goods-receipts/${row.id}`}>
          <span className="wms-doc-no">{row.docNo}</span>
        </Link>
      ),
    },
    {
      key: 'docDate',
      header: 'Tarix',
      width: '110px',
      render: (row) => <span className="wms-num wms-small">{formatDate(row.docDate)}</span>,
    },
    { key: 'supplierName', header: 'Təchizatçı', render: (row) => row.supplierName ?? '—' },
    { key: 'locationName', header: 'Lokasiya', render: (row) => row.locationName ?? '—' },
    {
      key: 'poDocNo',
      header: 'PO',
      width: '150px',
      render: (row) =>
        row.poDocNo ? (
          <span className="wms-doc-no">{row.poDocNo}</span>
        ) : (
          <span className="wms-muted">PO-suz</span>
        ),
    },
    { key: 'lineCount', header: 'Sətir', numeric: true, decimals: 0, width: '90px' },
    {
      key: 'hasVariance',
      header: 'Fərq',
      width: '120px',
      render: (row) =>
        row.hasVariance ? (
          <Badge tone="warning" dot>
            Fərq var
          </Badge>
        ) : (
          <span className="wms-muted">—</span>
        ),
    },
    {
      key: 'status',
      header: 'Status',
      width: '150px',
      render: (row) => <DocStatusBadge status={row.status} />,
    },
  ];

  return (
    <Page
      title="Qəbul"
      subtitle="Açıq və post edilmiş qəbul sənədləri"
      actions={
        can('inv.receipt.create') ? (
          <Button variant="primary" onClick={() => navigate('/inventory/goods-receipts/new')}>
            Yeni qəbul
          </Button>
        ) : (
          <Button disabled title="`inv.receipt.create` icazəniz yoxdur">
            Yeni qəbul
          </Button>
        )
      }
    >
      <Card>
        <div className="wms-toolbar">
          <Select
            label="Status"
            value={status}
            placeholder="Bütün statuslar"
            options={[
              { value: 'DRAFT', label: 'Qaralama' },
              { value: 'POSTED', label: 'Post edilib' },
              { value: 'CANCELLED', label: 'Ləğv edilib' },
            ]}
            onChange={(e) => {
              setStatus(e.target.value as typeof status);
              setPage(1);
            }}
          />
          <TextField
            label="Təchizatçı"
            value={supplierName}
            placeholder="Ada görə süz"
            onChange={(e) => setSupplierName(e.target.value)}
          />
          <div className="wms-toolbar__spacer" />
        </div>
      </Card>

      {receipts.isLoading ? (
        <LoadingState />
      ) : receipts.isError ? (
        <ErrorState error={receipts.error} onRetry={() => void receipts.refetch()} />
      ) : (
        <Card
          title="Qəbul sənədləri"
          flush
          footer={receipts.data ? <Pager page={receipts.data} onPageChange={setPage} /> : undefined}
        >
          <DataTable<GoodsReceiptSummary>
            columns={columns}
            rows={rows}
            rowKey={(row) => row.id}
            label="Qəbul siyahısı"
            empty={
              supplierName.trim()
                ? `«${supplierName.trim()}» üçün qəbul sənədi tapılmadı. Süzgəci təmizləyin.`
                : 'Qəbul sənədi yoxdur. «Yeni qəbul» ilə başlayın.'
            }
          />
        </Card>
      )}
    </Page>
  );
}
