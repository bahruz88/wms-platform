import { useState } from 'react';
import { Link } from 'react-router-dom';
import { Badge, DataTable, Select, TextField, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listMenuItems, type MenuItem } from '@api/endpoints';
import { ErrorState, LoadingState, Page, Section } from '@/components/Page';
import { Pager } from '@/components/Pager';

/**
 * Recipe catalogue — the menu items consumption is calculated from (ADR-012,
 * docs/architecture/branch-operations.md). A menu item without an active recipe produces no
 * consumption: its sales arrive as `unmapped`, which is why the flag is shown as a warning here
 * rather than as an empty cell.
 */
export function RecipesScreen() {
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [kind, setKind] = useState<'' | 'sub' | 'sold'>('');

  const query = {
    page,
    size: 50,
    ...(search.trim() ? { q: search.trim() } : {}),
    ...(kind ? { isSubRecipe: kind === 'sub' } : {}),
  };
  const menuItems = useApiPage<MenuItem>(['menu-items', query], () => listMenuItems(query), 50);

  const columns: Column<MenuItem>[] = [
    {
      key: 'code',
      header: 'Kod',
      width: '130px',
      render: (row) => (
        <Link to={`/consumption/recipes/${row.id}`}>
          <span className="wms-doc-no">{row.code}</span>
        </Link>
      ),
    },
    { key: 'name', header: 'Ad' },
    { key: 'category', header: 'Kateqoriya', render: (row) => row.category ?? '—' },
    {
      key: 'posCode',
      header: 'POS kodu',
      render: (row) =>
        row.posCode ? (
          <span className="wms-doc-no">{row.posCode}</span>
        ) : (
          <span className="wms-muted">Bağlanmayıb</span>
        ),
    },
    {
      key: 'isSubRecipe',
      header: 'Növ',
      render: (row) =>
        row.isSubRecipe ? (
          <Badge tone="accent">Yarımfabrikat</Badge>
        ) : (
          <Badge tone="neutral">Satılan maddə</Badge>
        ),
    },
    {
      key: 'activeRecipeId',
      header: 'Aktiv resept',
      render: (row) =>
        row.activeRecipeId ? (
          <Badge tone="success">{`Versiya #${row.activeRecipeId}`}</Badge>
        ) : (
          <Badge tone="warning" title="Satış gəldikdə sətir `unmapped` olur">
            Resept yoxdur
          </Badge>
        ),
    },
    {
      key: 'isActive',
      header: 'Vəziyyət',
      render: (row) =>
        row.isActive ? <Badge tone="success">Aktiv</Badge> : <Badge tone="neutral">Bağlı</Badge>,
    },
  ];

  return (
    <Page
      title="Reseptlər"
      subtitle="Menyu maddələri və onların aktiv resept versiyaları — nəzəri istehlakın mənbəyi"
    >
      <div className="wms-toolbar">
        <TextField
          label="Axtarış"
          value={search}
          placeholder="Kod, ad və ya POS kodu"
          onChange={(e) => {
            setSearch(e.target.value);
            setPage(1);
          }}
        />
        <Select
          label="Növ"
          value={kind}
          placeholder="Hamısı"
          options={[
            { value: 'sold', label: 'Satılan maddələr' },
            { value: 'sub', label: 'Yarımfabrikatlar' },
          ]}
          onChange={(e) => {
            setKind(e.target.value as typeof kind);
            setPage(1);
          }}
        />
      </div>
      <Section>
        {menuItems.isLoading ? (
          <LoadingState />
        ) : menuItems.isError ? (
          <ErrorState error={menuItems.error} onRetry={() => void menuItems.refetch()} />
        ) : (
          <>
            <DataTable<MenuItem>
              columns={columns}
              rows={menuItems.data?.items ?? []}
              rowKey={(row) => row.id}
              label="Menyu maddələri"
              empty="Menyu maddəsi yoxdur. İstehlak hesablanması üçün ən azı bir resept lazımdır."
            />
            {menuItems.data ? <Pager page={menuItems.data} onPageChange={setPage} /> : null}
          </>
        )}
      </Section>
    </Page>
  );
}
