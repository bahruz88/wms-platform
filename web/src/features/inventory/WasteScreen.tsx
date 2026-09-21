import { useState } from 'react';
import { Alert, DataTable, DocStatusBadge, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listWaste, type WasteSummary } from '@api/endpoints';
import { useAuth } from '@auth/index';
import { formatDate } from '@core/format';
import { ErrorState, LoadingState, Page, Section } from '@/components/Page';
import { Pager } from '@/components/Pager';

/**
 * Waste — docs/ux/screen-map.md §3.9. Creation is the mobile flow (a reason code with
 * `requiresPhoto` makes a photo mandatory); the web side is the approval and review view.
 * `totalValue` is permission-bound — the keeper does not see what the waste cost.
 */
export function WasteScreen() {
  const { session } = useAuth();
  const [page, setPage] = useState(1);
  const waste = useApiPage<WasteSummary>(['waste', page], () => listWaste({ page, size: 50 }), 50);

  const columns: Column<WasteSummary>[] = [
    {
      key: 'docNo',
      header: 'Sənəd',
      render: (row) => <span className="wms-doc-no">{row.docNo}</span>,
    },
    { key: 'docDate', header: 'Tarix', render: (row) => formatDate(row.docDate) },
    { key: 'location', header: 'Lokasiya', render: (row) => row.location.name },
    { key: 'reasonCodeName', header: 'Səbəb kodu' },
    { key: 'lineCount', header: 'Sətir', numeric: true, decimals: 0 },
    { key: 'status', header: 'Status', render: (row) => <DocStatusBadge status={row.status} /> },
    {
      key: 'totalValue',
      header: 'Dəyər (AZN)',
      numeric: true,
      decimals: 2,
      permission: 'master.product.view_cost',
    },
  ];

  return (
    <Page title="Tullantı" subtitle="Tullantı sənədləri və təsdiq vəziyyəti">
      <Alert tone="info" title="Öz sənədini təsdiqləmək olmaz">
        Səbəb kodunda <span className="wms-num">requiresApproval=true</span> olduqda sənəd
        `PENDING_APPROVAL` statusuna keçir; yaradan özü təsdiqləyə bilməz (SoD, SPEC §7.1).
      </Alert>
      <Section>
        {waste.isLoading ? (
          <LoadingState />
        ) : waste.isError ? (
          <ErrorState error={waste.error} onRetry={() => void waste.refetch()} />
        ) : (
          <>
            <DataTable<WasteSummary>
              columns={columns}
              rows={waste.data?.items ?? []}
              permissions={session?.permissions ?? []}
              rowKey={(row) => row.id}
              label="Tullantı siyahısı"
              empty="Tullantı sənədi yoxdur. Sənəd mobil tətbiqdə foto ilə yaradılır."
            />
            {waste.data ? <Pager page={waste.data} onPageChange={setPage} /> : null}
          </>
        )}
      </Section>
    </Page>
  );
}
