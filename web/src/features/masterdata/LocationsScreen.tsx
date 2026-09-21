import { Badge, DataTable, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listLocations, type Location } from '@api/endpoints';
import { Card, ErrorState, LoadingState, Page } from '@/components/Page';

/**
 * Locations — docs/ux/screen-map.md §5.3. Virtual locations carry the `virtual` tone so they are
 * never mistaken for a physical warehouse; `locationType` and `isVirtual` cannot be changed after
 * creation, which is why the screen is read-only.
 */
export function LocationsScreen() {
  const locations = useApiPage<Location>(['locations'], () => listLocations({}), 200);

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
      render: (row) => <Badge tone="neutral">{row.locationType}</Badge>,
    },
    {
      key: 'allowsFood',
      header: 'Qida',
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
      render: (row) => (row.parentId ? `#${row.parentId}` : '—'),
    },
    {
      key: 'isActive',
      header: 'Vəziyyət',
      render: (row) =>
        row.isActive ? <Badge tone="success">Aktiv</Badge> : <Badge tone="neutral">Bağlı</Badge>,
    },
  ];

  return (
    <Page title="Lokasiyalar" subtitle="Fiziki və virtual lokasiyalar">
      <Card title="Lokasiyalar" flush>
        {locations.isLoading ? (
          <LoadingState />
        ) : locations.isError ? (
          <ErrorState error={locations.error} onRetry={() => void locations.refetch()} />
        ) : (
          <DataTable<Location>
            columns={columns}
            rows={locations.data?.items ?? []}
            rowKey={(row) => row.id}
            label="Lokasiya siyahısı"
            empty="Lokasiya yoxdur. Master data quraşdırması ilə başlayın."
          />
        )}
      </Card>
    </Page>
  );
}
