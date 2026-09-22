import { useState } from 'react';
import { Link } from 'react-router-dom';
import { Badge, DataTable, Select, TextField, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listCategories, listProducts, type Category, type ProductSummary } from '@api/endpoints';
import { Card, ErrorState, LoadingState, Page } from '@/components/Page';
import { Pager } from '@/components/Pager';
import { MasterDataTabs } from './MasterDataTabs';

/**
 * Products — docs/ux/screen-map.md §5.3.
 *
 * Read-only in this build: `createProduct` / `updateProduct` are defined in the contract but not
 * routed by the gateway yet, and `sku` / `baseUomId` can never be changed after creation, so a
 * half-working edit form would be worse than none. The list and the document behind each row
 * are live.
 *
 * The filters are the contract's own (`master-data.v1.yaml#/products`), so the server does the
 * narrowing: a category filter that ran in the browser would only ever filter the page in hand.
 */
export function ProductsScreen() {
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [categoryId, setCategoryId] = useState('');
  const [productType, setProductType] = useState('');
  const [isActive, setIsActive] = useState('true');

  const categories = useApiPage<Category>(['categories', 'filter'], () => listCategories({}), 200, {
    retry: false,
  });

  const query = {
    page,
    size: 50,
    ...(search.trim() ? { q: search.trim() } : {}),
    ...(categoryId ? { categoryId: Number(categoryId) } : {}),
    ...(productType ? { productType: productType as ProductSummary['productType'] } : {}),
    ...(isActive === '' ? {} : { isActive: isActive === 'true' }),
  };
  const products = useApiPage<ProductSummary>(['products', query], () => listProducts(query), 50);

  const reset = () => setPage(1);

  const columns: Column<ProductSummary>[] = [
    {
      key: 'sku',
      header: 'SKU',
      width: '130px',
      render: (row) => (
        <Link className="wms-doc-no" to={`/master-data/products/${row.id}`}>
          {row.sku}
        </Link>
      ),
    },
    {
      key: 'name',
      header: 'Ad',
      render: (row) => <Link to={`/master-data/products/${row.id}`}>{row.name}</Link>,
    },
    {
      key: 'productType',
      header: 'Tip',
      width: '110px',
      render: (row) =>
        row.productType === 'FOOD' ? (
          <Badge tone="accent">Qida</Badge>
        ) : (
          <Badge tone="neutral">Qeyri-qida</Badge>
        ),
    },
    {
      key: 'baseUomCode',
      header: 'Base vahid',
      width: '110px',
      render: (row) => <span className="wms-num">{row.baseUomCode ?? `#${row.baseUomId}`}</span>,
    },
    {
      key: 'barcode',
      header: 'Barkod',
      width: '150px',
      render: (row) =>
        row.barcode ? (
          <span className="wms-doc-no">{row.barcode}</span>
        ) : (
          <span className="wms-muted">—</span>
        ),
    },
    {
      key: 'requiresBatch',
      header: 'Partiya',
      width: '110px',
      render: (row) =>
        row.requiresBatch ? (
          <Badge tone="accent">Tələb edir</Badge>
        ) : (
          <span className="wms-muted">—</span>
        ),
    },
    {
      key: 'requiresExpiry',
      header: 'Son istifadə',
      width: '120px',
      render: (row) =>
        row.requiresExpiry ? (
          <Badge tone="warning">Tələb edir</Badge>
        ) : (
          <span className="wms-muted">—</span>
        ),
    },
    {
      key: 'isActive',
      header: 'Vəziyyət',
      width: '110px',
      render: (row) =>
        row.isActive ? (
          <Badge tone="success">Aktiv</Badge>
        ) : (
          <Badge tone="neutral">Arxivlənib</Badge>
        ),
    },
  ];

  return (
    <Page
      title="Məhsullar"
      subtitle="Məhsul kataloqu — sıralama `nameSortKey` üzrə (Azərbaycan əlifbası)"
    >
      <MasterDataTabs />

      <Card>
        <div className="wms-toolbar">
          <TextField
            label="Axtarış"
            value={search}
            placeholder="SKU və ya ad"
            hint="Ad `TRIM` edilir; baş və son boşluqlar saxlanılmır."
            onChange={(e) => {
              setSearch(e.target.value);
              reset();
            }}
          />
          <Select
            label="Kateqoriya"
            value={categoryId}
            placeholder={
              categories.isError ? 'Kateqoriya siyahısı oxunmadı' : 'Bütün kateqoriyalar'
            }
            disabled={categories.isError}
            options={(categories.data?.items ?? []).map((c) => ({
              value: String(c.id),
              label: `${c.code} · ${c.name}`,
            }))}
            onChange={(e) => {
              setCategoryId(e.target.value);
              reset();
            }}
          />
          <Select
            label="Məhsul tipi"
            value={productType}
            placeholder="Hamısı"
            options={[
              { value: 'FOOD', label: 'Qida' },
              { value: 'NON_FOOD', label: 'Qeyri-qida' },
            ]}
            onChange={(e) => {
              setProductType(e.target.value);
              reset();
            }}
          />
          <Select
            label="Vəziyyət"
            value={isActive}
            placeholder="Hamısı"
            options={[
              { value: 'true', label: 'Aktiv' },
              { value: 'false', label: 'Arxivlənib' },
            ]}
            onChange={(e) => {
              setIsActive(e.target.value);
              reset();
            }}
          />
          <div className="wms-toolbar__spacer" />
        </div>
      </Card>

      <Card
        title="Məhsullar"
        subtitle={products.data ? `${products.data.total} məhsul` : undefined}
        flush
        footer={products.data ? <Pager page={products.data} onPageChange={setPage} /> : undefined}
      >
        {products.isLoading ? (
          <LoadingState />
        ) : products.isError ? (
          <div className="wms-card__body">
            <ErrorState error={products.error} onRetry={() => void products.refetch()} />
          </div>
        ) : (
          <DataTable<ProductSummary>
            columns={columns}
            rows={products.data?.items ?? []}
            rowKey={(row) => row.id}
            label="Məhsul siyahısı"
            empty="Bu axtarışa uyğun məhsul yoxdur. Axtarışı və ya filtrləri dəyişin."
          />
        )}
      </Card>
    </Page>
  );
}
