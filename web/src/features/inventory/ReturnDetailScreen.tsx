import { useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { Alert, Badge, Button, DataTable, Dialog, Select, TextField, type Column } from '@ds/index';
import { useApiQuery } from '@api/hooks';
import {
  closeReturnToVendor,
  getReturnToVendor,
  sendReturnToVendor,
  type ReturnToVendor,
  type WasteLine,
} from '@api/endpoints';
import { useAuth } from '@auth/index';
import { Money } from '@core/decimal';
import { formatDate, formatDateTime, formatMoney, formatNumber } from '@core/format';
import {
  Card,
  DocumentPage,
  ErrorState,
  LoadingState,
  Meta,
  MetaGrid,
  ProductCell,
} from '@/components/Page';
import { AttachmentsCard } from '@/components/AttachmentsCard';

/**
 * Return-to-vendor document — screen-map §3.11, the whole life of the document on one page:
 *
 *   `DRAFT → SENT` — `sendReturnToVendor`, writes the `RETURN` group: location −qty,
 *     `V_SUPPLIER` +qty, `unitCost = avgUnitCost` (SPEC §12.3);
 *   `SENT → ACCEPTED | REJECTED → CLOSED` — `closeReturnToVendor` in one step, recording the
 *     supplier's answer and the amount they actually accepted.
 *
 * Both operations are `inv.rtv.create` on the service. The final claim amount is a decimal
 * **string** all the way through — it is never parsed into a `number` (ADR-008).
 */
export function ReturnDetailScreen() {
  const { id } = useParams();
  const rtvId = Number(id);
  const { session, can } = useAuth();
  const queryClient = useQueryClient();
  const [action, setAction] = useState<'send' | 'close' | null>(null);
  const [outcome, setOutcome] = useState<'ACCEPTED' | 'REJECTED'>('ACCEPTED');
  const [claimAmount, setClaimAmount] = useState('');
  const [outcomeNote, setOutcomeNote] = useState('');

  const rtv = useApiQuery<ReturnToVendor>(['return', rtvId], () => getReturnToVendor(rtvId));

  const rowVersion = rtv.data?.rowVersion ?? 1;
  const canViewCost = can('master.product.view_cost');
  // `Money { amount, currency }` exactly as the contract declares it; the service answers in
  // that shape now, so nothing normalises it on the way in.
  const claim = rtv.data?.claimAmount ?? null;

  const run = useMutation({
    mutationFn: () =>
      action === 'send'
        ? sendReturnToVendor(rtvId, rowVersion)
        : closeReturnToVendor(
            rtvId,
            rowVersion,
            outcome,
            // `Money` is `{ amount, currency }`; the amount stays a decimal string (ADR-008).
            claimAmount.trim() === ''
              ? null
              : {
                  amount: claimAmount.trim(),
                  currency: claim?.currency ?? 'AZN',
                },
            outcomeNote.trim() === '' ? null : outcomeNote.trim(),
          ),
    onSuccess: () => {
      setAction(null);
      void queryClient.invalidateQueries({ queryKey: ['return', rtvId] });
      void queryClient.invalidateQueries({ queryKey: ['returns'] });
    },
  });

  if (rtv.isLoading) return <LoadingState />;
  if (rtv.isError)
    return (
      <DocumentPage breadcrumb="Anbar · Qaytarma" docNo={`#${rtvId}`}>
        <ErrorState error={rtv.error} onRetry={() => void rtv.refetch()} />
      </DocumentPage>
    );
  const doc = rtv.data;
  if (!doc) return null;

  const isDraft = doc.status === 'DRAFT';
  const isSent = doc.status === 'SENT';
  const isClosed = doc.status === 'CLOSED';

  const columns: Column<WasteLine>[] = [
    { key: 'lineNo', header: '#', numeric: true, decimals: 0, width: '44px' },
    {
      key: 'product',
      header: 'Məhsul',
      render: (row) => <ProductCell name={row.product.name} sku={row.product.sku} />,
    },
    {
      key: 'batchNo',
      header: 'Partiya',
      width: '140px',
      render: (row) =>
        row.batch ? (
          <span className="wms-num wms-small">{row.batch.batchNo}</span>
        ) : (
          <span className="wms-muted wms-small">partiyasız</span>
        ),
    },
    {
      key: 'qty',
      header: 'Qaytarılan',
      width: '150px',
      numeric: true,
      render: (row) => `${formatNumber(row.qty, 4)} ${row.uomCode}`,
    },
    { key: 'qtyBase', header: 'Baza miqdarı', width: '140px', numeric: true, decimals: 4 },
    {
      key: 'unitCost',
      header: 'Vahid dəyəri',
      width: '130px',
      numeric: true,
      decimals: 4,
      permission: 'master.product.view_cost',
    },
    {
      key: 'totalValue',
      header: 'Dəyər, AZN',
      width: '130px',
      numeric: true,
      decimals: 4,
      permission: 'master.product.view_cost',
    },
    {
      key: 'note',
      header: 'Qeyd',
      render: (row) => row.note ?? <span className="wms-muted">—</span>,
    },
  ];

  return (
    <DocumentPage
      breadcrumb={
        <>
          <Link to="/inventory/balances">Anbar</Link> ·{' '}
          <Link to="/inventory/returns">Qaytarma</Link>
        </>
      }
      docNo={doc.docNo}
      status={doc.status}
      badges={
        <Badge tone="neutral" variant="outline" title={`supplierId = ${doc.supplierId}`}>
          {doc.supplierName}
        </Badge>
      }
      context={`${doc.lines.length} sətir · ${doc.location.name}`}
      actions={
        <>
          <Button variant="ghost" onClick={() => window.print()}>
            Çap et
          </Button>
          {isDraft ? (
            can('inv.rtv.create') ? (
              <Button variant="primary" onClick={() => setAction('send')}>
                Təchizatçıya göndər
              </Button>
            ) : (
              <Button disabled title="`inv.rtv.create` icazəniz yoxdur">
                Təchizatçıya göndər
              </Button>
            )
          ) : null}
          {isSent ? (
            can('inv.rtv.create') ? (
              <Button
                variant="primary"
                onClick={() => {
                  setOutcome('ACCEPTED');
                  setClaimAmount(claim?.amount ?? '');
                  setOutcomeNote('');
                  setAction('close');
                }}
              >
                Cavabı qeyd et
              </Button>
            ) : (
              <Button disabled title="`inv.rtv.create` icazəniz yoxdur">
                Cavabı qeyd et
              </Button>
            )
          ) : null}
          {isClosed ? (
            <Badge tone="neutral" title="SPEC §9.4">
              Bağlanmış sənəd redaktə olunmur
            </Badge>
          ) : null}
        </>
      }
    >
      {run.isError ? <ErrorState error={run.error} /> : null}
      {run.isSuccess ? (
        <Alert tone="success" title={`${doc.docNo} yeniləndi`}>
          Sənədin yeni statusu: <span className="wms-num">{doc.status}</span>.
        </Alert>
      ) : null}
      {doc.outcome === 'REJECTED' ? (
        <Alert tone="warning" title="Təchizatçı qaytarmanı qəbul etmədi" code="REJECTED">
          {doc.outcomeNote ?? 'Səbəb yazılmayıb.'} Mal geri alınırsa ayrıca qəbul sənədi
          yaradılmalıdır.
        </Alert>
      ) : null}

      <Card>
        <MetaGrid columns={6}>
          <Meta
            label="Sənəd tarixi"
            value={<span className="wms-num">{formatDate(doc.docDate)}</span>}
          />
          <Meta label="Təchizatçı" value={doc.supplierName} sub={`#${doc.supplierId}`} />
          <Meta label="Lokasiya" value={doc.location.name} sub={doc.location.code} />
          <Meta
            label="Mənbə qəbul"
            value={
              doc.receiptId ? (
                <Link to={`/inventory/goods-receipts/${doc.receiptId}`} className="wms-doc-no">
                  {doc.receiptDocNo ?? `#${doc.receiptId}`}
                </Link>
              ) : (
                <span className="wms-muted">qəbulsuz</span>
              )
            }
          />
          <Meta label="Səbəb kodu" value={<span className="wms-num">#{doc.reasonCodeId}</span>} />
          {canViewCost ? (
            <Meta
              label="İddia məbləği"
              value={
                <span className="wms-num">
                  {claim ? formatMoney(Money.parse(claim.amount, claim.currency), 2) : '—'}
                </span>
              }
              sub={doc.outcome ? OUTCOME_LABELS[doc.outcome] : undefined}
            />
          ) : (
            <Meta label="Nəticə" value={doc.outcome ? OUTCOME_LABELS[doc.outcome] : '—'} />
          )}
        </MetaGrid>
      </Card>

      <Card title="Qaytarılan sətirlər" flush>
        <DataTable<WasteLine>
          columns={columns}
          rows={doc.lines}
          permissions={session?.permissions ?? []}
          rowKey={(row) => row.id}
          label="Qaytarma sətirləri"
          empty="Bu sənəddə sətir yoxdur."
        />
      </Card>

      <AttachmentsCard
        entityType="RETURN_TO_VENDOR"
        entityId={doc.id}
        attachmentTypes={['DISCREPANCY_PHOTO', 'DELIVERY_NOTE', 'OTHER']}
      />

      <Card title="Sənəd izi">
        <MetaGrid columns={4}>
          <Meta
            label="Hərəkət qrupu"
            value={
              doc.movementGroupId ? (
                <Link to={`/inventory/movement-groups/${doc.movementGroupId}`} className="wms-num">
                  #{doc.movementGroupId}
                </Link>
              ) : (
                '—'
              )
            }
            sub={doc.movementGroupId ? 'RETURN qrupu' : 'göndərilməyib'}
          />
          <Meta
            label="Yaradılıb"
            value={
              <span className="wms-num">
                {doc.audit?.createdAt ? formatDateTime(doc.audit.createdAt) : '—'}
              </span>
            }
          />
          <Meta label="Qeyd" value={doc.note ?? '—'} />
          <Meta label="rowVersion" value={<span className="wms-num">{doc.rowVersion}</span>} />
        </MetaGrid>
      </Card>

      <Dialog
        open={action !== null}
        title={action === 'send' ? 'Malı təchizatçıya göndərim?' : 'Təchizatçının cavabı'}
        subtitle={
          action === 'send'
            ? 'Ledger-ə yazılır: lokasiyadan −miqdar, `V_SUPPLIER` üzərinə +miqdar.'
            : 'Cavab qeyd edildikdə sənəd bağlanır — bundan sonra dəyişmir.'
        }
        onClose={run.isPending ? undefined : () => setAction(null)}
        footer={
          <>
            <Button
              disabled={run.isPending}
              title={run.isPending ? 'Sorğu göndərilir' : undefined}
              onClick={() => setAction(null)}
            >
              İmtina
            </Button>
            <Button
              variant={action === 'close' && outcome === 'REJECTED' ? 'danger' : 'primary'}
              loading={run.isPending}
              onClick={() => run.mutate()}
            >
              {action === 'send' ? 'Göndər' : 'Bağla'}
            </Button>
          </>
        }
      >
        <div className="wms-stack">
          <span>
            <span className="wms-doc-no">{doc.docNo}</span> — {doc.supplierName}, {doc.lines.length}{' '}
            sətir.
          </span>
          {action === 'close' ? (
            <>
              <Select
                label="Nəticə"
                required
                value={outcome}
                options={[
                  { value: 'ACCEPTED', label: 'Təchizatçı qəbul etdi' },
                  { value: 'REJECTED', label: 'Təchizatçı qəbul etmədi' },
                ]}
                hint="Qəbul edilmədikdə mal geri alınırsa ayrıca qəbul sənədi lazımdır."
                onChange={(e) => setOutcome(e.target.value as 'ACCEPTED' | 'REJECTED')}
              />
              {canViewCost ? (
                <TextField
                  label="Yekun iddia məbləği, AZN"
                  mono
                  value={claimAmount}
                  placeholder="0.0000"
                  hint="Təchizatçının qəbul etdiyi məbləğ. Boş buraxılsa dəyişmir."
                  onChange={(e) => setClaimAmount(e.target.value)}
                />
              ) : null}
              <TextField
                label="Cavab qeydi"
                value={outcomeNote}
                hint="Audit jurnalına yazılır."
                onChange={(e) => setOutcomeNote(e.target.value)}
              />
            </>
          ) : (
            <Alert tone="info" title="Göndərmə geri alınmır">
              Sənəd `SENT` statusuna keçir və hərəkət qrupu yazılır. Düzəliş yalnız storno ilə
              mümkündür (SPEC §9.4).
            </Alert>
          )}
        </div>
      </Dialog>
    </DocumentPage>
  );
}

const OUTCOME_LABELS: Record<string, string> = {
  ACCEPTED: 'Təchizatçı qəbul etdi',
  REJECTED: 'Təchizatçı qəbul etmədi',
};
