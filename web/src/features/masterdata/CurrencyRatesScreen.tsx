import { useState } from 'react';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { Alert, Button, DataTable, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listCurrencyRates, upsertCurrencyRate, type CurrencyRate } from '@api/endpoints';
import { useAuth } from '@auth/index';
import { formatDate } from '@core/format';
import { Card, ErrorState, LoadingState, Page } from '@/components/Page';
import { Pager } from '@/components/Pager';
import {
  ReferenceFormDialog,
  decimalField,
  text,
  type FieldSpec,
  type FormValues,
} from '@/components/ReferenceFormDialog';
import { MasterDataTabs } from './MasterDataTabs';

/**
 * Currency rates — docs/ux/screen-map.md §5.3. An old rate is never carried forward: if the day's
 * rate is missing, the PO or receipt is blocked with `409 FX_RATE_MISSING` (SPEC §12.5).
 */
/**
 * One rate per currency and date, so posting the same day again corrects it rather than adding a
 * second row — which is why the contract calls this an upsert and the dialog says «yaz» rather than
 * «yeni». A rate is never edited in place: the correction is another post for the same date.
 */
const RATE_FIELDS: FieldSpec[] = [
  {
    name: 'currency',
    label: 'Valyuta',
    kind: 'text',
    required: true,
    hint: 'Üç hərfli ISO kodu, məsələn USD.',
    validate: (value) =>
      value.trim().length === 0 || /^[A-Z]{3}$/.test(value.trim())
        ? undefined
        : 'Üç böyük latın hərfi yazın.',
  },
  { name: 'rateDate', label: 'Tarix', kind: 'date', required: true },
  {
    name: 'rateToBase',
    label: 'AZN-ə məzənnə',
    kind: 'decimal',
    required: true,
    hint: '1 vahid valyutanın AZN qarşılığı, 8 onluğa qədər.',
    validate: decimalField,
  },
];

export function CurrencyRatesScreen() {
  const { can } = useAuth();
  const queryClient = useQueryClient();
  const [page, setPage] = useState(1);
  const [creating, setCreating] = useState(false);

  const upsert = useMutation({
    mutationFn: (values: FormValues) =>
      upsertCurrencyRate({
        currency: text(values, 'currency'),
        rateDate: text(values, 'rateDate'),
        // The rate stays a decimal string all the way to the wire (ADR-008); the comma a user may
        // type is the Azerbaijani separator, and the contract expects a dot.
        rateToBase: text(values, 'rateToBase').replace(',', '.'),
      }),
    onSuccess: () => {
      setCreating(false);
      void queryClient.invalidateQueries({ queryKey: ['currency-rates'] });
    },
  });
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
    <Page
      title="Məzənnələr"
      subtitle="`1 <valyuta> = rateToBase AZN`, 8 onluq"
      actions={
        can('master.currency.manage') ? (
          <Button variant="primary" onClick={() => setCreating(true)}>
            Məzənnə yaz
          </Button>
        ) : null
      }
    >
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
      <ReferenceFormDialog
        open={creating}
        mode="create"
        title="Məzənnə yaz"
        subtitle="Eyni valyuta və tarix üçün təkrar yazmaq mövcud məzənnəni düzəldir."
        fields={RATE_FIELDS}
        initial={{ rateDate: new Date().toISOString().slice(0, 10) }}
        pending={upsert.isPending}
        error={upsert.isError ? upsert.error : undefined}
        onClose={() => setCreating(false)}
        onSubmit={(values) => upsert.mutate(values)}
      />

    </Page>
  );
}
