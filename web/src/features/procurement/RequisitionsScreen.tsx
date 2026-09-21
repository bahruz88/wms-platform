import { useState } from 'react';
import { Badge, DataTable, DocStatusBadge, Select, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listRequisitions, type RequisitionSummary } from '@api/endpoints';
import { formatDate } from '@core/format';
import { ErrorState, LoadingState, Page, Section } from '@/components/Page';
import { Pager } from '@/components/Pager';

/**
 * Requisitions (PR) — docs/ux/screen-map.md §4.1. One PR carries one `productType`; a mixed
 * document is refused with 422. Rejection requires a comment.
 */
export function RequisitionsScreen() {
  const [page, setPage] = useState(1);
  const [status, setStatus] = useState('');

  const query = { page, size: 50, ...(status ? { status: status as 'DRAFT' } : {}) };
  const requisitions = useApiPage<RequisitionSummary>(
    ['requisitions', query],
    () => listRequisitions(query),
    50,
  );

  const columns: Column<RequisitionSummary>[] = [
    {
      key: 'docNo',
      header: 'Sənəd',
      render: (row) => <span className="wms-doc-no">{row.docNo}</span>,
    },
    { key: 'docDate', header: 'Tarix', render: (row) => formatDate(row.docDate) },
    { key: 'location', header: 'Tələbçi lokasiyası', render: (row) => row.requesterLocation.name },
    {
      key: 'productType',
      header: 'Məhsul tipi',
      render: (row) => <Badge tone="neutral">{row.productType}</Badge>,
    },
    {
      key: 'priority',
      header: 'Prioritet',
      render: (row) => (
        <Badge
          tone={
            row.priority === 'URGENT' ? 'danger' : row.priority === 'HIGH' ? 'warning' : 'neutral'
          }
        >
          {row.priority}
        </Badge>
      ),
    },
    { key: 'requiredDate', header: 'Tələb tarixi', render: (row) => formatDate(row.requiredDate) },
    { key: 'lineCount', header: 'Sətir', numeric: true, decimals: 0 },
    { key: 'status', header: 'Status', render: (row) => <DocStatusBadge status={row.status} /> },
  ];

  return (
    <Page title="Tələblər" subtitle="PR — satınalma tələbləri">
      <div className="wms-toolbar">
        <Select
          label="Status"
          value={status}
          placeholder="Bütün statuslar"
          options={[
            'DRAFT',
            'SUBMITTED',
            'IN_PROCUREMENT',
            'CONVERTED_TO_PO',
            'REJECTED',
            'CANCELLED',
            'CLOSED',
          ].map((v) => ({ value: v, label: v }))}
          onChange={(e) => {
            setStatus(e.target.value);
            setPage(1);
          }}
        />
      </div>
      <Section>
        {requisitions.isLoading ? (
          <LoadingState />
        ) : requisitions.isError ? (
          <ErrorState error={requisitions.error} onRetry={() => void requisitions.refetch()} />
        ) : (
          <>
            <DataTable<RequisitionSummary>
              columns={columns}
              rows={requisitions.data?.items ?? []}
              rowKey={(row) => row.id}
              label="Tələb siyahısı"
              empty="Tələb yoxdur. Filial mobil tətbiqdən tələb göndərdikdə burada görünəcək."
            />
            {requisitions.data ? <Pager page={requisitions.data} onPageChange={setPage} /> : null}
          </>
        )}
      </Section>
    </Page>
  );
}
