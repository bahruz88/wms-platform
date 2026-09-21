import { useMemo } from 'react';
import { Link } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { Alert, Badge, Button, DataTable, DocStatusBadge, KpiCard, type Column } from '@ds/index';
import { useApiPage, useApiQuery } from '@api/hooks';
import {
  getDashboardSummary,
  listBalances,
  listCounts,
  listGoodsReceipts,
  listPendingApprovals,
  type Balance,
  type CountSummary,
  type DashboardSummary,
  type GoodsReceiptSummary,
  type PendingApproval,
} from '@api/endpoints';
import { normalizeBalance } from '@api/adapters';
import { settingsFallbackNote, useInventorySettings } from '@api/settings';
import { useAuth } from '@auth/index';
import { Decimal, Money } from '@core/decimal';
import { daysUntil, formatDate, formatDateTime, formatMoney, formatNumber } from '@core/format';
import { Card, DocNo, ErrorState, Page, ProductCell } from '@/components/Page';

/**
 * Warehouse dashboard — docs/design-system/screens/Main.dc.html.
 *
 * The artboard's spine: a document-level `Alert` when the nightly reconciliation finds a
 * mismatch, a four-up KPI row, then a `1.45fr / 1fr` split with the expiring batches on the left
 * and "Mənim təsdiqim gözlənilir" on the right.
 *
 * `GET /reporting/dashboard/summary` is the contract's source for the KPIs and for the
 * reconciliation state. While it is not routed the screen counts what the live endpoints give it
 * and says so — it never invents a figure, and it never shows a reconciliation alert it has not
 * been told about.
 *
 * The stock-value card is bound to `master.product.view_cost`: without the permission it is not
 * rendered at all, and a non-cost card takes its place so the row stays four wide
 * (components/KpiCard/README.md, SPEC §16).
 */

interface ExpiringRow {
  key: string;
  productName: string;
  sku: string;
  batchNo: string;
  expiryDate: string | null;
  daysLeft: number | null;
  qty: string;
  uom: string;
  location: string;
}

export function DashboardScreen() {
  const { t } = useTranslation();
  const { can } = useAuth();
  const canViewCost = can('master.product.view_cost');

  const summary = useApiQuery<DashboardSummary>(['dashboard', 'summary'], getDashboardSummary, {
    retry: false,
  });

  // One place reads `inv_setting`, and it says when it is showing a documented default rather
  // than the tenant's own value (TOR §36).
  const settings = useInventorySettings('dashboard');

  const balances = useApiPage<Balance>(
    ['dashboard', 'balances'],
    () => listBalances({ page: 1, size: 200 }),
    200,
  );

  const approvals = useApiPage<PendingApproval>(
    ['dashboard', 'approvals'],
    () => listPendingApprovals({ page: 1, size: 20 }),
    20,
    { retry: false },
  );

  const receipts = useApiPage<GoodsReceiptSummary>(
    ['dashboard', 'receipts'],
    () => listGoodsReceipts({ page: 1, size: 1 }),
    1,
    { retry: false },
  );

  const counts = useApiPage<CountSummary>(
    ['dashboard', 'counts'],
    () => listCounts({ page: 1, size: 1 }),
    1,
    { retry: false },
  );

  const warningDays = settings.get('expiry_warning_days');
  const criticalDays = settings.get('expiry_critical_days');

  const rows = useMemo(
    () => (balances.data?.items ?? []).map((row) => normalizeBalance(row)),
    [balances.data],
  );

  // Stock value is summed through Decimal, never through Number — the strings come as
  // DECIMAL(18,4) and a float sum drifts on the fourth decimal.
  const stockValue = rows.reduce(
    (acc, row) => (row.totalValue ? acc.plus(new Decimal(row.totalValue)) : acc),
    new Decimal(0),
  );

  const expiring: ExpiringRow[] = useMemo(() => {
    const withExpiry = rows
      .filter((row) => row.batch?.expiryDate)
      .map((row) => {
        const daysLeft = row.daysToExpiry ?? daysUntil(row.batch?.expiryDate);
        return {
          key: `${row.product.id}-${row.batch?.id ?? 0}-${row.location.id}`,
          productName: row.product.name,
          sku: row.product.sku,
          batchNo: row.batch?.batchNo ?? '—',
          expiryDate: row.batch?.expiryDate ?? null,
          daysLeft,
          qty: row.qtyOnHand,
          uom: row.baseUomCode,
          location: row.location.name,
        };
      })
      .filter((row) => row.daysLeft !== null && row.daysLeft <= warningDays);
    withExpiry.sort((a, b) => (a.daysLeft ?? 0) - (b.daysLeft ?? 0));
    return withExpiry.slice(0, 12);
  }, [rows, warningDays]);

  // The reconciliation alert is only shown when the server says the check failed. No summary
  // means no claim — an absent answer is not evidence of a mismatch.
  const health = summary.data?.systemHealth;
  const reconciliationFailed = health?.balanceReconciliationOk === false;

  const kpiByKey = (key: string) => summary.data?.kpis?.find((k) => k.key === key);
  const pendingCount = approvals.data?.total ?? 0;

  const expiringColumns: Column<ExpiringRow>[] = [
    {
      key: 'product',
      header: t('dashboard.colProduct'),
      render: (row) => <ProductCell name={row.productName} sku={row.sku} />,
    },
    {
      key: 'batch',
      header: t('dashboard.colBatch'),
      width: '130px',
      render: (row) => <span className="wms-num wms-small">{row.batchNo}</span>,
    },
    {
      key: 'expiry',
      header: t('dashboard.colExpiry'),
      width: '110px',
      render: (row) => <span className="wms-num wms-small">{formatDate(row.expiryDate)}</span>,
    },
    {
      key: 'daysLeft',
      header: t('dashboard.colDaysLeft'),
      width: '110px',
      numeric: true,
      decimals: 0,
      render: (row) =>
        row.daysLeft === null ? (
          <span className="wms-muted">—</span>
        ) : row.daysLeft <= criticalDays ? (
          <Badge tone="danger" dot title={`expiry_critical_days = ${criticalDays}`}>
            {formatNumber(row.daysLeft, 0)}
          </Badge>
        ) : (
          formatNumber(row.daysLeft, 0)
        ),
    },
    {
      key: 'qty',
      header: t('dashboard.colQty'),
      numeric: true,
      width: '140px',
      render: (row) => `${formatNumber(row.qty, 3)} ${row.uom}`,
    },
    { key: 'location', header: t('dashboard.colLocation'), width: '140px' },
  ];

  return (
    <Page
      title={t('dashboard.title')}
      subtitle={t('dashboard.subtitle', {
        location: summary.data?.locationId ? `#${summary.data.locationId}` : t('nav.inventory'),
        when: formatDateTime(summary.data?.generatedAt ?? new Date()),
      })}
      actions={
        <>
          <Button variant="secondary" onClick={() => void balances.refetch()}>
            {t('common.refresh')}
          </Button>
          {can('inv.receipt.create') ? (
            <Link to="/inventory/goods-receipts/new" className="wms-btn wms-btn--primary">
              {t('dashboard.newReceipt')}
            </Link>
          ) : (
            <Button disabled title="`inv.receipt.create` icazəniz yoxdur">
              {t('dashboard.newReceipt')}
            </Button>
          )}
        </>
      }
    >
      {reconciliationFailed ? (
        <Alert
          tone="danger"
          title={t('dashboard.reconciliationTitle')}
          code="RECONCILIATION_MISMATCH"
        >
          {t('dashboard.reconciliationBody', {
            location: summary.data?.locationId ? `#${summary.data.locationId}` : t('nav.inventory'),
            count:
              summary.data?.alerts?.find((a) => a.type === 'RECONCILIATION_MISMATCH')?.count ?? 0,
          })}
          {health?.lastBalanceReconciliationAt ? (
            <div className="wms-num wms-small">
              {formatDateTime(health.lastBalanceReconciliationAt)}
            </div>
          ) : null}
        </Alert>
      ) : null}

      {settings.unavailable ? (
        <Alert tone="info" title="Hədlər tenant parametrindən oxunmadı" code="NOT_FOUND">
          {settingsFallbackNote(settings.status)}
        </Alert>
      ) : null}

      {summary.isError ? (
        <Alert
          tone="info"
          title={t('state.notImplementedTitle')}
          code={summary.error?.code ?? undefined}
        >
          <span className="wms-num">GET /reporting/dashboard/summary</span> —{' '}
          {t('state.notImplementedBody', { status: summary.error?.status ?? 404 })}{' '}
          {t('dashboard.summaryFallback')}
        </Alert>
      ) : null}

      <div className="wms-grid wms-grid--kpi">
        {canViewCost ? (
          <KpiCard
            label={t('dashboard.kpiStockValue')}
            value={
              kpiByKey('stock_value')
                ? formatNumber(kpiByKey('stock_value')?.value ?? '0', 2)
                : formatMoney(Money.parse(stockValue.toFixed(4), 'AZN'), 2)
            }
            unit={kpiByKey('stock_value') ? 'AZN' : undefined}
            hint={t('dashboard.kpiStockValueHint')}
          />
        ) : (
          <KpiCard
            label={t('dashboard.kpiBalanceRows')}
            value={balances.data?.total ?? 0}
            hint="inv_balance"
          />
        )}
        <KpiCard
          label={t('dashboard.kpiPendingDocs')}
          value={pendingCount}
          hint="proc_approval_step"
        />
        <KpiCard
          label={t('dashboard.kpiExpiring')}
          value={expiring.length}
          unit={t('dashboard.kpiExpiringUnit')}
          hint={`expiry_warning_days = ${warningDays}`}
        />
        <KpiCard
          label={canViewCost ? t('dashboard.kpiBalanceRows') : t('dashboard.kpiOpenPos')}
          value={
            canViewCost
              ? (balances.data?.total ?? 0)
              : (receipts.data?.total ?? counts.data?.total ?? 0)
          }
          hint={canViewCost ? 'inv_balance' : 'inv_goods_receipt'}
        />
      </div>

      <div className="wms-split">
        <Card
          title={t('dashboard.expiringTitle')}
          subtitle={t('dashboard.expiringSub', { warning: warningDays, critical: criticalDays })}
          actions={<Link to="/inventory/batches">{t('common.seeAll')}</Link>}
          flush
        >
          {balances.isError ? (
            <div className="wms-card__body">
              <ErrorState error={balances.error} onRetry={() => void balances.refetch()} />
            </div>
          ) : (
            <DataTable<ExpiringRow>
              columns={expiringColumns}
              rows={expiring}
              rowKey={(row) => row.key}
              label={t('dashboard.expiringTitle')}
              empty={t('dashboard.expiringEmpty')}
            />
          )}
        </Card>

        <Card
          title={t('dashboard.pendingApprovals')}
          actions={
            pendingCount > 0 ? (
              <Badge tone="warning" dot>
                {formatNumber(pendingCount, 0)}
              </Badge>
            ) : undefined
          }
          rows
        >
          {approvals.isError ? (
            approvals.error.status === 404 || approvals.error.status === 405 ? (
              // The screen already carries one "not routed yet" notice; a second identical Alert
              // inside the card would be noise, so the card says it in one muted line instead.
              <div className="wms-muted" style={{ padding: '8px 16px' }}>
                <span className="wms-num">GET /procurement/approvals/pending</span> —{' '}
                {t('state.notImplementedBody', { status: approvals.error.status })}
              </div>
            ) : (
              <div style={{ padding: '8px 16px' }}>
                <ErrorState error={approvals.error} onRetry={() => void approvals.refetch()} />
              </div>
            )
          ) : (approvals.data?.items ?? []).length === 0 ? (
            <div className="wms-muted" style={{ padding: '8px 16px' }}>
              {t('dashboard.pendingEmpty')}
            </div>
          ) : (
            <div className="wms-doclist">
              {(approvals.data?.items ?? []).map((row) => (
                <div className="wms-doclist__row" key={row.approvalId}>
                  <div className="wms-doclist__main">
                    <div className="wms-doclist__title">
                      <span className="wms-num wms-doclist__no">{row.docNo}</span>
                      <DocStatusBadge status="PENDING_APPROVAL" />
                    </div>
                    <div className="wms-doclist__meta">
                      {[
                        row.summary,
                        canViewCost && row.amountBase
                          ? `${formatNumber(row.amountBase, 2)} AZN`
                          : null,
                        row.viaDelegationFrom
                          ? `delegasiya: ${row.viaDelegationFrom.username}`
                          : null,
                        t('dashboard.waitingSince', {
                          days: Math.max(0, -(daysUntil(row.waitingSince) ?? 0)),
                        }),
                      ]
                        .filter(Boolean)
                        .join(' · ')}
                    </div>
                  </div>
                  <Link
                    to={approvalLink(row)}
                    className="wms-btn wms-btn--secondary wms-btn--sm"
                    aria-label={`${row.docNo} — ${t('common.view')}`}
                  >
                    {t('common.view')}
                  </Link>
                </div>
              ))}
            </div>
          )}
        </Card>
      </div>
    </Page>
  );
}

/** Where a pending decision actually lives. An unknown document type stays on the approvals list. */
export function approvalLink(row: Pick<PendingApproval, 'docType' | 'docId'>): string {
  switch (row.docType) {
    case 'PO':
      return `/procurement/purchase-orders/${row.docId}`;
    case 'WASTE':
      return `/inventory/waste/${row.docId}`;
    case 'COUNT_ADJUST':
      return `/inventory/counts/${row.docId}`;
    default:
      return '/procurement/approvals';
  }
}

/** Re-exported for the dashboard test: the document number cell never loses its `mono` face. */
export { DocNo };
