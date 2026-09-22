import { useState } from 'react';
import { Alert, Badge, DataTable, Select, TextField, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listReasonCodes, type ReasonCode, type ReasonGroup } from '@api/endpoints';
import { Card, ErrorState, LoadingState, Page } from '@/components/Page';
import { MasterDataTabs } from './MasterDataTabs';

const GROUPS: Array<{ value: ReasonGroup; label: string }> = [
  { value: 'WASTE', label: 'Tullantı' },
  { value: 'ADJUSTMENT', label: 'Düzəliş və storno' },
  { value: 'RETURN', label: 'Qaytarma' },
  { value: 'SAMPLE', label: 'Nümunə' },
  { value: 'TRANSFER', label: 'Transfer' },
];

/**
 * Reason codes — docs/ux/screen-map.md §5.3.
 *
 * This is the list every cancellation, waste, adjustment, batch block, off-FEFO pick and
 * reversal picks from: `ReasonCodePicker` filters it by the document's `reasonGroup`, so what is
 * visible here as one group is exactly what a user sees in that document's dropdown.
 *
 * `requiresPhoto` and `requiresApproval` change the behaviour of every document that uses the
 * code, which is why they are badges rather than plain booleans.
 */
export function ReasonCodesScreen() {
  const [search, setSearch] = useState('');
  const [reasonGroup, setReasonGroup] = useState('');
  const [isActive, setIsActive] = useState('true');

  const query = {
    ...(reasonGroup ? { reasonGroup: reasonGroup as ReasonGroup } : {}),
    ...(isActive === '' ? {} : { isActive: isActive === 'true' }),
  };
  const reasons = useApiPage<ReasonCode>(
    ['reason-codes', query],
    () => listReasonCodes(query),
    200,
  );

  const all = reasons.data?.items ?? [];
  const needle = search.trim().toLowerCase();
  const rows = all.filter(
    (row) =>
      needle === '' ||
      row.code.toLowerCase().includes(needle) ||
      row.name.toLowerCase().includes(needle),
  );

  const columns: Column<ReasonCode>[] = [
    {
      key: 'code',
      header: 'Kod',
      width: '150px',
      render: (row) => <span className="wms-doc-no">{row.code}</span>,
    },
    { key: 'name', header: 'Ad' },
    {
      key: 'reasonGroup',
      header: 'Qrup',
      width: '170px',
      render: (row) => (
        <Badge tone="neutral">
          {GROUPS.find((g) => g.value === row.reasonGroup)?.label ?? row.reasonGroup}
        </Badge>
      ),
    },
    {
      key: 'requiresPhoto',
      header: 'Foto',
      width: '110px',
      render: (row) =>
        row.requiresPhoto ? (
          <Badge tone="warning">Məcburi</Badge>
        ) : (
          <span className="wms-muted">—</span>
        ),
    },
    {
      key: 'requiresApproval',
      header: 'Təsdiq',
      width: '120px',
      render: (row) =>
        row.requiresApproval ? (
          <Badge tone="warning">Tələb edir</Badge>
        ) : (
          <span className="wms-muted">—</span>
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
    <Page title="Səbəb kodları" subtitle="Tullantı, sayım fərqi, storno və transfer səbəbləri">
      <MasterDataTabs />

      <Alert tone="info" title="Səbəb kodu qrupla filtrlənir">
        Tullantı sənədində yalnız <span className="wms-num">WASTE</span> qrupu, nümunədə{' '}
        <span className="wms-num">SAMPLE</span> qrupu göstərilir — `reasonGroup` sonradan
        dəyişdirilmir. Kodu deaktiv etmək onu yeni sənədlərdən çıxarır, köhnə sənədlərdən yox.
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
            label="Qrup"
            value={reasonGroup}
            placeholder="Bütün qruplar"
            options={GROUPS.map((g) => ({ value: g.value, label: g.label }))}
            onChange={(e) => setReasonGroup(e.target.value)}
          />
          <Select
            label="Vəziyyət"
            value={isActive}
            placeholder="Hamısı"
            options={[
              { value: 'true', label: 'Aktiv' },
              { value: 'false', label: 'Bağlı' },
            ]}
            onChange={(e) => setIsActive(e.target.value)}
          />
          <div className="wms-toolbar__spacer" />
        </div>
      </Card>

      <Card title="Səbəb kodları" subtitle={`${rows.length} / ${all.length} kod`} flush>
        {reasons.isLoading ? (
          <LoadingState />
        ) : reasons.isError ? (
          <div className="wms-card__body">
            <ErrorState error={reasons.error} onRetry={() => void reasons.refetch()} />
          </div>
        ) : (
          <DataTable<ReasonCode>
            columns={columns}
            rows={rows}
            rowKey={(row) => row.id}
            label="Səbəb kodları"
            empty={
              all.length === 0
                ? 'Səbəb kodu yoxdur. Tullantı və sayım üçün ən azı bir kod lazımdır.'
                : 'Bu filtrə uyğun kod yoxdur. Axtarışı, qrupu və ya vəziyyəti dəyişin.'
            }
          />
        )}
      </Card>
    </Page>
  );
}
