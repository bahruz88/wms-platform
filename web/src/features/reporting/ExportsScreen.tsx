import { useState } from 'react';
import { Badge, Button, DataTable, DocStatusBadge, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listExports, type ExportJob } from '@api/endpoints';
import { formatDateTime } from '@core/format';
import { ErrorState, LoadingState, Page, Section } from '@/components/Page';
import { Pager } from '@/components/Pager';

/**
 * Export jobs — docs/ux/screen-map.md §5.2. The list polls while anything is still queued or
 * running, because the download URL only appears when the job completes and it is valid for five
 * minutes.
 */
export function ExportsScreen() {
  const [page, setPage] = useState(1);
  const exports = useApiPage<ExportJob>(
    ['exports', page],
    () => listExports({ page, size: 50 }),
    50,
    {
      refetchInterval: (query) => {
        const items = query.state.data?.items ?? [];
        return items.some((j) => j.status === 'QUEUED' || j.status === 'RUNNING') ? 5000 : false;
      },
    },
  );

  const columns: Column<ExportJob>[] = [
    { key: 'id', header: '№', numeric: true, decimals: 0, width: '80px' },
    {
      key: 'reportCode',
      header: 'Hesabat',
      render: (row) => <span className="wms-doc-no">{row.reportCode}</span>,
    },
    {
      key: 'format',
      header: 'Format',
      render: (row) => <Badge tone="neutral">{row.format}</Badge>,
    },
    { key: 'status', header: 'Status', render: (row) => <DocStatusBadge status={row.status} /> },
    { key: 'progressPct', header: 'İrəliləyiş', numeric: true, decimals: 0 },
    { key: 'rowCount', header: 'Sətir', numeric: true, decimals: 0 },
    { key: 'requestedAt', header: 'Sifariş', render: (row) => formatDateTime(row.requestedAt) },
    { key: 'completedAt', header: 'Tamamlanıb', render: (row) => formatDateTime(row.completedAt) },
    {
      key: 'download',
      header: '',
      width: '130px',
      render: (row) =>
        row.downloadUrl ? (
          <a className="wms-btn wms-btn--secondary wms-btn--sm" href={row.downloadUrl}>
            Yüklə
          </a>
        ) : (
          <Button
            size="sm"
            disabled
            title={
              row.errorMessage ??
              (row.status === 'FAILED' ? 'Export uğursuz oldu' : 'Fayl hələ hazır deyil')
            }
          >
            Yüklə
          </Button>
        ),
    },
  ];

  return (
    <Page
      title="Exportlar"
      subtitle="Asinxron export sifarişləri — yükləmə linki 5 dəqiqə etibarlıdır"
    >
      <Section>
        {exports.isLoading ? (
          <LoadingState />
        ) : exports.isError ? (
          <ErrorState error={exports.error} onRetry={() => void exports.refetch()} />
        ) : (
          <>
            <DataTable<ExportJob>
              columns={columns}
              rows={exports.data?.items ?? []}
              rowKey={(row) => row.id}
              label="Export sifarişləri"
              empty="Export sifarişi yoxdur. Hesabat kataloqundan «Excel-ə çıxar» ilə başlayın."
            />
            {exports.data ? <Pager page={exports.data} onPageChange={setPage} /> : null}
          </>
        )}
      </Section>
    </Page>
  );
}
