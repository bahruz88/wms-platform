import { beforeAll, describe, expect, it, vi } from 'vitest';
import { render, screen, within } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

/**
 * `PO-Tesdiq.dc.html` was the one artboard never applied, and its CSS was dead code:
 * `.wms-content--split-po` (the 1.55fr / 1fr split) and `.wms-sum*` (the totals block in the
 * card's sunken footer) existed in `app.css` and were referenced by nothing.
 *
 * Procurement's endpoints answer 404 on the gateway today, so the screen cannot be proved in a
 * browser. It is proved here instead, against the layout rules the artboard and
 * docs/design-system/screens/README.md set out — so the layout is right for the day the
 * endpoints land.
 */

const PO = {
  id: 87,
  docNo: 'PO-2026-00087',
  docDate: '2026-09-18',
  expectedDate: '2026-09-28',
  status: 'PENDING_APPROVAL',
  currency: 'AZN',
  fxRate: '1.00000000',
  subtotal: '40881.3600',
  vatAmount: '7358.6400',
  totalAmount: '48240.0000',
  totalAmountBase: '48240.0000',
  receivedPct: '0',
  incoterms: 'DAP',
  paymentTerms: '30 gün ödəniş',
  sentAt: null,
  quotationId: 21,
  productType: 'FOOD',
  rowVersion: 3,
  supplier: { id: 1, code: 'AZS', name: 'Azərsun MMC' },
  deliveryLocation: { id: 1, code: 'WH-01', name: 'Food WH', isVirtual: false },
  splitCheckWarning:
    'Azərsun MMC ilə son 30 gündə 142 800,00 AZN sifariş verilib; bu sifariş həddi aşacaq.',
  approval: {
    id: 5,
    docId: 87,
    docNo: 'PO-2026-00087',
    docType: 'PO',
    status: 'PENDING',
    currentStep: 3,
    steps: [
      { stepNo: 1, approverRoleCode: 'PROCUREMENT_OFFICER', decision: 'APPROVED' },
      { stepNo: 2, approverRoleCode: 'PROCUREMENT_MANAGER', decision: 'APPROVED' },
      { stepNo: 3, approverRoleCode: 'FINANCE_DIRECTOR', decision: 'PENDING' },
      { stepNo: 4, approverRoleCode: 'CEO', decision: 'PENDING' },
    ],
  },
  lines: [
    {
      id: 1,
      lineNo: 1,
      product: { id: 42, sku: 'CHS-0042', name: 'Chicken Strips', baseUomId: 2, baseUomCode: 'KG' },
      qty: '1200.0000',
      uomId: 2,
      uomCode: 'KG',
      unitPrice: '8.4000',
      vatRate: '18',
      lineTotal: '10080.0000',
      receivedQty: '0.0000',
      remainingQty: '1200.0000',
    },
  ],
  audit: { createdAt: '2026-09-18T09:00:00Z', createdBy: 0, rowVersion: 3 },
};

const getPurchaseOrder = vi.fn(async () => PO);

vi.mock('@api/endpoints', async () => {
  const actual = await vi.importActual<Record<string, unknown>>('@api/endpoints');
  return { ...actual, getPurchaseOrder };
});

beforeAll(() => {
  Object.defineProperty(window, 'matchMedia', {
    writable: true,
    value: (q: string) => ({
      matches: false,
      media: q,
      onchange: null,
      addEventListener: () => {},
      removeEventListener: () => {},
      addListener: () => {},
      removeListener: () => {},
      dispatchEvent: () => false,
    }),
  });
});

async function mount(roles: string[]) {
  const { PurchaseOrderDetailScreen } = await import('../PurchaseOrderDetailScreen');
  const { TestAuthProvider } = await import('@auth/AuthContext');
  const { permissionsForRoles } = await import('@auth/permissions');
  const client = new QueryClient({ defaultOptions: { queries: { retry: false, gcTime: 0 } } });

  return render(
    <QueryClientProvider client={client}>
      <TestAuthProvider
        session={{
          tenantId: 1,
          username: roles[0]?.toLowerCase() ?? 'anon',
          subject: 'sub',
          roles,
          permissions: permissionsForRoles(roles),
          permissionSource: 'roles' as const,
          accessToken: 'token',
        }}
      >
        <MemoryRouter initialEntries={['/procurement/purchase-orders/87']}>
          <PurchaseOrderDetailScreen />
        </MemoryRouter>
      </TestAuthProvider>
    </QueryClientProvider>,
  );
}

describe('purchase order approval — PO-Tesdiq.dc.html', () => {
  it('uses the artboard’s 84px document header with breadcrumb, mono number and status', async () => {
    const { container } = await mount(['PROCUREMENT_MANAGER']);
    expect(await screen.findByText('PO-2026-00087')).toBeInTheDocument();

    const header = container.querySelector('header');
    expect(header?.className).toContain('wms-header--doc');
    expect(container.querySelector('.wms-header__crumb')?.textContent).toContain('Satınalma');
    const docNo = container.querySelector('.wms-header__docno');
    expect(docNo?.textContent).toBe('PO-2026-00087');
    expect(docNo?.className).toContain('wms-num');
    expect(screen.getByTitle('PENDING_APPROVAL')).toHaveTextContent('Təsdiq gözləyir');
  });

  it('applies the split the artboard draws — the CSS class that was dead code', async () => {
    const { container } = await mount(['PROCUREMENT_MANAGER']);
    expect(await screen.findByText('PO-2026-00087')).toBeInTheDocument();
    expect(container.querySelector('.wms-content--split-po')).toBeInTheDocument();
    expect(container.querySelectorAll('.wms-content--split-po > .wms-col')).toHaveLength(2);
  });

  it('puts the totals in the card’s sunken footer, in the artboard’s order', async () => {
    const { container } = await mount(['PROCUREMENT_MANAGER']);
    expect(await screen.findByText('PO-2026-00087')).toBeInTheDocument();
    const sum = container.querySelector('.wms-sum');
    expect(sum).toBeInTheDocument();
    expect(sum?.closest('.wms-card__foot')).not.toBeNull();
    const labels = Array.from(sum?.querySelectorAll('.wms-sum__row') ?? []).map(
      (r) => r.firstElementChild?.textContent,
    );
    expect(labels).toEqual(['Ara cəm', 'ƏDV', 'Cəmi, AZN']);
    expect(sum?.querySelector('.wms-sum__row--total')?.textContent).toContain('48');
  });

  it('carries ghost → danger → primary, with exactly one primary', async () => {
    const { container } = await mount(['PROCUREMENT_MANAGER']);
    expect(await screen.findByText('PO-2026-00087')).toBeInTheDocument();
    const actions = container.querySelector('.wms-header__actions');
    expect(actions?.querySelectorAll('.wms-btn--primary')).toHaveLength(1);
    expect(Array.from(actions?.querySelectorAll('button') ?? []).map((b) => b.textContent)).toEqual(
      ['PDF', 'Rədd et', 'Təsdiqlə'],
    );
  });

  it('shows the split-check warning and the approval chain at its current step', async () => {
    await mount(['PROCUREMENT_MANAGER']);
    expect(await screen.findByText('PO-2026-00087')).toBeInTheDocument();
    expect(
      screen.getByText('Təchizatçı üzrə kumulyativ məbləğ həddə yaxınlaşır'),
    ).toBeInTheDocument();
    expect(screen.getByText('APPROVAL_REQUIRED')).toBeInTheDocument();
    expect(screen.getByText('Addım 3 / 4')).toBeInTheDocument();
  });

  it('never shows money to a reader without master.product.view_cost', async () => {
    const { container } = await mount(['WAREHOUSE_KEEPER']);
    expect(await screen.findByText('PO-2026-00087')).toBeInTheDocument();
    // The totals block is absent, not blanked, and the cost columns are not built.
    expect(container.querySelector('.wms-sum')).toBeNull();
    expect(screen.queryByText('Vahid qiymət')).toBeNull();
    expect(screen.queryByText('Sətir cəmi')).toBeNull();
    // U+202F narrow no-break space is what formatNumber groups with; escaped so the
    // source file carries no irregular whitespace.
    expect(screen.queryByText(/48\u202f240/)).toBeNull();
    expect(screen.queryByText(/48240/)).toBeNull();
  });

  it('disables the decision for a role that cannot approve, and says why', async () => {
    await mount(['WAREHOUSE_KEEPER']);
    expect(await screen.findByText('PO-2026-00087')).toBeInTheDocument();
    const header = document.querySelector('.wms-header__actions') as HTMLElement;
    const approve = within(header).getByRole('button', { name: 'Təsdiqlə' });
    expect(approve).toBeDisabled();
    expect(approve).toHaveAttribute('title', '`proc.po.approve` icazəniz yoxdur');
  });
});
