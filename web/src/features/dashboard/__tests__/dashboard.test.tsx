import { beforeAll, beforeEach, describe, expect, it, vi } from 'vitest';
import { render, screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import '@/i18n';

/**
 * The dashboard against a mocked summary: every figure on it has to come from
 * `GET /reporting/dashboard/summary` for the chosen period, and nothing that costs money may be
 * rendered for a role without `master.product.view_cost` — not masked, absent.
 */

const TODAY = '2026-09-30';

const SUMMARY_COST = {
  generatedAt: `${TODAY}T09:40:00Z`,
  locationId: null,
  kpis: [
    {
      key: 'stockValueTotal',
      label: 'Anbar dəyəri',
      value: '284150.4200',
      unit: 'AZN',
      trendPct: '3.8000',
      isCost: true,
    },
    { key: 'pendingApprovals', label: 'Təsdiq', value: '3', isCost: false },
    { key: 'expiringBatches', label: 'Partiya', value: '14', unit: 'batches', isCost: false },
    { key: 'openStockRequests', label: 'Tələb', value: '5', isCost: false },
    { key: 'receiptsInPeriod', label: 'Qəbul', value: '9', trendPct: null, isCost: false },
    {
      key: 'wasteValuePeriod',
      label: 'Tullantı',
      value: '1284.5000',
      unit: 'AZN',
      trendPct: '-12.4000',
      isCost: true,
    },
  ],
  alerts: [
    { type: 'BATCH_EXPIRING', severity: 'CRITICAL', count: 3, title: '3 partiya' },
    { type: 'BATCH_EXPIRED', severity: 'CRITICAL', count: 2, title: '2 partiya' },
  ],
  series: [
    { key: 'receiptsPerDay', label: '', points: [{ date: TODAY, value: '2' }] },
    { key: 'issuesPerDay', label: '', points: [{ date: TODAY, value: '1' }] },
    {
      key: 'inboundValuePerDay',
      label: '',
      unit: 'AZN',
      isCost: true,
      points: [{ date: '2026-09-28', value: '21400' }],
    },
    {
      key: 'outboundValuePerDay',
      label: '',
      unit: 'AZN',
      isCost: true,
      points: [{ date: '2026-09-28', value: '14600' }],
    },
    {
      key: 'stockValuePerDay',
      label: '',
      unit: 'AZN',
      isCost: true,
      points: [{ date: TODAY, value: '284150.42' }],
    },
    { key: 'wasteValuePerDay', label: '', unit: 'AZN', isCost: true, points: [] },
    { key: 'batchExpiriesAhead', label: '', points: [{ date: '2026-10-05', value: '3' }] },
  ],
  categoryValues: [
    { categoryId: 3, value: '96300.00' },
    { categoryId: 4, value: '62200.00' },
    { categoryId: null, value: '1000.00' },
  ],
};

/** What the server sends a keeper: no cost KPI, no cost series, no `categoryValues` key at all. */
const SUMMARY_PLAIN = {
  ...SUMMARY_COST,
  kpis: SUMMARY_COST.kpis.filter((k) => !k.isCost),
  series: SUMMARY_COST.series.filter((s) => !('isCost' in s) || !s.isCost),
  categoryValues: undefined,
};

const page = (items: unknown[]) => ({ items, page: 1, size: 50, total: items.length });

const mocks = {
  getDashboardSummary: vi.fn(async (): Promise<unknown> => SUMMARY_COST),
  listInventorySettings: vi.fn(async () =>
    page([
      { key: 'expiry_warning_days', value: '30' },
      { key: 'expiry_critical_days', value: '7' },
    ]),
  ),
  listBalances: vi.fn(async () =>
    page([
      {
        product: { id: 1, sku: 'BSB', name: 'Bread Stick Black', baseUomId: 1, baseUomCode: 'PCS' },
        location: { id: 1, code: 'WH', name: 'Food WH', isVirtual: false },
        batch: { id: 5, batchNo: 'BSB-2509-A', expiryDate: '2026-10-05', status: 'ACTIVE' },
        daysToExpiry: 5,
        qtyOnHand: '96.0000',
      },
      {
        product: { id: 2, sku: 'OLD', name: 'Köhnə partiya', baseUomId: 1, baseUomCode: 'PCS' },
        location: { id: 1, code: 'WH', name: 'Food WH', isVirtual: false },
        batch: { id: 6, batchNo: 'OLD-1', expiryDate: '2026-09-25', status: 'ACTIVE' },
        daysToExpiry: -5,
        qtyOnHand: '10.0000',
      },
    ]),
  ),
  listPendingApprovals: vi.fn(async () =>
    page([
      {
        approvalId: 1,
        stepId: 1,
        docType: 'PO',
        docId: 87,
        docNo: 'PO-2026-00087',
        stepNo: 1,
        amountBase: '48240.0000',
        summary: 'Azərsun MMC',
        waitingSince: '2026-09-28T08:00:00Z',
      },
    ]),
  ),
  listStockRequests: vi.fn(async () => page([])),
  listCategories: vi.fn(async () => [
    {
      id: 3,
      parentId: null,
      code: 'MEAT',
      name: 'Ət və toyuq',
      productType: 'FOOD',
      path: '/MEAT',
      isActive: true,
      rowVersion: 1,
    },
    {
      id: 4,
      parentId: null,
      code: 'DAIRY',
      name: 'Süd məhsulları',
      productType: 'FOOD',
      path: '/DAIRY',
      isActive: true,
      rowVersion: 1,
    },
  ]),
  createExport: vi.fn(async () => ({ id: 1, status: 'QUEUED' })),
};

vi.mock('@api/endpoints', async () => {
  const actual = await vi.importActual<Record<string, unknown>>('@api/endpoints');
  return { ...actual, ...mocks };
});

beforeAll(() => {
  Object.defineProperty(window, 'matchMedia', {
    writable: true,
    value: (query: string) => ({
      matches: false,
      media: query,
      onchange: null,
      addEventListener: () => {},
      removeEventListener: () => {},
      addListener: () => {},
      removeListener: () => {},
      dispatchEvent: () => false,
    }),
  });
});

beforeEach(() => {
  for (const fn of Object.values(mocks)) fn.mockClear();
  mocks.getDashboardSummary.mockImplementation(async () => SUMMARY_COST);
  window.localStorage.clear();
});

async function mount(permissions: string[], { settings = true }: { settings?: boolean } = {}) {
  const { DashboardScreen } = await import('../DashboardScreen');
  const { TestAuthProvider } = await import('@auth/AuthContext');
  const client = new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: 0 }, mutations: { retry: false } },
  });
  render(
    <QueryClientProvider client={client}>
      <TestAuthProvider
        session={{
          tenantId: 1,
          username: 'u',
          subject: 's',
          roles: [],
          permissions: [
            'rpt.dashboard.view',
            'inv.balance.view',
            ...(settings ? ['inv.settings.view'] : []),
            ...permissions,
          ],
          permissionSource: 'server',
          accessToken: 't',
          tenantName: 'Subway AZ',
        }}
      >
        <MemoryRouter>
          <DashboardScreen />
        </MemoryRouter>
      </TestAuthProvider>
    </QueryClientProvider>,
  );
}

describe('DashboardScreen', () => {
  it('asks for fourteen days by default and switches the period from the header', async () => {
    await mount(['master.product.view_cost']);
    await waitFor(() =>
      expect(mocks.getDashboardSummary).toHaveBeenCalledWith({ period: 'TWO_WEEKS' }),
    );
    const group = screen.getByRole('group', { name: 'Dövr' });
    expect(within(group).getByRole('button', { name: '14 gün' })).toHaveAttribute(
      'aria-pressed',
      'true',
    );
    await userEvent.click(within(group).getByRole('button', { name: '30 gün' }));
    await waitFor(() =>
      expect(mocks.getDashboardSummary).toHaveBeenCalledWith({ period: 'MONTH' }),
    );
  });

  it('shows the cost figures, the ledger-value chart and the category split to a cost holder', async () => {
    await mount(['master.product.view_cost', 'proc.approval.view']);
    expect(await screen.findByText('284 150,42')).toBeInTheDocument();
    expect(
      screen.getByRole('heading', { name: 'Mədaxil və məxaric — son 14 gün' }),
    ).toBeInTheDocument();
    expect(screen.getByText('min AZN · ledger hərəkətləri, gün üzrə')).toBeInTheDocument();
    // The tallest inflow carries its own figure, in thousands.
    expect(screen.getByText('+21,4')).toBeInTheDocument();
    expect(await screen.findByText('Ət və toyuq')).toBeInTheDocument();
    expect(screen.getByText('Kateqoriyasız')).toBeInTheDocument();
    // Falling waste is good news: the delta is green, and it reads −12,4.
    expect(screen.getByText('−12,4', { exact: false }).closest('.wms-delta')).toHaveClass(
      'wms-delta--up',
    );
  });

  it('renders no money at all for a role without view_cost — counts take the chart', async () => {
    mocks.getDashboardSummary.mockImplementation(async () => SUMMARY_PLAIN);
    await mount(['inv.request.view']);
    expect(
      await screen.findByRole('heading', { name: 'Qəbul və məxaric — son 14 gün' }),
    ).toBeInTheDocument();
    expect(screen.queryByText('Anbar dəyəri')).toBeNull();
    expect(screen.queryByText('Kateqoriya üzrə dəyər')).toBeNull();
    expect(screen.queryByText(/AZN/)).toBeNull();
    expect(mocks.listCategories).not.toHaveBeenCalled();
    // No approval permission: the stock requests waiting on the warehouse take that card.
    expect(mocks.listPendingApprovals).not.toHaveBeenCalled();
    expect(screen.getByText('Gözləyən filial tələbləri')).toBeInTheDocument();
  });

  it('lists only batches still inside the window, and counts the expired ones in the head', async () => {
    await mount(['master.product.view_cost']);
    expect(await screen.findByText('Bread Stick Black')).toBeInTheDocument();
    expect(screen.queryByText('Köhnə partiya')).toBeNull();
    expect(screen.getByText('2 vaxtı keçib')).toBeInTheDocument();
    expect(mocks.listBalances).toHaveBeenCalledWith(
      expect.objectContaining({ expiringWithinDays: 30 }),
    );
    expect(screen.getByText('5 gün')).toHaveClass('wms-pill--danger');
  });

  it('puts the decisions waiting on this user on the right, with their document links', async () => {
    await mount(['master.product.view_cost', 'proc.approval.view']);
    const link = await screen.findByRole('link', { name: 'PO-2026-00087 — Bax' });
    expect(link).toHaveAttribute('href', '/procurement/purchase-orders/87');
  });
});

describe('DashboardScreen without inv.settings.view', () => {
  it('does not ask for the settings and shows no 403 notice about them', async () => {
    await mount(['master.product.view_cost'], { settings: false });
    expect(await screen.findByText('Bread Stick Black')).toBeInTheDocument();
    expect(mocks.listInventorySettings).not.toHaveBeenCalled();
    expect(screen.queryByText('Hədlər tenant parametrindən oxunmadı')).toBeNull();
    expect(screen.getByText('ən yaxın son istifadə tarixləri')).toBeInTheDocument();
    // No threshold, no colour: the pill says the days and nothing more.
    expect(screen.getByText('5 gün')).toHaveClass('wms-pill--neutral');
  });
});
