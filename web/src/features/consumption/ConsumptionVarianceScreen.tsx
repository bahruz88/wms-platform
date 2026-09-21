import { useState } from 'react';
import { Alert, DataTable, Select, TextField, VarianceIndicator, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import {
  getConsumptionVariance,
  listLocations,
  type Location,
  type VarianceLine,
} from '@api/endpoints';
import { useAuth } from '@auth/index';
import { ErrorState, LoadingState, Page, Section } from '@/components/Page';
import { Pager } from '@/components/Pager';

/**
 * Theoretical vs actual consumption — the report ADR-012 exists to produce:
 *
 *     expected = opening + received − theoretical − waste − sample ± transfers
 *     variance = counted − expected
 *
 * A negative variance has three possible causes: portions larger than the recipe, waste that was
 * not recorded, or goods that went missing. The report does not prove the third — it rules out the
 * first two and sharpens the question. `varianceValue` is permission-bound.
 */
export function ConsumptionVarianceScreen() {
  const { session } = useAuth();
  const [page, setPage] = useState(1);
  const [locationId, setLocationId] = useState('');
  const [periodFrom, setPeriodFrom] = useState(() => {
    const d = new Date();
    d.setDate(d.getDate() - 30);
    return d.toISOString().slice(0, 10);
  });
  const [periodTo, setPeriodTo] = useState(() => new Date().toISOString().slice(0, 10));

  const query = {
    page,
    size: 50,
    periodFrom,
    periodTo,
    ...(locationId ? { locationId: Number(locationId) } : {}),
  };

  const locations = useApiPage<Location>(['locations', 'variance'], () => listLocations({}), 200);

  const variance = useApiPage<VarianceLine>(
    ['consumption-variance', query],
    () => getConsumptionVariance(query),
    50,
  );

  const columns: Column<VarianceLine>[] = [
    {
      key: 'productSku',
      header: 'SKU',
      render: (row) => <span className="wms-doc-no">{row.productSku}</span>,
    },
    { key: 'productName', header: 'Məhsul' },
    {
      key: 'locationName',
      header: 'Lokasiya',
      render: (row) => row.locationName ?? `#${row.locationId}`,
    },
    { key: 'openingQty', header: 'Açılış', numeric: true, decimals: 4 },
    { key: 'receivedQty', header: 'Qəbul', numeric: true, decimals: 4 },
    { key: 'theoreticalConsumedQty', header: 'Nəzəri istehlak', numeric: true, decimals: 4 },
    { key: 'sampleQty', header: 'Nümunə', numeric: true, decimals: 4 },
    { key: 'transferNetQty', header: 'Transfer (xalis)', numeric: true, decimals: 4 },
    { key: 'expectedQty', header: 'Gözlənilən', numeric: true, decimals: 4 },
    { key: 'countedQty', header: 'Sayılan', numeric: true, decimals: 4 },
    {
      key: 'variance',
      header: 'Fərq',
      render: (row) => (
        <VarianceIndicator
          book={row.expectedQty}
          counted={row.countedQty}
          uom={row.baseUomCode}
          decimals={4}
          thresholdPct={2}
          reasonCode={undefined}
        />
      ),
    },
    {
      key: 'varianceValue',
      header: 'Dəyər (AZN)',
      numeric: true,
      decimals: 2,
      permission: 'master.product.view_cost',
    },
  ];

  return (
    <Page
      title="Fərq hesabatı"
      subtitle="Nəzəri istehlak vs faktiki sayım — iki sayım arasındakı dövr üçün"
    >
      <Alert tone="info" title="Fərq nəyi sübut edir, nəyi etmir">
        Mənfi fərqin üç səbəbi var: porsiya normadan böyükdür, tullantı qeyd olunmayıb, mal itib.
        Hesabat üçüncüsünü sübut etmir — ilk ikisini istisna etməklə sualı kəskinləşdirir.
      </Alert>

      <div className="wms-toolbar">
        <TextField
          label="Dövrün başlanğıcı"
          type="date"
          required
          value={periodFrom}
          hint="Adətən əvvəlki sayımın tarixi"
          onChange={(e) => {
            setPeriodFrom(e.target.value);
            setPage(1);
          }}
        />
        <TextField
          label="Dövrün sonu"
          type="date"
          required
          value={periodTo}
          hint="Adətən son sayımın tarixi"
          onChange={(e) => {
            setPeriodTo(e.target.value);
            setPage(1);
          }}
        />
        <Select
          label="Lokasiya"
          value={locationId}
          placeholder="Bütün lokasiyalar"
          options={(locations.data?.items ?? [])
            .filter((l) => !l.isVirtual)
            .map((l) => ({ value: String(l.id), label: `${l.name} (${l.code})` }))}
          onChange={(e) => {
            setLocationId(e.target.value);
            setPage(1);
          }}
        />
      </div>

      <Section>
        {variance.isLoading ? (
          <LoadingState />
        ) : variance.isError ? (
          <ErrorState error={variance.error} onRetry={() => void variance.refetch()} />
        ) : (
          <>
            <DataTable<VarianceLine>
              columns={columns}
              rows={variance.data?.items ?? []}
              permissions={session?.permissions ?? []}
              rowKey={(row) => `${row.productId}-${row.locationId}`}
              label="Fərq hesabatı"
              empty="Bu dövrdə fərq sətri yoxdur. Dövrün hər iki ucunda sayım olmalıdır."
            />
            {variance.data ? <Pager page={variance.data} onPageChange={setPage} /> : null}
          </>
        )}
      </Section>
    </Page>
  );
}
