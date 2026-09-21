import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import {
  Alert,
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
import { ErrorState, LoadingState, Page, Section } from '@/components/Page';
import { Pager } from '@/components/Pager';

/**
 * Goods receipts — docs/ux/screen-map.md §3.1.
 *
 * `listGoodsReceipts` is defined in the contract but the gateway currently routes only POST on
 * `/goods-receipts` (it answers 405 on GET). The screen therefore also offers a direct lookup by
 * document id, which `getGoodsReceipt` does serve — a real receipt opens from here today.
 */
export function GoodsReceiptsScreen() {
  const navigate = useNavigate();
  const { can } = useAuth();
  const [page, setPage] = useState(1);
  const [status, setStatus] = useState<'' | 'DRAFT' | 'POSTED' | 'CANCELLED'>('');
  const [directId, setDirectId] = useState('1');

  const query = { page, size: 50, ...(status ? { status } : {}) };
  const receipts = useApiPage<GoodsReceiptSummary>(
    ['goods-receipts', query],
    () => listGoodsReceipts(query),
    50,
  );

  const columns: Column<GoodsReceiptSummary>[] = [
    {
      key: 'docNo',
      header: 'Sənəd',
      render: (row) => (
        <Link to={`/inventory/goods-receipts/${row.id}`}>
          <span className="wms-doc-no">{row.docNo}</span>
        </Link>
      ),
    },
    { key: 'docDate', header: 'Tarix', render: (row) => formatDate(row.docDate) },
    { key: 'supplierName', header: 'Təchizatçı', render: (row) => row.supplierName ?? '—' },
    { key: 'locationName', header: 'Lokasiya', render: (row) => row.locationName ?? '—' },
    {
      key: 'poDocNo',
      header: 'PO',
      render: (row) => row.poDocNo ?? <span className="wms-muted">PO-suz</span>,
    },
    { key: 'lineCount', header: 'Sətir', numeric: true, decimals: 0 },
    {
      key: 'hasVariance',
      header: 'Fərq',
      render: (row) =>
        row.hasVariance ? (
          <Badge tone="warning">Fərq var</Badge>
        ) : (
          <span className="wms-muted">—</span>
        ),
    },
    { key: 'status', header: 'Status', render: (row) => <DocStatusBadge status={row.status} /> },
  ];

  return (
    <Page
      title="Qəbullar"
      subtitle="Açıq və post edilmiş qəbullar"
      actions={
        can('inv.receipt.create') ? (
          <Button variant="primary" onClick={() => navigate('/inventory/goods-receipts/new')}>
            Yeni qəbul
          </Button>
        ) : null
      }
    >
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
        <div className="wms-toolbar__spacer" />
        <TextField
          label="Sənəd id ilə aç"
          mono
          value={directId}
          hint="`getGoodsReceipt` işləyir; siyahı endpoint-i gateway-də hələ açılmayıb."
          onChange={(e) => setDirectId(e.target.value)}
        />
        <Button
          disabled={!directId.trim()}
          title={!directId.trim() ? 'Sənəd id-si yazın' : undefined}
          onClick={() => navigate(`/inventory/goods-receipts/${directId.trim()}`)}
        >
          Aç
        </Button>
      </div>

      <Section>
        {receipts.isLoading ? (
          <LoadingState />
        ) : receipts.isError ? (
          <>
            <ErrorState error={receipts.error} onRetry={() => void receipts.refetch()} />
            <Alert tone="info" title="Sənədi birbaşa açın">
              Siyahı gələnə qədər sənəd nömrəsini bilirsinizsə yuxarıdakı id sahəsindən açın —
              məsələn <span className="wms-doc-no">GR-2026-00001</span> üçün id{' '}
              <span className="wms-num">1</span>.
            </Alert>
          </>
        ) : (
          <>
            <DataTable<GoodsReceiptSummary>
              columns={columns}
              rows={receipts.data?.items ?? []}
              rowKey={(row) => row.id}
              label="Qəbul siyahısı"
              empty="Qəbul sənədi yoxdur. «Yeni qəbul» ilə başlayın."
            />
            {receipts.data ? <Pager page={receipts.data} onPageChange={setPage} /> : null}
          </>
        )}
      </Section>
    </Page>
  );
}
