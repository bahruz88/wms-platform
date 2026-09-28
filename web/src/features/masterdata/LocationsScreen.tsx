import { useMemo, useState } from 'react';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { Alert, Badge, Button, DataTable, Select, TextField, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { createLocation, listLocations, updateLocation, type Location } from '@api/endpoints';
import { useAuth } from '@auth/index';
import { Card, ErrorState, LoadingState, Page } from '@/components/Page';
import {
  ReferenceFormDialog,
  codeField,
  text,
  type FieldSpec,
  type FormValues,
} from '@/components/ReferenceFormDialog';
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
  const { can } = useAuth();
  const queryClient = useQueryClient();
  const [search, setSearch] = useState('');
  const [locationType, setLocationType] = useState('');
  const [includeVirtual, setIncludeVirtual] = useState('true');
  const [creating, setCreating] = useState(false);
  const [editing, setEditing] = useState<Location | null>(null);

  const refresh = () => {
    setCreating(false);
    setEditing(null);
    void queryClient.invalidateQueries({ queryKey: ['locations'] });
  };

  const create = useMutation({
    mutationFn: (values: FormValues) =>
      createLocation({
        code: text(values, 'code'),
        name: text(values, 'name'),
        locationType: text(values, 'locationType') as Location['locationType'],
        allowsFood: text(values, 'allowsFood') === 'true',
        allowsNonFood: text(values, 'allowsNonFood') === 'true',
        ...(text(values, 'parentId') ? { parentId: Number(text(values, 'parentId')) } : {}),
      }),
    onSuccess: refresh,
  });

  const update = useMutation({
    mutationFn: (values: FormValues) =>
      updateLocation(editing!.id, {
        name: text(values, 'name'),
        allowsFood: text(values, 'allowsFood') === 'true',
        allowsNonFood: text(values, 'allowsNonFood') === 'true',
        isActive: text(values, 'isActive') === 'true',
        rowVersion: editing!.rowVersion,
        ...(text(values, 'parentId') ? { parentId: Number(text(values, 'parentId')) } : {}),
      }),
    onSuccess: refresh,
  });

  const query = {
    ...(locationType ? { locationType: locationType as Location['locationType'] } : {}),
    includeVirtual: includeVirtual === 'true',
  };
  const locations = useApiPage<Location>(['locations', query], () => listLocations(query), 200);

  // Memoised because the field list below depends on it: `?? []` would hand `useMemo` a new
  // array on every render and the memo would never hold.
  const all = useMemo(() => locations.data?.items ?? [], [locations.data]);

  /*
   * Only real locations may be created here. The virtual ones — `IN_TRANSIT` and every `V_*` — are
   * the counter-side of the double-entry ledger (SPEC §12.3): the platform seeds exactly one of
   * each, and a second «V_WASTE» would split the waste balance in two. The same reason keeps
   * `locationType` out of the edit form.
   */
  const fields: FieldSpec[] = useMemo(
    () => [
      {
        name: 'code',
        label: 'Kod',
        kind: 'text',
        required: true,
        createOnly: true,
        hint: 'Məsələn WH-01, BR-28M. Sonradan dəyişmir.',
        validate: codeField,
      },
      { name: 'name', label: 'Ad', kind: 'text', required: true },
      {
        name: 'locationType',
        label: 'Tip',
        kind: 'select',
        required: true,
        createOnly: true,
        hint: 'Virtual lokasiyalar platforma tərəfindən yaradılır, əl ilə əlavə edilmir.',
        options: [
          { value: 'CENTRAL_WAREHOUSE', label: 'Mərkəzi anbar' },
          { value: 'SUB_LOCATION', label: 'Alt lokasiya' },
          { value: 'SHELF', label: 'Rəf' },
          { value: 'RESTAURANT', label: 'Filial / restoran' },
        ],
      },
      {
        name: 'parentId',
        label: 'Üst lokasiya',
        kind: 'select',
        hint: 'Rəf və alt lokasiya üçün məcburidir.',
        options: [
          { value: '', label: 'Üst lokasiya yoxdur' },
          ...all
            .filter((l) => !l.isVirtual)
            .map((l) => ({ value: String(l.id), label: `${l.code} · ${l.name}` })),
        ],
      },
      {
        name: 'allowsFood',
        label: 'Qida saxlanır',
        kind: 'switch',
        hint: 'Xeyr olduqda qida məhsulunun bu lokasiyaya qəbulu rədd edilir.',
      },
      { name: 'allowsNonFood', label: 'Qeyri-qida saxlanır', kind: 'switch' },
      { name: 'isActive', label: 'Aktiv', kind: 'switch' },
    ],
    [all],
  );
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
    ...(can('master.location.manage')
      ? [
          {
            key: 'edit',
            header: '',
            width: '110px',
            render: (row: Location) =>
              row.isVirtual ? (
                <span className="wms-muted wms-small">virtual</span>
              ) : (
                <Button size="sm" variant="secondary" onClick={() => setEditing(row)}>
                  Redaktə
                </Button>
              ),
          } as Column<Location>,
        ]
      : []),
  ];

  return (
    <Page
      title="Lokasiyalar"
      subtitle="Fiziki və virtual lokasiyalar"
      actions={
        can('master.location.manage') ? (
          <Button variant="primary" onClick={() => setCreating(true)}>
            Yeni lokasiya
          </Button>
        ) : null
      }
    >
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
                ? 'Lokasiya yoxdur. Sorğu kitabçalarının quraşdırılması ilə başlayın.'
                : 'Bu filtrə uyğun lokasiya yoxdur. Axtarışı və ya tipi dəyişin.'
            }
          />
        )}
      </Card>
      <ReferenceFormDialog
        open={creating}
        mode="create"
        title="Yeni lokasiya"
        subtitle="Kod və tip sonradan dəyişmir. Virtual lokasiyalar əl ilə yaradılmır."
        fields={fields}
        initial={{
          locationType: 'RESTAURANT',
          allowsFood: 'true',
          allowsNonFood: 'true',
          isActive: 'true',
        }}
        pending={create.isPending}
        error={create.isError ? create.error : undefined}
        onClose={() => setCreating(false)}
        onSubmit={(values) => create.mutate(values)}
      />

      <ReferenceFormDialog
        open={editing !== null}
        mode="edit"
        title={editing ? `Lokasiya: ${editing.code}` : ''}
        fields={fields}
        initial={
          editing
            ? {
                name: editing.name,
                parentId: editing.parentId ? String(editing.parentId) : '',
                allowsFood: String(editing.allowsFood),
                allowsNonFood: String(editing.allowsNonFood),
                isActive: String(editing.isActive),
              }
            : undefined
        }
        pending={update.isPending}
        error={update.isError ? update.error : undefined}
        onClose={() => setEditing(null)}
        onSubmit={(values) => update.mutate(values)}
      />

    </Page>
  );
}
