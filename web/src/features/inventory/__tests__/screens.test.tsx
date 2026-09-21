import { beforeAll, beforeEach, describe, expect, it, vi } from 'vitest';
import { render, screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import type { ReactElement } from 'react';

/**
 * Screen-level tests: a warehouse screen mounted against a mocked query client.
 *
 * The 245 tests this suite grew from covered the design system, formatting, auth and helpers —
 * nothing mounted a feature screen, so a screen could render the wrong permission gate, a dead
 * route or an empty picker and every test stayed green. These mount the real screens with the
 * real route table and assert the things the audit found broken:
 *
 *   · `/inventory/waste/:id` resolves to the waste document, not `NotFoundScreen`;
 *   · the waste document offers the submit → approve → post cycle the backend serves, gated on
 *     the permission each operation really needs;
 *   · return to vendor exists at all, and its send / close actions are wired;
 *   · the ledger offers «Storno et», and refuses it on a group already reversed;
 *   · the reason-code control explains itself instead of rendering an empty dropdown;
 *   · the stock-request primary button matches the route it navigates to;
 *   · `/` is permission-guarded;
 *   · a cost column is absent for the keeper, not masked.
 *
 * `@api/endpoints` is mocked wholesale: these are interface tests, and the wire shapes are
 * already covered by the client and adapter tests.
 */

vi.mock('@api/endpoints', async () => {
  const actual = await vi.importActual<Record<string, unknown>>('@api/endpoints');
  return { ...actual, ...mocks };
});

/** The `{ items, page, size, total }` envelope every list endpoint answers with (SPEC §13.4). */
const page = (items: unknown[]) => ({ items, page: 1, size: 50, total: items.length });

const WASTE_LIST = [
  {
    id: 67,
    docNo: 'WS-2026-00067',
    docDate: '2026-09-21',
    location: { id: 1, code: 'WH-01', name: 'Mərkəzi anbar', isVirtual: false },
    reasonCodeId: 6,
    reasonCodeName: 'Zədələnmiş',
    status: 'PENDING_APPROVAL',
    totalValue: '48.5600',
    lineCount: 1,
    rowVersion: 2,
  },
];

const WASTE_DOC = {
  ...WASTE_LIST[0],
  approvalComment: null,
  approvedAt: null,
  approvedBy: null,
  attachmentIds: [11],
  movementGroupId: null,
  note: 'soyuducu sıradan çıxıb',
  lines: [
    {
      id: 1,
      lineNo: 1,
      product: { id: 6, sku: 'ONION', name: 'Soğan', baseUomId: 1, baseUomCode: 'G' },
      qty: '5.0000',
      uomId: 1,
      uomCode: 'G',
      qtyBase: '5.0000',
      unitCost: '0.0112',
      totalValue: '48.5600',
      note: null,
    },
  ],
  audit: { createdAt: '2026-09-21T15:06:07Z', createdBy: 0, rowVersion: 2 },
};

const RTV_DOC = {
  id: 2,
  docNo: 'RV-2026-00002',
  docDate: '2026-09-21',
  supplierId: 1,
  supplierName: 'Baku Food Supply',
  location: { id: 1, code: 'WH-01', name: 'Mərkəzi anbar', isVirtual: false },
  reasonCodeId: 9,
  claimAmount: { amount: '40.0000', currency: 'AZN' },
  status: 'DRAFT',
  rowVersion: 1,
  movementGroupId: null,
  outcome: null,
  outcomeNote: null,
  note: null,
  attachmentIds: [],
  lines: [
    {
      id: 2,
      lineNo: 1,
      product: { id: 6, sku: 'ONION', name: 'Soğan', baseUomId: 1, baseUomCode: 'G' },
      qty: '6.0000',
      uomId: 1,
      uomCode: 'G',
      qtyBase: '6.0000',
      note: null,
    },
  ],
  audit: { createdAt: '2026-09-21T16:01:24Z', createdBy: 0, rowVersion: 1 },
};

const GROUP = {
  id: 28,
  docNo: 'WS-2026-00067',
  docType: 'WASTE',
  docDate: '2026-09-21',
  postedAt: '2026-09-21T15:06:08Z',
  postedBy: 0,
  sourceDocType: 'WASTE',
  sourceDocId: 67,
  reversesGroupId: null,
  reversedByGroupId: null,
  note: null,
  lines: [
    {
      id: 1,
      groupId: 28,
      lineNo: 1,
      docType: 'WASTE',
      docNo: 'WS-2026-00067',
      product: { id: 6, sku: 'ONION', name: 'Soğan', baseUomId: 1, baseUomCode: 'G' },
      location: { id: 1, code: 'WH-01', name: 'Mərkəzi anbar', isVirtual: false },
      qtyBase: '-5.0000',
      baseUomId: 1,
      enteredQty: '5.0000',
      enteredUomId: 1,
      conversionRate: '1',
      postedAt: '2026-09-21T15:06:08Z',
      postedBy: 0,
    },
    {
      id: 2,
      groupId: 28,
      lineNo: 2,
      docType: 'WASTE',
      docNo: 'WS-2026-00067',
      product: { id: 6, sku: 'ONION', name: 'Soğan', baseUomId: 1, baseUomCode: 'G' },
      location: { id: 900, code: 'V_WASTE', name: 'Tullantı', isVirtual: true },
      qtyBase: '5.0000',
      baseUomId: 1,
      enteredQty: '5.0000',
      enteredUomId: 1,
      conversionRate: '1',
      postedAt: '2026-09-21T15:06:08Z',
      postedBy: 0,
    },
  ],
};

const notRouted = async () => {
  const { ApiError } = await import('@api/problem');
  throw new ApiError({
    type: 'about:blank',
    title: 'Not Found',
    status: 404,
    code: 'NOT_FOUND',
  });
};

const mocks = {
  listWaste: vi.fn(async () => page(WASTE_LIST)),
  getWaste: vi.fn(async () => WASTE_DOC),
  submitWaste: vi.fn(async () => WASTE_DOC),
  decideWaste: vi.fn(async () => WASTE_DOC),
  postWaste: vi.fn(async () => WASTE_DOC),
  listSamples: vi.fn(async () => page([])),
  getSample: vi.fn(async () => ({ ...WASTE_DOC, authority: 'AQTA', status: 'DRAFT' })),
  postSample: vi.fn(async () => WASTE_DOC),
  listReturnsToVendor: vi.fn(async (): Promise<ReturnType<typeof page>> => page([RTV_DOC])),
  getReturnToVendor: vi.fn(async (): Promise<Record<string, unknown>> => RTV_DOC),
  sendReturnToVendor: vi.fn(async () => ({ ...RTV_DOC, status: 'SENT' })),
  closeReturnToVendor: vi.fn(async () => ({ ...RTV_DOC, status: 'CLOSED' })),
  createReturnToVendor: vi.fn(async () => RTV_DOC),
  getMovementGroup: vi.fn(async (): Promise<Record<string, unknown>> => GROUP),
  reverseMovementGroup: vi.fn(async () => ({ ...GROUP, id: 30, reversesGroupId: 28 })),
  listStockRequests: vi.fn(async () => page([])),
  getStockRequest: vi.fn(async () => ({})),
  listGoodsReceipts: vi.fn(async () => page([])),
  listBatches: vi.fn(async (): Promise<ReturnType<typeof page>> => page([])),
  listBalances: vi.fn(async () => page([])),
  listCounts: vi.fn(async () => page([])),
  listMovements: vi.fn(async () => page([])),
  listProducts: vi.fn(async () => page([])),
  listLocations: vi.fn(async () => page([])),
  listSuppliers: vi.fn(notRouted),
  listUoms: vi.fn(notRouted),
  // The reason-code list is the one the audit calls out: unrouted on the gateway today.
  listReasonCodes: vi.fn(notRouted),
  listInventorySettings: vi.fn(notRouted),
  listPendingApprovals: vi.fn(notRouted),
  getDashboardSummary: vi.fn(notRouted),
  getTenant: vi.fn(async () => ({ id: 1, code: 'SUBWAY', name: 'Subway AZ' })),
};

// jsdom has no matchMedia and the shell's ThemeProvider asks for it on mount.
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
});

async function mountAt(path: string, roles: string[]): Promise<void> {
  const { AppRoutes } = await import('@app/routes');
  const { ThemeProvider } = await import('@app/theme');
  const { TestAuthProvider } = await import('@auth/AuthContext');
  const { permissionsForRoles } = await import('@auth/permissions');

  const client = new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: 0 }, mutations: { retry: false } },
  });

  const session = {
    tenantId: 1,
    username: roles[0]?.toLowerCase() ?? 'anon',
    subject: 'sub',
    roles,
    permissions: permissionsForRoles(roles),
    accessToken: 'token',
  };

  const ui: ReactElement = (
    <QueryClientProvider client={client}>
      <TestAuthProvider session={session}>
        <ThemeProvider>
          <MemoryRouter initialEntries={[path]}>
            <AppRoutes />
          </MemoryRouter>
        </ThemeProvider>
      </TestAuthProvider>
    </QueryClientProvider>
  );
  render(ui);
}

describe('waste document route', () => {
  it('resolves /inventory/waste/:id instead of falling through to NotFound', async () => {
    // The dashboard's pending-approval link for a WASTE document points exactly here.
    await mountAt('/inventory/waste/67', ['ADMIN']);
    await waitFor(() => expect(screen.getByText('WS-2026-00067')).toBeInTheDocument());
    expect(screen.queryByText(/Səhifə tapılmadı|tapılmadı \(404\)/)).toBeNull();
    expect(mocks.getWaste).toHaveBeenCalledWith(67);
  });

  it('offers the cycle the backend serves, in the state the document is in', async () => {
    await mountAt('/inventory/waste/67', ['ADMIN']);
    await waitFor(() => expect(screen.getByText('WS-2026-00067')).toBeInTheDocument());
    // PENDING_APPROVAL: decide, not submit and not post.
    expect(screen.getAllByRole('button', { name: 'Təsdiqlə' }).length).toBeGreaterThan(0);
    expect(screen.getByRole('button', { name: 'Rədd et' })).toBeEnabled();
    expect(screen.queryByRole('button', { name: 'Təsdiqə göndər' })).toBeNull();
    expect(screen.queryByRole('button', { name: 'Post et' })).toBeNull();
  });

  it('sends the approval with the row version the document carries', async () => {
    const user = userEvent.setup();
    await mountAt('/inventory/waste/67', ['ADMIN']);
    await waitFor(() => expect(screen.getByText('WS-2026-00067')).toBeInTheDocument());
    await user.click(screen.getAllByRole('button', { name: 'Təsdiqlə' })[0] as HTMLElement);
    const dialog = await screen.findByRole('dialog');
    await user.click(within(dialog).getByRole('button', { name: 'Təsdiqlə' }));
    await waitFor(() => expect(mocks.decideWaste).toHaveBeenCalled());
    expect(mocks.decideWaste).toHaveBeenCalledWith(67, 2, 'APPROVED', undefined);
  });

  it('refuses the decision to a keeper, who may post but not approve', async () => {
    await mountAt('/inventory/waste/67', ['WAREHOUSE_KEEPER']);
    await waitFor(() => expect(screen.getByText('WS-2026-00067')).toBeInTheDocument());
    expect(screen.getByRole('button', { name: 'Təsdiqlə' })).toBeDisabled();
    expect(screen.getByRole('button', { name: 'Təsdiqlə' })).toHaveAttribute(
      'title',
      '`inv.waste.approve` icazəniz yoxdur',
    );
  });

  it('never shows the keeper a cost column — absent, not masked', async () => {
    await mountAt('/inventory/waste/67', ['WAREHOUSE_KEEPER']);
    await waitFor(() => expect(screen.getByText('WS-2026-00067')).toBeInTheDocument());
    expect(screen.queryByText('Dəyər, AZN')).toBeNull();
    expect(screen.queryByText('Vahid dəyəri')).toBeNull();
    // And the figure itself never reaches the DOM.
    expect(screen.queryByText(/48,56/)).toBeNull();
  });

  it('shows the cost column to a reader who holds the permission', async () => {
    await mountAt('/inventory/waste/67', ['ADMIN']);
    await waitFor(() => expect(screen.getByText('WS-2026-00067')).toBeInTheDocument());
    expect(screen.getByText('Dəyər, AZN')).toBeInTheDocument();
  });
});

describe('return to vendor', () => {
  it('has a list screen, which it did not before', async () => {
    await mountAt('/inventory/returns', ['ADMIN']);
    await waitFor(() => expect(screen.getByText('RV-2026-00002')).toBeInTheDocument());
    expect(screen.getByRole('heading', { name: 'Təchizatçıya qaytarma' })).toBeInTheDocument();
  });

  it('sends a draft to the supplier through the contract operation', async () => {
    const user = userEvent.setup();
    await mountAt('/inventory/returns/2', ['ADMIN']);
    await waitFor(() => expect(screen.getByText('RV-2026-00002')).toBeInTheDocument());
    await user.click(screen.getByRole('button', { name: 'Təchizatçıya göndər' }));
    const dialog = await screen.findByRole('dialog');
    await user.click(within(dialog).getByRole('button', { name: 'Göndər' }));
    await waitFor(() => expect(mocks.sendReturnToVendor).toHaveBeenCalledWith(2, 1));
  });

  it('survives the bare decimal string the service sends for claimAmount', async () => {
    // Regression: the contract declares `Money { amount, currency }` but the live service
    // answers `"claimAmount": "40.0000"`. Reading `.amount` off that reached Decimal as
    // `undefined` and threw `[DecimalError] Invalid argument`, blanking the whole document.
    mocks.getReturnToVendor.mockResolvedValueOnce({ ...RTV_DOC, claimAmount: '40.0000' });
    await mountAt('/inventory/returns/2', ['ADMIN']);
    await waitFor(() => expect(screen.getByText('RV-2026-00002')).toBeInTheDocument());
    expect(screen.getByText(/40,00/)).toBeInTheDocument();
  });

  it('renders the claim column for either shape in the list', async () => {
    mocks.listReturnsToVendor.mockResolvedValueOnce(
      page([
        { ...RTV_DOC, id: 1, docNo: 'RV-2026-00001', claimAmount: '20.0000' },
        { ...RTV_DOC, id: 2, claimAmount: { amount: '40.0000', currency: 'AZN' } },
      ]),
    );
    await mountAt('/inventory/returns', ['ADMIN']);
    await waitFor(() => expect(screen.getByText('RV-2026-00001')).toBeInTheDocument());
    expect(screen.getByText(/20,00/)).toBeInTheDocument();
    expect(screen.getByText(/40,00/)).toBeInTheDocument();
    expect(screen.queryByText('[object Object]')).toBeNull();
  });

  it('is hidden from the branch user, whom the gateway refuses with 403', async () => {
    await mountAt('/inventory/returns', ['BRANCH_USER']);
    expect(await screen.findByText('Bu ekrana icazəniz yoxdur')).toBeInTheDocument();
    expect(mocks.listReturnsToVendor).not.toHaveBeenCalled();
  });
});

describe('ledger reversal', () => {
  it('offers «Storno et» to a role that holds inv.movement.reverse', async () => {
    await mountAt('/inventory/movement-groups/28', ['PROCUREMENT_MANAGER']);
    await waitFor(() => expect(screen.getByText('WS-2026-00067')).toBeInTheDocument());
    expect(screen.getByRole('button', { name: 'Storno et' })).toBeEnabled();
  });

  it('disables it for the keeper, who posts but does not reverse', async () => {
    await mountAt('/inventory/movement-groups/28', ['WAREHOUSE_KEEPER']);
    await waitFor(() => expect(screen.getByText('WS-2026-00067')).toBeInTheDocument());
    expect(screen.getByRole('button', { name: 'Storno et' })).toBeDisabled();
  });

  it('demands a reason code and posts the reversal with it', async () => {
    const user = userEvent.setup();
    await mountAt('/inventory/movement-groups/28', ['ADMIN']);
    await waitFor(() => expect(screen.getByText('WS-2026-00067')).toBeInTheDocument());
    await user.click(screen.getByRole('button', { name: 'Storno et' }));
    const dialog = await screen.findByRole('dialog');
    const confirm = within(dialog).getByRole('button', { name: 'Storno et' });
    // Nothing is sent until the mandatory reason is there, and the button says why.
    expect(confirm).toBeDisabled();
    expect(confirm).toHaveAttribute('title', 'Səbəb kodu məcburidir');

    // The reason-code list is unrouted, so the control is an id field that names the operation.
    const reason = within(dialog).getByLabelText(/Səbəb kodu/);
    await user.type(reason, '6');
    await waitFor(() => expect(confirm).toBeEnabled());
    await user.click(confirm);
    await waitFor(() => expect(mocks.reverseMovementGroup).toHaveBeenCalledWith(28, 6, undefined));
  });

  it('names the state transition when the service refuses a second reversal', async () => {
    // The service leaves `reversedByGroupId` null even on a reversed group, so the interface
    // cannot always know in advance; the 409 is the real answer and its code stays visible.
    const { ApiError } = await import('@api/problem');
    mocks.reverseMovementGroup.mockRejectedValueOnce(
      new ApiError({
        type: 'https://wms/errors/invalid-state-transition',
        title: 'INVALID_STATE_TRANSITION',
        status: 409,
        code: 'INVALID_STATE_TRANSITION',
        detail: 'Group 28 has already been reversed.',
      }),
    );
    const user = userEvent.setup();
    await mountAt('/inventory/movement-groups/28', ['ADMIN']);
    await waitFor(() => expect(screen.getByText('WS-2026-00067')).toBeInTheDocument());
    await user.click(screen.getByRole('button', { name: 'Storno et' }));
    const dialog = await screen.findByRole('dialog');
    await user.type(within(dialog).getByLabelText(/Səbəb kodu/), '6');
    await user.click(within(dialog).getByRole('button', { name: 'Storno et' }));
    // The RFC 7807 code is visible (title and the Alert's code chip both carry it).
    expect((await screen.findAllByText('INVALID_STATE_TRANSITION')).length).toBeGreaterThan(0);
    expect(screen.getByText('Group 28 has already been reversed.')).toBeInTheDocument();
    expect(screen.getByText('Bu qrup artıq storno edilmiş ola bilər')).toBeInTheDocument();
  });

  it('refuses to reverse a group that has already been reversed', async () => {
    mocks.getMovementGroup.mockResolvedValueOnce({ ...GROUP, reversedByGroupId: 30 });
    await mountAt('/inventory/movement-groups/28', ['ADMIN']);
    await waitFor(() => expect(screen.getByText('WS-2026-00067')).toBeInTheDocument());
    expect(screen.queryByRole('button', { name: 'Storno et' })).toBeNull();
    expect(screen.getByText('Bu qrup artıq storno edilib')).toBeInTheDocument();
  });
});

describe('mandatory reason code', () => {
  it('explains itself instead of rendering an empty dropdown', async () => {
    const user = userEvent.setup();
    await mountAt('/inventory/movement-groups/28', ['ADMIN']);
    await waitFor(() => expect(screen.getByText('WS-2026-00067')).toBeInTheDocument());
    await user.click(screen.getByRole('button', { name: 'Storno et' }));
    const dialog = await screen.findByRole('dialog');

    // Not a select with no options — a field that names the operation and its status.
    expect(within(dialog).queryByRole('combobox')).toBeNull();
    const hint = dialog.querySelector('.wms-field__hint');
    expect(hint?.textContent).toContain('GET /master-data/reason-codes');
    expect(hint?.textContent).toContain('404');
    expect(hint?.textContent).toContain('ADJUSTMENT');
  });
});

describe('stock requests', () => {
  it('gates the primary button on the permission the route it opens needs', async () => {
    // The branch user holds inv.request.create, not inv.issue.create: the button is theirs.
    await mountAt('/inventory/stock-requests', ['BRANCH_USER']);
    await waitFor(() => expect(mocks.listStockRequests).toHaveBeenCalled());
    const button = screen.getByRole('button', { name: 'Yeni tələb' });
    expect(button).toBeEnabled();
  });

  it('disables it for the keeper, who fulfils requests rather than raising them', async () => {
    await mountAt('/inventory/stock-requests', ['WAREHOUSE_KEEPER']);
    await waitFor(() => expect(mocks.listStockRequests).toHaveBeenCalled());
    expect(screen.getByRole('button', { name: 'Yeni tələb' })).toBeDisabled();
  });

  it('routes /inventory/stock-requests/new to the creation screen', async () => {
    await mountAt('/inventory/stock-requests/new', ['BRANCH_USER']);
    expect(await screen.findByText('Yeni mal tələbi')).toBeInTheDocument();
  });
});

describe('dashboard route guard', () => {
  it('never renders the dashboard to a user without rpt.dashboard.view', async () => {
    // The keeper's roles do not include it; the navigation already hides the entry, and the
    // index route no longer renders the screen a deep link used to walk straight into.
    await mountAt('/', ['WAREHOUSE_KEEPER']);
    await waitFor(() => expect(mocks.listGoodsReceipts).toHaveBeenCalled());
    // The dashboard's own queries never run.
    expect(mocks.getDashboardSummary).not.toHaveBeenCalled();
    expect(mocks.listPendingApprovals).not.toHaveBeenCalled();
  });

  it('sends them to the first screen their own navigation offers, not to a dead end', async () => {
    // Sign-in lands on `/`; a refusal as the first screen after logging in would be wrong.
    await mountAt('/', ['WAREHOUSE_KEEPER']);
    expect(await screen.findByRole('heading', { name: 'Qəbul' })).toBeInTheDocument();
    expect(screen.queryByText('Bu ekrana icazəniz yoxdur')).toBeNull();
  });

  it('sends the branch user to their own first screen instead', async () => {
    // Their navigation opens on «Məxaric və transfer», not on «Qəbul» — they hold
    // inv.issue.view but not inv.receipt.view.
    await mountAt('/', ['BRANCH_USER']);
    expect(await screen.findByRole('heading', { name: 'Məxaric və transfer' })).toBeInTheDocument();
  });

  it('refuses outright when the user can open nothing at all', async () => {
    await mountAt('/', []);
    expect(await screen.findByText('Bu ekrana icazəniz yoxdur')).toBeInTheDocument();
  });

  it('renders it for a user who holds the permission', async () => {
    await mountAt('/', ['ADMIN']);
    await waitFor(() => expect(mocks.listBalances).toHaveBeenCalled());
    expect(screen.queryByText('Bu ekrana icazəniz yoxdur')).toBeNull();
  });
});

describe('goods receipts list', () => {
  it('no longer carries the "open a document by id" workaround', async () => {
    await mountAt('/inventory/goods-receipts', ['WAREHOUSE_KEEPER']);
    await waitFor(() => expect(mocks.listGoodsReceipts).toHaveBeenCalled());
    expect(screen.queryByLabelText(/Sənəd id ilə aç/)).toBeNull();
    expect(screen.queryByText(/siyahı endpoint-i gateway-də hələ açılmayıb/i)).toBeNull();
    expect(screen.queryByRole('button', { name: 'Aç' })).toBeNull();
  });

  it('names the reason and the next step when the list is empty', async () => {
    await mountAt('/inventory/goods-receipts', ['WAREHOUSE_KEEPER']);
    expect(
      await screen.findByText('Qəbul sənədi yoxdur. «Yeni qəbul» ilə başlayın.'),
    ).toBeInTheDocument();
  });
});

describe('batch status dialog', () => {
  it('offers the status action only to a holder of inv.batch.manage', async () => {
    mocks.listBatches.mockResolvedValueOnce(
      page([
        {
          id: 3,
          batchNo: 'BSB-2602-B',
          product: { id: 1, sku: 'BSB-0114', name: 'Bread Stick Black' },
          expiryDate: '2027-02-18',
          daysToExpiry: 120,
          qtyOnHand: '1284.0000',
          status: 'ACTIVE',
          receivedAt: '2026-09-01',
          rowVersion: 1,
        },
      ]),
    );
    await mountAt('/inventory/batches', ['WAREHOUSE_KEEPER']);
    expect(await screen.findByRole('button', { name: 'Status dəyiş' })).toBeEnabled();
  });

  it('hides the column entirely from a reader without the permission', async () => {
    mocks.listBatches.mockResolvedValueOnce(
      page([
        {
          id: 3,
          batchNo: 'BSB-2602-B',
          product: { id: 1, sku: 'BSB-0114', name: 'Bread Stick Black' },
          expiryDate: '2027-02-18',
          daysToExpiry: 120,
          qtyOnHand: '1284.0000',
          status: 'ACTIVE',
          receivedAt: '2026-09-01',
          rowVersion: 1,
        },
      ]),
    );
    await mountAt('/inventory/batches', ['AUDITOR']);
    await waitFor(() => expect(screen.getByText('BSB-2602-B')).toBeInTheDocument());
    expect(screen.queryByRole('button', { name: 'Status dəyiş' })).toBeNull();
  });
});
