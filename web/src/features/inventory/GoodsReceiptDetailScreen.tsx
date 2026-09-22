import { useMemo, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { Alert, Badge, Button, DataTable, Dialog, VarianceIndicator, type Column } from '@ds/index';
import { useApiPage, useApiQuery } from '@api/hooks';
import {
  cancelGoodsReceipt,
  getGoodsReceipt,
  listProducts,
  listUoms,
  postGoodsReceipt,
  type GoodsReceipt,
  type ProductSummary,
  type Uom,
} from '@api/endpoints';
import { indexById, normalizeGoodsReceipt } from '@api/adapters';
import { useAuth } from '@auth/index';
import { isApiError } from '@api/problem';
import { Decimal } from '@core/decimal';
import { formatDate, formatDateTime, formatNumber } from '@core/format';
import {
  Card,
  DocumentPage,
  ErrorState,
  LoadingState,
  Meta,
  MetaGrid,
  NotOpenYet,
  ProductCell,
} from '@/components/Page';
import { AttachmentsCard } from '@/components/AttachmentsCard';
import { ReasonCodePicker, isUnrouted } from '@/components/ReasonCodePicker';

type Line = GoodsReceipt['lines'][number];

/**
 * Goods receipt document — docs/design-system/screens/Qebul.dc.html, the posted side of it.
 *
 *   · `unitPrice` carries `permission: "master.product.view_cost"`; the keeper never sees the
 *     column — it is not rendered at all, not blanked (SPEC §16);
 *   · a posted document has no "Redaktə et": a correction is a reversal, which creates a new
 *     document (SPEC §9.4);
 *   · posting goes through a confirmation dialog, and the 409s the operation can raise
 *     (`LOCATION_FROZEN`, `FX_RATE_MISSING`, `APPROVAL_REQUIRED`) are shown with their code.
 */
export function GoodsReceiptDetailScreen() {
  const { id } = useParams();
  const receiptId = Number(id);
  const { session, can } = useAuth();
  const queryClient = useQueryClient();
  const [postOpen, setPostOpen] = useState(false);
  const [cancelOpen, setCancelOpen] = useState(false);
  const [reasonCodeId, setReasonCodeId] = useState('');

  const products = useApiPage<ProductSummary>(
    ['products', 'receipt'],
    () => listProducts({ page: 1, size: 200 }),
    200,
    { retry: false },
  );
  const uoms = useApiPage<Uom>(['uoms', 'receipt'], () => listUoms({}), 200, { retry: false });
  const receipt = useApiQuery<GoodsReceipt>(['goods-receipt', receiptId], () =>
    getGoodsReceipt(receiptId),
  );

  // Lines still come back with flat productId / uomId; the adapter restores the contract shape.
  const productIndex = useMemo(() => indexById(products.data?.items ?? []), [products.data]);
  const uomIndex = useMemo(() => indexById(uoms.data?.items ?? []), [uoms.data]);
  const doc = useMemo(
    () => (receipt.data ? normalizeGoodsReceipt(receipt.data, productIndex, uomIndex) : null),
    [receipt.data, productIndex, uomIndex],
  );

  const post = useMutation({
    mutationFn: () => postGoodsReceipt(receiptId, receipt.data?.rowVersion ?? 1),
    onSuccess: () => {
      setPostOpen(false);
      void queryClient.invalidateQueries({ queryKey: ['goods-receipt', receiptId] });
    },
  });

  const cancel = useMutation({
    mutationFn: () =>
      cancelGoodsReceipt(receiptId, receipt.data?.rowVersion ?? 1, Number(reasonCodeId)),
    onSuccess: () => {
      setCancelOpen(false);
      void queryClient.invalidateQueries({ queryKey: ['goods-receipt', receiptId] });
    },
  });

  if (receipt.isLoading) return <LoadingState />;
  if (receipt.isError)
    return (
      <DocumentPage breadcrumb="Anbar · Qəbul" docNo={`#${receiptId}`} actions={null}>
        <ErrorState error={receipt.error} onRetry={() => void receipt.refetch()} />
      </DocumentPage>
    );
  if (!doc) return null;

  const isPosted = doc.status === 'POSTED';
  const canViewCost = can('master.product.view_cost');

  // `POST /goods-receipts/{id}/cancel` is in the contract but not routed on the gateway: it
  // answers a bare 404 with no problem `code`, i.e. an unmatched route rather than a refused
  // operation. The button is not hidden — the operation is real and the permission is real —
  // but the moment it comes back unrouted the dialog says so in place of a false success, and
  // the button afterwards carries the reason in its `title`.
  const cancelUnrouted = isUnrouted(cancel.error);

  const total = canViewCost
    ? doc.lines.reduce((acc, line) => {
        if (!line.unitPrice) return acc;
        try {
          return acc.plus(new Decimal(line.unitPrice).times(new Decimal(line.receivedQty)));
        } catch {
          return acc;
        }
      }, new Decimal(0))
    : null;

  const varianceLines = doc.lines.filter((line) => {
    if (!line.orderedQty) return false;
    try {
      return !new Decimal(line.orderedQty).equals(new Decimal(line.receivedQty));
    } catch {
      return false;
    }
  }).length;

  const columns: Column<Line>[] = [
    { key: 'lineNo', header: '#', numeric: true, decimals: 0, width: '44px' },
    {
      key: 'product',
      header: 'Məhsul',
      render: (row) => <ProductCell name={row.product.name} sku={row.product.sku} />,
    },
    {
      key: 'batchNo',
      header: 'Partiya',
      width: '130px',
      render: (row) =>
        row.batchNo ? (
          <span className="wms-num wms-small">{row.batchNo}</span>
        ) : (
          <span className="wms-muted wms-small">partiyasız</span>
        ),
    },
    {
      key: 'expiryDate',
      header: 'Son istifadə',
      width: '110px',
      render: (row) => <span className="wms-num wms-small">{formatDate(row.expiryDate)}</span>,
    },
    {
      key: 'orderedQty',
      header: 'Sifariş',
      width: '120px',
      numeric: true,
      render: (row) =>
        row.orderedQty ? (
          `${formatNumber(row.orderedQty, 3)} ${row.uomCode}`
        ) : (
          <span className="wms-muted">PO-suz</span>
        ),
    },
    {
      key: 'receivedQty',
      header: 'Qəbul edilən',
      width: '150px',
      numeric: true,
      render: (row) => `${formatNumber(row.receivedQty, 3)} ${row.uomCode}`,
    },
    { key: 'rejectedQty', header: 'Rədd', width: '110px', numeric: true, decimals: 3 },
    {
      key: 'variance',
      header: 'Fərq',
      width: '210px',
      render: (row) =>
        row.orderedQty ? (
          <VarianceIndicator
            book={row.orderedQty}
            counted={row.receivedQty}
            uom={row.uomCode}
            decimals={3}
            thresholdPct={0}
            reasonCode={row.varianceNote ?? undefined}
          />
        ) : (
          <span className="wms-muted wms-small">Fərq yoxdur</span>
        ),
    },
    // Cost column — not built at all without the permission.
    {
      key: 'unitPrice',
      header: 'Vahid qiymət',
      width: '120px',
      numeric: true,
      decimals: 4,
      permission: 'master.product.view_cost',
    },
  ];

  return (
    <DocumentPage
      breadcrumb={
        <>
          <Link to="/inventory/balances">Anbar</Link> ·{' '}
          <Link to="/inventory/goods-receipts">Qəbul</Link>
        </>
      }
      docNo={doc.docNo}
      status={doc.status}
      badges={
        doc.poDocNo ? (
          <Badge tone="neutral" variant="outline">
            {doc.poDocNo}
          </Badge>
        ) : (
          <Badge tone="neutral" variant="outline">
            PO-suz
          </Badge>
        )
      }
      context={`${doc.lines.length} sətir`}
      actions={
        <>
          <Button variant="ghost" onClick={() => window.print()}>
            Çap et
          </Button>
          {isPosted ? (
            <Badge tone="neutral" title="SPEC §9.4">
              Post edilmiş sənəd redaktə olunmur
            </Badge>
          ) : !can('inv.receipt.create') ? null : cancelUnrouted ? (
            <Button
              disabled
              title="POST /inventory/goods-receipts/{id}/cancel gateway-də marşrutlanmır (404)"
            >
              Ləğv et
            </Button>
          ) : (
            <Button variant="secondary" onClick={() => setCancelOpen(true)}>
              Ləğv et
            </Button>
          )}
          {isPosted ? null : can('inv.receipt.post') ? (
            <Button variant="primary" onClick={() => setPostOpen(true)}>
              Post et
            </Button>
          ) : (
            <Button disabled title="`inv.receipt.post` icazəniz yoxdur">
              Post et
            </Button>
          )}
        </>
      }
    >
      {post.isError ? <ErrorState error={post.error} /> : null}
      {/* An unrouted cancel is reported inside the dialog the user is still looking at. */}
      {cancel.isError && !cancelUnrouted ? <ErrorState error={cancel.error} /> : null}
      {post.isSuccess ? (
        <Alert tone="success" title={`Post edildi — ${doc.docNo}`}>
          Balans yeniləndi; hərəkətlər `RECEIPT` qrupuna yazıldı.
        </Alert>
      ) : null}
      {varianceLines > 0 ? (
        <Alert tone="warning" title={`${varianceLines} sətirdə PO ilə fərq var`}>
          receipt_over_tolerance_pct = 0 olduğu üçün artıq qəbul təsdiq tələb edir; çatışmazlıqda
          fərq qeydi məcburidir.
        </Alert>
      ) : null}

      <Card>
        <MetaGrid columns={6}>
          <Meta
            label="Təchizatçı"
            value={doc.supplierName ?? `#${doc.supplierId}`}
            sub={`Təchizatçı #${doc.supplierId}`}
          />
          <Meta
            label="Sənəd tarixi"
            value={<span className="wms-num">{formatDate(doc.docDate)}</span>}
          />
          <Meta label="Qəbul lokasiyası" value={doc.locationName ?? `#${doc.locationId}`} />
          <Meta
            label="Temperatur, °C"
            value={
              <span className="wms-num">
                {doc.temperatureC ? formatNumber(doc.temperatureC, 2) : '—'}
              </span>
            }
            sub={doc.temperatureC ? 'Soyuducu maşında ölçülüb' : undefined}
          />
          <Meta
            label="Keyfiyyət statusu"
            value={QUALITY_LABELS[doc.qualityStatus] ?? doc.qualityStatus}
          />
          <Meta label="Qablaşdırma qeydi" value={doc.packagingNote ?? '—'} />
        </MetaGrid>
      </Card>

      <Card title="Qəbul sətirləri" flush>
        <DataTable<Line>
          columns={columns}
          rows={doc.lines}
          permissions={session?.permissions ?? []}
          rowKey={(row) => row.id}
          label="Qəbul sətirləri"
          empty="Bu qəbulda sətir yoxdur. Sətir əlavə edin və sonra post edin."
          footer={{
            product: `${doc.lines.length} sətir`,
            ...(total ? { unitPrice: `${formatNumber(total.toFixed(2), 2)} AZN` } : {}),
          }}
        />
      </Card>

      <Card title="Sənəd izi" subtitle="Audit jurnalı bu sahələri saxlayır">
        <MetaGrid columns={4}>
          <Meta
            label="Post edilib"
            value={
              <span className="wms-num">{doc.postedAt ? formatDateTime(doc.postedAt) : '—'}</span>
            }
          />
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
          />
          <Meta
            label="Yaradılıb"
            value={
              <span className="wms-num">
                {doc.audit?.createdAt ? formatDateTime(doc.audit.createdAt) : '—'}
              </span>
            }
          />
          <Meta label="rowVersion" value={<span className="wms-num">{doc.rowVersion}</span>} />
        </MetaGrid>
      </Card>

      <AttachmentsCard
        entityType="GOODS_RECEIPT"
        entityId={doc.id}
        attachmentTypes={['DELIVERY_NOTE', 'INVOICE', 'CERTIFICATE', 'TEMP_PHOTO', 'OTHER']}
      />

      <Dialog
        open={postOpen}
        title="Qəbulu post edim?"
        subtitle="Post edildikdən sonra sənəd redaktə olunmur — yalnız storno mümkündür."
        onClose={post.isPending ? undefined : () => setPostOpen(false)}
        footer={
          <>
            <Button
              disabled={post.isPending}
              title={post.isPending ? 'Sorğu göndərilir' : undefined}
              onClick={() => setPostOpen(false)}
            >
              İmtina
            </Button>
            <Button variant="primary" loading={post.isPending} onClick={() => post.mutate()}>
              Post et
            </Button>
          </>
        }
      >
        <div className="wms-stack">
          <span>
            <span className="wms-doc-no">{doc.docNo}</span> sənədindəki {doc.lines.length} sətir
            balansa yazılacaq; `V_SUPPLIER` lokasiyasından anbar lokasiyasına ikili yazılış
            qurulacaq.
          </span>
          {post.isError && isApiError(post.error) ? (
            <Alert tone="danger" title={post.error.problem.title} code={post.error.code}>
              {post.error.problem.detail}
            </Alert>
          ) : null}
        </div>
      </Dialog>

      <Dialog
        open={cancelOpen}
        title="Qəbulu ləğv edim?"
        subtitle="Ləğv edilmiş qaralama balansa düşmür; səbəb kodu audit jurnalına yazılır."
        onClose={cancel.isPending ? undefined : () => setCancelOpen(false)}
        footer={
          <>
            <Button
              disabled={cancel.isPending}
              title={cancel.isPending ? 'Sorğu göndərilir' : undefined}
              onClick={() => setCancelOpen(false)}
            >
              İmtina
            </Button>
            <Button
              variant="danger"
              loading={cancel.isPending}
              disabled={!reasonCodeId}
              title={!reasonCodeId ? 'Səbəb kodu məcburidir' : undefined}
              onClick={() => cancel.mutate()}
            >
              Ləğv et
            </Button>
          </>
        }
      >
        <div className="wms-stack">
          <ReasonCodePicker
            reasonGroup="ADJUSTMENT"
            cacheKey="receipt-cancel"
            value={reasonCodeId}
            onChange={setReasonCodeId}
          />
          {cancelUnrouted ? (
            <NotOpenYet
              operation="POST /inventory/goods-receipts/{id}/cancel"
              status={isApiError(cancel.error) ? cancel.error.status : 404}
            >
              Sənəd dəyişmədi — sorğu gateway-də marşrutlanmır. Qaralamanı bağlamaq üçün əməliyyat
              açılana qədər anbar müdirinə müraciət edin.
            </NotOpenYet>
          ) : null}
        </div>
      </Dialog>
    </DocumentPage>
  );
}

const QUALITY_LABELS: Record<string, string> = {
  ACCEPTED: 'Tam qəbul edildi',
  PARTIALLY_ACCEPTED: 'Qismən qəbul edildi',
  REJECTED: 'Rədd edildi',
};
