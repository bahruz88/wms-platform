import { useState } from 'react';
import { Badge, DataTable, TextField, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listSuppliers, type SupplierSummary } from '@api/endpoints';
import { ErrorState, LoadingState, Page, Section } from '@/components/Page';
import { Pager } from '@/components/Pager';

/**
 * Suppliers — docs/ux/screen-map.md §5.3. `isApprovedFoodSupplier` is the flag that decides
 * whether a food receipt from this supplier is allowed at all (TOR §7, `422` otherwise).
 */
export function SuppliersScreen() {
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');

  const query = { page, size: 50, ...(search.trim() ? { q: search.trim() } : {}) };
  const suppliers = useApiPage<SupplierSummary>(
    ['suppliers', query],
    () => listSuppliers(query),
    50,
  );

  const columns: Column<SupplierSummary>[] = [
    {
      key: 'code',
      header: 'Kod',
      width: '120px',
      render: (row) => <span className="wms-doc-no">{row.code}</span>,
    },
    { key: 'name', header: 'Ad' },
    {
      key: 'taxId',
      header: 'VÖEN',
      render: (row) => (row.taxId ? <span className="wms-doc-no">{row.taxId}</span> : '—'),
    },
    { key: 'currency', header: 'Valyuta' },
    {
      key: 'isApprovedFoodSupplier',
      header: 'Qida təsdiqi',
      render: (row) =>
        row.isApprovedFoodSupplier ? (
          <Badge tone="success">Təsdiqlənib</Badge>
        ) : (
          <Badge tone="warning" title="Qida məhsulu qəbul edilə bilməz (TOR §7)">
            Təsdiqlənməyib
          </Badge>
        ),
    },
    {
      key: 'isActive',
      header: 'Vəziyyət',
      render: (row) =>
        row.isActive ? <Badge tone="success">Aktiv</Badge> : <Badge tone="neutral">Bağlı</Badge>,
    },
  ];

  return (
    <Page title="Təchizatçılar" subtitle="Təchizatçı kataloqu və qida təsdiqi vəziyyəti">
      <div className="wms-toolbar">
        <TextField
          label="Axtarış"
          value={search}
          placeholder="Ad, kod və ya VÖEN"
          onChange={(e) => {
            setSearch(e.target.value);
            setPage(1);
          }}
        />
      </div>
      <Section>
        {suppliers.isLoading ? (
          <LoadingState />
        ) : suppliers.isError ? (
          <ErrorState error={suppliers.error} onRetry={() => void suppliers.refetch()} />
        ) : (
          <>
            <DataTable<SupplierSummary>
              columns={columns}
              rows={suppliers.data?.items ?? []}
              rowKey={(row) => row.id}
              label="Təchizatçı siyahısı"
              empty="Təchizatçı yoxdur. Satınalmaya başlamazdan əvvəl təchizatçı əlavə edin."
            />
            {suppliers.data ? <Pager page={suppliers.data} onPageChange={setPage} /> : null}
          </>
        )}
      </Section>
    </Page>
  );
}
