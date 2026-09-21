import { useState } from 'react';
import { DataTable, VarianceIndicator, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listPriceHistory, type PriceHistoryEntry } from '@api/endpoints';
import { formatDate } from '@core/format';
import { ErrorState, LoadingState, Page, Section } from '@/components/Page';
import { Pager } from '@/components/Pager';

/**
 * Price history — docs/ux/screen-map.md §4.6. The whole screen sits behind
 * `master.product.view_cost`: a keeper does not see it at all, which the route guard enforces
 * before the screen renders.
 */
export function PriceHistoryScreen() {
  const [page, setPage] = useState(1);
  const history = useApiPage<PriceHistoryEntry>(
    ['price-history', page],
    () => listPriceHistory({ page, size: 50 }),
    50,
  );

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
      <Section>
        {history.isLoading ? (
          <LoadingState />
        ) : history.isError ? (
          <ErrorState error={history.error} onRetry={() => void history.refetch()} />
        ) : (
          <>
            <DataTable<PriceHistoryEntry>
              columns={columns}
              rows={history.data?.items ?? []}
              rowKey={(row) => row.id}
              label="Qiymət tarixçəsi"
              empty="Qiymət tarixçəsi boşdur. PO göndərildikdə sətirlər yazılır."
            />
            {history.data ? <Pager page={history.data} onPageChange={setPage} /> : null}
          </>
        )}
      </Section>
    </Page>
  );
}
