import { beforeAll, beforeEach, describe, expect, it, vi } from 'vitest';
import { render, screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import type { ReactElement } from 'react';

/**
 * Administration, against the identity and inventory-settings endpoints that now serve.
 *
 * Both screens used to be honest placeholders: the permission matrix was rendered from a
 * TypeScript constant with a badge saying so, and the settings screen listed four keys with a
 * «standart dəyər» badge. Both of those are the sort of thing an administrator acts on and is
 * wrong about, so what is pinned here is the switch: the matrix is `iam_role` × `iam_permission`
 * including a role no constant in this repo knows about, and the settings table is the tenant's
 * rows with no default anywhere in it.
 */

vi.mock('@api/endpoints', async () => {
  const actual = await vi.importActual<Record<string, unknown>>('@api/endpoints');
  return { ...actual, ...mocks };
});

const page = (items: unknown[]) => ({ items, page: 1, size: 50, total: items.length });

const ROLES = [
  {
    id: 1,
    code: 'ADMIN',
    name: 'Administrator',
    isSystem: true,
    permissions: ['iam.role.view', 'inv.settings.view', 'inv.count.recount'],
  },
  {
    id: 7,
    code: 'STOCKTAKER',
    name: 'Sayıcı',
    isSystem: false,
    // A tenant role: `RolePermissionMap` has never heard of it, so a client-side matrix
    // would show this column as empty.
    permissions: ['inv.count.enter', 'inv.count.recount'],
  },
];

const PERMISSIONS = [
  { id: 1, code: 'iam.role.view', module: 'identity', description: 'Rolları görmək' },
  { id: 2, code: 'inv.settings.view', module: 'inventory', description: 'Parametrləri görmək' },
  {
    id: 3,
    code: 'inv.count.recount',
    module: 'inventory',
    description: 'Təkrar sayım',
    isCritical: true,
  },
  { id: 4, code: 'inv.count.enter', module: 'inventory', description: 'Sayım daxil etmək' },
];

const SETTINGS = [
  {
    key: 'expiry_warning_days',
    value: '45',
    valueType: 'INT',
    description: 'Bitmə tarixi xəbərdarlığı (gün)',
  },
  {
    key: 'costing_method',
    value: 'MOVING_AVERAGE',
    valueType: 'ENUM',
    allowedValues: ['MOVING_AVERAGE', 'FIFO'],
    description: 'Maya dəyəri metodu',
  },
];

const notRouted = async () => {
  const { ApiError } = await import('@api/problem');
  throw new ApiError({ type: 'about:blank', title: 'Not Found', status: 404, code: 'NOT_FOUND' });
};

const mocks = {
  listRoles: vi.fn(async (): Promise<unknown> => ROLES),
  listPermissions: vi.fn(async (): Promise<unknown> => PERMISSIONS),
  listInventorySettings: vi.fn(async (): Promise<unknown> => SETTINGS),
  listUsers: vi.fn(async () => page([])),
  getTenant: vi.fn(async () => ({ id: 1, code: 'WMS', name: 'WMS platforması' })),
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
          permissionSource: 'server' as const,
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

describe('roles and permissions', () => {
  it('builds the matrix from the tenant`s own rows, not from the bootstrap constant', async () => {
    await mountAt('/admin/roles', ['ADMIN']);
    const matrix = await screen.findByRole('table', { name: 'Rol × icazə matrisi' });
    // A permission the client catalogue does not contain is nonetheless a row.
    expect(within(matrix).getByText('inv.count.recount')).toBeInTheDocument();
    // A tenant role the client map has never heard of is nonetheless a column.
    expect(within(matrix).getByText('STOCKTAKER')).toBeInTheDocument();
    expect(screen.getByText('Mənbə: tenant')).toBeInTheDocument();
  });

  it('grants a cell from the server`s list, including for the unknown tenant role', async () => {
    await mountAt('/admin/roles', ['ADMIN']);
    const matrix = await screen.findByRole('table', { name: 'Rol × icazə matrisi' });
    expect(within(matrix).getByTitle('STOCKTAKER → inv.count.enter')).toBeInTheDocument();
    // …and withholds one the server did not grant.
    expect(within(matrix).queryByTitle('STOCKTAKER → iam.role.view')).toBeNull();
  });

  it('no longer claims the matrix is the tenant`s when it came from the constant', async () => {
    await mountAt('/admin/roles', ['ADMIN']);
    await screen.findByRole('table', { name: 'Rol × icazə matrisi' });
    expect(screen.queryByText('Mənbə: bootstrap xəritəsi')).toBeNull();
    expect(screen.queryByText(/hesablanıb/)).toBeNull();
  });

  it('says which columns are derived when the server sends a role without its codes', async () => {
    mocks.listRoles.mockResolvedValueOnce([
      ROLES[0],
      { id: 9, code: 'WASTE_TESTER', name: 'Tullantı yoxlaması', isSystem: false },
    ]);
    await mountAt('/admin/roles', ['ADMIN']);
    expect(
      await screen.findByText('Bir neçə sütun serverdən deyil, hesablanıb'),
    ).toBeInTheDocument();
  });

  it('reports the failure with its RFC 7807 code instead of falling back silently', async () => {
    mocks.listPermissions.mockImplementationOnce(notRouted);
    await mountAt('/admin/roles', ['ADMIN']);
    expect(await screen.findByText('Matris oxunmadı')).toBeInTheDocument();
    expect(screen.getAllByText('NOT_FOUND').length).toBeGreaterThan(0);
  });

  it('narrows the matrix by module', async () => {
    const user = userEvent.setup();
    await mountAt('/admin/roles', ['ADMIN']);
    const matrix = await screen.findByRole('table', { name: 'Rol × icazə matrisi' });
    expect(within(matrix).getByText('iam.role.view')).toBeInTheDocument();
    await user.selectOptions(screen.getByLabelText('Modul'), 'inventory');
    await waitFor(() => expect(within(matrix).queryByText('iam.role.view')).toBeNull());
  });
});

describe('inventory settings', () => {
  it('shows the tenant value, not a documented default', async () => {
    await mountAt('/admin/settings', ['ADMIN']);
    const table = await screen.findByRole('table', { name: 'Anbar parametrləri' });
    // 45, the tenant's window — the interface used to show 30 from a constant.
    expect(within(table).getByText('45')).toBeInTheDocument();
    expect(within(table).getByText('MOVING_AVERAGE')).toBeInTheDocument();
    expect(screen.queryByText('Standart dəyər')).toBeNull();
  });

  it('marks which keys the interface itself reads', async () => {
    await mountAt('/admin/settings', ['ADMIN']);
    const table = await screen.findByRole('table', { name: 'Anbar parametrləri' });
    expect(within(table).getByText('İnterfeys oxuyur')).toBeInTheDocument();
    expect(within(table).getByText('yalnız server')).toBeInTheDocument();
  });

  it('reports a failed read as an error, with no substitute values', async () => {
    mocks.listInventorySettings.mockImplementationOnce(notRouted);
    await mountAt('/admin/settings', ['ADMIN']);
    expect(await screen.findByText('Oxunmadı')).toBeInTheDocument();
    expect(screen.queryByText('expiry_warning_days')).toBeNull();
  });

  it('is refused outright to a session without inv.settings.view', async () => {
    // The route refuses before the query runs. Which roles hold the permission is the
    // tenant's business and the server's answer — the interface only honours what it was told.
    await mountAt('/admin/settings', []);
    expect(await screen.findByText('Bu ekrana icazəniz yoxdur')).toBeInTheDocument();
    expect(mocks.listInventorySettings).not.toHaveBeenCalled();
  });
});
