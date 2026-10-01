import { useEffect, useMemo, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { keepPreviousData, useMutation } from '@tanstack/react-query';
import { Alert, Badge, Button, DocStatusBadge, KpiCard } from '@ds/index';
import { useApiPage, useApiQuery } from '@api/hooks';
import {
  createExport,
  getDashboardSummary,
  listBalances,
  listCategories,
  listPendingApprovals,
  listStockRequests,
  type Balance,
  type Category,
  type DashboardSummary,
  type PendingApproval,
  type StockRequestSummary,
} from '@api/endpoints';
import { normalizeBalance } from '@api/adapters';
import { isApiError } from '@api/problem';
import { settingsUnavailableNote, useInventorySettings } from '@api/settings';
import { useAuth } from '@auth/index';
import { Decimal } from '@core/decimal';
import { daysUntil, formatDate, formatDateTime, formatNumber } from '@core/format';
import { Card, DocNo, ErrorState, Page } from '@/components/Page';
import { CategoryDonut, FlowChart, Sparkline, type FlowDay } from './charts';
import {
  PERIODS,
  PERIOD_PARAM,
  addDays,
  categorySlices,
  cumulative,
  expiryTone,
  fillDays,
  flowScale,
  utcDate,
  windowDays,
  type PeriodDays,
} from './series';

/**
 * Warehouse dashboard — docs/design-system/screens/Main.dc.html (30.09.2026 revision).
 *
 * Top to bottom: the reconciliation strip (only when the server says the nightly check failed),
 * four tinted KPI cards with their trend lines, the inbound/outbound chart beside stock value by
 * category, then the expiring batches beside the decisions waiting on this user.
 *
 * Every figure comes from `GET /reporting/dashboard/summary` for the period chosen in the header;
 * nothing is summed from a page of balances in the browser. Money is bound to
 * `master.product.view_cost` twice over: the server leaves the cost series and `categoryValues`
 * out, and the screen does not render their cards — a keeper sees document counts in the chart's
 * place, not an empty frame (components/KpiCard/README.md, SPEC §16).
 */

const PERIOD_STORAGE_KEY = 'wms.dashboard.period';

function readPeriod(): PeriodDays {
  try {
    const stored = Number(window.localStorage.getItem(PERIOD_STORAGE_KEY));
    return (PERIODS as readonly number[]).includes(stored) ? (stored as PeriodDays) : 14;
  } catch {
    return 14;
  }
}

function writePeriod(period: PeriodDays) {
  try {
    window.localStorage.setItem(PERIOD_STORAGE_KEY, String(period));
  } catch {
    // A private window without storage just forgets the choice.
  }
}

interface ExpiringRow {
  key: string;
  productName: string;
  sku: string;
  batchNo: string;
  daysLeft: number;
  qty: string;
  uom: string;
  location: string;
}

/** Left rule of a pending decision, by what kind of document it is. */
const DOC_TONE: Record<string, string> = {
  PO: 'accent',
  WASTE: 'warning',
  COUNT_ADJUST: 'virtual',
};

export function DashboardScreen() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const { can, session } = useAuth();
  const canViewCost = can('master.product.view_cost');
  // `listPendingApprovals` carries `proc.approval.view`, which the keeper and the branch user do
  // not hold. An element a role has no permission for is not rendered, not shown broken
  // (screen-map §2) — those roles get the stock requests waiting on the warehouse instead.
  const canViewApprovals = can('proc.approval.view');
  const canViewRequests = can('inv.request.view');

  const [period, setPeriodState] = useState<PeriodDays>(readPeriod);
  const setPeriod = (next: PeriodDays) => {
    setPeriodState(next);
    writePeriod(next);
  };

  const summary = useApiQuery<DashboardSummary>(
    ['dashboard', 'summary', period],
    () => getDashboardSummary({ period: PERIOD_PARAM[period] }),
    // Switching the period keeps the previous render on screen, dimmed, until the new one lands.
    { retry: false, placeholderData: keepPreviousData },
  );

  // One place reads `inv_setting`, and it says when it cannot (TOR §36).
  const settings = useInventorySettings('dashboard', { enabled: can('inv.settings.view') });
  const warningDays = settings.get('expiry_warning_days');
  const criticalDays = settings.get('expiry_critical_days');

  const expiringBalances = useApiPage<Balance>(
    ['dashboard', 'expiring', warningDays],
    () =>
      listBalances({
        page: 1,
        size: 200,
        ...(warningDays !== null ? { expiringWithinDays: warningDays } : {}),
      }),
    200,
    { enabled: !settings.isLoading },
  );

  const approvals = useApiPage<PendingApproval>(
    ['dashboard', 'approvals'],
    () => listPendingApprovals({ page: 1, size: 20 }),
    20,
    { retry: false, enabled: canViewApprovals },
  );

  const requests = useApiPage<StockRequestSummary>(
    ['dashboard', 'stock-requests'],
    () => listStockRequests({ status: 'SUBMITTED', page: 1, size: 20 }),
    20,
    { retry: false, enabled: !canViewApprovals && canViewRequests },
  );

  const hasCategoryValues = (summary.data?.categoryValues?.length ?? 0) > 0;
  const categories = useApiPage<Category>(
    ['dashboard', 'categories'],
    () => listCategories(),
    500,
    { enabled: canViewCost && hasCategoryValues, staleTime: 5 * 60_000 },
  );

  const exportJob = useMutation({
    mutationFn: () => createExport({ reportCode: 'STOCK_BALANCE', format: 'XLSX', parameters: {} }),
    onSuccess: () => navigate('/reporting/exports'),
  });

  // "son yenilənmə N dəq əvvəl" has to move while the screen is open.
  const [now, setNow] = useState(() => Date.now());
  useEffect(() => {
    const id = window.setInterval(() => setNow(Date.now()), 30_000);
    return () => window.clearInterval(id);
  }, []);

  const data = summary.data;
  const generatedAt = data?.generatedAt ?? null;
  const today = utcDate(generatedAt ?? new Date(now));
  const dates = useMemo(() => windowDays(today, period), [today, period]);

  const series = (key: string) => data?.series?.find((s) => s.key === key);
  const kpi = (key: string) => data?.kpis?.find((k) => k.key === key);
  const alertCount = (type: string, severity?: string) =>
    (data?.alerts ?? [])
      .filter((a) => a.type === type && (severity === undefined || a.severity === severity))
      .reduce((acc, a) => acc + a.count, 0);

  const trend = (key: string): number | undefined => {
    const pct = kpi(key)?.trendPct;
    return pct === null || pct === undefined ? undefined : new Decimal(pct).toNumber();
  };

  const periodHint = t(`dashboard.periodHint.${period}`);

  // --- chart: money for cost holders, document counts for everyone else -------------------
  const flowIsMoney = canViewCost && series('inboundValuePerDay') !== undefined;
  const flowDays: FlowDay[] = useMemo(() => {
    const inbound = fillDays(
      series(flowIsMoney ? 'inboundValuePerDay' : 'receiptsPerDay')?.points,
      dates,
    );
    const outbound = fillDays(
      series(flowIsMoney ? 'outboundValuePerDay' : 'issuesPerDay')?.points,
      dates,
    );
    return dates.map((date, i) => ({
      date,
      inbound: inbound[i]?.value ?? new Decimal(0),
      outbound: outbound[i]?.value ?? new Decimal(0),
    }));
    // `series` reads `data`; listing it keeps the memo honest without a new closure per render.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [data, dates, flowIsMoney]);
  const flowMax = flowDays.reduce((m, d) => Decimal.max(m, d.inbound, d.outbound), new Decimal(0));
  const flowEmpty = flowMax.isZero();
  const flowUnit = flowIsMoney ? flowScale(flowMax).unit : t('dashboard.flowUnitDocs');

  // --- donut ----------------------------------------------------------------------------------
  const categoryValues = useMemo(() => data?.categoryValues ?? [], [data]);
  const slices = useMemo(
    () =>
      categorySlices(
        categoryValues,
        (categories.data?.items ?? []).map((c) => ({
          id: c.id,
          parentId: c.parentId,
          name: c.name,
        })),
        { uncategorised: t('dashboard.categoryNone'), other: t('dashboard.categoryOther') },
      ),
    [categoryValues, categories.data, t],
  );
  const categoryTotal = categoryValues.reduce(
    (acc, c) => acc.plus(new Decimal(c.value)),
    new Decimal(0),
  );
  const showCategories = canViewCost && data?.categoryValues !== undefined;

  // --- expiring batches -----------------------------------------------------------------------
  const expiring: ExpiringRow[] = useMemo(() => {
    const rows = (expiringBalances.data?.items ?? [])
      .map((raw) => normalizeBalance(raw))
      .map((row) => ({
        key: `${row.product.id}-${row.batch?.id ?? 0}-${row.location.id}`,
        productName: row.product.name,
        sku: row.product.sku,
        batchNo: row.batch?.batchNo ?? '—',
        daysLeft: row.daysToExpiry ?? daysUntil(row.batch?.expiryDate),
        qty: row.qtyOnHand,
        uom: row.baseUomCode,
        location: row.location.name,
        isVirtual: row.location.isVirtual,
        hasExpiry: Boolean(row.batch?.expiryDate),
      }))
      // Already expired stock is not "approaching" — it is counted in the card head and handled
      // on the batches screen. A virtual location (V-WASTE, transit) holds nothing to issue, and the
      // summary leaves those out too, so the table and the KPI count the same stock.
      .filter(
        (row): row is typeof row & { daysLeft: number } =>
          row.hasExpiry &&
          !row.isVirtual &&
          row.daysLeft !== null &&
          row.daysLeft >= 0 &&
          (warningDays === null || row.daysLeft <= warningDays) &&
          new Decimal(row.qty).gt(0),
      )
      .map(({ hasExpiry: _hasExpiry, isVirtual: _isVirtual, ...row }) => row);
    rows.sort((a, b) => a.daysLeft - b.daysLeft);
    return rows.slice(0, 50);
  }, [expiringBalances.data, warningDays]);

  const expiredCount = alertCount('BATCH_EXPIRED');

  // --- KPI sparklines -------------------------------------------------------------------------
  const stockSpark = fillDays(series('stockValuePerDay')?.points, dates).map((d) => d.value);
  const wasteSpark = fillDays(series('wasteValuePerDay')?.points, dates).map((d) => d.value);
  const receiptSpark = fillDays(series('receiptsPerDay')?.points, dates).map((d) => d.value);
  const expiryDates =
    warningDays !== null
      ? windowDays(addDays(today, warningDays), warningDays + 1)
      : [...new Set((series('batchExpiriesAhead')?.points ?? []).map((p) => p.date))].sort();
  const expirySpark = cumulative(fillDays(series('batchExpiriesAhead')?.points, expiryDates)).map(
    (d) => d.value,
  );

  const reconciliationFailed = data?.systemHealth?.balanceReconciliationOk === false;
  const reconciliationCount =
    alertCount('RECONCILIATION_MISMATCH') || alertCount('RECONCILIATION_FAILED');

  const pendingApprovals = [...(approvals.data?.items ?? [])].sort((a, b) =>
    a.waitingSince.localeCompare(b.waitingSince),
  );
  const oldestWaiting = pendingApprovals[0]
    ? Math.max(0, -(daysUntil(pendingApprovals[0].waitingSince) ?? 0))
    : null;

  const relative = generatedAt ? relativeMinutes(generatedAt, now, t) : null;

  return (
    <Page
      title={t('dashboard.title')}
      subtitle={[
        session?.tenantName ?? t('nav.inventory'),
        generatedAt ? formatDateTime(generatedAt) : null,
        relative,
      ]
        .filter(Boolean)
        .join(' · ')}
      contentClassName="wms-dash wms-viz"
      actions={
        <>
          <div className="wms-seg" role="group" aria-label={t('dashboard.periodLabel')}>
            {PERIODS.map((p) => (
              <button
                key={p}
                type="button"
                aria-pressed={period === p}
                onClick={() => setPeriod(p)}
              >
                {t('dashboard.periodDays', { count: p })}
              </button>
            ))}
          </div>
          {can('rpt.export.create') ? (
            <Button
              variant="secondary"
              onClick={() => exportJob.mutate()}
              disabled={exportJob.isPending}
              title={t('dashboard.exportHint')}
            >
              {t('dashboard.export')}
            </Button>
          ) : null}
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
        <div className="wms-strip wms-strip--danger" role="alert">
          <span className="wms-strip__icon" aria-hidden="true">
            !
          </span>
          <span className="wms-strip__text">
            <b>{t('dashboard.reconciliationTitle')}</b> —{' '}
            {t('dashboard.reconciliationBody', { count: reconciliationCount })}{' '}
            <span className="wms-num wms-strip__code">RECONCILIATION_MISMATCH</span>
          </span>
          <Link to="/inventory/movements" className="wms-strip__link">
            {t('dashboard.reconciliationLink')}
          </Link>
        </div>
      ) : null}

      {exportJob.isError ? (
        <Alert
          tone="danger"
          title={t('dashboard.exportFailed')}
          code={isApiError(exportJob.error) ? (exportJob.error.code ?? undefined) : undefined}
          onClose={() => exportJob.reset()}
        >
          {exportJob.error instanceof Error ? exportJob.error.message : null}
        </Alert>
      ) : null}

      {settings.unavailable ? (
        <Alert
          tone="warning"
          title="Hədlər tenant parametrindən oxunmadı"
          code={settings.code ?? undefined}
        >
          {settingsUnavailableNote(settings.status)}
        </Alert>
      ) : null}

      {summary.isError ? (
        <Card>
          <ErrorState error={summary.error} onRetry={() => void summary.refetch()} />
        </Card>
      ) : null}

      <div
        className={summary.isPlaceholderData ? 'wms-dash__live is-refreshing' : 'wms-dash__live'}
        aria-busy={summary.isFetching}
      >
        <div className="wms-grid wms-grid--kpi">
          {canViewCost ? (
            <KpiCard
              tone="accent"
              label={t('dashboard.kpiStockValue')}
              value={kpi('stockValueTotal') ? formatNumber(kpi('stockValueTotal')?.value, 2) : '—'}
              unit="AZN"
              delta={trend('stockValueTotal')}
              deltaUnit="%"
              hint={trend('stockValueTotal') === undefined ? t('dashboard.noTrend') : periodHint}
              spark={
                series('stockValuePerDay') ? (
                  <Sparkline
                    values={stockSpark}
                    color="var(--accent)"
                    ring="var(--accent-soft)"
                    label={t('dashboard.sparkStock', { days: period })}
                  />
                ) : undefined
              }
            />
          ) : (
            <KpiCard
              tone="accent"
              label={t('dashboard.kpiOpenRequests')}
              value={kpi('openStockRequests')?.value ?? '—'}
              unit={t('dashboard.unitDocs')}
              hint={t('dashboard.kpiOpenRequestsHint')}
            />
          )}

          {canViewApprovals ? (
            <KpiCard
              tone="warning"
              label={t('dashboard.pendingApprovals')}
              value={approvals.data?.total ?? '—'}
              unit={t('dashboard.unitDocs')}
              hint={
                oldestWaiting === null
                  ? t('dashboard.kpiPendingEmptyHint')
                  : t('dashboard.oldestWaiting', { days: oldestWaiting })
              }
            />
          ) : (
            <KpiCard
              tone="warning"
              label={t('dashboard.kpiPendingDocs')}
              value={kpi('pendingApprovals')?.value ?? '—'}
              unit={t('dashboard.unitDocs')}
              hint={t('dashboard.kpiPendingHint')}
            />
          )}

          <KpiCard
            tone="virtual"
            label={
              warningDays === null
                ? t('dashboard.kpiExpiringFallback')
                : t('dashboard.kpiExpiring', { days: warningDays })
            }
            value={kpi('expiringBatches')?.value ?? '—'}
            unit={t('dashboard.kpiExpiringUnit')}
            badge={
              alertCount('BATCH_EXPIRING', 'CRITICAL') > 0 && criticalDays !== null ? (
                <span className="wms-kpi__alarm">
                  {t('dashboard.kpiExpiringCritical', {
                    count: alertCount('BATCH_EXPIRING', 'CRITICAL'),
                    days: criticalDays,
                  })}
                </span>
              ) : undefined
            }
            hint={
              alertCount('BATCH_EXPIRING', 'CRITICAL') > 0 && criticalDays !== null
                ? undefined
                : t('dashboard.kpiExpiringCalm')
            }
            spark={
              series('batchExpiriesAhead') ? (
                <Sparkline
                  values={expirySpark}
                  color="var(--virtual-location)"
                  ring="var(--virtual-location-soft)"
                  label={t('dashboard.sparkExpiry')}
                />
              ) : undefined
            }
          />

          {canViewCost && kpi('wasteValuePeriod') ? (
            <KpiCard
              tone="success"
              label={t(`dashboard.kpiWaste.${period}`)}
              value={formatNumber(kpi('wasteValuePeriod')?.value, 2)}
              unit="AZN"
              delta={trend('wasteValuePeriod')}
              deltaUnit="%"
              // Less waste is the good direction.
              deltaTone={
                trend('wasteValuePeriod') === undefined
                  ? undefined
                  : (trend('wasteValuePeriod') ?? 0) <= 0
                    ? 'up'
                    : 'down'
              }
              hint={trend('wasteValuePeriod') === undefined ? t('dashboard.noTrend') : periodHint}
              spark={
                series('wasteValuePerDay') ? (
                  <Sparkline
                    values={wasteSpark}
                    color="var(--success)"
                    ring="var(--success-soft)"
                    label={t('dashboard.sparkWaste', { days: period })}
                  />
                ) : undefined
              }
            />
          ) : (
            <KpiCard
              tone="success"
              label={t('dashboard.kpiReceipts', { days: period })}
              value={kpi('receiptsInPeriod')?.value ?? '—'}
              unit={t('dashboard.unitDocs')}
              delta={trend('receiptsInPeriod')}
              deltaUnit="%"
              hint={trend('receiptsInPeriod') === undefined ? t('dashboard.noTrend') : periodHint}
              spark={
                series('receiptsPerDay') ? (
                  <Sparkline
                    values={receiptSpark}
                    color="var(--success)"
                    ring="var(--success-soft)"
                    label={t('dashboard.sparkReceipts', { days: period })}
                  />
                ) : undefined
              }
            />
          )}
        </div>

        <div
          className={showCategories ? 'wms-dash__charts' : 'wms-dash__charts wms-dash__charts--one'}
        >
          <Card
            title={t(flowIsMoney ? 'dashboard.flowTitle' : 'dashboard.flowTitleDocs', {
              days: period,
            })}
            subtitle={t(flowIsMoney ? 'dashboard.flowSub' : 'dashboard.flowSubDocs', {
              unit: flowUnit,
            })}
            actions={
              <div className="wms-legend">
                <span>
                  <i style={{ background: 'var(--viz-in)' }} />
                  {t(flowIsMoney ? 'dashboard.flowIn' : 'dashboard.flowInDocs')}
                </span>
                <span>
                  <i style={{ background: 'var(--viz-out)' }} />
                  {t('dashboard.flowOut')}
                </span>
              </div>
            }
          >
            {data && !flowEmpty ? (
              <FlowChart
                days={flowDays}
                money={flowIsMoney}
                labels={{
                  inbound: t(flowIsMoney ? 'dashboard.flowIn' : 'dashboard.flowInDocs'),
                  outbound: t('dashboard.flowOut'),
                  net: t('dashboard.flowNet'),
                  caption: t(flowIsMoney ? 'dashboard.flowTitle' : 'dashboard.flowTitleDocs', {
                    days: period,
                  }),
                  docs: t('dashboard.unitDocs'),
                }}
              />
            ) : (
              <div className="wms-dash__empty">
                {data ? t('dashboard.flowEmpty', { days: period }) : ' '}
              </div>
            )}
          </Card>

          {showCategories ? (
            <Card title={t('dashboard.categoryTitle')} subtitle={t('dashboard.categorySub')}>
              {slices.length > 0 ? (
                <CategoryDonut
                  slices={slices}
                  total={categoryTotal}
                  label={t('dashboard.categoryTitle')}
                />
              ) : (
                <div className="wms-dash__empty">{t('dashboard.categoryEmpty')}</div>
              )}
            </Card>
          ) : null}
        </div>
      </div>

      <div className="wms-split wms-dash__lists">
        <Card
          title={t('dashboard.expiringTitle')}
          subtitle={
            warningDays !== null && criticalDays !== null ? (
              <span className="wms-num">
                expiry_warning_days = {warningDays} · expiry_critical_days = {criticalDays}
              </span>
            ) : (
              t('dashboard.expiringSubFallback')
            )
          }
          actions={
            <>
              {expiredCount > 0 ? (
                <Link to="/inventory/batches" className="wms-dash__expired">
                  <Badge tone="danger" dot>
                    {t('dashboard.expiredBadge', { count: expiredCount })}
                  </Badge>
                </Link>
              ) : null}
              <Link to="/inventory/batches" className="wms-card__link">
                {t('common.seeAll')}
              </Link>
            </>
          }
          flush
        >
          {expiringBalances.isError ? (
            <div className="wms-card__body">
              <ErrorState
                error={expiringBalances.error}
                onRetry={() => void expiringBalances.refetch()}
              />
            </div>
          ) : expiring.length === 0 ? (
            <div className="wms-dash__empty">
              {expiringBalances.isLoading ? ' ' : t('dashboard.expiringEmpty')}
            </div>
          ) : (
            <div className="wms-dash__scroll">
              <table className="wms-dtable">
                <thead>
                  <tr>
                    <th scope="col">{t('dashboard.colProduct')}</th>
                    <th scope="col">{t('dashboard.colBatch')}</th>
                    <th scope="col" className="wms-dtable__num">
                      {t('dashboard.colQty')}
                    </th>
                    <th scope="col">{t('dashboard.colLocation')}</th>
                    <th scope="col" className="wms-dtable__days">
                      {t('dashboard.colDaysLeft')}
                    </th>
                  </tr>
                </thead>
                <tbody>
                  {expiring.map((row) => {
                    const tone = expiryTone(row.daysLeft, criticalDays, warningDays);
                    const fill =
                      warningDays && warningDays > 0
                        ? Math.max(4, Math.min(100, (row.daysLeft / warningDays) * 100))
                        : null;
                    return (
                      <tr key={row.key}>
                        <td title={row.sku}>{row.productName}</td>
                        <td className="wms-num">{row.batchNo}</td>
                        <td className="wms-dtable__num wms-num">
                          {formatNumber(row.qty, 3)}
                          <span className="wms-dtable__uom">{row.uom}</span>
                        </td>
                        <td>{row.location}</td>
                        <td>
                          <span className={`wms-pill wms-pill--${tone}`}>
                            {t('dashboard.daysLeft', { count: row.daysLeft })}
                          </span>
                          {fill !== null ? (
                            <div className="wms-meter" aria-hidden="true">
                              <i
                                className={`wms-meter__fill--${tone}`}
                                style={{ width: `${fill}%` }}
                              />
                            </div>
                          ) : null}
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          )}
        </Card>

        {canViewApprovals ? (
          <Card
            title={t('dashboard.pendingApprovals')}
            actions={
              (approvals.data?.total ?? 0) > 0 ? (
                <Badge tone="warning" dot>
                  {formatNumber(approvals.data?.total ?? 0, 0)}
                </Badge>
              ) : undefined
            }
            flush
          >
            {approvals.isError ? (
              approvals.error.status === 404 || approvals.error.status === 405 ? (
                // One muted line rather than a second Alert. The route and status go in a data
                // attribute for whoever builds the endpoint; the reader gets a sentence.
                <div
                  className="wms-dash__empty"
                  data-wms-operation={`GET /procurement/approvals/pending → ${approvals.error.status}`}
                >
                  {t('state.notImplementedBody')}
                </div>
              ) : (
                <div className="wms-card__body">
                  <ErrorState error={approvals.error} onRetry={() => void approvals.refetch()} />
                </div>
              )
            ) : pendingApprovals.length === 0 ? (
              <div className="wms-dash__empty">
                {approvals.isLoading ? ' ' : t('dashboard.pendingEmpty')}
              </div>
            ) : (
              <div className="wms-dash__scroll wms-aplist">
                {pendingApprovals.map((row) => (
                  <div
                    className={`wms-aplist__row wms-aplist__row--${DOC_TONE[row.docType] ?? 'accent'}`}
                    key={row.approvalId}
                  >
                    <div className="wms-aplist__main">
                      <div className="wms-aplist__title">
                        <DocNo value={row.docNo} />
                        <DocStatusBadge status="PENDING_APPROVAL" />
                      </div>
                      <div className="wms-aplist__meta">
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
        ) : canViewRequests ? (
          <Card
            title={t('dashboard.requestsTitle')}
            subtitle={t('dashboard.requestsSub')}
            actions={
              (requests.data?.total ?? 0) > 0 ? (
                <Badge tone="warning" dot>
                  {formatNumber(requests.data?.total ?? 0, 0)}
                </Badge>
              ) : undefined
            }
            flush
          >
            {requests.isError ? (
              <div className="wms-card__body">
                <ErrorState error={requests.error} onRetry={() => void requests.refetch()} />
              </div>
            ) : (requests.data?.items ?? []).length === 0 ? (
              <div className="wms-dash__empty">
                {requests.isLoading ? ' ' : t('dashboard.requestsEmpty')}
              </div>
            ) : (
              <div className="wms-dash__scroll wms-aplist">
                {(requests.data?.items ?? []).map((row) => {
                  const due = row.requiredDate ? daysUntil(row.requiredDate) : null;
                  const late = due !== null && due < 0;
                  return (
                    <div
                      className={`wms-aplist__row wms-aplist__row--${late ? 'danger' : 'accent'}`}
                      key={row.id}
                    >
                      <div className="wms-aplist__main">
                        <div className="wms-aplist__title">
                          <DocNo value={row.docNo} />
                          <DocStatusBadge status={row.status} />
                        </div>
                        <div className="wms-aplist__meta">
                          {[
                            row.toLocation.name,
                            row.lineCount !== undefined
                              ? t('dashboard.requestLines', { count: row.lineCount })
                              : null,
                            row.requiredDate
                              ? t('dashboard.requiredBy', { date: formatDate(row.requiredDate) })
                              : null,
                          ]
                            .filter(Boolean)
                            .join(' · ')}
                          {late ? (
                            <>
                              {' · '}
                              <b className="wms-aplist__late">
                                {t('dashboard.lateBy', { days: -(due ?? 0) })}
                              </b>
                            </>
                          ) : null}
                        </div>
                      </div>
                      <Link
                        to={`/inventory/stock-requests/${row.id}`}
                        className="wms-btn wms-btn--secondary wms-btn--sm"
                        aria-label={`${row.docNo} — ${t('common.view')}`}
                      >
                        {t('common.view')}
                      </Link>
                    </div>
                  );
                })}
              </div>
            )}
          </Card>
        ) : null}
      </div>
    </Page>
  );
}

function relativeMinutes(
  generatedAt: string,
  now: number,
  t: (key: string, options?: Record<string, unknown>) => string,
): string {
  const minutes = Math.max(0, Math.floor((now - new Date(generatedAt).getTime()) / 60_000));
  if (minutes < 1) return t('dashboard.updatedJustNow');
  if (minutes < 60) return t('dashboard.updatedMinutesAgo', { count: minutes });
  return t('dashboard.updatedHoursAgo', { count: Math.floor(minutes / 60) });
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
