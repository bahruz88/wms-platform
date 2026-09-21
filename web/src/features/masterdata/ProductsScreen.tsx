import { useState } from 'react';
import { Badge, DataTable, TextField, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listProducts, type ProductSummary } from '@api/endpoints';
import { ErrorState, LoadingState, Page, Section } from '@/components/Page';
import { Pager } from '@/components/Pager';

/**
 * Products — docs/ux/screen-map.md §5.3.
 *
 * Read-only in this build: `createProduct` / `updateProduct` are defined in the contract but not
 * routed by the gateway yet, and `sku` / `baseUomId` can never be changed after creation, so a
 * half-working edit form would be worse than none. The list is live.
 */
export function ProductsScreen() {
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');

  const query = { page, size: 50, ...(search.trim() ? { q: search.trim() } : {}) };
  const products = useApiPage<ProductSummary>(['products', query], () => listProducts(query), 50);

  const columns: Column<ProductSummary>[] = [
    {
      key: 'sku',
      header: 'SKU',
      width: '130px',
      render: (row) => <span className="wms-doc-no">{row.sku}</span>,
    },
    { key: 'name', header: 'Ad' },
    {
      key: 'productType',
      header: 'Tip',
      render: (row) => <Badge tone="neutral">{row.productType}</Badge>,
    },
    {
      key: 'baseUomCode',
      header: 'Base vahid',
      render: (row) => row.baseUomCode ?? `#${row.baseUomId}`,
    },
    {
      key: 'barcode',
      header: 'Barkod',
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
      <div className="wms-toolbar">
        <TextField
          label="Axtarış"
          value={search}
          placeholder="SKU və ya ad"
          hint="Ad `TRIM` edilir; baş və son boşluqlar saxlanılmır."
          onChange={(e) => {
            setSearch(e.target.value);
            setPage(1);
          }}
        />
      </div>
      <Section>
        {products.isLoading ? (
          <LoadingState />
        ) : products.isError ? (
          <ErrorState error={products.error} onRetry={() => void products.refetch()} />
        ) : (
          <>
            <DataTable<ProductSummary>
              columns={columns}
              rows={products.data?.items ?? []}
              rowKey={(row) => row.id}
              label="Məhsul siyahısı"
              empty="Bu axtarışa uyğun məhsul yoxdur. Axtarışı dəyişin və ya yeni məhsul əlavə edin."
            />
            {products.data ? <Pager page={products.data} onPageChange={setPage} /> : null}
          </>
        )}
      </Section>
    </Page>
  );
}
