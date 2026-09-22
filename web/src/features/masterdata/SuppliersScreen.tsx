import { useState } from 'react';
import { Link } from 'react-router-dom';
import { Badge, DataTable, Select, TextField, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listSuppliers, type SupplierSummary } from '@api/endpoints';
import { Card, ErrorState, LoadingState, Page } from '@/components/Page';
import { Pager } from '@/components/Pager';
import { MasterDataTabs } from './MasterDataTabs';

/**
 * Suppliers — docs/ux/screen-map.md §5.3. `isApprovedFoodSupplier` is the flag that decides
 * whether a food receipt from this supplier is allowed at all (TOR §7, `422` otherwise), so it
 * is both a column and a filter: "who can we actually buy food from" is a question a buyer asks
 * before every order.
 */
export function SuppliersScreen() {
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [approvedFoodOnly, setApprovedFoodOnly] = useState('');
  const [isActive, setIsActive] = useState('true');

  const query = {
    page,
    size: 50,
    ...(search.trim() ? { q: search.trim() } : {}),
    ...(approvedFoodOnly === 'true' ? { approvedFoodOnly: true } : {}),
    ...(isActive === '' ? {} : { isActive: isActive === 'true' }),
  };
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
      render: (row) => (
        <Link className="wms-doc-no" to={`/master-data/suppliers/${row.id}`}>
          {row.code}
        </Link>
      ),
    },
    {
      key: 'name',
      header: 'Ad',
      render: (row) => <Link to={`/master-data/suppliers/${row.id}`}>{row.name}</Link>,
    },
    {
      key: 'taxId',
      header: 'VÖEN',
      width: '160px',
      render: (row) =>
        row.taxId ? (
          <span className="wms-doc-no">{row.taxId}</span>
        ) : (
          <span className="wms-muted">—</span>
        ),
    },
    {
      key: 'currency',
      header: 'Valyuta',
      width: '100px',
      render: (row) => <span className="wms-num">{row.currency}</span>,
    },
    {
      key: 'isApprovedFoodSupplier',
      header: 'Qida təsdiqi',
      width: '150px',
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
      width: '110px',
      render: (row) =>
        row.isActive ? <Badge tone="success">Aktiv</Badge> : <Badge tone="neutral">Bağlı</Badge>,
    },
  ];

  return (
    <Page title="Təchizatçılar" subtitle="Təchizatçı kataloqu və qida təsdiqi vəziyyəti">
      <MasterDataTabs />

      <Card>
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
          <Select
            label="Qida təsdiqi"
            value={approvedFoodOnly}
            placeholder="Hamısı"
            options={[{ value: 'true', label: 'Yalnız təsdiqlənmiş' }]}
            onChange={(e) => {
              setApprovedFoodOnly(e.target.value);
              setPage(1);
            }}
          />
          <Select
            label="Vəziyyət"
            value={isActive}
            placeholder="Hamısı"
            options={[
              { value: 'true', label: 'Aktiv' },
              { value: 'false', label: 'Bağlı' },
            ]}
            onChange={(e) => {
              setIsActive(e.target.value);
              setPage(1);
            }}
          />
          <div className="wms-toolbar__spacer" />
        </div>
      </Card>

      <Card
        title="Təchizatçılar"
        subtitle={suppliers.data ? `${suppliers.data.total} təchizatçı` : undefined}
        flush
        footer={suppliers.data ? <Pager page={suppliers.data} onPageChange={setPage} /> : undefined}
      >
        {suppliers.isLoading ? (
          <LoadingState />
        ) : suppliers.isError ? (
          <div className="wms-card__body">
            <ErrorState error={suppliers.error} onRetry={() => void suppliers.refetch()} />
          </div>
        ) : (
          <DataTable<SupplierSummary>
            columns={columns}
            rows={suppliers.data?.items ?? []}
            rowKey={(row) => row.id}
            label="Təchizatçı siyahısı"
            empty="Bu filtrə uyğun təchizatçı yoxdur. Filtri dəyişin və ya yeni təchizatçı əlavə edin."
          />
        )}
      </Card>
    </Page>
  );
}
