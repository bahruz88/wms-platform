import { Badge, DataTable, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listUoms, type Uom } from '@api/endpoints';
import { ErrorState, LoadingState, Page, Section } from '@/components/Page';

/**
 * Units of measure — docs/ux/screen-map.md §5.3. `decimals` is where every quantity's display
 * precision comes from; it is never hard-coded in a screen (components/QtyUomInput/README.md).
 */
export function UomsScreen() {
  const uoms = useApiPage<Uom>(['uoms'], () => listUoms({}), 200);

  const columns: Column<Uom>[] = [
    {
      key: 'code',
      header: 'Kod',
      width: '110px',
      render: (row) => <span className="wms-doc-no">{row.code}</span>,
    },
    { key: 'name', header: 'Ad' },
    {
      key: 'uomClass',
      header: 'Sinif',
      render: (row) => <Badge tone="neutral">{row.uomClass}</Badge>,
    },
    { key: 'decimals', header: 'Onluq sayı', numeric: true, decimals: 0 },
  ];

  return (
    <Page
      title="Ölçü vahidləri"
      subtitle="`decimals` miqdarın göstərilmə dəqiqliyini təyin edir — ekranlarda sabit yazılmır"
    >
      <Section>
        {uoms.isLoading ? (
          <LoadingState />
        ) : uoms.isError ? (
          <ErrorState error={uoms.error} onRetry={() => void uoms.refetch()} />
        ) : (
          <DataTable<Uom>
            columns={columns}
            rows={uoms.data?.items ?? []}
            rowKey={(row) => row.id}
            label="Ölçü vahidləri"
            empty="Ölçü vahidi yoxdur. Master data quraşdırması ilə başlayın."
          />
        )}
      </Section>
    </Page>
  );
}
