import { useState } from 'react';
import { DataTable, DocStatusBadge, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listSamples, type SampleSummary } from '@api/endpoints';
import { formatDate } from '@core/format';
import { ErrorState, LoadingState, Page, Section } from '@/components/Page';
import { Pager } from '@/components/Pager';

/**
 * Samples (AQTA) — docs/ux/screen-map.md §3.10. Same structure as waste, with `authority` and
 * `purpose`, and no approval step: a sample is posted directly. Creation is the mobile flow.
 */
export function SamplesScreen() {
  const [page, setPage] = useState(1);
  const samples = useApiPage<SampleSummary>(
    ['samples', page],
    () => listSamples({ page, size: 50 }),
    50,
  );

  const columns: Column<SampleSummary>[] = [
    {
      key: 'docNo',
      header: 'Sənəd',
      render: (row) => <span className="wms-doc-no">{row.docNo}</span>,
    },
    { key: 'docDate', header: 'Tarix', render: (row) => formatDate(row.docDate) },
    { key: 'location', header: 'Lokasiya', render: (row) => row.location.name },
    { key: 'authority', header: 'Orqan' },
    { key: 'purpose', header: 'Məqsəd', render: (row) => row.purpose ?? '—' },
    { key: 'lineCount', header: 'Sətir', numeric: true, decimals: 0 },
    { key: 'status', header: 'Status', render: (row) => <DocStatusBadge status={row.status} /> },
  ];

  return (
    <Page title="Nümunə" subtitle="AQTA və digər orqanlara verilən nümunələr">
      <Section>
        {samples.isLoading ? (
          <LoadingState />
        ) : samples.isError ? (
          <ErrorState error={samples.error} onRetry={() => void samples.refetch()} />
        ) : (
          <>
            <DataTable<SampleSummary>
              columns={columns}
              rows={samples.data?.items ?? []}
              rowKey={(row) => row.id}
              label="Nümunə siyahısı"
              empty="Nümunə sənədi yoxdur. Nümunə mobil tətbiqdə qeyd olunur."
            />
            {samples.data ? <Pager page={samples.data} onPageChange={setPage} /> : null}
          </>
        )}
      </Section>
    </Page>
  );
}
