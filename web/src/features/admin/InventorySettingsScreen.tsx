import { Alert, Badge, DataTable, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listInventorySettings, type InventorySetting } from '@api/endpoints';
import { SETTING_FALLBACKS, type SettingKey } from '@api/settings';
import { Card, ErrorState, LoadingState, Page } from '@/components/Page';

/**
 * Inventory settings — docs/ux/screen-map.md §5.4. These are the `inv_setting` keys that every
 * expiry warning, tolerance percentage, costing method and count threshold is read from; TOR §36
 * requires that none of them be hard-coded in the interface.
 *
 * While `GET /inventory/settings` is unrouted the screen does not go blank and it does not
 * pretend there are no settings: it lists the keys the interface actually reads and the value it
 * is falling back to for each, which is the honest answer to "what is the app using right now".
 * Every one of those rows disappears into the server's answer the moment the endpoint lands.
 *
 * Read-only: `PUT /inventory/settings/{key}` is not routed either, and changing a costing method
 * mid-period needs its own confirmation flow.
 */

interface Row {
  key: string;
  value: string;
  valueType: string;
  allowedValues?: string[] | null;
  description?: string | null;
  source: 'server' | 'fallback';
}

const FALLBACK_DESCRIPTIONS: Record<SettingKey, string> = {
  expiry_warning_days: 'Partiya siyahısında və paneldə sarı xəbərdarlıq pəncərəsi.',
  expiry_critical_days: 'Qırmızı xəbərdarlıq pəncərəsi — bu qədər gün qalanda.',
  count_variance_approval_threshold_pct: 'Sayım fərqi bu faizi aşarsa təsdiq tələb olunur.',
  receipt_over_tolerance_pct: 'Qəbulda artıq miqdarın icazəli faizi.',
};

/** The rows the screen shows when the server has not answered: what the interface is using. */
export function fallbackRows(): Row[] {
  return (Object.keys(SETTING_FALLBACKS) as SettingKey[]).map((key) => ({
    key,
    value: String(SETTING_FALLBACKS[key]),
    valueType: 'INT',
    allowedValues: null,
    description: FALLBACK_DESCRIPTIONS[key],
    source: 'fallback',
  }));
}

export function InventorySettingsScreen() {
  const settings = useApiPage<InventorySetting>(
    ['inventory-settings', 'admin'],
    () => listInventorySettings(),
    100,
    { retry: false },
  );

  const unrouted =
    settings.isError && (settings.error?.status === 404 || settings.error?.status === 405);
  const serverRows: Row[] = (settings.data?.items ?? []).map((s) => ({
    key: s.key,
    value: s.value,
    valueType: s.valueType,
    allowedValues: s.allowedValues,
    description: s.description,
    source: 'server',
  }));
  const rows = unrouted ? fallbackRows() : serverRows;

  const columns: Column<Row>[] = [
    {
      key: 'key',
      header: 'Açar',
      width: '320px',
      render: (row) => <span className="wms-doc-no">{row.key}</span>,
    },
    {
      key: 'value',
      header: 'Dəyər',
      width: '120px',
      render: (row) => <span className="wms-num">{row.value}</span>,
    },
    {
      key: 'source',
      header: 'Mənbə',
      width: '160px',
      render: (row) =>
        row.source === 'server' ? (
          <Badge tone="success">Tenant parametri</Badge>
        ) : (
          <Badge tone="warning" dot title="GET /inventory/settings açılmayıb">
            Standart dəyər
          </Badge>
        ),
    },
    {
      key: 'valueType',
      header: 'Tip',
      width: '100px',
      render: (row) => (
        <Badge tone="neutral" variant="outline">
          {row.valueType}
        </Badge>
      ),
    },
    {
      key: 'allowedValues',
      header: 'İcazəli dəyərlər',
      render: (row) => (row.allowedValues?.length ? row.allowedValues.join(', ') : '—'),
    },
    { key: 'description', header: 'İzah', render: (row) => row.description ?? '—' },
  ];

  return (
    <Page
      title="Parametrlər"
      subtitle="`inv_setting` açarları — expiry günləri, tolerans faizləri, costing metodu, sayım həddi"
    >
      {unrouted ? (
        <Alert
          tone="warning"
          title="Tenant parametrləri oxunmur — interfeys standart dəyərlərlə işləyir"
          code={settings.error?.code}
        >
          <span className="wms-num">GET /inventory/settings</span> gateway-də açılmayıb (
          <span className="wms-num">{settings.error?.status ?? 404}</span>). Aşağıdakı sətirlər
          serverin deyil, interfeysin hazırda işlətdiyi standart dəyərlərdir. Endpoint açılan kimi
          bu cədvəl tenantın öz açarlarını göstərəcək və heç bir dəyər kodda qalmayacaq (TOR §36).
        </Alert>
      ) : (
        <Alert tone="info" title="Heç bir dəyər kodda sabit yazılmır">
          Bu açarlar interfeysin davranışını təyin edir: partiya xəbərdarlıq hədləri,{' '}
          <span className="wms-num">VarianceIndicator</span> təsdiq həddi, qəbul tolerans faizləri
          (TOR §36).
        </Alert>
      )}

      {settings.isLoading ? (
        <LoadingState />
      ) : settings.isError && !unrouted ? (
        <ErrorState error={settings.error} onRetry={() => void settings.refetch()} />
      ) : (
        <Card title="Anbar parametrləri" subtitle={`${rows.length} açar`} flush>
          <DataTable<Row>
            columns={columns}
            rows={rows}
            rowKey={(row) => row.key}
            label="Anbar parametrləri"
            empty="Parametr yoxdur. Tenant quraşdırıldıqda standart açarlar yazılır."
          />
        </Card>
      )}
    </Page>
  );
}
