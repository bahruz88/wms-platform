import { useState } from 'react';
import { DataTable, Select, TextField, VarianceIndicator, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import {
  listPriceHistory,
  listProducts,
  listSuppliers,
  type PriceHistoryEntry,
  type ProductSummary,
  type SupplierSummary,
} from '@api/endpoints';
import { formatDate } from '@core/format';
import { Card, ErrorState, LoadingState, Page } from '@/components/Page';
import { Pager } from '@/components/Pager';

/**
 * Price history — docs/ux/screen-map.md §4.6. The whole screen sits behind
 * `master.product.view_cost`: a keeper does not see it at all, which the route guard enforces
 * before the screen renders.
 *
 * The filters are the screen. Without them it is a reverse-chronological list of every price the
 * tenant has ever paid, and the question someone actually brings to it — "what has lettuce been
 * costing us, and from whom" — cannot be asked at all. The server has taken `productId`,
 * `supplierId`, a date range and `minDiffPct` from the beginning; only the interface was missing.
 */
export function PriceHistoryScreen() {
  const [page, setPage] = useState(1);
  const [productId, setProductId] = useState('');
  const [supplierId, setSupplierId] = useState('');
  const [dateFrom, setDateFrom] = useState('');
  const [dateTo, setDateTo] = useState('');
  const [minDiffPct, setMinDiffPct] = useState('');

  const products = useApiPage<ProductSummary>(
    ['products', 'price-history'],
    () => listProducts({ page: 1, size: 200 }),
    200,
  );
  const suppliers = useApiPage<SupplierSummary>(
    ['suppliers', 'price-history'],
    () => listSuppliers({ page: 1, size: 200 }),
    200,
  );

  const query = {
    page,
    size: 50,
    ...(productId ? { productId: Number(productId) } : {}),
    ...(supplierId ? { supplierId: Number(supplierId) } : {}),
    ...(dateFrom ? { dateFrom } : {}),
    ...(dateTo ? { dateTo } : {}),
    ...(minDiffPct ? { minDiffPct } : {}),
  };

  const history = useApiPage<PriceHistoryEntry>(
    ['price-history', query],
    () => listPriceHistory(query),
    50,
  );

  /** Every filter change starts the paging again; page 3 of a different question is nonsense. */
  const onFilter = <T,>(set: (value: T) => void) => (value: T) => {
    set(value);
    setPage(1);
  };

  const filtered = Boolean(productId || supplierId || dateFrom || dateTo || minDiffPct);

  const columns: Column<PriceHistoryEntry>[] = [
    { key: 'priceDate', header: 'Tarix', render: (row) => formatDate(row.priceDate) },
    {
      key: 'sku',
      header: 'SKU',
      render: (row) => <span className="wms-doc-no">{row.product.sku}</span>,
    },
    { key: 'product', header: 'Məhsul', render: (row) => row.product.name },
    { key: 'supplier', header: 'Təchizatçı', render: (row) => row.supplier.name },
    { key: 'unitPrice', header: 'Qiymət', numeric: true, decimals: 4 },
    { key: 'currency', header: 'Valyuta' },
    { key: 'unitPriceBase', header: 'Qiymət (AZN)', numeric: true, decimals: 4 },
    { key: 'prevPriceBase', header: 'Əvvəlki (AZN)', numeric: true, decimals: 4 },
    {
      key: 'diff',
      header: 'Dəyişmə',
      render: (row) =>
        row.prevPriceBase ? (
          <VarianceIndicator
            book={row.prevPriceBase}
            counted={row.unitPriceBase}
            decimals={4}
            reasonCode="qiymət dəyişməsi"
          />
        ) : (
          <span className="wms-muted">İlk qiymət</span>
        ),
    },
    { key: 'poDocNo', header: 'PO', render: (row) => row.poDocNo ?? '—' },
  ];

  return (
    <Page
      title="Qiymət tarixçəsi"
      subtitle="Təchizatçı qiymətlərinin dəyişməsi — `master.product.view_cost` tələb olunur"
    >
      <Card>
        <div className="wms-toolbar">
          <Select
            label="Məhsul"
            value={productId}
            placeholder="Bütün məhsullar"
            hint="Bir məhsul seçin — qiymətin vaxt üzrə dəyişməsi görünsün."
            options={(products.data?.items ?? []).map((p) => ({
              value: String(p.id),
              label: `${p.name} (${p.sku})`,
            }))}
            onChange={(e) => onFilter(setProductId)(e.target.value)}
          />
          <Select
            label="Təchizatçı"
            value={supplierId}
            placeholder="Bütün təchizatçılar"
            options={(suppliers.data?.items ?? []).map((s) => ({
              value: String(s.id),
              label: `${s.name} (${s.code})`,
            }))}
            onChange={(e) => onFilter(setSupplierId)(e.target.value)}
          />
          <TextField
            label="Tarixdən"
            type="date"
            value={dateFrom}
            onChange={(e) => onFilter(setDateFrom)(e.target.value)}
          />
          <TextField
            label="Tarixə"
            type="date"
            value={dateTo}
            onChange={(e) => onFilter(setDateTo)(e.target.value)}
          />
          <TextField
            label="Min. dəyişmə, %"
            type="number"
            align="right"
            value={minDiffPct}
            placeholder="0"
            hint="Yalnız bu qədər və artıq dəyişən qiymətlər."
            onChange={(e) => onFilter(setMinDiffPct)(e.target.value)}
          />
          <div className="wms-toolbar__spacer" />
        </div>
      </Card>

      <Card
        title="Qiymət tarixçəsi"
        flush
        footer={history.data ? <Pager page={history.data} onPageChange={setPage} /> : undefined}
      >
        {history.isLoading ? (
          <LoadingState />
        ) : history.isError ? (
          <ErrorState error={history.error} onRetry={() => void history.refetch()} />
        ) : (
          <DataTable<PriceHistoryEntry>
            columns={columns}
            rows={history.data?.items ?? []}
            rowKey={(row) => row.id}
            label="Qiymət tarixçəsi"
            empty={
              filtered
                ? 'Bu şərtlərə uyğun qiymət yoxdur. Süzgəci genişləndirin.'
                : 'Qiymət tarixçəsi boşdur. PO göndərildikdə sətirlər yazılır.'
            }
          />
        )}
      </Card>
    </Page>
  );
}
