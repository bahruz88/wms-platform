import { useMemo, useState } from 'react';
import { Badge, DataTable, Select, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import {
  listBalances,
  listLocations,
  listProducts,
  type Balance,
  type Location,
  type ProductSummary,
} from '@api/endpoints';
import { indexById, normalizeBalance } from '@api/adapters';
import { useAuth } from '@auth/index';
import { ErrorState, LoadingState, Page, Section } from '@/components/Page';
import { Pager } from '@/components/Pager';

/**
 * Balances — docs/ux/screen-map.md §3.3.
 *
 * Two rules shape this screen:
 *   · **balance is never an input.** There is no edit control anywhere on it; stock moves only
 *     through a document (ADR-004).
 *   · `avgUnitCost` and `totalValue` carry `permission: "master.product.view_cost"`, so without
 *     that code the columns are not built at all. The server already leaves the fields out of the
 *     JSON — the interface repeats that, it does not stand in for it (SPEC §16).
 */
export function BalancesScreen() {
  const { session } = useAuth();
  const [page, setPage] = useState(1);
  const [locationId, setLocationId] = useState<string>('');
  const [includeZero, setIncludeZero] = useState(false);

  const locations = useApiPage<Location>(['locations', 'all'], () => listLocations({}), 200);

  const query = {
    page,
    size: 50,
    ...(locationId ? { locationId: Number(locationId) } : {}),
    ...(includeZero ? { includeZero: true } : {}),
  };

  const products = useApiPage<ProductSummary>(
    ['products', 'balances'],
    () => listProducts({ page: 1, size: 200 }),
    200,
  );

  const raw = useApiPage<Balance>(['balances', query], () => listBalances(query), 50);

  // The gateway answers this endpoint with flat ids; the adapter restores the contract shape and
  // resolves the product and location names from the master-data lists (see src/api/adapters.ts).
  const productIndex = useMemo(() => indexById(products.data?.items ?? []), [products.data]);
  const locationIndex = useMemo(() => indexById(locations.data?.items ?? []), [locations.data]);
  const balances = useMemo(
    () =>
      raw.data
        ? {
            ...raw.data,
            items: raw.data.items.map((row) => normalizeBalance(row, productIndex, locationIndex)),
          }
        : undefined,
    [raw.data, productIndex, locationIndex],
  );

  const columns: Column<Balance>[] = [
    {
      key: 'sku',
      header: 'SKU',
      width: '120px',
      render: (row) => <span className="wms-doc-no">{row.product.sku}</span>,
    },
    { key: 'product', header: 'Məhsul', render: (row) => row.product.name },
    {
      key: 'location',
      header: 'Lokasiya',
      render: (row) =>
        row.location.isVirtual ? (
          <Badge tone="virtual" title={row.location.code}>
            {row.location.name}
          </Badge>
        ) : (
          row.location.name
        ),
    },
    {
      key: 'batch',
      header: 'Partiya',
      render: (row) =>
        row.batch ? (
          <span className="wms-doc-no">{row.batch.batchNo}</span>
        ) : (
          <span className="wms-muted">—</span>
        ),
    },
    { key: 'qtyOnHand', header: 'Qalıq', numeric: true, decimals: 4 },
    { key: 'qtyReserved', header: 'Rezerv', numeric: true, decimals: 4 },
    { key: 'qtyAvailable', header: 'Mövcud', numeric: true, decimals: 4 },
    {
      key: 'baseUomCode',
      header: 'Vahid',
      width: '70px',
      render: (row) => row.baseUomCode || <span className="wms-muted">—</span>,
    },
    {
      key: 'daysToExpiry',
      header: 'Expiry (gün)',
      numeric: true,
      decimals: 0,
      render: (row) =>
        row.daysToExpiry === null || row.daysToExpiry === undefined ? (
          <span className="wms-muted">—</span>
        ) : row.daysToExpiry <= 7 ? (
          <Badge tone="danger">{`${row.daysToExpiry} gün`}</Badge>
        ) : row.daysToExpiry <= 30 ? (
          <Badge tone="warning">{`${row.daysToExpiry} gün`}</Badge>
        ) : (
          String(row.daysToExpiry)
        ),
    },
    // Cost columns: rendered only when the permission is held (never masked).
    {
      key: 'avgUnitCost',
      header: 'Orta maya',
      numeric: true,
      decimals: 4,
      permission: 'master.product.view_cost',
    },
    {
      key: 'totalValue',
      header: 'Dəyər (AZN)',
      numeric: true,
      decimals: 2,
      permission: 'master.product.view_cost',
    },
  ];

  return (
    <Page
      title="Qalıq"
      subtitle="Balans proyeksiyası — yalnız oxunur. Dəyişiklik yalnız sənədlə olur (ADR-004)."
    >
      <div className="wms-toolbar">
        <Select
          label="Lokasiya"
          value={locationId}
          placeholder="Bütün lokasiyalar"
          hint="Siyahı `iam_user_location` ilə filtrlənir."
          options={(locations.data?.items ?? []).map((l) => ({
            value: String(l.id),
            label: `${l.name} (${l.code})`,
          }))}
          onChange={(e) => {
            setLocationId(e.target.value);
            setPage(1);
          }}
        />
        <Select
          label="Sıfır qalıqlar"
          value={includeZero ? '1' : '0'}
          options={[
            { value: '0', label: 'Gizlədilir' },
            { value: '1', label: 'Göstərilir' },
          ]}
          onChange={(e) => {
            setIncludeZero(e.target.value === '1');
            setPage(1);
          }}
        />
      </div>

      <Section>
        {raw.isLoading ? (
          <LoadingState />
        ) : raw.isError ? (
          <ErrorState error={raw.error} onRetry={() => void raw.refetch()} />
        ) : (
          <>
            <DataTable<Balance>
              columns={columns}
              rows={balances?.items ?? []}
              permissions={session?.permissions ?? []}
              rowKey={(row) => `${row.product.id}-${row.location.id}-${row.batch?.id ?? 0}`}
              label="Qalıq siyahısı"
              empty="Bu lokasiyada qalıq yoxdur. Qəbul sənədi yaradın."
            />
            {balances ? <Pager page={balances} onPageChange={setPage} /> : null}
          </>
        )}
      </Section>
    </Page>
  );
}
