import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Badge, Button, DataTable, DocStatusBadge, Select, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listSalesImports, type SalesImport } from '@api/endpoints';
import { useAuth } from '@auth/index';
import { formatDate, formatDateTime } from '@core/format';
import { ErrorState, LoadingState, Page, Section } from '@/components/Page';
import { Pager } from '@/components/Pager';

/**
 * Sales imports — the input side of consumption (ADR-012). A row whose POS code matches no menu
 * item stays `unmapped`: it never silently disappears, because a sale that produced no consumption
 * is exactly the thing the variance report has to explain.
 */
export function SalesImportsScreen() {
  const navigate = useNavigate();
  const { can } = useAuth();
  const [page, setPage] = useState(1);
  const [source, setSource] = useState<'' | 'POS' | 'CSV' | 'MANUAL'>('');

  const query = { page, size: 50, ...(source ? { source } : {}) };
  const imports = useApiPage<SalesImport>(
    ['sales-imports', query],
    () => listSalesImports(query),
    50,
  );

  const columns: Column<SalesImport>[] = [
    {
      key: 'id',
      header: 'Sənəd',
      width: '90px',
      render: (row) => (
        <Link to={`/consumption/sales-imports/${row.id}`}>
          <span className="wms-doc-no">{`SI-${String(row.id).padStart(5, '0')}`}</span>
        </Link>
      ),
    },
    { key: 'businessDate', header: 'İş günü', render: (row) => formatDate(row.businessDate) },
    {
      key: 'locationName',
      header: 'Lokasiya',
      render: (row) => row.locationName ?? `#${row.locationId}`,
    },
    { key: 'source', header: 'Mənbə', render: (row) => <Badge tone="neutral">{row.source}</Badge> },
    { key: 'externalRef', header: 'Xarici istinad', render: (row) => row.externalRef ?? '—' },
    { key: 'lineCount', header: 'Sətir', numeric: true, decimals: 0 },
    {
      key: 'unmappedCount',
      header: 'Uyğunsuz',
      numeric: true,
      decimals: 0,
      render: (row) =>
        (row.unmappedCount ?? 0) > 0 ? (
          <Badge tone="warning">{`${row.unmappedCount} sətir`}</Badge>
        ) : (
          <span className="wms-muted">—</span>
        ),
    },
    { key: 'grossAmount', header: 'Brüt məbləğ', numeric: true, decimals: 2 },
    { key: 'importedAt', header: 'İmport vaxtı', render: (row) => formatDateTime(row.importedAt) },
    { key: 'status', header: 'Status', render: (row) => <DocStatusBadge status={row.status} /> },
    {
      key: 'consumptionRunId',
      header: 'İstehlak sənədi',
      render: (row) =>
        row.consumptionRunId ? (
          <Link to={`/consumption/runs/${row.consumptionRunId}`}>
            <span className="wms-doc-no">{`#${row.consumptionRunId}`}</span>
          </Link>
        ) : (
          <span className="wms-muted">Yaradılmayıb</span>
        ),
    },
  ];

  return (
    <Page
      title="Satış importu"
      subtitle="POS, CSV və əl ilə daxil edilən satış məlumatı"
      actions={
        <Button
          variant="primary"
          disabled={!can('cons.sales.import')}
          title={!can('cons.sales.import') ? '`cons.sales.import` icazəniz yoxdur' : undefined}
          onClick={() => navigate('/consumption/sales-imports/csv')}
        >
          CSV yüklə
        </Button>
      }
    >
      <div className="wms-toolbar">
        <Select
          label="Mənbə"
          value={source}
          placeholder="Bütün mənbələr"
          options={[
            { value: 'POS', label: 'POS' },
            { value: 'CSV', label: 'CSV' },
            { value: 'MANUAL', label: 'Əl ilə' },
          ]}
          onChange={(e) => {
            setSource(e.target.value as typeof source);
            setPage(1);
          }}
        />
      </div>
      <Section>
        {imports.isLoading ? (
          <LoadingState />
        ) : imports.isError ? (
          <ErrorState error={imports.error} onRetry={() => void imports.refetch()} />
        ) : (
          <>
            <DataTable<SalesImport>
              columns={columns}
              rows={imports.data?.items ?? []}
              rowKey={(row) => row.id}
              label="Satış importları"
              empty="Satış importu yoxdur. CSV yükləyin və ya POS inteqrasiyasını qoşun."
            />
            {imports.data ? <Pager page={imports.data} onPageChange={setPage} /> : null}
          </>
        )}
      </Section>
    </Page>
  );
}
