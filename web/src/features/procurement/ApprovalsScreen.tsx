import { useState } from 'react';
import { Link } from 'react-router-dom';
import { Badge, DataTable, KpiCard, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listPendingApprovals, type PendingApproval } from '@api/endpoints';
import { useAuth } from '@auth/index';
import { formatDateTime } from '@core/format';
import { ErrorState, LoadingState, Page, Section } from '@/components/Page';
import { Pager } from '@/components/Pager';

/**
 * Approval inbox — docs/ux/screen-map.md §4.5. Delegation is written out in full: a decision that
 * reached this user on someone else's behalf says whose.
 */
export function ApprovalsScreen() {
  const { session } = useAuth();
  const [page, setPage] = useState(1);
  const approvals = useApiPage<PendingApproval>(
    ['approvals', page],
    () => listPendingApprovals({ page, size: 50 }),
    50,
  );

  const columns: Column<PendingApproval>[] = [
    {
      key: 'docType',
      header: 'Sənəd tipi',
      render: (row) => <Badge tone="neutral">{row.docType}</Badge>,
    },
    {
      key: 'docNo',
      header: 'Sənəd',
      render: (row) =>
        row.docType === 'PO' ? (
          <Link to={`/procurement/purchase-orders/${row.docId}`}>
            <span className="wms-doc-no">{row.docNo}</span>
          </Link>
        ) : (
          <span className="wms-doc-no">{row.docNo}</span>
        ),
    },
    { key: 'summary', header: 'Xülasə', render: (row) => row.summary ?? '—' },
    {
      key: 'amountBase',
      header: 'Məbləğ (AZN)',
      numeric: true,
      decimals: 2,
      permission: 'master.product.view_cost',
    },
    { key: 'stepNo', header: 'Addım', numeric: true, decimals: 0 },
    { key: 'requestedBy', header: 'Tələbçi', render: (row) => row.requestedBy?.username ?? '—' },
    {
      key: 'viaDelegationFrom',
      header: 'Delegasiya',
      render: (row) =>
        row.viaDelegationFrom ? (
          <Badge tone="accent">{`Delegasiya: ${row.viaDelegationFrom.username}`}</Badge>
        ) : (
          <span className="wms-muted">—</span>
        ),
    },
    { key: 'waitingSince', header: 'Gözləyir', render: (row) => formatDateTime(row.waitingSince) },
  ];

  return (
    <Page title="Təsdiqlər" subtitle="Sizdən qərar gözləyən sənədlər">
      <div className="wms-grid wms-grid--kpi">
        <KpiCard
          label="Gözləyən təsdiq"
          value={approvals.data?.total ?? 0}
          hint="Cari addımın sahibi sizsiniz"
        />
      </div>
      <Section>
        {approvals.isLoading ? (
          <LoadingState />
        ) : approvals.isError ? (
          <ErrorState error={approvals.error} onRetry={() => void approvals.refetch()} />
        ) : (
          <>
            <DataTable<PendingApproval>
              columns={columns}
              rows={approvals.data?.items ?? []}
              permissions={session?.permissions ?? []}
              rowKey={(row) => row.approvalId}
              label="Təsdiq gözləyən sənədlər"
              empty="Gözləyən təsdiq yoxdur. Yeni sənəd təsdiqə göndərildikdə burada görünəcək."
            />
            {approvals.data ? <Pager page={approvals.data} onPageChange={setPage} /> : null}
          </>
        )}
      </Section>
    </Page>
  );
}
