import { useState } from 'react';
import { Link } from 'react-router-dom';
import { Badge, DataTable, DocStatusBadge, KpiCard, Select, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listConsumptionRuns, type ConsumptionRun } from '@api/endpoints';
import { formatDate, formatDateTime } from '@core/format';
import { ErrorState, LoadingState, Page, Section } from '@/components/Page';
import { Pager } from '@/components/Pager';

/**
 * Consumption journal — one document per branch per day (`CN-{YYYY}-{00000}`, ADR-012).
 * `shortfallCount` is the number of lines where stock was not enough to issue the theoretical
 * quantity; it is a signal that a receipt was not recorded, not a rounding artefact.
 */
export function ConsumptionRunsScreen() {
  const [page, setPage] = useState(1);
  const [status, setStatus] = useState('');

  const query = { page, size: 50, ...(status ? { status: status as 'POSTED' } : {}) };
  const runs = useApiPage<ConsumptionRun>(['runs', query], () => listConsumptionRuns(query), 50);

  const posted = (runs.data?.items ?? []).filter((r) => r.status === 'POSTED').length;
  const shortfalls = (runs.data?.items ?? []).reduce((acc, r) => acc + r.shortfallCount, 0);

  const columns: Column<ConsumptionRun>[] = [
    {
      key: 'docNo',
      header: 'Sənəd',
      render: (row) => (
        <Link to={`/consumption/runs/${row.id}`}>
          <span className="wms-doc-no">{row.docNo}</span>
        </Link>
      ),
    },
    { key: 'businessDate', header: 'İş günü', render: (row) => formatDate(row.businessDate) },
    {
      key: 'locationName',
      header: 'Lokasiya',
      render: (row) => row.locationName ?? `#${row.locationId}`,
    },
    { key: 'status', header: 'Status', render: (row) => <DocStatusBadge status={row.status} /> },
    {
      key: 'shortfallCount',
      header: 'Çatışmazlıq',
      numeric: true,
      decimals: 0,
      render: (row) =>
        row.shortfallCount > 0 ? (
          <Badge tone="danger">{`${row.shortfallCount} sətir`}</Badge>
        ) : (
          <span className="wms-muted">—</span>
        ),
    },
    {
      key: 'unmappedCount',
      header: 'Uyğunsuz POS',
      numeric: true,
      decimals: 0,
      render: (row) =>
        row.unmappedCount > 0 ? (
          <Badge tone="warning">{`${row.unmappedCount} sətir`}</Badge>
        ) : (
          <span className="wms-muted">—</span>
        ),
    },
    {
      key: 'calculatedAt',
      header: 'Hesablanıb',
      render: (row) => formatDateTime(row.calculatedAt),
    },
    { key: 'postedAt', header: 'Post edilib', render: (row) => formatDateTime(row.postedAt) },
    {
      key: 'movementGroupId',
      header: 'Hərəkət qrupu',
      render: (row) =>
        row.movementGroupId ? (
          <Link to={`/inventory/movement-groups/${row.movementGroupId}`}>
            <span className="wms-doc-no">{`#${row.movementGroupId}`}</span>
          </Link>
        ) : (
          <span className="wms-muted">—</span>
        ),
    },
  ];

  return (
    <Page title="İstehlak jurnalı" subtitle="Filial × gün — resept əsaslı nəzəri məxaric">
      <div className="wms-grid wms-grid--kpi">
        <KpiCard label="Sənəd sayı" value={runs.data?.total ?? 0} hint="Bu filtrə uyğun" />
        <KpiCard label="Post edilmiş" value={posted} hint="Cari səhifədə" />
        <KpiCard label="Çatışmayan sətir" value={shortfalls} hint="Cari səhifədə cəmi" />
      </div>
      <div className="wms-toolbar">
        <Select
          label="Status"
          value={status}
          placeholder="Bütün statuslar"
          options={['DRAFT', 'CALCULATED', 'POSTED', 'REVERSED', 'FAILED'].map((v) => ({
            value: v,
            label: v,
          }))}
          onChange={(e) => {
            setStatus(e.target.value);
            setPage(1);
          }}
        />
      </div>
      <Section>
        {runs.isLoading ? (
          <LoadingState />
        ) : runs.isError ? (
          <ErrorState error={runs.error} onRetry={() => void runs.refetch()} />
        ) : (
          <>
            <DataTable<ConsumptionRun>
              columns={columns}
              rows={runs.data?.items ?? []}
              rowKey={(row) => row.id}
              label="İstehlak sənədləri"
              empty="İstehlak sənədi yoxdur. Satış importu göndərin və hesablamanı başladın."
            />
            {runs.data ? <Pager page={runs.data} onPageChange={setPage} /> : null}
          </>
        )}
      </Section>
    </Page>
  );
}
