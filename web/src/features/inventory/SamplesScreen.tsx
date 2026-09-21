import { useState } from 'react';
import { Badge, DataTable, DocStatusBadge, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listSamples, type SampleSummary } from '@api/endpoints';
import { formatDate } from '@core/format';
import { Card, ErrorState, LoadingState, Page, Tabs } from '@/components/Page';
import { Pager } from '@/components/Pager';
import { WASTE_TABS } from './WasteScreen';

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
      key: 'authority',
      header: 'Orqan',
      width: '140px',
      render: (row) => (
        <Badge tone="neutral" variant="outline">
          {row.authority ?? 'AQTA'}
        </Badge>
      ),
    },
    { key: 'purpose', header: 'Məqsəd', render: (row) => row.purpose ?? '—' },
    { key: 'lineCount', header: 'Sətir', numeric: true, decimals: 0, width: '90px' },
    {
      key: 'status',
      header: 'Status',
      width: '150px',
      render: (row) => <DocStatusBadge status={row.status} />,
    },
  ];

  return (
    <Page title="Tullantı və nümunə" subtitle="AQTA və digər orqanlara verilən nümunələr">
      <Tabs items={WASTE_TABS} />

      {samples.isLoading ? (
        <LoadingState />
      ) : samples.isError ? (
        <ErrorState error={samples.error} onRetry={() => void samples.refetch()} />
      ) : (
        <Card
          title="Nümunə sənədləri"
          subtitle="Nümunə təsdiq addımı olmadan birbaşa post edilir"
          flush
          footer={samples.data ? <Pager page={samples.data} onPageChange={setPage} /> : undefined}
        >
          <DataTable<SampleSummary>
            columns={columns}
            rows={samples.data?.items ?? []}
            rowKey={(row) => row.id}
            label="Nümunə siyahısı"
            empty="Nümunə sənədi yoxdur. Nümunə mobil tətbiqdə qeyd olunur."
          />
        </Card>
      )}
    </Page>
  );
}
