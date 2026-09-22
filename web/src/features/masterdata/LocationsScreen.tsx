import { useState } from 'react';
import { Alert, Badge, DataTable, Select, TextField, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listLocations, type Location } from '@api/endpoints';
import { Card, ErrorState, LoadingState, Page } from '@/components/Page';
import { MasterDataTabs } from './MasterDataTabs';

const LOCATION_TYPES: Array<{ value: Location['locationType']; label: string }> = [
  { value: 'CENTRAL_WAREHOUSE', label: 'Mərkəzi anbar' },
  { value: 'SUB_LOCATION', label: 'Alt lokasiya' },
  { value: 'SHELF', label: 'Rəf' },
  { value: 'RESTAURANT', label: 'Filial' },
  { value: 'IN_TRANSIT', label: 'Yolda' },
  { value: 'V_SUPPLIER', label: 'Virtual · təchizatçı' },
  { value: 'V_WASTE', label: 'Virtual · tullantı' },
  { value: 'V_SAMPLE', label: 'Virtual · nümunə' },
  { value: 'V_ADJUSTMENT', label: 'Virtual · düzəliş' },
];

/**
 * Locations — docs/ux/screen-map.md §5.3.
 *
 * Virtual locations carry the `virtual` tone so they are never mistaken for a physical
 * warehouse: they are the counter-party of every movement that leaves the company (waste,
 * sample, return, adjustment), which is what keeps the ledger balanced, and a stock figure read
 * off one of them means something entirely different from a figure on `WH-01`.
 *
 * Read-only: `locationType` and `isVirtual` cannot be changed after creation, and the write
 * operations are not routed.
 */
export function LocationsScreen() {
  const [search, setSearch] = useState('');
  const [locationType, setLocationType] = useState('');
  const [includeVirtual, setIncludeVirtual] = useState('true');

  const query = {
    ...(locationType ? { locationType: locationType as Location['locationType'] } : {}),
    includeVirtual: includeVirtual === 'true',
  };
  const locations = useApiPage<Location>(['locations', query], () => listLocations(query), 200);

  const all = locations.data?.items ?? [];
  const needle = search.trim().toLowerCase();
  const rows = all.filter(
    (row) =>
      needle === '' ||
      row.code.toLowerCase().includes(needle) ||
      row.name.toLowerCase().includes(needle),
  );
  const virtualCount = all.filter((row) => row.isVirtual).length;

  const columns: Column<Location>[] = [
    {
      key: 'code',
      header: 'Kod',
      width: '120px',
      render: (row) => <span className="wms-doc-no">{row.code}</span>,
    },
    {
      key: 'name',
      header: 'Ad',
      render: (row) =>
        row.isVirtual ? (
          <Badge tone="virtual" title={row.locationType}>
            {row.name}
          </Badge>
        ) : (
          row.name
        ),
    },
    {
      key: 'locationType',
      header: 'Tip',
      width: '170px',
      render: (row) => (
        <Badge tone="neutral">
          {LOCATION_TYPES.find((t) => t.value === row.locationType)?.label ?? row.locationType}
        </Badge>
      ),
    },
    {
      key: 'allowsFood',
      header: 'Qida',
      width: '130px',
      render: (row) =>
        row.allowsFood ? (
          <Badge tone="success">Qəbul edir</Badge>
        ) : (
          <Badge tone="danger">Qəbul etmir</Badge>
        ),
    },
    {
      key: 'allowsNonFood',
      header: 'Qeyri-qida',
      width: '130px',
      render: (row) =>
        row.allowsNonFood ? (
          <Badge tone="success">Qəbul edir</Badge>
        ) : (
          <Badge tone="danger">Qəbul etmir</Badge>
        ),
    },
    {
      key: 'parentId',
      header: 'Üst lokasiya',
      width: '140px',
      render: (row) =>
        row.parentId ? (
          <span className="wms-num">
            {all.find((l) => l.id === row.parentId)?.code ?? `#${row.parentId}`}
          </span>
        ) : (
          <span className="wms-muted">kök</span>
        ),
    },
    {
      key: 'isActive',
      header: 'Vəziyyət',
      width: '110px',
      render: (row) =>
        row.isActive ? <Badge tone="success">Aktiv</Badge> : <Badge tone="neutral">Bağlı</Badge>,
    },
  ];

  return (
    <Page title="Lokasiyalar" subtitle="Fiziki və virtual lokasiyalar">
      <MasterDataTabs />

      <Alert tone="info" title="Virtual lokasiya balans daşımır, ledger-i balanslaşdırır">
        <span className="wms-num">V_WASTE</span>, <span className="wms-num">V_SAMPLE</span>,{' '}
        <span className="wms-num">V_SUPPLIER</span> və <span className="wms-num">V_ADJUSTMENT</span>{' '}
        malın şirkətdən çıxdığı qarşı tərəfdir — hər hərəkət qrupunun cəmi buna görə sıfırdır (SPEC
        §12.3).
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
            label="Tip"
            value={locationType}
            placeholder="Bütün tiplər"
            options={LOCATION_TYPES.map((t) => ({ value: t.value, label: t.label }))}
            onChange={(e) => setLocationType(e.target.value)}
          />
          <Select
            label="Virtual lokasiyalar"
            value={includeVirtual}
            options={[
              { value: 'true', label: 'Göstərilsin' },
              { value: 'false', label: 'Yalnız fiziki' },
            ]}
            onChange={(e) => setIncludeVirtual(e.target.value)}
          />
          <div className="wms-toolbar__spacer" />
        </div>
      </Card>

      <Card
        title="Lokasiyalar"
        subtitle={`${rows.length} / ${all.length} lokasiya · ${virtualCount} virtual`}
        flush
      >
        {locations.isLoading ? (
          <LoadingState />
        ) : locations.isError ? (
          <div className="wms-card__body">
            <ErrorState error={locations.error} onRetry={() => void locations.refetch()} />
          </div>
        ) : (
          <DataTable<Location>
            columns={columns}
            rows={rows}
            rowKey={(row) => row.id}
            label="Lokasiya siyahısı"
            empty={
              all.length === 0
                ? 'Lokasiya yoxdur. Master data quraşdırması ilə başlayın.'
                : 'Bu filtrə uyğun lokasiya yoxdur. Axtarışı və ya tipi dəyişin.'
            }
          />
        )}
      </Card>
    </Page>
  );
}
