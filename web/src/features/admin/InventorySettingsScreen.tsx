import { useState } from 'react';
import { Alert, Badge, DataTable, Select, TextField, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listInventorySettings, type InventorySetting } from '@api/endpoints';
import { SETTING_KEYS, type SettingKey } from '@api/settings';
import { Card, ErrorState, LoadingState, Page } from '@/components/Page';
import { AdminTabs } from './AdminTabs';

/**
 * Inventory settings — docs/ux/screen-map.md §5.4. These are the `inv_setting` keys that every
 * expiry warning, tolerance percentage, costing method and count threshold is read from; TOR §36
 * requires that none of them be hard-coded in the interface.
 *
 * `GET /inventory/settings` serves the tenant's rows, so that is all this screen shows. It used
 * to list four keys with a «standart dəyər» badge while the endpoint was closed; those defaults
 * are gone from the app entirely, and the only thing left of them is the note marking which keys
 * the interface itself reads — so an administrator can see at a glance which row changes a
 * screen's behaviour and which is only enforced server-side.
 *
 * Read-only: `PUT /inventory/settings/{key}` is not routed, and changing a costing method
 * mid-period needs its own confirmation flow.
 */

/** What each key the interface reads actually changes on screen. */
const UI_EFFECT: Record<SettingKey, string> = {
  expiry_warning_days: 'Partiya siyahısında və paneldə sarı xəbərdarlıq pəncərəsi.',
  expiry_critical_days: 'Qırmızı xəbərdarlıq pəncərəsi — bu qədər gün qalanda.',
  count_variance_approval_threshold_pct: 'Sayım fərqi bu faizi aşarsa təsdiq tələb olunur.',
  receipt_over_tolerance_pct: 'Qəbulda artıq miqdarın icazəli faizi.',
};

const readByUi = (key: string): key is SettingKey =>
  (SETTING_KEYS as readonly string[]).includes(key);

export function InventorySettingsScreen() {
  const [search, setSearch] = useState('');
  const [valueType, setValueType] = useState('');

  const settings = useApiPage<InventorySetting>(
    ['inventory-settings', 'admin'],
    () => listInventorySettings(),
    200,
    { retry: false },
  );

  const all = settings.data?.items ?? [];
  const rows = all.filter(
    (row) =>
      (valueType === '' || row.valueType === valueType) &&
      (search.trim() === '' ||
        row.key.includes(search.trim().toLowerCase()) ||
        (row.description ?? '').toLowerCase().includes(search.trim().toLowerCase())),
  );

  const types = [...new Set(all.map((row) => row.valueType))].sort();
  const usedByUi = all.filter((row) => readByUi(row.key)).length;

  const columns: Column<InventorySetting>[] = [
    {
      key: 'key',
      header: 'Açar',
      width: '320px',
      render: (row) => (
        <div>
          <span className="wms-doc-no">{row.key}</span>
          {readByUi(row.key) ? (
            <div className="wms-cell__sku">{UI_EFFECT[row.key]}</div>
          ) : (
            <div className="wms-cell__sku">Serverdə tətbiq olunur.</div>
          )}
        </div>
      ),
    },
    {
      key: 'value',
      header: 'Dəyər',
      width: '150px',
      align: 'right',
      render: (row) => <span className="wms-num">{row.value}</span>,
    },
    {
      key: 'valueType',
      header: 'Tip',
      width: '110px',
      render: (row) => (
        <Badge tone="neutral" variant="outline">
          {row.valueType}
        </Badge>
      ),
    },
    {
      key: 'scope',
      header: 'Tətbiq',
      width: '150px',
      render: (row) =>
        readByUi(row.key) ? (
          <Badge tone="accent">İnterfeys oxuyur</Badge>
        ) : (
          <span className="wms-muted">yalnız server</span>
        ),
    },
    {
      key: 'allowedValues',
      header: 'İcazəli dəyərlər',
      width: '220px',
      render: (row) =>
        row.allowedValues?.length ? (
          <span className="wms-num wms-small">{row.allowedValues.join(', ')}</span>
        ) : (
          <span className="wms-muted">—</span>
        ),
    },
    { key: 'description', header: 'İzah', render: (row) => row.description ?? '—' },
  ];

  return (
    <Page
      title="Parametrlər"
      subtitle="Sistem parametrləri — expiry günləri, tolerans faizləri, maya metodu, sayım həddi"
      actions={
        settings.isError ? (
          <Badge tone="danger" dot>
            Oxunmadı
          </Badge>
        ) : (
          <Badge tone="success">Mənbə: tenant</Badge>
        )
      }
    >
      <AdminTabs />

      <Alert tone="info" title="Heç bir dəyər kodda sabit yazılmır">
        Bu cədvəl şirkətinizin cari parametrləridir. <span className="wms-num">{usedByUi}</span>{' '}
        açarı interfeys özü oxuyur: partiya xəbərdarlıq hədləri,{' '}
        <span className="wms-num">VarianceIndicator</span> təsdiq həddi və qəbul tolerans faizi (TOR
        §36). Açar cavabda yoxdursa ekran standart dəyər işlətmir — həmin göstərici «—» ilə qalır.
      </Alert>

      <Card>
        <div className="wms-toolbar">
          <TextField
            label="Axtarış"
            value={search}
            placeholder="Açar və ya izah"
            onChange={(e) => setSearch(e.target.value)}
          />
          <Select
            label="Tip"
            value={valueType}
            placeholder="Bütün tiplər"
            options={types.map((t) => ({ value: t, label: t }))}
            onChange={(e) => setValueType(e.target.value)}
          />
          <div className="wms-toolbar__spacer" />
        </div>
      </Card>

      <Card title="Anbar parametrləri" subtitle={`${rows.length} / ${all.length} açar`} flush>
        {settings.isLoading ? (
          <LoadingState />
        ) : settings.isError ? (
          <div className="wms-card__body">
            <ErrorState error={settings.error} onRetry={() => void settings.refetch()} />
          </div>
        ) : (
          <DataTable<InventorySetting>
            columns={columns}
            rows={rows}
            rowKey={(row) => row.key}
            label="Anbar parametrləri"
            empty={
              all.length === 0
                ? 'Tenant üçün parametr yazılmayıb. Anbar modulu ilk işə düşəndə standart açarlar yaradılır.'
                : 'Bu filtrə uyğun açar yoxdur. Axtarışı və ya tipi dəyişin.'
            }
          />
        )}
      </Card>
    </Page>
  );
}
