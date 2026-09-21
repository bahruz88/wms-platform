import { Alert, Badge, DataTable, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listInventorySettings, type InventorySetting } from '@api/endpoints';
import { ErrorState, LoadingState, Page, Section } from '@/components/Page';

/**
 * Inventory settings — docs/ux/screen-map.md §5.4. These are the `inv_setting` keys that every
 * expiry warning, tolerance percentage, costing method and count threshold is read from; none of
 * them is hard-coded anywhere in the interface (TOR §36).
 *
 * Read-only: `updateInventorySetting` is a PUT the gateway does not route yet, and changing a
 * costing method mid-period has consequences that need their own confirmation flow.
 */
export function InventorySettingsScreen() {
  const settings = useApiPage<InventorySetting>(
    ['inventory-settings'],
    () => listInventorySettings(),
    100,
  );

  const columns: Column<InventorySetting>[] = [
    {
      key: 'key',
      header: 'Açar',
      width: '320px',
      render: (row) => <span className="wms-doc-no">{row.key}</span>,
    },
    {
      key: 'value',
      header: 'Dəyər',
      render: (row) => <span className="wms-num">{row.value}</span>,
    },
    {
      key: 'valueType',
      header: 'Tip',
      render: (row) => <Badge tone="neutral">{row.valueType}</Badge>,
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
      <Alert tone="info" title="Heç bir dəyər kodda sabit yazılmır">
        Bu açarlar interfeysin davranışını təyin edir: `BatchPicker` xəbərdarlıq hədləri,
        `VarianceIndicator` təsdiq həddi, qəbul tolerans faizləri (TOR §36).
      </Alert>
      <Section>
        {settings.isLoading ? (
          <LoadingState />
        ) : settings.isError ? (
          <ErrorState error={settings.error} onRetry={() => void settings.refetch()} />
        ) : (
          <DataTable<InventorySetting>
            columns={columns}
            rows={settings.data?.items ?? []}
            rowKey={(row) => row.key}
            label="Anbar parametrləri"
            empty="Parametr yoxdur. Tenant quraşdırıldıqda standart açarlar yazılır."
          />
        )}
      </Section>
    </Page>
  );
}
