import { useState } from 'react';
import { Alert, DataTable, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listCurrencyRates, type CurrencyRate } from '@api/endpoints';
import { formatDate } from '@core/format';
import { Card, ErrorState, LoadingState, Page } from '@/components/Page';
import { Pager } from '@/components/Pager';
import { MasterDataTabs } from './MasterDataTabs';

/**
 * Currency rates — docs/ux/screen-map.md §5.3. An old rate is never carried forward: if the day's
 * rate is missing, the PO or receipt is blocked with `409 FX_RATE_MISSING` (SPEC §12.5).
 */
export function CurrencyRatesScreen() {
  const [page, setPage] = useState(1);
  const rates = useApiPage<CurrencyRate>(
    ['currency-rates', page],
    () => listCurrencyRates({ page, size: 50 }),
    50,
  );

  const columns: Column<CurrencyRate>[] = [
    { key: 'rateDate', header: 'Tarix', render: (row) => formatDate(row.rateDate) },
    { key: 'currency', header: 'Valyuta' },
    { key: 'rateToBase', header: '1 vahid = AZN', numeric: true, decimals: 8 },
    { key: 'source', header: 'Mənbə' },
  ];

  return (
    <Page title="Məzənnələr" subtitle="`1 <valyuta> = rateToBase AZN`, 8 onluq">
      <MasterDataTabs />

      <Alert tone="warning" title="Köhnə məzənnə avtomatik götürülmür">
        Sənəd tarixinə məzənnə yoxdursa PO və xarici valyutada qəbul bloklanır —{' '}
        <span className="wms-num">409 FX_RATE_MISSING</span>.
      </Alert>
      <Card
        title="Məzənnələr"
        flush
        footer={rates.data ? <Pager page={rates.data} onPageChange={setPage} /> : undefined}
      >
        {rates.isLoading ? (
          <LoadingState />
        ) : rates.isError ? (
          <div className="wms-card__body">
            <ErrorState error={rates.error} onRetry={() => void rates.refetch()} />
          </div>
        ) : (
          <DataTable<CurrencyRate>
            columns={columns}
            rows={rates.data?.items ?? []}
            rowKey={(row) => row.id}
            label="Məzənnə siyahısı"
            empty="Məzənnə yoxdur. Xarici valyutada əməliyyat üçün gündəlik məzənnə daxil edin."
          />
        )}
      </Card>
    </Page>
  );
}
