import { beforeAll, beforeEach, describe, expect, it, vi } from 'vitest';
import { render, screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import type { ReactElement } from 'react';

/**
 * Master data, mounted against the shapes the gateway actually answers with.
 *
 * These six screens were built while `GET /masterdata/suppliers`, `/uoms`, `/categories` and
 * `/reason-codes` answered 404, so nothing ever rendered a row: the list frame was right and
 * the content was a permanent empty state. The endpoints serve now, and these tests are what
 * says so — a row reaches the table, the filters are the contract's own parameters and go to
 * the server rather than being applied to the page in hand, and the product document shows the
 * `master_product_uom` rows that `QtyUomInput` depends on.
 */

vi.mock('@api/endpoints', async () => {
  const actual = await vi.importActual<Record<string, unknown>>('@api/endpoints');
  return { ...actual, ...mocks };
});

const page = (items: unknown[]) => ({ items, page: 1, size: 50, total: items.length });

const PRODUCTS = [
  {
    id: 10,
    sku: 'HAM',
    name: 'Vetçina',
    baseUomId: 1,
    baseUomCode: 'G',
    productType: 'FOOD',
    requiresBatch: true,
    requiresExpiry: true,
    isActive: true,
  },
  {
    id: 25,
    sku: 'DETERGENT',
    name: 'Yuyucu vasitə',
    baseUomId: 5,
    baseUomCode: 'L',
    productType: 'NON_FOOD',
    requiresBatch: false,
    requiresExpiry: false,
    isActive: true,
  },
];

const PRODUCT_DOC = {
  ...PRODUCTS[0],
  categoryId: 3,
  categoryPath: '/MEAT',
  defaultSupplierId: 2,
  minStock: '3000.0000',
  maxStock: '20000.0000',
  reorderPoint: '4500.0000',
  vatRate: '18.0000',
  issueStrategy: 'FEFO',
  shelfLifeDays: 21,
  uoms: [
    {
      id: 17,
      productId: 10,
      uomId: 1,
      uomCode: 'G',
      factorToBase: '1.00000000',
      isPurchaseDefault: false,
      isIssueDefault: true,
      validFrom: '2026-01-01',
    },
    {
      id: 18,
      productId: 10,
      uomId: 2,
      uomCode: 'KG',
      factorToBase: '1000.00000000',
      isPurchaseDefault: true,
      isIssueDefault: false,
      validFrom: '2026-01-01',
    },
  ],
  audit: { createdAt: '2026-09-21T14:32:40Z', createdBy: 1, rowVersion: 1 },
};

const SUPPLIERS = [
  {
    id: 1,
    code: 'SUP-01',
    name: 'Baku Food Supply',
    currency: 'AZN',
    isApprovedFoodSupplier: true,
    isActive: true,
  },
  {
    id: 6,
    code: 'SUP-06',
    name: 'CleanPro Kimya',
    currency: 'USD',
    isApprovedFoodSupplier: false,
    isActive: true,
  },
];

const SUPPLIER_DOC = {
  ...SUPPLIERS[0],
  address: 'Bakı, Nizami küç. 1',
  contactPerson: 'Rəşad Məmmədov',
  phone: '+994 12 000 00 00',
  email: 'sales@bakufood.az',
  paymentTerms: '30 gün',
  deliveryTerms: 'DDP',
  incoterms: 'DDP',
  bankDetails: 'AZ00 NABZ 0000',
  certificates: [
    {
      id: 1,
      supplierId: 1,
      certType: 'HACCP',
      certNumber: 'HC-2024-77',
      issuedDate: '2024-02-01',
      expiryDate: '2026-02-01',
      isExpired: true,
      attachmentId: null,
    },
  ],
  audit: { createdAt: '2026-09-21T05:00:00Z', createdBy: 1, rowVersion: 1 },
};

const UOMS = [
  { id: 1, code: 'G', name: 'qram', uomClass: 'MASS', decimals: 4 },
  { id: 4, code: 'PCS', name: 'ədəd', uomClass: 'COUNT', decimals: 4 },
];

const CATEGORIES = [
  {
    id: 1,
    code: 'FOOD',
    name: 'Qida',
    productType: 'FOOD',
    path: '/FOOD',
    isActive: true,
    rowVersion: 1,
  },
  {
    id: 3,
    code: 'MEAT',
    name: 'Ət və toyuq',
    productType: 'FOOD',
    path: '/FOOD/MEAT',
    parentId: 1,
    defaultIssueStrategy: 'FEFO',
    isActive: true,
    rowVersion: 1,
  },
];

const REASON_CODES = [
  {
    id: 6,
    code: 'WST-DMG',
    name: 'Zədələnmiş',
    reasonGroup: 'WASTE',
    requiresApproval: true,
    requiresPhoto: true,
    isActive: true,
    rowVersion: 1,
  },
];

const LOCATIONS = [
  {
    id: 1,
    code: 'WH-01',
    name: 'Mərkəzi anbar',
    locationType: 'CENTRAL_WAREHOUSE',
    isVirtual: false,
    allowsFood: true,
    allowsNonFood: true,
    isActive: true,
    rowVersion: 1,
  },
  {
    id: 900,
    code: 'V_WASTE',
    name: 'Tullantı',
    locationType: 'V_WASTE',
    isVirtual: true,
    allowsFood: true,
    allowsNonFood: true,
    isActive: true,
    rowVersion: 1,
  },
];

const mocks = {
  listProducts: vi.fn(async (): Promise<ReturnType<typeof page>> => page(PRODUCTS)),
  getProduct: vi.fn(async (): Promise<Record<string, unknown>> => PRODUCT_DOC),
  listSuppliers: vi.fn(async (): Promise<ReturnType<typeof page>> => page(SUPPLIERS)),
  getSupplier: vi.fn(async (): Promise<Record<string, unknown>> => SUPPLIER_DOC),
  listUoms: vi.fn(async () => page(UOMS)),
  listCategories: vi.fn(async () => page(CATEGORIES)),
  listReasonCodes: vi.fn(async () => page(REASON_CODES)),
  listLocations: vi.fn(async () => page(LOCATIONS)),
  listCurrencyRates: vi.fn(async () => page([])),
};

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

  const ui: ReactElement = (
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

describe('products', () => {
  it('renders the rows the endpoint answers with', async () => {
    await mountAt('/master-data/products', ['ADMIN']);
    expect(await screen.findByText('Vetçina')).toBeInTheDocument();
    expect(screen.getByText('DETERGENT')).toBeInTheDocument();
  });

  it('sends the category filter to the server rather than filtering the page in hand', async () => {
    const user = userEvent.setup();
    await mountAt('/master-data/products', ['ADMIN']);
    await waitFor(() => expect(screen.getByText('Vetçina')).toBeInTheDocument());
    await user.selectOptions(screen.getByLabelText('Kateqoriya'), '3');
    await waitFor(() =>
      expect(mocks.listProducts).toHaveBeenCalledWith(expect.objectContaining({ categoryId: 3 })),
    );
  });

  it('opens the product document from the SKU', async () => {
    const user = userEvent.setup();
    await mountAt('/master-data/products', ['ADMIN']);
    await user.click(await screen.findByRole('link', { name: 'HAM' }));
    await waitFor(() => expect(mocks.getProduct).toHaveBeenCalledWith(10));
  });
});

describe('product document', () => {
  it('shows the master_product_uom rows QtyUomInput offers', async () => {
    await mountAt('/master-data/products/10', ['ADMIN']);
    const table = await screen.findByRole('table', { name: 'Məhsulun ölçü vahidləri' });
    expect(within(table).getByText('KG')).toBeInTheDocument();
    // The factor is the contract decimal string, formatted — never parsed into a float.
    expect(within(table).getByText(/1\s000,00000000/)).toBeInTheDocument();
  });

  it('never shows the VAT rate to a reader without master.product.view_cost', async () => {
    await mountAt('/master-data/products/10', ['WAREHOUSE_KEEPER']);
    await waitFor(() => expect(screen.getAllByText('Vetçina').length).toBeGreaterThan(0));
    expect(screen.queryByText(/18,00 %/)).toBeNull();
  });
});

describe('suppliers', () => {
  it('renders the rows and the food-approval state', async () => {
    await mountAt('/master-data/suppliers', ['ADMIN']);
    expect(await screen.findByText('Baku Food Supply')).toBeInTheDocument();
    expect(screen.getByText('Təsdiqlənməyib')).toBeInTheDocument();
  });

  it('asks the server for approved suppliers only when the filter is set', async () => {
    const user = userEvent.setup();
    await mountAt('/master-data/suppliers', ['ADMIN']);
    await waitFor(() => expect(screen.getByText('Baku Food Supply')).toBeInTheDocument());
    await user.selectOptions(screen.getByLabelText('Qida təsdiqi'), 'true');
    await waitFor(() =>
      expect(mocks.listSuppliers).toHaveBeenCalledWith(
        expect.objectContaining({ approvedFoodOnly: true }),
      ),
    );
  });

  it('names an expired certificate on the supplier document, with its code', async () => {
    await mountAt('/master-data/suppliers/1', ['ADMIN']);
    expect(await screen.findByText('Vaxtı keçmiş sertifikat')).toBeInTheDocument();
    expect(screen.getByText('CERTIFICATE_EXPIRED')).toBeInTheDocument();
  });
});

describe('categories', () => {
  it('has a screen at all, and renders the tree the endpoint answers with', async () => {
    await mountAt('/master-data/categories', ['ADMIN']);
    expect(await screen.findByText('Ət və toyuq')).toBeInTheDocument();
    expect(screen.getByText('/FOOD/MEAT')).toBeInTheDocument();
  });

  it('narrows by product type through the contract parameter', async () => {
    const user = userEvent.setup();
    await mountAt('/master-data/categories', ['ADMIN']);
    await waitFor(() => expect(screen.getByText('Ət və toyuq')).toBeInTheDocument());
    await user.selectOptions(screen.getByLabelText('Məhsul tipi'), 'NON_FOOD');
    await waitFor(() =>
      expect(mocks.listCategories).toHaveBeenCalledWith({ productType: 'NON_FOOD' }),
    );
  });
});

describe('units of measure', () => {
  it('renders the rows and filters by class on the server', async () => {
    const user = userEvent.setup();
    await mountAt('/master-data/uoms', ['ADMIN']);
    expect(await screen.findByText('qram')).toBeInTheDocument();
    await user.selectOptions(screen.getByLabelText('Sinif'), 'COUNT');
    await waitFor(() => expect(mocks.listUoms).toHaveBeenCalledWith({ uomClass: 'COUNT' }));
  });
});

describe('reason codes', () => {
  it('renders the rows and filters by group on the server', async () => {
    const user = userEvent.setup();
    await mountAt('/master-data/reason-codes', ['ADMIN']);
    expect(await screen.findByText('Zədələnmiş')).toBeInTheDocument();
    await user.selectOptions(screen.getByLabelText('Qrup'), 'SAMPLE');
    await waitFor(() =>
      expect(mocks.listReasonCodes).toHaveBeenCalledWith(
        expect.objectContaining({ reasonGroup: 'SAMPLE' }),
      ),
    );
  });
});

describe('locations', () => {
  it('marks a virtual location as virtual, not as a warehouse', async () => {
    await mountAt('/master-data/locations', ['ADMIN']);
    const table = await screen.findByRole('table', { name: 'Lokasiya siyahısı' });
    const virtual = table.querySelector('.wms-badge--virtual');
    expect(virtual).toHaveTextContent('Tullantı');
  });

  it('can ask the server to leave virtual locations out', async () => {
    const user = userEvent.setup();
    await mountAt('/master-data/locations', ['ADMIN']);
    await screen.findByRole('table', { name: 'Lokasiya siyahısı' });
    await user.selectOptions(screen.getByLabelText('Virtual lokasiyalar'), 'false');
    await waitFor(() =>
      expect(mocks.listLocations).toHaveBeenCalledWith(
        expect.objectContaining({ includeVirtual: false }),
      ),
    );
  });
});

describe('master-data tab strip', () => {
  it('offers the sibling screens from one navigation entry', async () => {
    await mountAt('/master-data/products', ['ADMIN']);
    const nav = await screen.findByRole('navigation', { name: /bölmə/i });
    expect(within(nav).getByRole('link', { name: 'Kateqoriyalar' })).toBeInTheDocument();
    expect(within(nav).getByRole('link', { name: 'Səbəb kodları' })).toBeInTheDocument();
  });

  it('hides a tab the user may not open', async () => {
    // The keeper holds master.product.view and master.location.view, not master.reason.view.
    await mountAt('/master-data/products', ['WAREHOUSE_KEEPER']);
    const nav = await screen.findByRole('navigation', { name: /bölmə/i });
    expect(within(nav).queryByRole('link', { name: 'Səbəb kodları' })).toBeNull();
    expect(within(nav).getByRole('link', { name: 'Lokasiyalar' })).toBeInTheDocument();
  });
});
