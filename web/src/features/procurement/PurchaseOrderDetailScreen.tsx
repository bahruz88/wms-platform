import { useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import {
  Alert,
  ApprovalChain,
  Badge,
  Button,
  DataTable,
  Dialog,
  TextField,
  type ApprovalStep,
  type Column,
} from '@ds/index';
import { useApiQuery } from '@api/hooks';
import {
  approvePurchaseOrder,
  cancelPurchaseOrder,
  closePurchaseOrder,
  sendPurchaseOrder,
  submitPurchaseOrder,
  getPurchaseOrder,
  rejectPurchaseOrder,
  type PurchaseOrder,
} from '@api/endpoints';
import { useAuth } from '@auth/index';
import { formatDate, formatDateTime, formatNumber, formatPercent } from '@core/format';
import { Card, DocumentPage, ErrorState, LoadingState, Meta, MetaGrid } from '@/components/Page';

type Line = PurchaseOrder['lines'][number];

/**
 * Purchase order approval — docs/design-system/screens/PO-Tesdiq.dc.html, the one artboard that
 * had never been applied. Its layout is now this screen's:
 *
 *   · an 84px document header: breadcrumb, `wms-num` document number, `DocStatusBadge`, and the
 *     total beside them as a muted mono figure — bound to `master.product.view_cost`, so a
 *     reader without it sees the header without the money rather than a masked figure;
 *   · ghost → danger → primary in the action row, one primary;
 *   · a `minmax(0, 1.55fr) minmax(0, 1fr)` split (`wms-content--split-po`, whose CSS existed but
 *     was dead): the lines table on the left under the split-check warning, and the approval
 *     chain, the decision box and the quotation comparison stacked on the right;
 *   · the totals block in the card's sunken footer (`wms-sum`, also previously dead).
 *
 * The order's whole lifecycle is driven from here: DRAFT is submitted for approval, an approved
 * order is sent to the supplier, and a sent one is closed when receiving is done or cancelled if it
 * never will be. Each transition is one endpoint, and each is offered only in the state that
 * accepts it — an order that cannot be sent does not show a send button that would answer 409.
 */
export function PurchaseOrderDetailScreen() {
  const { id } = useParams();
  const poId = Number(id);
  const { session, can } = useAuth();
  const queryClient = useQueryClient();
  const [decision, setDecision] = useState<'approve' | 'reject' | null>(null);
  const [comment, setComment] = useState('');

  const po = useApiQuery<PurchaseOrder>(['purchase-order', poId], () => getPurchaseOrder(poId));

  const decide = useMutation({
    mutationFn: () =>
      decision === 'approve'
        ? approvePurchaseOrder(poId, po.data?.rowVersion ?? 1, comment.trim() || undefined)
        : rejectPurchaseOrder(poId, po.data?.rowVersion ?? 1, comment.trim()),
    onSuccess: () => {
      setDecision(null);
      setComment('');
      void queryClient.invalidateQueries({ queryKey: ['purchase-order', poId] });
    },
  });

  /**
   * The transitions that are not approval decisions. They share one mutation because they share one
   * shape — row version in, refreshed document out — and one confirmation dialog.
   */
  const [transition, setTransition] = useState<'submit' | 'send' | 'close' | 'cancel' | null>(null);

  const run = useMutation({
    mutationFn: () => {
      const rowVersion = po.data?.rowVersion ?? 1;
      if (transition === 'submit') return submitPurchaseOrder(poId, rowVersion);
      if (transition === 'send') return sendPurchaseOrder(poId, rowVersion);
      if (transition === 'close') return closePurchaseOrder(poId, rowVersion);
      return cancelPurchaseOrder(poId, rowVersion);
    },
    onSuccess: () => {
      setTransition(null);
      void queryClient.invalidateQueries({ queryKey: ['purchase-order', poId] });
      void queryClient.invalidateQueries({ queryKey: ['purchase-orders'] });
    },
  });

  if (po.isLoading) return <LoadingState />;
  if (po.isError)
    return (
      <DocumentPage breadcrumb="Satınalma · Sifarişlər" docNo={`#${poId}`}>
        <ErrorState error={po.error} onRetry={() => void po.refetch()} />
      </DocumentPage>
    );
  const doc = po.data;
  if (!doc) return null;

  const canViewCost = can('master.product.view_cost');

  const steps: ApprovalStep[] = (doc.approval?.steps ?? []).map((step) => ({
    stepNo: step.stepNo,
    role: step.approverRoleCode,
    user: step.approverUser?.username,
    decision: step.decision,
    decidedAt: step.decidedAt ?? undefined,
    comment: step.comment ?? undefined,
    delegatedFrom: step.delegatedFromUser?.username,
  }));
  const currentStep = doc.approval?.currentStep;

  const columns: Column<Line>[] = [
    { key: 'lineNo', header: '#', numeric: true, decimals: 0, width: '44px' },
    {
      key: 'product',
      header: 'Məhsul',
      render: (row) => (
        <div>
          <div className="wms-cell__name">{row.product.name}</div>
          <div className="wms-cell__sku wms-num">{row.product.sku}</div>
        </div>
      ),
    },
    {
      key: 'qty',
      header: 'Miqdar',
      width: '140px',
      numeric: true,
      render: (row) => `${formatNumber(row.qty, 3)} ${row.uomCode}`,
    },
    {
      key: 'unitPrice',
      header: 'Vahid qiymət',
      width: '120px',
      numeric: true,
      decimals: 4,
      permission: 'master.product.view_cost',
    },
    {
      key: 'receivedQty',
      header: 'Qəbul edilib',
      width: '150px',
      numeric: true,
      render: (row) => `${formatNumber(row.receivedQty, 3)} ${row.uomCode}`,
    },
    {
      key: 'remainingQty',
      header: 'Qalıq',
      width: '140px',
      numeric: true,
      render: (row) =>
        row.remainingQty === undefined ? (
          <span className="wms-muted">—</span>
        ) : (
          `${formatNumber(row.remainingQty, 3)} ${row.uomCode}`
        ),
    },
    {
      key: 'vatRate',
      header: 'ƏDV',
      width: '80px',
      numeric: true,
      permission: 'master.product.view_cost',
      render: (row) => formatPercent(row.vatRate, 0),
    },
    {
      key: 'lineTotal',
      header: 'Sətir cəmi',
      width: '130px',
      numeric: true,
      decimals: 2,
      permission: 'master.product.view_cost',
    },
  ];

  const canDecide = can('proc.po.approve') && doc.status === 'PENDING_APPROVAL';
  const finished = doc.status === 'CLOSED' || doc.status === 'CANCELLED';

  // Each transition is offered only in the state that accepts it, so the screen never shows a
  // button whose only possible answer is 409 INVALID_STATE_TRANSITION.
  const canSubmit = can('proc.po.submit') && doc.status === 'DRAFT';
  const canSend = can('proc.po.send') && doc.status === 'APPROVED';
  const canClose =
    can('proc.po.close') &&
    (doc.status === 'PARTIALLY_RECEIVED' || doc.status === 'FULLY_RECEIVED');
  const canCancel =
    can('proc.po.cancel') &&
    (doc.status === 'DRAFT' || doc.status === 'PENDING_APPROVAL' || doc.status === 'APPROVED');

  const blockedReason = !can('proc.po.approve')
    ? '`proc.po.approve` icazəniz yoxdur'
    : `«${doc.status}» statusunda əməliyyat yoxdur`;
  const openDecision = (which: 'approve' | 'reject') => {
    setDecision(which);
    setComment('');
  };

  return (
    <DocumentPage
      breadcrumb={
        <>
          <Link to="/procurement/requisitions">Satınalma</Link> ·{' '}
          <Link to="/procurement/purchase-orders">Sifarişlər</Link>
        </>
      }
      docNo={doc.docNo}
      status={doc.status}
      // The artboard puts the total beside the number as a muted mono figure. Without the cost
      // permission it is absent, not masked (SPEC §16).
      context={
        canViewCost
          ? `${formatNumber(doc.totalAmount, 2)} ${doc.currency}`
          : `${doc.lines.length} sətir`
      }
      contentClassName="wms-content--split-po"
      actions={
        <>
          <Button variant="ghost" onClick={() => window.print()}>
            PDF
          </Button>
          {finished ? (
            <Badge tone="neutral">Sifariş bağlanıb</Badge>
          ) : (
            <>
              {canCancel ? (
                <Button variant="secondary" onClick={() => setTransition('cancel')}>
                  Ləğv et
                </Button>
              ) : null}
              {canClose ? (
                <Button variant="secondary" onClick={() => setTransition('close')}>
                  Bağla
                </Button>
              ) : null}
              {canDecide ? (
                <>
                  <Button variant="danger" onClick={() => openDecision('reject')}>
                    Rədd et
                  </Button>
                  <Button variant="primary" onClick={() => openDecision('approve')}>
                    Təsdiqlə
                  </Button>
                </>
              ) : canSubmit ? (
                <Button variant="primary" onClick={() => setTransition('submit')}>
                  Təsdiqə göndər
                </Button>
              ) : canSend ? (
                <Button variant="primary" onClick={() => setTransition('send')}>
                  Təchizatçıya göndər
                </Button>
              ) : (
                <Button disabled title={blockedReason}>
                  {doc.status === 'PENDING_APPROVAL' ? 'Təsdiqlə' : 'Növbəti addım yoxdur'}
                </Button>
              )}
            </>
          )}
        </>
      }
    >
      {/* Left column: the warning, then the lines with their totals in the card's footer. */}
      <div className="wms-col">
        {doc.splitCheckWarning ? (
          <Alert
            tone="warning"
            title="Təchizatçı üzrə kumulyativ məbləğ həddə yaxınlaşır"
            code="APPROVAL_REQUIRED"
          >
            {doc.splitCheckWarning}
          </Alert>
        ) : null}
        {decide.isError ? <ErrorState error={decide.error} /> : null}

        <Card
          title="Sifariş sətirləri"
          subtitle={`Valyuta: ${doc.currency} · məzənnə ${formatNumber(doc.fxRate, 8)} · çatdırılma: ${
            doc.deliveryLocation.name
          }${doc.expectedDate ? `, ${formatDate(doc.expectedDate)}` : ''}`}
          className="wms-card--fill"
          flush
          footer={
            canViewCost ? (
              <div className="wms-sum">
                <div className="wms-sum__row">
                  <span className="wms-sum__key">Ara cəm</span>
                  <span>{formatNumber(doc.subtotal, 2)}</span>
                </div>
                <div className="wms-sum__row">
                  <span className="wms-sum__key">ƏDV</span>
                  <span>{formatNumber(doc.vatAmount, 2)}</span>
                </div>
                <div className="wms-sum__row wms-sum__row--total">
                  <span>Cəmi, {doc.currency}</span>
                  <span>{formatNumber(doc.totalAmount, 2)}</span>
                </div>
                {doc.currency === 'AZN' ? null : (
                  <div className="wms-sum__row">
                    <span className="wms-sum__key">Cəmi, AZN</span>
                    <span>{formatNumber(doc.totalAmountBase, 2)}</span>
                  </div>
                )}
              </div>
            ) : undefined
          }
        >
          <DataTable<Line>
            columns={columns}
            rows={doc.lines}
            permissions={session?.permissions ?? []}
            rowKey={(row) => row.id}
            label="PO sətirləri"
            empty="Bu sifarişdə sətir yoxdur."
          />
        </Card>

        <Card title="Sifariş məlumatları">
          <MetaGrid columns={4}>
            <Meta label="Təchizatçı" value={doc.supplier.name} />
            <Meta
              label="Sənəd tarixi"
              value={<span className="wms-num">{formatDate(doc.docDate)}</span>}
            />
            <Meta
              label="Gözlənilən tarix"
              value={<span className="wms-num">{formatDate(doc.expectedDate)}</span>}
            />
            <Meta label="Qəbul faizi" value={formatPercent(doc.receivedPct, 1)} />
            <Meta label="Incoterms" value={doc.incoterms ?? '—'} />
            <Meta label="Ödəniş şərtləri" value={doc.paymentTerms ?? '—'} />
            <Meta
              label="Göndərilib"
              value={
                <span className="wms-num">{doc.sentAt ? formatDateTime(doc.sentAt) : '—'}</span>
              }
            />
            <Meta
              label="Məzənnə (dondurulmuş)"
              value={<span className="wms-num">{formatNumber(doc.fxRate, 8)}</span>}
            />
          </MetaGrid>
        </Card>
      </div>

      {/* Right column: the chain, the decision box, the quotation comparison. */}
      <div className="wms-col">
        <Card
          title="Təsdiq zənciri"
          actions={
            steps.length > 0 && currentStep ? (
              <Badge tone="warning" dot>
                Addım {currentStep} / {steps.length}
              </Badge>
            ) : undefined
          }
        >
          {steps.length === 0 ? (
            <Alert tone="info" title="Təsdiq zənciri açılmayıb">
              Sənəd təsdiqə göndərildikdə uyğun approval qaydası tapılır və zəncir burada görünür.
              Uyğun qayda yoxdursa server <span className="wms-num">422</span> qaytarır.
            </Alert>
          ) : (
            <ApprovalChain steps={steps} currentStep={currentStep} />
          )}
        </Card>

        <Card title="Qərarınız">
          <div className="wms-stack">
            <TextField
              label="Şərh"
              value={comment}
              disabled={!canDecide}
              hint="Rədd edilərkən şərh məcburidir"
              onChange={(e) => setComment(e.target.value)}
            />
            <div className="wms-row" style={{ justifyContent: 'flex-end' }}>
              <Button
                variant="danger"
                disabled={!canDecide}
                title={canDecide ? undefined : 'Sənəd sizin təsdiqinizi gözləmir'}
                onClick={() => setDecision('reject')}
              >
                Rədd et
              </Button>
              <Button
                variant="primary"
                disabled={!canDecide}
                title={canDecide ? undefined : 'Sənəd sizin təsdiqinizi gözləmir'}
                onClick={() => setDecision('approve')}
              >
                Təsdiqlə
              </Button>
            </div>
          </div>
        </Card>

        <Card
          title="Təklif müqayisəsi"
          actions={
            doc.quotationId ? (
              <Link to={`/procurement/quotations`} className="wms-num">
                #{doc.quotationId}
              </Link>
            ) : undefined
          }
          className="wms-card--fill"
        >
          {doc.quotationId ? (
            <div className="wms-stack">
              <div className="wms-option wms-option--picked">
                <div className="wms-option__main">
                  <div className="wms-option__name">{doc.supplier.name}</div>
                  <div className="wms-option__meta">
                    {[doc.paymentTerms, 'seçilib'].filter(Boolean).join(' · ')}
                  </div>
                </div>
                {canViewCost ? (
                  <span className="wms-option__price wms-num">
                    {formatNumber(doc.totalAmount, 2)}
                  </span>
                ) : null}
              </div>
              <div className="wms-muted wms-small">
                Müqayisənin tam cədvəli RFQ ekranındadır. Ən ucuz təklif seçilmədikdə seçim qeydi
                məcburidir (SPEC §11.4).
              </div>
            </div>
          ) : (
            <div className="wms-muted">
              Bu sifariş təklifə bağlanmayıb — RFQ-suz birbaşa sifarişdir. Müqayisə göstəriləcək bir
              şey yoxdur.
            </div>
          )}
        </Card>
      </div>

      <Dialog
        open={decision !== null}
        title={decision === 'approve' ? 'Sifarişi təsdiqləyim?' : 'Sifarişi rədd edim?'}
        subtitle={
          decision === 'reject'
            ? 'Rəddə şərh məcburidir — tələbçi səbəbi görməlidir.'
            : 'Təsdiq növbəti addıma keçir və ya sənədi təsdiqlənmiş edir.'
        }
        onClose={decide.isPending ? undefined : () => setDecision(null)}
        footer={
          <>
            <Button
              disabled={decide.isPending}
              title={decide.isPending ? 'Sorğu göndərilir' : undefined}
              onClick={() => setDecision(null)}
            >
              İmtina
            </Button>
            <Button
              variant={decision === 'reject' ? 'danger' : 'primary'}
              loading={decide.isPending}
              disabled={decision === 'reject' && comment.trim().length === 0}
              title={
                decision === 'reject' && comment.trim().length === 0
                  ? 'Rədd şərhi məcburidir'
                  : undefined
              }
              onClick={() => decide.mutate()}
            >
              {decision === 'reject' ? 'Rədd et' : 'Təsdiqlə'}
            </Button>
          </>
        }
      >
        <div className="wms-stack">
          <span>
            <span className="wms-doc-no">{doc.docNo}</span> — {doc.supplier.name}
            {canViewCost ? `, ${formatNumber(doc.totalAmountBase, 2)} AZN` : ''}.
          </span>
          <TextField
            label="Şərh"
            required={decision === 'reject'}
            value={comment}
            hint="Şərh təsdiq zəncirində görünür və audit jurnalına düşür."
            error={
              decision === 'reject' && comment.trim().length === 0
                ? 'Rəddə şərh məcburidir.'
                : undefined
            }
            onChange={(e) => setComment(e.target.value)}
          />
        </div>
      </Dialog>

      {run.isError ? <ErrorState error={run.error} /> : null}

      <Dialog
        open={transition !== null}
        title={transition ? TRANSITION_TITLES[transition] : ''}
        subtitle={transition ? TRANSITION_NOTES[transition] : undefined}
        onClose={run.isPending ? undefined : () => setTransition(null)}
        footer={
          <>
            <Button disabled={run.isPending} onClick={() => setTransition(null)}>
              İmtina
            </Button>
            <Button
              variant={transition === 'cancel' ? 'danger' : 'primary'}
              loading={run.isPending}
              onClick={() => run.mutate()}
            >
              {transition ? TRANSITION_ACTIONS[transition] : ''}
            </Button>
          </>
        }
      >
        <span>
          <span className="wms-doc-no">{doc.docNo}</span> — {doc.supplier.name}
          {canViewCost ? `, ${formatNumber(doc.totalAmountBase, 2)} AZN` : ''}.
        </span>
      </Dialog>
    </DocumentPage>
  );
}

const TRANSITION_TITLES: Record<string, string> = {
  submit: 'Sifarişi təsdiqə göndərim?',
  send: 'Sifarişi təchizatçıya göndərim?',
  close: 'Sifarişi bağlayım?',
  cancel: 'Sifarişi ləğv edim?',
};

const TRANSITION_NOTES: Record<string, string> = {
  submit: 'Sənəd təsdiq zəncirinə düşür və təsdiqləyənin növbəsində görünür.',
  send: 'Təchizatçıya göndərildikdən sonra sifariş qəbul üçün açıq olur.',
  close: 'Bağlanmış sifariş üzrə yeni qəbul edilə bilməz.',
  cancel: 'Ləğv edilmiş sifariş üzrə qəbul edilmir. Qəbul başlayıbsa ləğv yerinə bağlayın.',
};

const TRANSITION_ACTIONS: Record<string, string> = {
  submit: 'Göndər',
  send: 'Göndər',
  close: 'Bağla',
  cancel: 'Ləğv et',
};
