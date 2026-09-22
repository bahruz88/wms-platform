import { useState } from 'react';
import { Alert, Badge, DataTable, Select, TextField, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listCategories, type Category } from '@api/endpoints';
import { Card, ErrorState, LoadingState, Page } from '@/components/Page';
import { MasterDataTabs } from './MasterDataTabs';

/**
 * Categories — docs/ux/screen-map.md §5.3, the tree `master_category.path` encodes.
 *
 * The screen exists because `productType` and `defaultIssueStrategy` are decided here and then
 * inherited by every product underneath: a `FOOD` category is what makes a receipt from an
 * unapproved supplier a `422`, and `defaultIssueStrategy` is the FEFO/FIFO order the issue
 * screen suggests batches in when the product does not override it (SPEC §12.4).
 *
 * Read-only: `POST`/`PUT /masterdata/categories` are in the contract but not routed, and a
 * category's `productType` can never be changed once products hang off it.
 */

/** Depth from `path`: `/FOOD/DAIRY` is one level in. Indentation is the tree, there is no grid. */
function depthOf(path: string): number {
  return Math.max(0, path.split('/').filter(Boolean).length - 1);
}

export function CategoriesScreen() {
  const [search, setSearch] = useState('');
  const [productType, setProductType] = useState('');

  // `productType` is a contract filter, so the server narrows it; free-text search is not, and
  // is applied to the answer.
  const query = productType ? { productType: productType as Category['productType'] } : {};
  const categories = useApiPage<Category>(['categories', query], () => listCategories(query), 200);

  const all = categories.data?.items ?? [];
  const needle = search.trim().toLowerCase();
  // Sorted by `path` so a child always follows its parent; the indent then reads as the tree.
  const rows = [...all]
    .filter(
      (row) =>
        needle === '' ||
        row.code.toLowerCase().includes(needle) ||
        row.name.toLowerCase().includes(needle) ||
        row.path.toLowerCase().includes(needle),
    )
    .sort((a, b) => a.path.localeCompare(b.path, 'az'));

  const columns: Column<Category>[] = [
    {
      key: 'code',
      header: 'Kod',
      width: '170px',
      render: (row) => (
        <span style={{ paddingLeft: depthOf(row.path) * 16 }}>
          <span className="wms-doc-no">{row.code}</span>
        </span>
      ),
    },
    { key: 'name', header: 'Ad' },
    {
      key: 'path',
      header: 'Yol',
      width: '200px',
      render: (row) => <span className="wms-num wms-small">{row.path}</span>,
    },
    {
      key: 'productType',
      header: 'Məhsul tipi',
      width: '130px',
      render: (row) =>
        row.productType === 'FOOD' ? (
          <Badge tone="accent">Qida</Badge>
        ) : (
          <Badge tone="neutral">Qeyri-qida</Badge>
        ),
    },
    {
      key: 'defaultIssueStrategy',
      header: 'Məxaric sırası',
      width: '140px',
      render: (row) =>
        row.defaultIssueStrategy ? (
          <Badge tone="neutral" variant="outline">
            {row.defaultIssueStrategy}
          </Badge>
        ) : (
          <span className="wms-muted">məhsuldan</span>
        ),
    },
    {
      key: 'parentId',
      header: 'Üst kateqoriya',
      width: '140px',
      render: (row) =>
        row.parentId ? (
          <span className="wms-num">
            {all.find((c) => c.id === row.parentId)?.code ?? `#${row.parentId}`}
          </span>
        ) : (
          <span className="wms-muted">kök</span>
        ),
    },
    {
      key: 'isActive',
      header: 'Vəziyyət',
      width: '110px',
      render: (row) =>
        row.isActive ? <Badge tone="success">Aktiv</Badge> : <Badge tone="neutral">Bağlı</Badge>,
    },
  ];

  return (
    <Page
      title="Kateqoriyalar"
      subtitle="`master_category` ağacı — məhsul tipi və default məxaric sırası buradan miras qalır"
    >
      <MasterDataTabs />

      <Alert tone="info" title="Kateqoriya məhsulun davranışını təyin edir">
        <span className="wms-num">FOOD</span> kateqoriyasındakı məhsul yalnız qida təsdiqi olan
        təchizatçıdan qəbul edilir (TOR §7), və{' '}
        <span className="wms-num">defaultIssueStrategy</span> məhsul onu əvəz etmədikdə partiya
        təklifinin sırasıdır (SPEC §12.4).
      </Alert>

      <Card>
        <div className="wms-toolbar">
          <TextField
            label="Axtarış"
            value={search}
            placeholder="Kod, ad və ya yol"
            onChange={(e) => setSearch(e.target.value)}
          />
          <Select
            label="Məhsul tipi"
            value={productType}
            placeholder="Hamısı"
            options={[
              { value: 'FOOD', label: 'Qida' },
              { value: 'NON_FOOD', label: 'Qeyri-qida' },
            ]}
            onChange={(e) => setProductType(e.target.value)}
          />
          <div className="wms-toolbar__spacer" />
        </div>
      </Card>

      <Card title="Kateqoriyalar" subtitle={`${rows.length} / ${all.length} kateqoriya`} flush>
        {categories.isLoading ? (
          <LoadingState />
        ) : categories.isError ? (
          <div className="wms-card__body">
            <ErrorState error={categories.error} onRetry={() => void categories.refetch()} />
          </div>
        ) : (
          <DataTable<Category>
            columns={columns}
            rows={rows}
            rowKey={(row) => row.id}
            label="Kateqoriya siyahısı"
            empty={
              all.length === 0
                ? 'Kateqoriya yoxdur. Məhsul kataloqu kateqoriya ağacı olmadan qurula bilmir.'
                : 'Bu filtrə uyğun kateqoriya yoxdur. Axtarışı və ya məhsul tipini dəyişin.'
            }
          />
        )}
      </Card>
    </Page>
  );
}
