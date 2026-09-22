import { useState } from 'react';
import { Alert, Badge, DataTable, Select, TextField, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listUoms, type Uom } from '@api/endpoints';
import { Card, ErrorState, LoadingState, Page } from '@/components/Page';
import { MasterDataTabs } from './MasterDataTabs';

const UOM_CLASSES: Array<{ value: Uom['uomClass']; label: string }> = [
  { value: 'MASS', label: 'Kütlə' },
  { value: 'VOLUME', label: 'Həcm' },
  { value: 'COUNT', label: 'Say' },
];

/**
 * Units of measure — docs/ux/screen-map.md §5.3.
 *
 * `decimals` is where every quantity's display precision comes from; it is never hard-coded in
 * a screen (components/QtyUomInput/README.md). `uomClass` is the other rule on this screen: a
 * conversion is only ever defined between units of the same class, so a product's `KG` row can
 * never be given a factor against `L`.
 */
export function UomsScreen() {
  const [search, setSearch] = useState('');
  const [uomClass, setUomClass] = useState('');

  const query = uomClass ? { uomClass: uomClass as Uom['uomClass'] } : {};
  const uoms = useApiPage<Uom>(['uoms', query], () => listUoms(query), 200);

  const all = uoms.data?.items ?? [];
  const needle = search.trim().toLowerCase();
  const rows = all.filter(
    (row) =>
      needle === '' ||
      row.code.toLowerCase().includes(needle) ||
      row.name.toLowerCase().includes(needle),
  );

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
      width: '140px',
      render: (row) => (
        <Badge tone="neutral">
          {UOM_CLASSES.find((c) => c.value === row.uomClass)?.label ?? row.uomClass}
        </Badge>
      ),
    },
    { key: 'decimals', header: 'Onluq sayı', width: '130px', numeric: true, decimals: 0 },
  ];

  return (
    <Page
      title="Ölçü vahidləri"
      subtitle="`decimals` miqdarın göstərilmə dəqiqliyini təyin edir — ekranlarda sabit yazılmır"
    >
      <MasterDataTabs />

      <Alert tone="info" title="Çevirmə yalnız eyni sinif daxilində olur">
        <span className="wms-num">KG → G</span> mümkündür, <span className="wms-num">KG → L</span>{' '}
        yox. Məhsulun alternativ vahidləri və əmsalları məhsul kartındadır (`master_product_uom`).
      </Alert>

      <Card>
        <div className="wms-toolbar">
          <TextField
            label="Axtarış"
            value={search}
            placeholder="Kod və ya ad"
            onChange={(e) => setSearch(e.target.value)}
          />
          <Select
            label="Sinif"
            value={uomClass}
            placeholder="Bütün siniflər"
            options={UOM_CLASSES.map((c) => ({ value: c.value, label: c.label }))}
            onChange={(e) => setUomClass(e.target.value)}
          />
          <div className="wms-toolbar__spacer" />
        </div>
      </Card>

      <Card title="Ölçü vahidləri" subtitle={`${rows.length} / ${all.length} vahid`} flush>
        {uoms.isLoading ? (
          <LoadingState />
        ) : uoms.isError ? (
          <div className="wms-card__body">
            <ErrorState error={uoms.error} onRetry={() => void uoms.refetch()} />
          </div>
        ) : (
          <DataTable<Uom>
            columns={columns}
            rows={rows}
            rowKey={(row) => row.id}
            label="Ölçü vahidləri"
            empty={
              all.length === 0
                ? 'Ölçü vahidi yoxdur. Master data quraşdırması ilə başlayın.'
                : 'Bu filtrə uyğun vahid yoxdur. Axtarışı və ya sinfi dəyişin.'
            }
          />
        )}
      </Card>
    </Page>
  );
}
