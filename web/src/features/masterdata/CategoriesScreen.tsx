import { useMemo, useState } from 'react';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { Alert, Badge, Button, DataTable, Select, TextField, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { createCategory, listCategories, updateCategory, type Category } from '@api/endpoints';
import { useAuth } from '@auth/index';
import { Card, ErrorState, LoadingState, Page } from '@/components/Page';
import {
  ReferenceFormDialog,
  codeField,
  text,
  type FieldSpec,
  type FormValues,
} from '@/components/ReferenceFormDialog';
import { MasterDataTabs } from './MasterDataTabs';

/**
 * Categories — docs/ux/screen-map.md §5.3, the tree `master_category.path` encodes.
 *
 * The screen exists because `productType` and `defaultIssueStrategy` are decided here and then
 * inherited by every product underneath: a `FOOD` category is what makes a receipt from an
 * unapproved supplier a `422`, and `defaultIssueStrategy` is the FEFO/FIFO order the issue
 * screen suggests batches in when the product does not override it (SPEC §12.4).
 *
 * A category's `code` and `productType` are fixed after creation: the code is what other rows point
 * at, and the type is inherited by every product underneath, so changing it would silently rewrite
 * the receiving rules of stock already on the shelf. The edit form therefore offers neither.
 */

/** Depth from `path`: `/FOOD/DAIRY` is one level in. Indentation is the tree, there is no grid. */
function depthOf(path: string): number {
  return Math.max(0, path.split('/').filter(Boolean).length - 1);
}

export function CategoriesScreen() {
  const { can } = useAuth();
  const queryClient = useQueryClient();
  const [search, setSearch] = useState('');
  const [productType, setProductType] = useState('');
  const [editing, setEditing] = useState<Category | null>(null);
  const [creating, setCreating] = useState(false);

  // `productType` is a contract filter, so the server narrows it; free-text search is not, and
  // is applied to the answer.
  const query = productType ? { productType: productType as Category['productType'] } : {};
  const categories = useApiPage<Category>(['categories', query], () => listCategories(query), 200);

  // Memoised because the field list below depends on it: `?? []` would hand `useMemo` a new
  // array on every render and the memo would never hold.
  const all = useMemo(() => categories.data?.items ?? [], [categories.data]);
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

  const refresh = () => {
    setCreating(false);
    setEditing(null);
    void queryClient.invalidateQueries({ queryKey: ['categories'] });
  };

  const create = useMutation({
    mutationFn: (values: FormValues) =>
      createCategory({
        code: text(values, 'code'),
        name: text(values, 'name'),
        productType: values.productType as Category['productType'],
        ...(values.parentId ? { parentId: Number(values.parentId) } : {}),
        ...(values.defaultIssueStrategy
          ? { defaultIssueStrategy: values.defaultIssueStrategy as 'FEFO' | 'FIFO' }
          : {}),
      }),
    onSuccess: refresh,
  });

  const update = useMutation({
    mutationFn: (values: FormValues) =>
      updateCategory(editing!.id, {
        name: text(values, 'name'),
        isActive: values.isActive === 'true',
        rowVersion: editing!.rowVersion,
        ...(values.parentId ? { parentId: Number(values.parentId) } : {}),
        ...(values.defaultIssueStrategy
          ? { defaultIssueStrategy: values.defaultIssueStrategy as 'FEFO' | 'FIFO' }
          : {}),
      }),
    onSuccess: refresh,
  });

  const fields: FieldSpec[] = useMemo(
    () => [
      {
        name: 'code',
        label: 'Kod',
        kind: 'text',
        required: true,
        createOnly: true,
        hint: 'Sonradan dəyişmir — digər sətirlər buna işarə edir.',
        validate: codeField,
      },
      { name: 'name', label: 'Ad', kind: 'text', required: true },
      {
        name: 'productType',
        label: 'Məhsul tipi',
        kind: 'select',
        required: true,
        createOnly: true,
        hint: 'Altındaki bütün məhsullara miras qalır; sonradan dəyişmir.',
        options: [
          { value: 'FOOD', label: 'Qida' },
          { value: 'NON_FOOD', label: 'Qeyri-qida' },
        ],
      },
      {
        name: 'parentId',
        label: 'Üst kateqoriya',
        kind: 'select',
        hint: 'Boş buraxılsa kök kateqoriya olur.',
        options: [
          { value: '', label: 'Kök kateqoriya' },
          ...all.map((c) => ({ value: String(c.id), label: `${c.code} · ${c.name}` })),
        ],
      },
      {
        name: 'defaultIssueStrategy',
        label: 'Məxaric sırası',
        kind: 'select',
        hint: 'Boş buraxılsa məhsulun özündən götürülür.',
        options: [
          { value: '', label: 'Məhsuldan' },
          { value: 'FEFO', label: 'FEFO' },
          { value: 'FIFO', label: 'FIFO' },
        ],
      },
      { name: 'isActive', label: 'Aktiv', kind: 'switch' },
    ],
    [all],
  );

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
    ...(can('master.category.manage')
      ? [
          {
            key: 'edit',
            header: '',
            width: '110px',
            render: (row: Category) => (
              <Button size="sm" variant="secondary" onClick={() => setEditing(row)}>
                Redaktə
              </Button>
            ),
          } as Column<Category>,
        ]
      : []),
  ];

  return (
    <Page
      title="Kateqoriyalar"
      subtitle="`master_category` ağacı — məhsul tipi və default məxaric sırası buradan miras qalır"
      actions={
        can('master.category.manage') ? (
          <Button variant="primary" onClick={() => setCreating(true)}>
            Yeni kateqoriya
          </Button>
        ) : null
      }
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
      <ReferenceFormDialog
        open={creating}
        mode="create"
        title="Yeni kateqoriya"
        subtitle="Kod və məhsul tipi sonradan dəyişmir."
        fields={fields}
        initial={{ productType: 'FOOD', isActive: 'true' }}
        pending={create.isPending}
        error={create.isError ? create.error : undefined}
        onClose={() => setCreating(false)}
        onSubmit={(values) => create.mutate(values)}
      />

      <ReferenceFormDialog
        open={editing !== null}
        mode="edit"
        title={editing ? `Kateqoriya: ${editing.code}` : ''}
        fields={fields}
        initial={
          editing
            ? {
                name: editing.name,
                parentId: editing.parentId ? String(editing.parentId) : '',
                defaultIssueStrategy: editing.defaultIssueStrategy ?? '',
                isActive: String(editing.isActive),
              }
            : undefined
        }
        pending={update.isPending}
        error={update.isError ? update.error : undefined}
        onClose={() => setEditing(null)}
        onSubmit={(values) => update.mutate(values)}
      />

    </Page>
  );
}
