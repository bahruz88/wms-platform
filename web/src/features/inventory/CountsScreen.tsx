import { useState } from 'react';
import { Alert, Badge, DataTable, DocStatusBadge, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listCounts, type CountSummary } from '@api/endpoints';
import { formatDateTime } from '@core/format';
import { ErrorState, LoadingState, Page, Section } from '@/components/Page';
import { Pager } from '@/components/Pager';

/**
 * Counts — docs/ux/screen-map.md §3.8. Web is the control and approval side; entering counted
 * quantities shelf by shelf is the mobile flow.
 *
 * Read-only here: `freezeCount`, `submitCountLines`, `approveCount` and `postCount` are all POST
 * operations the gateway does not yet route, and freezing blocks every operation on the location —
 * an action that must not be offered before it can be carried out.
 */
export function CountsScreen() {
  const [page, setPage] = useState(1);
  const counts = useApiPage<CountSummary>(
    ['counts', page],
    () => listCounts({ page, size: 50 }),
    50,
  );

  const columns: Column<CountSummary>[] = [
    {
      key: 'docNo',
      header: 'Sənəd',
      render: (row) => <span className="wms-doc-no">{row.docNo}</span>,
    },
    { key: 'location', header: 'Lokasiya', render: (row) => row.location.name },
    {
      key: 'countType',
      header: 'Tip',
      render: (row) => <Badge tone="neutral">{row.countType}</Badge>,
    },
    { key: 'status', header: 'Status', render: (row) => <DocStatusBadge status={row.status} /> },
    { key: 'frozenAt', header: 'Dondurulub', render: (row) => formatDateTime(row.frozenAt) },
    { key: 'lineCount', header: 'Sətir', numeric: true, decimals: 0 },
    { key: 'countedLineCount', header: 'Sayılıb', numeric: true, decimals: 0 },
    { key: 'varianceLineCount', header: 'Fərqli sətir', numeric: true, decimals: 0 },
    {
      key: 'requiresApproval',
      header: 'Təsdiq',
      render: (row) =>
        row.requiresApproval ? (
          <Badge tone="warning">Təsdiq tələb edir</Badge>
        ) : (
          <span className="wms-muted">—</span>
        ),
    },
  ];

  return (
    <Page title="Sayımlar" subtitle="Sayım sənədləri, fərq icmalı və təsdiq vəziyyəti">
      <Alert tone="info" title="Dondurma lokasiyanı bloklayır">
        `freezeCount` işə düşdükdə həmin lokasiyada qəbul, məxaric, transfer, tullantı və nümunə
        əməliyyatları dayanır və server <span className="wms-num">409 LOCATION_FROZEN</span>{' '}
        qaytarır. Sayımı aparan özü təsdiqləyə bilməz (SoD, SPEC §7.1).
      </Alert>
      <Section>
        {counts.isLoading ? (
          <LoadingState />
        ) : counts.isError ? (
          <ErrorState error={counts.error} onRetry={() => void counts.refetch()} />
        ) : (
          <>
            <DataTable<CountSummary>
              columns={columns}
              rows={counts.data?.items ?? []}
              rowKey={(row) => row.id}
              label="Sayım siyahısı"
              empty="Açıq sayım yoxdur. Sayım mobil tətbiqdə yaradılır və burada nəzarət edilir."
            />
            {counts.data ? <Pager page={counts.data} onPageChange={setPage} /> : null}
          </>
        )}
      </Section>
    </Page>
  );
}
