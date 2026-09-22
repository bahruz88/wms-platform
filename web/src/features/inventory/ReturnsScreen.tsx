import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Badge, Button, DataTable, DocStatusBadge, Select, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listReturnsToVendor, type ReturnToVendorSummary, type RtvStatus } from '@api/endpoints';
import { useAuth } from '@auth/index';
import { formatDate, formatMoney } from '@core/format';
import { Money } from '@core/decimal';
import { Card, ErrorState, LoadingState, Page } from '@/components/Page';
import { Pager } from '@/components/Pager';

/**
 * Return to vendor — docs/ux/screen-map.md §3.11, the sidebar's «Qaytarma».
 *
 * This is the web's primary screen for the flow, not a mobile mirror: the claim amount, the
 * supplier's answer and the closing decision are office work. `claimAmount` is permission-bound
 * and the column is absent without `master.product.view_cost`, never masked (SPEC §16).
 *
 * The contract spells the permission `inv.rtv.*` and the running service enforces the same
 * (`InventoryPermissions.cs`), and the guards follow the service.
 */
export const RTV_STATUS_OPTIONS = [
  { value: 'DRAFT', label: 'Qaralama' },
  { value: 'SENT', label: 'Göndərilib' },
  { value: 'ACCEPTED', label: 'Qəbul edilib' },
  { value: 'REJECTED', label: 'Rədd edilib' },
  { value: 'CLOSED', label: 'Bağlanıb' },
];

export function ReturnsScreen() {
  const navigate = useNavigate();
  const { session, can } = useAuth();
  const [page, setPage] = useState(1);
  const [status, setStatus] = useState('');

  const query = {
    page,
    size: 50,
    ...(status ? { status: status as RtvStatus } : {}),
  };
  const returns = useApiPage<ReturnToVendorSummary>(
    ['returns', query],
    () => listReturnsToVendor(query),
    50,
  );

  const columns: Column<ReturnToVendorSummary>[] = [
    {
      key: 'docNo',
      header: 'Sənəd',
      width: '160px',
      render: (row) => (
        <Link to={`/inventory/returns/${row.id}`}>
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
    { key: 'supplierName', header: 'Təchizatçı', render: (row) => row.supplierName },
    { key: 'location', header: 'Lokasiya', render: (row) => row.location.name },
    {
      key: 'receiptDocNo',
      header: 'Mənbə qəbul',
      width: '160px',
      render: (row) =>
        row.receiptId ? (
          <Link to={`/inventory/goods-receipts/${row.receiptId}`}>
            <span className="wms-doc-no">{row.receiptDocNo ?? `#${row.receiptId}`}</span>
          </Link>
        ) : (
          <span className="wms-muted">qəbulsuz</span>
        ),
    },
    {
      key: 'reasonCodeId',
      header: 'Səbəb kodu',
      width: '130px',
      render: (row) => (
        <Badge tone="neutral" variant="outline">
          #{row.reasonCodeId}
        </Badge>
      ),
    },
    {
      key: 'status',
      header: 'Status',
      width: '150px',
      render: (row) => <DocStatusBadge status={row.status} />,
    },
    {
      key: 'claimAmount',
      header: 'İddia',
      width: '140px',
      numeric: true,
      permission: 'master.product.view_cost',
      // The contract's `Money { amount, currency }`, straight from the service — the adapter
      // that used to absorb a bare decimal string here is gone.
      render: (row) => {
        const claim = row.claimAmount;
        return claim ? formatMoney(Money.parse(claim.amount, claim.currency), 2) : '—';
      },
    },
  ];

  return (
    <Page
      title="Təchizatçıya qaytarma"
      subtitle="Qaytarma sənədləri, iddia məbləği və təchizatçının cavabı"
      actions={
        can('inv.rtv.create') ? (
          <Button variant="primary" onClick={() => navigate('/inventory/returns/new')}>
            Yeni qaytarma
          </Button>
        ) : (
          <Button disabled title="`inv.rtv.create` icazəniz yoxdur">
            Yeni qaytarma
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
            options={RTV_STATUS_OPTIONS}
            onChange={(e) => {
              setStatus(e.target.value);
              setPage(1);
            }}
          />
          <div className="wms-toolbar__spacer" />
        </div>
      </Card>

      {returns.isLoading ? (
        <LoadingState />
      ) : returns.isError ? (
        <ErrorState error={returns.error} onRetry={() => void returns.refetch()} />
      ) : (
        <Card
          title="Qaytarma sənədləri"
          flush
          footer={returns.data ? <Pager page={returns.data} onPageChange={setPage} /> : undefined}
        >
          <DataTable<ReturnToVendorSummary>
            columns={columns}
            rows={returns.data?.items ?? []}
            permissions={session?.permissions ?? []}
            rowKey={(row) => row.id}
            label="Qaytarma siyahısı"
            empty="Qaytarma sənədi yoxdur. «Yeni qaytarma» ilə başlayın — qəbul sənədinə bağlamaq tövsiyə olunur."
          />
        </Card>
      )}
    </Page>
  );
}
