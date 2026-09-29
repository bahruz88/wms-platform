import { beforeAll, beforeEach, describe, expect, it, vi } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

/**
 * Price history without filters is a reverse-chronological list of every price the tenant has ever
 * paid — the question someone brings to it ("what has lettuce been costing us, and from whom")
 * cannot be asked at all. The server has taken `productId`, `supplierId`, a date range and
 * `minDiffPct` from the beginning; these tests hold the interface to them.
 */

const page = <T,>(items: T[]) => ({ items, page: 1, size: 50, total: items.length });

const ENTRY = {
  id: 1,
  product: { id: 7, sku: 'LETTUCE', name: 'Kahı', baseUomId: 1, baseUomCode: 'KG' },
  supplier: { id: 1, code: 'AZS', name: 'Azərsun MMC' },
  priceDate: '2026-09-18',
  unitPrice: '1.2000',
  currency: 'AZN',
  unitPriceBase: '1.2000',
  prevPriceBase: '1.0000',
  poDocNo: 'PO-2026-00087',
};

const listPriceHistory = vi.fn(async () => page([ENTRY]));
const listProducts = vi.fn(async () =>
  page([
    { id: 7, sku: 'LETTUCE', name: 'Kahı', baseUomId: 1, baseUomCode: 'KG', productType: 'FOOD' },
    { id: 9, sku: 'ONION', name: 'Soğan', baseUomId: 1, baseUomCode: 'KG', productType: 'FOOD' },
  ]),
);
const listSuppliers = vi.fn(async () =>
  page([{ id: 1, code: 'AZS', name: 'Azərsun MMC', currency: 'AZN' }]),
);

vi.mock('@api/endpoints', async () => {
  const actual = await vi.importActual<Record<string, unknown>>('@api/endpoints');
  return { ...actual, listPriceHistory, listProducts, listSuppliers };
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

async function mount() {
  const { PriceHistoryScreen } = await import('../PriceHistoryScreen');
  const { TestAuthProvider } = await import('@auth/AuthContext');
  const { permissionsForRoles } = await import('@auth/permissions');
  const roles = ['PROCUREMENT_MANAGER'];
  const client = new QueryClient({ defaultOptions: { queries: { retry: false, gcTime: 0 } } });

  return render(
    <QueryClientProvider client={client}>
      <TestAuthProvider
        session={{
          tenantId: 1,
          username: 'buyer',
          subject: 'sub',
          roles,
          permissions: permissionsForRoles(roles),
          permissionSource: 'roles' as const,
          accessToken: 'token',
        }}
      >
        <MemoryRouter initialEntries={['/procurement/price-history']}>
          <PriceHistoryScreen />
        </MemoryRouter>
      </TestAuthProvider>
    </QueryClientProvider>,
  );
}

describe('price history filters', () => {
  beforeEach(() => listPriceHistory.mockResolvedValue(page([ENTRY])));

  it('asks the server for one product instead of filtering in the browser', async () => {
    await mount();
    await screen.findByText('Kahı');
    listPriceHistory.mockClear();

    await userEvent.selectOptions(screen.getByLabelText(/Məhsul/), '7');

    await waitFor(() =>
      expect(listPriceHistory).toHaveBeenCalledWith(
        expect.objectContaining({ productId: 7, page: 1 }),
      ),
    );
  });

  it('passes the supplier, the date range and the minimum change', async () => {
    await mount();
    await screen.findByText('Kahı');
    listPriceHistory.mockClear();

    await userEvent.selectOptions(screen.getByLabelText(/Təchizatçı/), '1');
    await userEvent.type(screen.getByLabelText(/Tarixdən/), '2026-01-01');
    await userEvent.type(screen.getByLabelText(/Min\. dəyişmə/), '10');

    await waitFor(() =>
      expect(listPriceHistory).toHaveBeenLastCalledWith(
        expect.objectContaining({
          supplierId: 1,
          dateFrom: '2026-01-01',
          minDiffPct: '10',
        }),
      ),
    );
  });

  it('a filter that matches nothing says so, and says what to do', async () => {
    await mount();
    // The options come from `listProducts`; selecting before they arrive picks nothing.
    await screen.findByRole('option', { name: /Soğan/ });
    listPriceHistory.mockResolvedValue(page([]));

    await userEvent.selectOptions(screen.getByLabelText(/Məhsul/), '9');

    expect(await screen.findByText(/Süzgəci genişləndirin/)).toBeInTheDocument();
  });
});
