import { Link, useParams } from 'react-router-dom';
import { Alert, Badge, DataTable, type Column } from '@ds/index';
import { useApiQuery } from '@api/hooks';
import { getProduct, type Product, type ProductUomRow } from '@api/endpoints';
import { useAuth } from '@auth/index';
import { formatDate, formatDateTime, formatNumber } from '@core/format';
import {
  Card,
  DocumentPage,
  ErrorState,
  KeyValue,
  LoadingState,
  Meta,
  MetaGrid,
} from '@/components/Page';

/**
 * A product as master data holds it — docs/ux/screen-map.md §5.3.
 *
 * The list can only show what fits in a row; the things that actually decide how a product
 * behaves are here: the category it inherits `productType` from, the issue strategy the batch
 * picker follows, the stock thresholds the reorder report reads, and — the reason this screen
 * exists at all — `master_product_uom`, the alternative units the product may be entered in.
 * `QtyUomInput` offers exactly these rows, so seeing them is how a keeper knows whether a
 * receipt can be typed in `KG` instead of `G`.
 *
 * Read-only: `PUT /masterdata/products/{id}` is in the contract and not routed, and `sku` and
 * `baseUomId` can never change once movements exist.
 */
export function ProductDetailScreen() {
  const { id } = useParams();
  const productId = Number(id);
  const { can } = useAuth();
  const canViewCost = can('master.product.view_cost');

  const product = useApiQuery<Product>(['product', productId], () => getProduct(productId));

  if (product.isLoading) return <LoadingState />;
  if (product.isError)
    return (
      <DocumentPage breadcrumb="Master data · Məhsullar" docNo={`#${productId}`}>
        <ErrorState error={product.error} onRetry={() => void product.refetch()} />
      </DocumentPage>
    );

  const doc = product.data;
  if (!doc) return null;

  const uomColumns: Column<ProductUomRow>[] = [
    {
      key: 'uomCode',
      header: 'Vahid',
      width: '110px',
      render: (row) => <span className="wms-doc-no">{row.uomCode}</span>,
    },
    {
      key: 'factorToBase',
      header: `1 vahid = ? ${doc.baseUomCode ?? 'base'}`,
      width: '190px',
      numeric: true,
      render: (row) => <span className="wms-num">{formatNumber(row.factorToBase, 8)}</span>,
    },
    {
      key: 'isPurchaseDefault',
      header: 'Alış defoltu',
      width: '130px',
      render: (row) =>
        row.isPurchaseDefault ? (
          <Badge tone="accent">Bəli</Badge>
        ) : (
          <span className="wms-muted">—</span>
        ),
    },
    {
      key: 'isIssueDefault',
      header: 'Məxaric defoltu',
      width: '140px',
      render: (row) =>
        row.isIssueDefault ? (
          <Badge tone="accent">Bəli</Badge>
        ) : (
          <span className="wms-muted">—</span>
        ),
    },
    {
      key: 'validFrom',
      header: 'Qüvvədədir',
      width: '190px',
      render: (row) => (
        <span className="wms-num wms-small">
          {formatDate(row.validFrom)}
          {row.validTo ? ` — ${formatDate(row.validTo)}` : ' — bu gün'}
        </span>
      ),
    },
  ];

  const stockRows: Array<[string, string | null | undefined]> = [
    ['Minimum qalıq', doc.minStock],
    ['Maksimum qalıq', doc.maxStock],
    ['Yenidən sifariş nöqtəsi', doc.reorderPoint],
  ];

  return (
    <DocumentPage
      breadcrumb={
        <>
          <Link to="/master-data/products">Master data · Məhsullar</Link>
        </>
      }
      docNo={doc.sku}
      badges={
        <>
          {doc.isActive ? (
            <Badge tone="success">Aktiv</Badge>
          ) : (
            <Badge tone="neutral">Arxivlənib</Badge>
          )}
          {doc.productType === 'FOOD' ? (
            <Badge tone="accent">Qida</Badge>
          ) : (
            <Badge tone="neutral">Qeyri-qida</Badge>
          )}
          {doc.requiresBatch ? <Badge tone="accent">Partiya tələb edir</Badge> : null}
          {doc.requiresExpiry ? <Badge tone="warning">Son istifadə tələb edir</Badge> : null}
        </>
      }
      context={doc.name}
    >
      {doc.requiresExpiry && !doc.shelfLifeDays ? (
        <Alert tone="warning" title="Son istifadə tələb olunur, raf ömrü yazılmayıb">
          Qəbulda tarix əl ilə yazılmalıdır — <span className="wms-num">shelfLifeDays</span> boş
          olduqda server onu hesablaya bilmir.
        </Alert>
      ) : null}

      <Card title="Məhsul">
        <MetaGrid columns={6}>
          <Meta label="SKU" value={<span className="wms-doc-no">{doc.sku}</span>} />
          <Meta label="Ad" value={doc.name} sub={doc.brand ?? undefined} />
          <Meta
            label="Kateqoriya"
            value={<span className="wms-num">{doc.categoryPath ?? `#${doc.categoryId}`}</span>}
            sub={doc.productType === 'FOOD' ? 'qida' : 'qeyri-qida'}
          />
          <Meta
            label="Base vahid"
            value={<span className="wms-num">{doc.baseUomCode ?? `#${doc.baseUomId}`}</span>}
            sub="bütün qalıqlar bu vahiddədir"
          />
          <Meta
            label="Məxaric sırası"
            value={<Badge tone="neutral">{doc.issueStrategy}</Badge>}
            sub="partiya təklifinin sırası"
          />
          <Meta
            label="Barkod"
            value={
              doc.barcode ? (
                <span className="wms-doc-no">{doc.barcode}</span>
              ) : (
                <span className="wms-muted">—</span>
              )
            }
          />
        </MetaGrid>
      </Card>

      <div className="wms-grid wms-grid--2">
        <Card title="Qalıq hədləri" subtitle={`base vahid: ${doc.baseUomCode ?? doc.baseUomId}`}>
          <KeyValue
            items={stockRows.map(([label, value]) => [
              label,
              value ? (
                <span className="wms-num">{formatNumber(value, 4)}</span>
              ) : (
                <span className="wms-muted">təyin edilməyib</span>
              ),
            ])}
          />
        </Card>

        <Card title="Digər">
          <KeyValue
            items={[
              [
                'Raf ömrü',
                doc.shelfLifeDays ? (
                  <span className="wms-num">{doc.shelfLifeDays} gün</span>
                ) : (
                  <span className="wms-muted">—</span>
                ),
              ],
              [
                'ƏDV dərəcəsi',
                canViewCost ? (
                  <span className="wms-num">{formatNumber(doc.vatRate, 2)} %</span>
                ) : (
                  <span className="wms-muted">`master.product.view_cost` icazəsi yoxdur</span>
                ),
              ],
              [
                'Default təchizatçı',
                doc.defaultSupplierId ? (
                  <Link to={`/master-data/suppliers/${doc.defaultSupplierId}`}>
                    <span className="wms-num">#{doc.defaultSupplierId}</span>
                  </Link>
                ) : (
                  <span className="wms-muted">—</span>
                ),
              ],
              [
                'Son dəyişiklik',
                <span className="wms-num wms-small" key="audit">
                  {formatDateTime(doc.audit.updatedAt ?? doc.audit.createdAt)} · v
                  {doc.audit.rowVersion}
                </span>,
              ],
            ]}
          />
        </Card>
      </div>

      <Card
        title="Ölçü vahidləri"
        subtitle="`master_product_uom` — miqdar bu vahidlərin hər birində yazıla bilər"
        flush
      >
        <DataTable<ProductUomRow>
          columns={uomColumns}
          rows={doc.uoms ?? []}
          rowKey={(row) => row.id}
          label="Məhsulun ölçü vahidləri"
          empty="Yalnız base vahid var. Alternativ vahid (məsələn CASE = 12 PCS) master data-da təyin edilir."
        />
      </Card>
    </DocumentPage>
  );
}
