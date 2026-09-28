import { useState } from 'react';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { Alert, Badge, Button, DataTable, Select, TextField, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { createUom, listUoms, type Uom } from '@api/endpoints';
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
/**
 * A unit is created but never edited: the contract has no `PUT /uoms`, and for good reason — a unit
 * already used in a conversion factor or on a posted line cannot have its meaning changed
 * afterwards. Getting it wrong means adding the right one, not rewriting the wrong one.
 */
const UOM_FIELDS: FieldSpec[] = [
  {
    name: 'code',
    label: 'Kod',
    kind: 'text',
    required: true,
    hint: 'Məsələn KG, L, ƏDƏD. Sonradan dəyişmir.',
    validate: codeField,
  },
  { name: 'name', label: 'Ad', kind: 'text', required: true },
  {
    name: 'uomClass',
    label: 'Sinif',
    kind: 'select',
    required: true,
    hint: 'Çevrilmə yalnız eyni sinif daxilində mümkündür.',
    options: [
      { value: 'COUNT', label: 'Say' },
      { value: 'MASS', label: 'Kütlə' },
      { value: 'VOLUME', label: 'Həcm' },
    ],
  },
  {
    name: 'decimals',
    label: 'Onluq rəqəm sayı',
    kind: 'number',
    hint: 'Ədədlə sayılan vahid üçün 0, çəki üçün adətən 3.',
  },
];

export function UomsScreen() {
  const { can } = useAuth();
  const queryClient = useQueryClient();
  const [search, setSearch] = useState('');
  const [uomClass, setUomClass] = useState('');
  const [creating, setCreating] = useState(false);

  const create = useMutation({
    mutationFn: (values: FormValues) =>
      createUom({
        code: text(values, 'code'),
        name: text(values, 'name'),
        uomClass: text(values, 'uomClass') as Uom['uomClass'],
        ...(text(values, 'decimals') ? { decimals: Number(text(values, 'decimals')) } : {}),
      }),
    onSuccess: () => {
      setCreating(false);
      void queryClient.invalidateQueries({ queryKey: ['uoms'] });
    },
  });

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
      actions={
        can('master.uom.manage') ? (
          <Button variant="primary" onClick={() => setCreating(true)}>
            Yeni vahid
          </Button>
        ) : null
      }
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
                ? 'Ölçü vahidi yoxdur. Sorğu kitabçalarının quraşdırılması ilə başlayın.'
                : 'Bu filtrə uyğun vahid yoxdur. Axtarışı və ya sinfi dəyişin.'
            }
          />
        )}
      </Card>
      <ReferenceFormDialog
        open={creating}
        mode="create"
        title="Yeni ölçü vahidi"
        subtitle="Vahid yaradıldıqdan sonra redaktə olunmur — səhv olarsa düzgününü əlavə edin."
        fields={UOM_FIELDS}
        initial={{ uomClass: 'COUNT', decimals: '0' }}
        pending={create.isPending}
        error={create.isError ? create.error : undefined}
        onClose={() => setCreating(false)}
        onSubmit={(values) => create.mutate(values)}
      />

    </Page>
  );
}
