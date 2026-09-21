import { useState } from 'react';
import { Alert, Badge, DataTable, DocStatusBadge, Select, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listWaste, type WasteSummary } from '@api/endpoints';
import { useAuth } from '@auth/index';
import { formatDate } from '@core/format';
import { Card, ErrorState, LoadingState, Page, Tabs } from '@/components/Page';
import { Pager } from '@/components/Pager';

/**
 * Waste — docs/ux/screen-map.md §3.9, under the artboard's single «Tullantı və nümunə» entry, so
 * waste and samples share one navigation item and are reached from each other through the tab
 * strip.
 *
 * Creation is the mobile flow (a reason code with `requiresPhoto` makes a photo mandatory); the
 * web side is approval and review. `totalValue` is permission-bound — the keeper does not see
 * what the waste cost, and the column is absent rather than masked.
 */
export const WASTE_TABS = [
  { to: '/inventory/waste', label: 'Tullantı' },
  { to: '/inventory/samples', label: 'Nümunə' },
];

export function WasteScreen() {
  const { session } = useAuth();
  const [page, setPage] = useState(1);
  const [status, setStatus] = useState('');

  const query = {
    page,
    size: 50,
    ...(status ? { status: status as WasteSummary['status'] } : {}),
  };
  const waste = useApiPage<WasteSummary>(['waste', query], () => listWaste(query), 50);

  const columns: Column<WasteSummary>[] = [
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
    { key: 'location', header: 'Lokasiya', render: (row) => row.location.name },
    {
      key: 'reasonCodeName',
      header: 'Səbəb kodu',
      render: (row) => (
        <Badge tone="neutral" variant="outline">
          {row.reasonCodeName ?? '—'}
        </Badge>
      ),
    },
    { key: 'lineCount', header: 'Sətir', numeric: true, decimals: 0, width: '90px' },
    {
      key: 'status',
      header: 'Status',
      width: '170px',
      render: (row) => <DocStatusBadge status={row.status} />,
    },
    {
      key: 'totalValue',
      header: 'Dəyər, AZN',
      width: '130px',
      numeric: true,
      decimals: 2,
      permission: 'master.product.view_cost',
    },
  ];

  return (
    <Page title="Tullantı və nümunə" subtitle="Tullantı sənədləri və təsdiq vəziyyəti">
      <Tabs items={WASTE_TABS} />

      <Alert tone="info" title="Öz sənədini təsdiqləmək olmaz">
        Səbəb kodunda <span className="wms-num">requiresApproval=true</span> olduqda sənəd
        `PENDING_APPROVAL` statusuna keçir; yaradan özü təsdiqləyə bilməz (SoD, SPEC §7.1).
      </Alert>

      <Card>
        <div className="wms-toolbar">
          <Select
            label="Status"
            value={status}
            placeholder="Bütün statuslar"
            options={[
              { value: 'DRAFT', label: 'Qaralama' },
              { value: 'PENDING_APPROVAL', label: 'Təsdiq gözləyir' },
              { value: 'APPROVED', label: 'Təsdiqlənib' },
              { value: 'POSTED', label: 'Post edilib' },
              { value: 'REJECTED', label: 'Rədd edilib' },
            ]}
            onChange={(e) => {
              setStatus(e.target.value);
              setPage(1);
            }}
          />
          <div className="wms-toolbar__spacer" />
        </div>
      </Card>

      {waste.isLoading ? (
        <LoadingState />
      ) : waste.isError ? (
        <ErrorState error={waste.error} onRetry={() => void waste.refetch()} />
      ) : (
        <Card
          title="Tullantı sənədləri"
          flush
          footer={waste.data ? <Pager page={waste.data} onPageChange={setPage} /> : undefined}
        >
          <DataTable<WasteSummary>
            columns={columns}
            rows={waste.data?.items ?? []}
            permissions={session?.permissions ?? []}
            rowKey={(row) => row.id}
            label="Tullantı siyahısı"
            empty="Tullantı sənədi yoxdur. Sənəd mobil tətbiqdə foto ilə yaradılır."
          />
        </Card>
      )}
    </Page>
  );
}
