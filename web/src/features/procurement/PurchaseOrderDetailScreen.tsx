import { useState } from 'react';
import { useParams } from 'react-router-dom';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import {
  Alert,
  ApprovalChain,
  Badge,
  Button,
  DataTable,
  Dialog,
  DocStatusBadge,
  TextField,
  type ApprovalStep,
  type Column,
} from '@ds/index';
import { useApiQuery } from '@api/hooks';
import {
  approvePurchaseOrder,
  getPurchaseOrder,
  rejectPurchaseOrder,
  type PurchaseOrder,
} from '@api/endpoints';
import { useAuth } from '@auth/index';
import { formatDate, formatDateTime, formatNumber, formatPercent } from '@core/format';
import { DocNo, ErrorState, KeyValue, LoadingState, Page, Section } from '@/components/Page';

type Line = PurchaseOrder['lines'][number];

/**
 * Purchase order detail — docs/ux/screen-map.md §4.4 and §4.5.
 *
 * The approval chain is rendered with `ApprovalChain`; the approve / reject buttons sit in the
 * document toolbar, not inside the component (components/ApprovalChain/README.md). Rejection
 * requires a comment, which the dialog enforces before the request goes out.
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

  if (po.isLoading) return <LoadingState />;
  if (po.isError) return <ErrorState error={po.error} onRetry={() => void po.refetch()} />;
  const doc = po.data;
  if (!doc) return null;

  const steps: ApprovalStep[] = (doc.approval?.steps ?? []).map((step) => ({
    stepNo: step.stepNo,
    role: step.approverRoleCode,
    user: step.approverUser?.username,
    decision: step.decision,
    decidedAt: step.decidedAt ?? undefined,
    comment: step.comment ?? undefined,
    delegatedFrom: step.delegatedFromUser?.username,
  }));

  const columns: Column<Line>[] = [
    { key: 'lineNo', header: '№', numeric: true, decimals: 0, width: '48px' },
    {
      key: 'sku',
      header: 'SKU',
      render: (row) => <span className="wms-doc-no">{row.product.sku}</span>,
    },
    { key: 'product', header: 'Məhsul', render: (row) => row.product.name },
    { key: 'qty', header: 'Miqdar', numeric: true, decimals: 4 },
    { key: 'uomCode', header: 'Vahid', width: '70px' },
    {
      key: 'unitPrice',
      header: 'Vahid qiyməti',
      numeric: true,
      decimals: 4,
      permission: 'master.product.view_cost',
    },
    {
      key: 'vatRate',
      header: 'ƏDV',
      numeric: true,
      decimals: 2,
      permission: 'master.product.view_cost',
      render: (row) => formatPercent(row.vatRate, 2),
    },
    {
      key: 'lineTotal',
      header: 'Sətir cəmi',
      numeric: true,
      decimals: 2,
      permission: 'master.product.view_cost',
    },
    { key: 'receivedQty', header: 'Qəbul edilib', numeric: true, decimals: 4 },
    { key: 'remainingQty', header: 'Qalıq', numeric: true, decimals: 4 },
  ];

  const canDecide = can('proc.po.approve') && doc.status === 'PENDING_APPROVAL';

  return (
    <Page
      title={<DocNo value={doc.docNo} />}
      subtitle="Satınalma sifarişi"
      actions={
        <>
          <DocStatusBadge status={doc.status} />
          {doc.status === 'CLOSED' || doc.status === 'CANCELLED' ? null : canDecide ? (
            <>
              <Button
                variant="danger"
                onClick={() => {
                  setDecision('reject');
                  setComment('');
                }}
              >
                Rədd et
              </Button>
              <Button
                variant="primary"
                onClick={() => {
                  setDecision('approve');
                  setComment('');
                }}
              >
                Təsdiqlə
              </Button>
            </>
          ) : (
            <Button
              disabled
              title={
                !can('proc.po.approve')
                  ? '`proc.po.approve` icazəniz yoxdur'
                  : 'Sənəd təsdiq gözləmir'
              }
            >
              Təsdiqlə
            </Button>
          )}
        </>
      }
    >
      {doc.splitCheckWarning ? (
        <Alert tone="warning" title="PR bölünməsi şübhəsi" code="APPROVAL_REQUIRED">
          {doc.splitCheckWarning}
        </Alert>
      ) : null}
      {decide.isError ? <ErrorState error={decide.error} /> : null}

      <Section title="Başlıq">
        <div className="wms-card">
          <KeyValue
            items={[
              ['Sənəd nömrəsi', <DocNo key="d" value={doc.docNo} />],
              ['Təchizatçı', doc.supplier.name],
              ['Çatdırılma lokasiyası', doc.deliveryLocation.name],
              ['Sənəd tarixi', formatDate(doc.docDate)],
              ['Gözlənilən tarix', formatDate(doc.expectedDate)],
              ['Valyuta', doc.currency],
              [
                'Məzənnə (dondurulmuş)',
                <span key="fx" className="wms-num">
                  {formatNumber(doc.fxRate, 8)}
                </span>,
              ],
              ['Incoterms', doc.incoterms ?? '—'],
              ['Ödəniş şərtləri', doc.paymentTerms ?? '—'],
              ['Göndərilib', doc.sentAt ? formatDateTime(doc.sentAt) : '—'],
              ['Qəbul faizi', formatPercent(doc.receivedPct, 1)],
            ]}
          />
        </div>
      </Section>

      {can('master.product.view_cost') ? (
        <Section title="Cəmlər">
          <div className="wms-card">
            <KeyValue
              items={[
                [
                  'Ara cəm',
                  <span key="s" className="wms-num">
                    {formatNumber(doc.subtotal, 2)} {doc.currency}
                  </span>,
                ],
                [
                  'ƏDV',
                  <span key="v" className="wms-num">
                    {formatNumber(doc.vatAmount, 2)} {doc.currency}
                  </span>,
                ],
                [
                  'Ümumi',
                  <span key="t" className="wms-num">
                    {formatNumber(doc.totalAmount, 2)} {doc.currency}
                  </span>,
                ],
                [
                  'Ümumi (AZN)',
                  <span key="tb" className="wms-row">
                    <span className="wms-num">{formatNumber(doc.totalAmountBase, 2)} AZN</span>
                    <Badge tone="accent">Approval limiti bununla</Badge>
                  </span>,
                ],
              ]}
            />
          </div>
        </Section>
      ) : null}

      <Section title="Sətirlər">
        <DataTable<Line>
          columns={columns}
          rows={doc.lines}
          permissions={session?.permissions ?? []}
          rowKey={(row) => row.id}
          label="PO sətirləri"
          empty="Bu PO-da sətir yoxdur."
        />
      </Section>

      <Section title="Təsdiq zənciri">
        {steps.length === 0 ? (
          <Alert tone="info" title="Təsdiq zənciri açılmayıb">
            Sənəd təsdiqə göndərildikdə uyğun approval qaydası tapılır və zəncir burada görünür.
            Uyğun qayda yoxdursa server <span className="wms-num">422</span> qaytarır.
          </Alert>
        ) : (
          <div className="wms-card">
            <ApprovalChain steps={steps} currentStep={doc.approval?.currentStep} />
          </div>
        )}
      </Section>

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
            <DocNo value={doc.docNo} /> — {doc.supplier.name}
            {can('master.product.view_cost') ? `, ${formatNumber(doc.totalAmountBase, 2)} AZN` : ''}
            .
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
    </Page>
  );
}
