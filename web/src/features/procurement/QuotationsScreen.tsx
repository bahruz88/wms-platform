import { useState } from 'react';
import { Link } from 'react-router-dom';
import { Badge, DataTable, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listQuotations, type QuotationSummary } from '@api/endpoints';
import { useAuth } from '@auth/index';
import { formatDate } from '@core/format';
import { ErrorState, LoadingState, Page, Section } from '@/components/Page';
import { Pager } from '@/components/Pager';

/** Quotations — the flat list behind the comparison matrix (screen-map §4.3). */
export function QuotationsScreen() {
  const { session } = useAuth();
  const [page, setPage] = useState(1);
  const quotations = useApiPage<QuotationSummary>(
    ['quotations', page],
    () => listQuotations({ page, size: 50 }),
    50,
  );

  const columns: Column<QuotationSummary>[] = [
    {
      key: 'quoteNo',
      header: 'Təklif',
      render: (row) => <span className="wms-doc-no">{row.quoteNo ?? `#${row.id}`}</span>,
    },
    {
      key: 'rfqDocNo',
      header: 'RFQ',
      render: (row) =>
        row.rfqId ? (
          <Link to={`/procurement/rfqs/${row.rfqId}/comparison`}>
            <span className="wms-doc-no">{row.rfqDocNo ?? `#${row.rfqId}`}</span>
          </Link>
        ) : (
          '—'
        ),
    },
    { key: 'supplier', header: 'Təchizatçı', render: (row) => row.supplier.name },
    { key: 'quoteDate', header: 'Tarix', render: (row) => formatDate(row.quoteDate) },
    { key: 'validUntil', header: 'Etibarlıdır', render: (row) => formatDate(row.validUntil) },
    { key: 'deliveryDays', header: 'Çatdırılma (gün)', numeric: true, decimals: 0 },
    { key: 'currency', header: 'Valyuta' },
    {
      key: 'totalAmount',
      header: 'Məbləğ',
      numeric: true,
      decimals: 2,
      permission: 'master.product.view_cost',
    },
    {
      key: 'totalAmountBase',
      header: 'Məbləğ (AZN)',
      numeric: true,
      decimals: 2,
      permission: 'master.product.view_cost',
    },
    {
      key: 'flags',
      header: 'Nişanlar',
      render: (row) => (
        <span className="wms-row">
          {row.isCheapest ? <Badge tone="success">Ən ucuz</Badge> : null}
          {row.isSelected ? <Badge tone="accent">Seçilib</Badge> : null}
          {row.selectionNote ? (
            <Badge tone="warning" title={row.selectionNote}>
              Seçim qeydi var
            </Badge>
          ) : null}
        </span>
      ),
    },
  ];

  return (
    <Page title="Təkliflər" subtitle="Təchizatçı təklifləri və seçim vəziyyəti">
      <Section>
        {quotations.isLoading ? (
          <LoadingState />
        ) : quotations.isError ? (
          <ErrorState error={quotations.error} onRetry={() => void quotations.refetch()} />
        ) : (
          <>
            <DataTable<QuotationSummary>
              columns={columns}
              rows={quotations.data?.items ?? []}
              permissions={session?.permissions ?? []}
              rowKey={(row) => row.id}
              label="Təklif siyahısı"
              empty="Təklif yoxdur. RFQ göndərin və təchizatçı cavablarını daxil edin."
            />
            {quotations.data ? <Pager page={quotations.data} onPageChange={setPage} /> : null}
          </>
        )}
      </Section>
    </Page>
  );
}
