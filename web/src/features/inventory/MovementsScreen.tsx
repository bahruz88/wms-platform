import { useMemo, useState } from 'react';
import { Link } from 'react-router-dom';
import { Badge, DataTable, Select, TextField, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import {
  listLocations,
  listMovements,
  listProducts,
  type Location,
  type Movement,
  type ProductSummary,
} from '@api/endpoints';
import { indexById, normalizeMovement } from '@api/adapters';
import { useAuth } from '@auth/index';
import { formatDateTime, formatSigned } from '@core/format';
import { ErrorState, LoadingState, Page, Section } from '@/components/Page';
import { Pager } from '@/components/Pager';

/**
 * Ledger — docs/ux/screen-map.md §3.12.
 *
 * Append-only: there is no edit control on this screen and there must not be one. The only
 * correction is a reversal, which creates a new document (SPEC §9.4, §12.6). The sign is always
 * printed; `unitCost`, `currency` and `fxRate` are permission-bound columns.
 */
export function MovementsScreen() {
  const { session } = useAuth();
  const [page, setPage] = useState(1);
  const [docType, setDocType] = useState('');
  const [groupId, setGroupId] = useState('');

  const query = {
    page,
    size: 50,
    ...(docType ? { docType: docType as 'RECEIPT' } : {}),
  };
  const products = useApiPage<ProductSummary>(
    ['products', 'movements'],
    () => listProducts({ page: 1, size: 200 }),
    200,
  );
  const locations = useApiPage<Location>(['locations', 'movements'], () => listLocations({}), 200);
  const movements = useApiPage<Movement>(['movements', query], () => listMovements(query), 50);

  const rows = useMemo(() => {
    const productIndex = indexById(products.data?.items ?? []);
    const locationIndex = indexById(locations.data?.items ?? []);
    return (movements.data?.items ?? []).map((row) =>
      normalizeMovement(row, productIndex, locationIndex),
    );
  }, [movements.data, products.data, locations.data]);

  const columns: Column<Movement>[] = [
    { key: 'postedAt', header: 'Post vaxtı', render: (row) => formatDateTime(row.postedAt) },
    { key: 'docType', header: 'Tip', render: (row) => <Badge tone="neutral">{row.docType}</Badge> },
    {
      key: 'docNo',
      header: 'Sənəd',
      render: (row) => (
        <Link to={`/inventory/movement-groups/${row.groupId}`}>
          <span className="wms-doc-no">{row.docNo}</span>
        </Link>
      ),
    },
    {
      key: 'sku',
      header: 'SKU',
      render: (row) => <span className="wms-doc-no">{row.product.sku}</span>,
    },
    { key: 'product', header: 'Məhsul', render: (row) => row.product.name },
    {
      key: 'batch',
      header: 'Partiya',
      render: (row) => (row.batch ? <span className="wms-doc-no">{row.batch.batchNo}</span> : '—'),
    },
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
      key: 'qtyBase',
      header: 'Miqdar (base)',
      numeric: true,
      decimals: 4,
      // The sign is the primary signal; colour repeats it (components/LedgerTable/README.md).
      render: (row) => (
        <span
          className={row.qtyBase.startsWith('-') ? 'wms-ledger__qty--out' : 'wms-ledger__qty--in'}
        >
          {formatSigned(row.qtyBase, 4)}
        </span>
      ),
    },
    { key: 'enteredQty', header: 'Daxil edilən', numeric: true, decimals: 4 },
    { key: 'conversionRate', header: 'Əmsal', numeric: true, decimals: 8 },
    {
      key: 'unitCost',
      header: 'Vahid dəyəri',
      numeric: true,
      decimals: 4,
      permission: 'master.product.view_cost',
    },
    { key: 'currency', header: 'Valyuta', permission: 'master.product.view_cost' },
    {
      key: 'fxRate',
      header: 'Məzənnə',
      numeric: true,
      decimals: 8,
      permission: 'master.product.view_cost',
    },
  ];

  return (
    <Page
      title="Ledger"
      subtitle="Hərəkət jurnalı — append-only. Düzəliş yalnız storno ilə (SPEC §9.4)."
    >
      <div className="wms-toolbar">
        <Select
          label="Sənəd tipi"
          value={docType}
          placeholder="Bütün tiplər"
          options={[
            'RECEIPT',
            'ISSUE',
            'TRANSFER',
            'COUNT_ADJUST',
            'WASTE',
            'SAMPLE',
            'RETURN',
            'OPENING',
            'REVERSAL',
          ].map((v) => ({ value: v, label: v }))}
          onChange={(e) => {
            setDocType(e.target.value);
            setPage(1);
          }}
        />
        <div className="wms-toolbar__spacer" />
        <TextField
          label="Qrup id ilə aç"
          mono
          value={groupId}
          hint="Bir sənədin bütün sətirləri `LedgerTable` ilə açılır."
          onChange={(e) => setGroupId(e.target.value)}
        />
        {groupId.trim() ? (
          <Link
            className="wms-btn wms-btn--secondary"
            to={`/inventory/movement-groups/${groupId.trim()}`}
          >
            Aç
          </Link>
        ) : null}
      </div>

      <Section>
        {movements.isLoading ? (
          <LoadingState />
        ) : movements.isError ? (
          <ErrorState error={movements.error} onRetry={() => void movements.refetch()} />
        ) : (
          <>
            <DataTable<Movement>
              columns={columns}
              rows={rows}
              permissions={session?.permissions ?? []}
              rowKey={(row) => row.id}
              label="Hərəkət jurnalı"
              empty="Bu filtrə uyğun hərəkət yoxdur. Sənəd post edildikdə sətirlər burada görünür."
            />
            {movements.data ? <Pager page={movements.data} onPageChange={setPage} /> : null}
          </>
        )}
      </Section>
    </Page>
  );
}
