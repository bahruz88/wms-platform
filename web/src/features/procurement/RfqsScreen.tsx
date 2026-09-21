import { useState } from 'react';
import { Link } from 'react-router-dom';
import { Alert, Badge, DataTable, DocStatusBadge, Select, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listRfqs, type RfqSummary } from '@api/endpoints';
import { formatDate } from '@core/format';
import { ErrorState, LoadingState, Page, Section } from '@/components/Page';
import { Pager } from '@/components/Pager';

/**
 * RFQs — docs/ux/screen-map.md §4.2. An RFQ needs at least two suppliers (`422` otherwise): the
 * whole point is that quotations get compared.
 */
export function RfqsScreen() {
  const [page, setPage] = useState(1);
  const [status, setStatus] = useState('');

  const query = { page, size: 50, ...(status ? { status: status as 'DRAFT' } : {}) };
  const rfqs = useApiPage<RfqSummary>(['rfqs', query], () => listRfqs(query), 50);

  const columns: Column<RfqSummary>[] = [
    {
      key: 'docNo',
      header: 'Sənəd',
      render: (row) => (
        <Link to={`/procurement/rfqs/${row.id}/comparison`}>
          <span className="wms-doc-no">{row.docNo}</span>
        </Link>
      ),
    },
    { key: 'docDate', header: 'Tarix', render: (row) => formatDate(row.docDate) },
    { key: 'dueDate', header: 'Son tarix', render: (row) => formatDate(row.dueDate) },
    { key: 'supplierCount', header: 'Təchizatçı', numeric: true, decimals: 0 },
    { key: 'quotationCount', header: 'Təklif', numeric: true, decimals: 0 },
    {
      key: 'selectedQuotationId',
      header: 'Seçim',
      render: (row) =>
        row.selectedQuotationId ? (
          <Badge tone="success">Təklif seçilib</Badge>
        ) : (
          <span className="wms-muted">Seçilməyib</span>
        ),
    },
    { key: 'status', header: 'Status', render: (row) => <DocStatusBadge status={row.status} /> },
  ];

  return (
    <Page title="RFQ" subtitle="Təklif sorğuları — ən azı iki təchizatçı">
      <Alert tone="info" title="Müqayisə tələbi">
        Bir RFQ ən azı iki təchizatçıya göndərilməlidir; birdən az olduqda server{' '}
        <span className="wms-num">422</span> qaytarır (SPEC §10).
      </Alert>
      <div className="wms-toolbar">
        <Select
          label="Status"
          value={status}
          placeholder="Bütün statuslar"
          options={['DRAFT', 'SENT', 'CLOSED', 'CANCELLED'].map((v) => ({ value: v, label: v }))}
          onChange={(e) => {
            setStatus(e.target.value);
            setPage(1);
          }}
        />
      </div>
      <Section>
        {rfqs.isLoading ? (
          <LoadingState />
        ) : rfqs.isError ? (
          <ErrorState error={rfqs.error} onRetry={() => void rfqs.refetch()} />
        ) : (
          <>
            <DataTable<RfqSummary>
              columns={columns}
              rows={rfqs.data?.items ?? []}
              rowKey={(row) => row.id}
              label="RFQ siyahısı"
              empty="RFQ yoxdur. Tələbləri seçib «RFQ yarat» ilə başlayın."
            />
            {rfqs.data ? <Pager page={rfqs.data} onPageChange={setPage} /> : null}
          </>
        )}
      </Section>
    </Page>
  );
}
