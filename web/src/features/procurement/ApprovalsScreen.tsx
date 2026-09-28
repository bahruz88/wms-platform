import { useState } from 'react';
import { Link } from 'react-router-dom';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { Badge, Button, DataTable, Dialog, KpiCard, TextField, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { decideApproval, listPendingApprovals, type PendingApproval } from '@api/endpoints';
import { useAuth } from '@auth/index';
import { formatDateTime } from '@core/format';
import { ErrorState, LoadingState, Page, Section } from '@/components/Page';
import { Pager } from '@/components/Pager';

/**
 * Approval inbox — docs/ux/screen-map.md §4.5. Delegation is written out in full: a decision that
 * reached this user on someone else's behalf says whose.
 *
 * Deciding happens here rather than on each document, because that is how the queue is worked: an
 * approver goes down a list, not from document to document. The row's own `stepNo` travels with the
 * decision as `expectedStepNo`, so a decision taken against a screen that has since moved on is
 * refused instead of landing on the wrong step.
 */
export function ApprovalsScreen() {
  const { session, can } = useAuth();
  const queryClient = useQueryClient();
  const [page, setPage] = useState(1);
  const [pending, setPending] = useState<{ row: PendingApproval; decision: 'APPROVED' | 'REJECTED' } | null>(
    null,
  );
  const [comment, setComment] = useState('');
  const approvals = useApiPage<PendingApproval>(
    ['approvals', page],
    () => listPendingApprovals({ page, size: 50 }),
    50,
  );

  const decide = useMutation({
    mutationFn: () => {
      if (!pending) throw new Error('no pending decision');
      return decideApproval(
        pending.row.approvalId,
        pending.decision,
        comment.trim() || undefined,
        pending.row.stepNo,
      );
    },
    onSuccess: () => {
      setPending(null);
      setComment('');
      void queryClient.invalidateQueries({ queryKey: ['approvals'] });
      void queryClient.invalidateQueries({ queryKey: ['notifications'] });
    },
  });

  const ask = (row: PendingApproval, decision: 'APPROVED' | 'REJECTED') => {
    setComment('');
    setPending({ row, decision });
  };

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
    {
      key: 'decision',
      header: '',
      width: '190px',
      render: (row) =>
        can('proc.approval.decide') ? (
          <div className="wms-row">
            <Button size="sm" variant="primary" onClick={() => ask(row, 'APPROVED')}>
              Təsdiqlə
            </Button>
            <Button size="sm" variant="danger" onClick={() => ask(row, 'REJECTED')}>
              Rədd et
            </Button>
          </div>
        ) : (
          <span className="wms-muted">Qərar icazəniz yoxdur</span>
        ),
    },
  ];

  const rejecting = pending?.decision === 'REJECTED';

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

      {decide.isError ? <ErrorState error={decide.error} /> : null}

      <Dialog
        open={pending !== null}
        title={rejecting ? 'Sənədi rədd edim?' : 'Sənədi təsdiqləyim?'}
        subtitle={
          pending
            ? `${pending.row.docNo} · ${pending.row.stepNo}-ci addım${
                pending.row.viaDelegationFrom
                  ? ` · ${pending.row.viaDelegationFrom.username} adından`
                  : ''
              }`
            : undefined
        }
        onClose={decide.isPending ? undefined : () => setPending(null)}
        footer={
          <>
            <Button disabled={decide.isPending} onClick={() => setPending(null)}>
              İmtina
            </Button>
            <Button
              variant={rejecting ? 'danger' : 'primary'}
              loading={decide.isPending}
              disabled={rejecting && comment.trim().length === 0}
              title={rejecting && comment.trim().length === 0 ? 'Səbəb məcburidir' : undefined}
              onClick={() => decide.mutate()}
            >
              {rejecting ? 'Rədd et' : 'Təsdiqlə'}
            </Button>
          </>
        }
      >
        <TextField
          label={rejecting ? 'Rədd səbəbi' : 'Şərh'}
          required={rejecting}
          value={comment}
          hint={
            rejecting
              ? 'Server səbəbsiz rəddi qəbul etmir; səbəb sənədi yazana görünür.'
              : 'İstəyə bağlı — təsdiq zəncirində qeyd olaraq saxlanır.'
          }
          onChange={(e) => setComment(e.target.value)}
        />
      </Dialog>
    </Page>
  );
}
