import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Badge, Button, DataTable, DocStatusBadge, Select, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listStockRequests, type StockRequestSummary } from '@api/endpoints';
import { useAuth } from '@auth/index';
import { formatDate } from '@core/format';
import { Card, ErrorState, LoadingState, Page } from '@/components/Page';
import { Pager } from '@/components/Pager';

/**
 * Stock requests — the branch asking the warehouse for goods, which is what an issue is normally
 * raised against. The list is the warehouse's queue: a submitted request is picked, then issued,
 * and the issue document carries the request number in its breadcrumb.
 */
export function StockRequestsScreen() {
  const navigate = useNavigate();
  const { can } = useAuth();
  const [page, setPage] = useState(1);
  const [status, setStatus] = useState('');

  const query = {
    page,
    size: 50,
    ...(status ? { status: status as StockRequestSummary['status'] } : {}),
  };
  const requests = useApiPage<StockRequestSummary>(
    ['stock-requests', query],
    () => listStockRequests(query),
    50,
  );

  const columns: Column<StockRequestSummary>[] = [
    {
      key: 'docNo',
      header: 'Sənəd',
      width: '160px',
      render: (row) => <span className="wms-doc-no">{row.docNo}</span>,
    },
    {
      key: 'docDate',
      header: 'Tarix',
      width: '110px',
      render: (row) => <span className="wms-num wms-small">{formatDate(row.docDate)}</span>,
    },
    {
      key: 'route',
      header: 'Marşrut',
      render: (row) => `${row.fromLocation.name} → ${row.toLocation.name}`,
    },
    {
      key: 'requiredDate',
      header: 'Tələb olunan tarix',
      width: '160px',
      render: (row) =>
        row.requiredDate ? (
          <span className="wms-num wms-small">{formatDate(row.requiredDate)}</span>
        ) : (
          <span className="wms-muted">—</span>
        ),
    },
    { key: 'lineCount', header: 'Sətir', numeric: true, decimals: 0, width: '90px' },
    {
      key: 'status',
      header: 'Status',
      width: '180px',
      render: (row) => <DocStatusBadge status={row.status} />,
    },
    {
      key: 'act',
      header: '',
      width: '140px',
      render: (row) =>
        can('inv.issue.create') &&
        ['SUBMITTED', 'PICKING', 'PARTIALLY_ISSUED'].includes(row.status) ? (
          <Link
            to={`/inventory/issues/new?requestId=${row.id}&fromLocationId=${row.fromLocation.id}&toLocationId=${row.toLocation.id}`}
            className="wms-btn wms-btn--secondary wms-btn--sm"
          >
            Məxaric yarat
          </Link>
        ) : (
          <span className="wms-muted">—</span>
        ),
    },
  ];

  return (
    <Page
      title="Mal tələbi"
      subtitle="Filialdan gələn tələblər — məxaric sənədi bu tələbə bağlanır"
      actions={
        can('inv.request.create') ? (
          <Button variant="primary" onClick={() => navigate('/inventory/issues/new')}>
            Məxaric yarat
          </Button>
        ) : (
          <Button disabled title="`inv.request.create` icazəniz yoxdur">
            Məxaric yarat
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
              { value: 'SUBMITTED', label: 'Göndərilib' },
              { value: 'PICKING', label: 'Yığılır' },
              { value: 'PARTIALLY_ISSUED', label: 'Qismən məxaric edilib' },
              { value: 'ISSUED', label: 'Məxaric edilib' },
              { value: 'CLOSED', label: 'Bağlanıb' },
              { value: 'CANCELLED', label: 'Ləğv edilib' },
            ]}
            onChange={(e) => {
              setStatus(e.target.value);
              setPage(1);
            }}
          />
          <div className="wms-toolbar__spacer" />
          <Badge tone="neutral" variant="outline">
            Tələb mobil tətbiqdə yaradılır
          </Badge>
        </div>
      </Card>

      {requests.isLoading ? (
        <LoadingState />
      ) : requests.isError ? (
        <ErrorState error={requests.error} onRetry={() => void requests.refetch()} />
      ) : (
        <Card
          title="Mal tələbləri"
          flush
          footer={requests.data ? <Pager page={requests.data} onPageChange={setPage} /> : undefined}
        >
          <DataTable<StockRequestSummary>
            columns={columns}
            rows={requests.data?.items ?? []}
            rowKey={(row) => row.id}
            label="Mal tələbi siyahısı"
            empty="Açıq mal tələbi yoxdur. Filial tələbi mobil tətbiqdən göndərir."
          />
        </Card>
      )}
    </Page>
  );
}
