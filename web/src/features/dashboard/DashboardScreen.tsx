import { Link } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { Alert, DataTable, DocStatusBadge, KpiCard, type Column } from '@ds/index';
import { useApiPage, useApiQuery } from '@api/hooks';
import {
  getDashboardSummary,
  listBalances,
  listConsumptionRuns,
  listLocations,
  listPendingApprovals,
  listProducts,
  listPurchaseOrders,
  type Balance,
  type ConsumptionRun,
  type PendingApproval,
} from '@api/endpoints';
import { useAuth } from '@auth/index';
import { Decimal } from '@core/decimal';
import { formatDate, formatMoney } from '@core/format';
import { Money } from '@core/decimal';
import { DocNo, ErrorState, Page, Section } from '@/components/Page';

/**
 * Dashboard — docs/ux/screen-map.md §5.1.
 *
 * `GET /reporting/dashboard/summary` is the contract's source for the KPIs. While that operation
 * is not live on the gateway the screen falls back to counting the collections that are, and says
 * so rather than showing invented numbers.
 *
 * The stock-value card is bound to `master.product.view_cost`: without the permission the card is
 * **not rendered** — not blanked, not starred out (components/KpiCard/README.md, SPEC §16).
 */
export function DashboardScreen() {
  const { t } = useTranslation();
  const { can } = useAuth();
  const canViewCost = can('master.product.view_cost');

  const summary = useApiQuery(['dashboard', 'summary'], getDashboardSummary, { retry: false });

  const products = useApiPage(
    ['dashboard', 'products'],
    () => listProducts({ page: 1, size: 1 }),
    1,
  );
  const locations = useApiPage(['dashboard', 'locations'], () => listLocations({}), 1);
  const balances = useApiPage<Balance>(
    ['dashboard', 'balances'],
    () => listBalances({ page: 1, size: 200 }),
    200,
  );
  const purchaseOrders = useApiPage(
    ['dashboard', 'purchase-orders'],
    () => listPurchaseOrders({ page: 1, size: 1 }),
    1,
  );
  const runs = useApiPage<ConsumptionRun>(
    ['dashboard', 'runs'],
    () => listConsumptionRuns({ page: 1, size: 5 }),
    5,
  );
  const approvals = useApiPage<PendingApproval>(
    ['dashboard', 'approvals'],
    () => listPendingApprovals({ page: 1, size: 20 }),
    20,
  );

  // Stock value is summed through Decimal, never through Number — the strings come as
  // DECIMAL(18,4) and a float sum drifts on the fourth decimal.
  const stockValue = (balances.data?.items ?? []).reduce(
    (acc, row) => (row.totalValue ? acc.plus(new Decimal(row.totalValue)) : acc),
    new Decimal(0),
  );

  const approvalColumns: Column<PendingApproval>[] = [
    {
      key: 'docNo',
      header: 'Sənəd',
      render: (row) => <DocNo value={row.docNo} />,
    },
    { key: 'docType', header: 'Tip' },
    {
      key: 'amountBase',
      header: 'Məbləğ (AZN)',
      numeric: true,
      decimals: 2,
      permission: 'master.product.view_cost',
    },
    { key: 'requestedBy', header: 'Tələbçi', render: (row) => row.requestedBy?.username ?? '—' },
    {
      key: 'viaDelegationFrom',
      header: 'Delegasiya',
      render: (row) => row.viaDelegationFrom?.username ?? '—',
    },
    {
      key: 'waitingSince',
      header: 'Gözləyir',
      render: (row) => formatDate(row.waitingSince),
    },
  ];

  const runColumns: Column<ConsumptionRun>[] = [
    {
      key: 'docNo',
      header: 'Sənəd',
      render: (row) => (
        <Link to={`/consumption/runs/${row.id}`}>
          <DocNo value={row.docNo} />
        </Link>
      ),
    },
    { key: 'locationName', header: 'Lokasiya' },
    { key: 'businessDate', header: 'Tarix', render: (row) => formatDate(row.businessDate) },
    { key: 'status', header: 'Status', render: (row) => <DocStatusBadge status={row.status} /> },
    { key: 'shortfallCount', header: 'Çatışmazlıq', numeric: true, decimals: 0 },
    { key: 'unmappedCount', header: 'Uyğunsuz POS', numeric: true, decimals: 0 },
  ];

  return (
    <Page title={t('dashboard.title')} subtitle={t('dashboard.subtitle')}>
      {summary.isError ? (
        <Alert
          tone="info"
          title="Dashboard xülasəsi hələ backend-də açılmayıb"
          code={summary.error?.code}
        >
          `GET /reporting/dashboard/summary` kontraktda var, lakin gateway {summary.error?.status}{' '}
          qaytarır. Aşağıdakı göstəricilər işləyən endpoint-lərdən birbaşa sayılıb.
        </Alert>
      ) : null}

      <div className="wms-grid wms-grid--kpi">
        <KpiCard
          label={t('dashboard.kpiProducts')}
          value={products.data?.total ?? 0}
          hint="master_product, aktiv tenant"
        />
        <KpiCard
          label={t('dashboard.kpiLocations')}
          value={locations.data?.total ?? 0}
          hint="master_location, virtual daxil"
        />
        <KpiCard
          label={t('dashboard.kpiBalanceRows')}
          value={balances.data?.total ?? 0}
          hint="inv_balance proyeksiyası"
        />
        <KpiCard
          label={t('dashboard.kpiOpenPos')}
          value={purchaseOrders.data?.total ?? 0}
          hint="proc_purchase_order"
        />
        <KpiCard
          label={t('dashboard.kpiRuns')}
          value={runs.data?.total ?? 0}
          hint="cons_consumption_run"
        />
        {/* Money KPI only with master.product.view_cost — otherwise not rendered at all. */}
        {canViewCost ? (
          <KpiCard
            label={t('dashboard.kpiStockValue')}
            value={formatMoney(Money.parse(stockValue.toFixed(4), 'AZN'), 2)}
            hint="İlk 200 qalıq sətrinin cəmi"
            badge={<DocStatusBadge status="POSTED" label="Cari" />}
          />
        ) : null}
      </div>

      <Section title={t('dashboard.pendingApprovals')}>
        {approvals.isError ? (
          <ErrorState error={approvals.error} onRetry={() => void approvals.refetch()} />
        ) : (
          <DataTable<PendingApproval>
            columns={approvalColumns}
            rows={approvals.data?.items ?? []}
            permissions={canViewCost ? ['master.product.view_cost'] : []}
            rowKey={(row) => row.approvalId}
            label={t('dashboard.pendingApprovals')}
            empty={t('dashboard.pendingEmpty')}
          />
        )}
      </Section>

      <Section title={t('dashboard.recentRuns')}>
        {runs.isError ? (
          <ErrorState error={runs.error} onRetry={() => void runs.refetch()} />
        ) : (
          <DataTable<ConsumptionRun>
            columns={runColumns}
            rows={runs.data?.items ?? []}
            rowKey={(row) => row.id}
            label={t('dashboard.recentRuns')}
            empty="Hələ istehlak sənədi yoxdur. Satış importu göndərin və hesablama başladın."
          />
        )}
      </Section>
    </Page>
  );
}
