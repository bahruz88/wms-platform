import { useState } from 'react';
import { Link } from 'react-router-dom';
import { Badge, DataTable, DocStatusBadge, Select, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listPurchaseOrders, type PurchaseOrderSummary } from '@api/endpoints';
import { useAuth } from '@auth/index';
import { formatDate, formatPercent } from '@core/format';
import { ErrorState, LoadingState, Page, Section } from '@/components/Page';
import { Pager } from '@/components/Pager';

/**
 * Purchase orders — docs/ux/screen-map.md §4.4. `totalAmountBase` is the AZN figure the approval
 * limit is checked against; both money columns are permission-bound.
 */
export function PurchaseOrdersScreen() {
  const { session } = useAuth();
  const [page, setPage] = useState(1);
  const [status, setStatus] = useState('');

  const query = { page, size: 50, ...(status ? { status: status as 'DRAFT' } : {}) };
  const orders = useApiPage<PurchaseOrderSummary>(
    ['purchase-orders', query],
    () => listPurchaseOrders(query),
    50,
  );

  const columns: Column<PurchaseOrderSummary>[] = [
    {
      key: 'docNo',
      header: 'Sənəd',
      render: (row) => (
        <Link to={`/procurement/purchase-orders/${row.id}`}>
          <span className="wms-doc-no">{row.docNo}</span>
        </Link>
      ),
    },
    { key: 'docDate', header: 'Tarix', render: (row) => formatDate(row.docDate) },
    { key: 'supplier', header: 'Təchizatçı', render: (row) => row.supplier.name },
    { key: 'deliveryLocation', header: 'Çatdırılma', render: (row) => row.deliveryLocation.name },
    { key: 'expectedDate', header: 'Gözlənilir', render: (row) => formatDate(row.expectedDate) },
    {
      key: 'productType',
      header: 'Tip',
      render: (row) => <Badge tone="neutral">{row.productType}</Badge>,
    },
    { key: 'currency', header: 'Valyuta' },
    {
      key: 'totalAmount',
      header: 'Məbləğ',
      numeric: true,
      decimals: 2,
      permission: 'master.product.view_cost',
    },
    {
      key: 'totalAmountBase',
      header: 'Məbləğ (AZN)',
      numeric: true,
      decimals: 2,
      permission: 'master.product.view_cost',
    },
    {
      key: 'receivedPct',
      header: 'Qəbul',
      numeric: true,
      decimals: 2,
      render: (row) => formatPercent(row.receivedPct, 1),
    },
    { key: 'status', header: 'Status', render: (row) => <DocStatusBadge status={row.status} /> },
  ];

  return (
    <Page title="Satınalma sifarişləri" subtitle="PO — təsdiq, göndərmə və qəbul vəziyyəti">
      <div className="wms-toolbar">
        <Select
          label="Status"
          value={status}
          placeholder="Bütün statuslar"
          options={[
            'DRAFT',
            'PENDING_APPROVAL',
            'APPROVED',
            'REJECTED',
            'SENT_TO_SUPPLIER',
            'PARTIALLY_RECEIVED',
            'FULLY_RECEIVED',
            'CLOSED',
            'CANCELLED',
          ].map((v) => ({ value: v, label: v }))}
          onChange={(e) => {
            setStatus(e.target.value);
            setPage(1);
          }}
        />
      </div>
      <Section>
        {orders.isLoading ? (
          <LoadingState />
        ) : orders.isError ? (
          <ErrorState error={orders.error} onRetry={() => void orders.refetch()} />
        ) : (
          <>
            <DataTable<PurchaseOrderSummary>
              columns={columns}
              rows={orders.data?.items ?? []}
              permissions={session?.permissions ?? []}
              rowKey={(row) => row.id}
              label="PO siyahısı"
              empty="Satınalma sifarişi yoxdur. Seçilmiş təklifdən PO yaradın."
            />
            {orders.data ? <Pager page={orders.data} onPageChange={setPage} /> : null}
          </>
        )}
      </Section>
    </Page>
  );
}
