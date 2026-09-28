import { useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { Alert, Badge, Button, DataTable, Dialog, TextField, type Column } from '@ds/index';
import { useApiQuery } from '@api/hooks';
import {
  cancelRequisition,
  getRequisition,
  rejectRequisition,
  submitRequisition,
} from '@api/endpoints';
import { useAuth } from '@auth/index';
import { formatDate } from '@core/format';
import { Card, DocumentPage, ErrorState, LoadingState, Meta, MetaGrid } from '@/components/Page';

/**
 * Requisition — the first document of the purchasing chain (spec §8.1).
 *
 * Three transitions live here, and each is a different person's job: the requester submits, the
 * procurement side rejects with a reason, and either may cancel while nothing has been ordered yet.
 * A rejection without a comment is refused by the server, so the dialog requires one before it
 * will let the request go out.
 *
 * The per-line «Anbarda» column is the number that makes the screen useful to procurement: it is
 * the current stock of the requested product, so an officer can see at a glance whether the branch
 * is asking for something already sitting in the warehouse.
 */
type Requisition = {
  id: number;
  docNo: string;
  docDate: string;
  requesterLocation: { id: number; code: string; name: string };
  productType: string;
  priority: string;
  requiredDate?: string | null;
  status: string;
  rowVersion: number;
  note?: string | null;
  rejectComment?: string | null;
  lines: Line[];
};

type Line = {
  id: number;
  lineNo: number;
  product: { id: number; sku: string; name: string };
  qty: string;
  uomCode?: string | null;
  convertedQty?: string | null;
  currentStockQty?: string | null;
  note?: string | null;
};

export function RequisitionDetailScreen() {
  const { id } = useParams();
  const requisitionId = Number(id);
  const { can } = useAuth();
  const queryClient = useQueryClient();
  const [action, setAction] = useState<'submit' | 'cancel' | 'reject' | null>(null);
  const [comment, setComment] = useState('');

  const requisition = useApiQuery<Requisition>(['requisition', requisitionId], () =>
    getRequisition(requisitionId) as Promise<Requisition>,
  );

  const rowVersion = requisition.data?.rowVersion ?? 1;

  const run = useMutation({
    mutationFn: () => {
      if (action === 'submit') return submitRequisition(requisitionId, rowVersion);
      if (action === 'reject') return rejectRequisition(requisitionId, rowVersion, comment.trim());
      return cancelRequisition(requisitionId, rowVersion);
    },
    onSuccess: () => {
      setAction(null);
      setComment('');
      void queryClient.invalidateQueries({ queryKey: ['requisition', requisitionId] });
      void queryClient.invalidateQueries({ queryKey: ['requisitions'] });
    },
  });

  if (requisition.isLoading) return <LoadingState />;
  if (requisition.isError)
    return (
      <DocumentPage breadcrumb="Satınalma · Tələbnamə" docNo={`#${requisitionId}`}>
        <ErrorState error={requisition.error} onRetry={() => void requisition.refetch()} />
      </DocumentPage>
    );
  const doc = requisition.data;
  if (!doc) return null;

  const isDraft = doc.status === 'DRAFT';
  const isSubmitted = doc.status === 'SUBMITTED';
  const isOpen = isDraft || isSubmitted || doc.status === 'IN_PROCUREMENT';

  const columns: Column<Line>[] = [
    { key: 'lineNo', header: '#', width: '50px', numeric: true, decimals: 0 },
    {
      key: 'sku',
      header: 'SKU',
      width: '120px',
      render: (row) => <span className="wms-doc-no">{row.product.sku}</span>,
    },
    { key: 'product', header: 'Məhsul', render: (row) => row.product.name },
    { key: 'qty', header: 'Tələb', numeric: true, decimals: 4 },
    {
      key: 'uomCode',
      header: 'Vahid',
      width: '70px',
      render: (row) => row.uomCode || <span className="wms-muted">—</span>,
    },
    {
      key: 'currentStockQty',
      header: 'Anbarda',
      numeric: true,
      decimals: 4,
      render: (row) =>
        row.currentStockQty === null || row.currentStockQty === undefined ? (
          <span className="wms-muted">—</span>
        ) : (
          <span className="wms-num">{row.currentStockQty}</span>
        ),
    },
    {
      key: 'note',
      header: 'Qeyd',
      render: (row) => row.note ?? <span className="wms-muted">—</span>,
    },
  ];

  const rejecting = action === 'reject';
  const dialogTitle =
    action === 'submit'
      ? 'Tələbnaməni satınalmaya göndərim?'
      : action === 'reject'
        ? 'Tələbnaməni rədd edim?'
        : 'Tələbnaməni ləğv edim?';

  return (
    <DocumentPage
      breadcrumb={
        <>
          <Link to="/procurement/requisitions">Satınalma</Link> ·{' '}
          <Link to="/procurement/requisitions">Tələbnamə</Link>
        </>
      }
      docNo={doc.docNo}
      status={doc.status}
      context={doc.requesterLocation.name}
      actions={
        <>
          <Button variant="ghost" onClick={() => window.print()}>
            Çap et
          </Button>
          {isSubmitted && can('proc.pr.reject') ? (
            <Button variant="secondary" onClick={() => setAction('reject')}>
              Rədd et
            </Button>
          ) : null}
          {isOpen && can('proc.pr.create') ? (
            <Button variant="secondary" onClick={() => setAction('cancel')}>
              Ləğv et
            </Button>
          ) : null}
          {isDraft ? (
            can('proc.pr.submit') ? (
              <Button variant="primary" onClick={() => setAction('submit')}>
                Təsdiqə göndər
              </Button>
            ) : (
              <Button disabled title="`proc.pr.submit` icazəniz yoxdur">
                Təsdiqə göndər
              </Button>
            )
          ) : isSubmitted && can('proc.rfq.create') ? (
            <Link
              to={`/procurement/rfqs/new?requisitionId=${doc.id}`}
              className="wms-btn wms-btn--primary"
            >
              RFQ yarat
            </Link>
          ) : (
            <Badge tone="neutral">{STATUS_NOTES[doc.status] ?? 'Sənəd bağlıdır'}</Badge>
          )}
        </>
      }
    >
      {run.isError ? <ErrorState error={run.error} /> : null}
      {isDraft ? (
        <Alert tone="info" title="Qaralama satınalmaya görünmür">
          Tələbnamə yalnız «Təsdiqə göndər» addımından sonra satınalmanın növbəsinə düşür.
        </Alert>
      ) : null}
      {doc.rejectComment ? (
        <Alert tone="danger" title="Tələbnamə rədd edilib">
          {doc.rejectComment}
        </Alert>
      ) : null}

      <Card>
        <MetaGrid columns={6}>
          <Meta
            label="Sənəd tarixi"
            value={<span className="wms-num">{formatDate(doc.docDate)}</span>}
          />
          <Meta
            label="Tələb edən"
            value={doc.requesterLocation.name}
            sub={doc.requesterLocation.code}
          />
          <Meta label="Məhsul tipi" value={PRODUCT_TYPES[doc.productType] ?? doc.productType} />
          <Meta label="Prioritet" value={PRIORITIES[doc.priority] ?? doc.priority} />
          <Meta
            label="Tələb olunan tarix"
            value={
              <span className="wms-num">
                {doc.requiredDate ? formatDate(doc.requiredDate) : '—'}
              </span>
            }
          />
          <Meta label="Qeyd" value={doc.note ?? '—'} />
        </MetaGrid>
      </Card>

      <Card title="Tələbnamə sətirləri">
        <DataTable<Line>
          columns={columns}
          rows={doc.lines ?? []}
          rowKey={(row) => row.id}
          empty="Sətir yoxdur."
        />
      </Card>

      <Dialog
        open={action !== null}
        title={dialogTitle}
        subtitle={
          rejecting
            ? 'Səbəb tələbnaməni yazana görünür və audit jurnalına yazılır.'
            : action === 'submit'
              ? 'Göndərildikdən sonra tələbnamə satınalmanın növbəsinə düşür.'
              : 'Ləğv edilmiş tələbnamədən sifariş yaranmır.'
        }
        onClose={run.isPending ? undefined : () => setAction(null)}
        footer={
          <>
            <Button disabled={run.isPending} onClick={() => setAction(null)}>
              İmtina
            </Button>
            <Button
              variant={action === 'submit' ? 'primary' : 'danger'}
              loading={run.isPending}
              disabled={rejecting && comment.trim().length === 0}
              title={rejecting && comment.trim().length === 0 ? 'Səbəb məcburidir' : undefined}
              onClick={() => run.mutate()}
            >
              {action === 'submit' ? 'Göndər' : action === 'reject' ? 'Rədd et' : 'Ləğv et'}
            </Button>
          </>
        }
      >
        {rejecting ? (
          <TextField
            label="Rədd səbəbi"
            required
            value={comment}
            hint="Server səbəbsiz rəddi qəbul etmir."
            onChange={(e) => setComment(e.target.value)}
          />
        ) : null}
      </Dialog>
    </DocumentPage>
  );
}

const PRODUCT_TYPES: Record<string, string> = { FOOD: 'Ərzaq', NON_FOOD: 'Ərzaq olmayan' };

const PRIORITIES: Record<string, string> = {
  LOW: 'Aşağı',
  NORMAL: 'Normal',
  HIGH: 'Yüksək',
  URGENT: 'Təcili',
};

const STATUS_NOTES: Record<string, string> = {
  IN_PROCUREMENT: 'Satınalmada',
  CONVERTED_TO_PO: 'Sifarişə çevrilib',
  REJECTED: 'Rədd edilib',
  CANCELLED: 'Ləğv edilib',
  CLOSED: 'Bağlanıb',
};
