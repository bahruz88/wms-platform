import { useMemo, useState } from 'react';
import { useParams } from 'react-router-dom';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import {
  Alert,
  Badge,
  Button,
  DataTable,
  Dialog,
  DocStatusBadge,
  VarianceIndicator,
  type Column,
} from '@ds/index';
import { useApiPage, useApiQuery } from '@api/hooks';
import {
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
import { formatDate, formatDateTime, formatNumber } from '@core/format';
import { DocNo, ErrorState, KeyValue, LoadingState, Page, Section } from '@/components/Page';

type Line = GoodsReceipt['lines'][number];

/**
 * Goods receipt detail — docs/ux/screen-map.md §3.2.
 *
 *   · `unitPrice` carries `permission: "master.product.view_cost"`; the keeper never sees the
 *     column (SPEC §16);
 *   · a posted document has no "Redaktə et" — only a reversal creates a new document (SPEC §9.4);
 *   · posting goes through a confirmation dialog, and the 409s the operation can raise
 *     (`LOCATION_FROZEN`, `FX_RATE_MISSING`, `APPROVAL_REQUIRED`) are shown with their code.
 */
export function GoodsReceiptDetailScreen() {
  const { id } = useParams();
  const receiptId = Number(id);
  const { session, can } = useAuth();
  const queryClient = useQueryClient();
  const [postOpen, setPostOpen] = useState(false);

  const products = useApiPage<ProductSummary>(
    ['products', 'receipt'],
    () => listProducts({ page: 1, size: 200 }),
    200,
  );
  const uoms = useApiPage<Uom>(['uoms', 'receipt'], () => listUoms({}), 200);

  const receipt = useApiQuery<GoodsReceipt>(['goods-receipt', receiptId], () =>
    getGoodsReceipt(receiptId),
  );

  // Lines come back with flat productId / uomId; the adapter restores the contract shape.
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

  if (receipt.isLoading) return <LoadingState />;
  if (receipt.isError)
    return <ErrorState error={receipt.error} onRetry={() => void receipt.refetch()} />;
  if (!doc) return null;

  const isPosted = doc.status === 'POSTED';

  const columns: Column<Line>[] = [
    { key: 'lineNo', header: '№', numeric: true, decimals: 0, width: '48px' },
    {
      key: 'sku',
      header: 'SKU',
      render: (row) => <span className="wms-doc-no">{row.product.sku}</span>,
    },
    { key: 'product', header: 'Məhsul', render: (row) => row.product.name },
    {
      key: 'orderedQty',
      header: 'Sifariş',
      numeric: true,
      decimals: 4,
      render: (row) =>
        row.orderedQty ? (
          formatNumber(row.orderedQty, 4)
        ) : (
          <span className="wms-muted">PO-suz</span>
        ),
    },
    { key: 'receivedQty', header: 'Qəbul', numeric: true, decimals: 4 },
    { key: 'rejectedQty', header: 'Rədd', numeric: true, decimals: 4 },
    { key: 'uomCode', header: 'Vahid', width: '70px' },
    { key: 'acceptedQtyBase', header: 'Base miqdar', numeric: true, decimals: 4 },
    {
      key: 'variance',
      header: 'Fərq',
      render: (row) =>
        row.orderedQty ? (
          <VarianceIndicator
            book={row.orderedQty}
            counted={row.receivedQty}
            uom={row.uomCode}
            decimals={4}
            reasonCode={row.varianceNote ?? undefined}
          />
        ) : (
          <span className="wms-muted">—</span>
        ),
    },
    {
      key: 'batchNo',
      header: 'Partiya',
      render: (row) =>
        row.batchNo ? (
          <span className="wms-doc-no">{row.batchNo}</span>
        ) : (
          <span className="wms-muted">—</span>
        ),
    },
    { key: 'expiryDate', header: 'Son istifadə', render: (row) => formatDate(row.expiryDate) },
    // Cost column — not built at all without the permission.
    {
      key: 'unitPrice',
      header: 'Vahid qiyməti',
      numeric: true,
      decimals: 4,
      permission: 'master.product.view_cost',
    },
  ];

  return (
    <Page
      title={<DocNo value={doc.docNo} />}
      subtitle="Anbara qəbul sənədi"
      actions={
        <>
          <DocStatusBadge status={doc.status} />
          {isPosted ? (
            <Badge tone="neutral" title="SPEC §9.4">
              Post edilmiş sənəd redaktə olunmur
            </Badge>
          ) : can('inv.receipt.post') ? (
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
      {post.isSuccess ? (
        <Alert tone="success" title={`Qəbul edildi ${doc.docNo}`}>
          Balans yeniləndi; hərəkətlər `RECEIPT` qrupuna yazıldı.
        </Alert>
      ) : null}

      <Section title="Sənəd başlığı">
        <div className="wms-card">
          <KeyValue
            items={[
              ['Sənəd nömrəsi', <DocNo key="d" value={doc.docNo} />],
              ['Tarix', formatDate(doc.docDate)],
              ['Təchizatçı', doc.supplierName ?? `#${doc.supplierId}`],
              ['Lokasiya', doc.locationName ?? `#${doc.locationId}`],
              ['PO', doc.poDocNo ?? 'PO-suz qəbul'],
              ['Temperatur', doc.temperatureC ? `${formatNumber(doc.temperatureC, 2)} °C` : '—'],
              ['Keyfiyyət', <DocStatusBadge key="q" status={doc.qualityStatus} />],
              ['Qablaşdırma qeydi', doc.packagingNote ?? '—'],
              ['Post edilib', doc.postedAt ? formatDateTime(doc.postedAt) : '—'],
              ['Hərəkət qrupu', doc.movementGroupId ? String(doc.movementGroupId) : '—'],
              [
                'rowVersion',
                <span key="rv" className="wms-num">
                  {doc.rowVersion}
                </span>,
              ],
            ]}
          />
        </div>
      </Section>

      <Section title="Sətirlər">
        <DataTable<Line>
          columns={columns}
          rows={doc.lines}
          permissions={session?.permissions ?? []}
          rowKey={(row) => row.id}
          label="Qəbul sətirləri"
          empty="Bu qəbulda sətir yoxdur. Sətir əlavə edin və sonra post edin."
        />
      </Section>

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
            <DocNo value={doc.docNo} /> sənədindəki {doc.lines.length} sətir balansa yazılacaq;
            `V_SUPPLIER` lokasiyasından anbar lokasiyasına ikili yazılış qurulacaq.
          </span>
          {post.isError && isApiError(post.error) ? (
            <Alert tone="danger" title={post.error.problem.title} code={post.error.code}>
              {post.error.problem.detail}
            </Alert>
          ) : null}
        </div>
      </Dialog>
    </Page>
  );
}
