import { describe, expect, it } from 'vitest';
import { render, screen } from '@testing-library/react';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { RequirePermission } from '../guards';
import { TestAuthProvider } from '../AuthContext';
import { permissionsForRoles } from '../permissions';
import type { WmsSession } from '../session';
import { visibleNavGroups } from '@app/navigation';

function sessionFor(roles: string[]): WmsSession {
  return {
    tenantId: 1,
    username: roles[0]?.toLowerCase() ?? 'anon',
    subject: 'sub',
    roles,
    permissions: permissionsForRoles(roles),
    accessToken: 'token',
  };
}

function renderDeepLink(path: string, session: WmsSession | null) {
  return render(
    <TestAuthProvider session={session}>
      <MemoryRouter initialEntries={[path]}>
        <Routes>
          <Route
            path="/procurement/price-history"
            element={
              <RequirePermission permission="master.product.view_cost">
                <div>Qiymət tarixçəsi məzmunu</div>
              </RequirePermission>
            }
          />
          <Route
            path="/inventory/balances"
            element={
              <RequirePermission permission="inv.balance.view">
                <div>Qalıq məzmunu</div>
              </RequirePermission>
            }
          />
          <Route
            path="/inventory/goods-receipts/new"
            element={
              <RequirePermission permission="inv.receipt.create">
                <div>Yeni qəbul məzmunu</div>
              </RequirePermission>
            }
          />
        </Routes>
      </MemoryRouter>
    </TestAuthProvider>,
  );
}

/**
 * A deep link must not get past the guard. The screen-map is explicit that the navigation entry is
 * hidden rather than disabled — but hiding a link is not a control, so the route itself refuses.
 */
describe('RequirePermission', () => {
  it('renders the screen when the permission is held', () => {
    renderDeepLink('/procurement/price-history', sessionFor(['PROCUREMENT_OFFICER']));
    expect(screen.getByText('Qiymət tarixçəsi məzmunu')).toBeInTheDocument();
  });

  it('refuses a deep link when the permission is missing, and never renders the screen', () => {
    renderDeepLink('/procurement/price-history', sessionFor(['WAREHOUSE_KEEPER']));
    expect(screen.queryByText('Qiymət tarixçəsi məzmunu')).not.toBeInTheDocument();
    expect(screen.getByText('Bu ekrana icazəniz yoxdur')).toBeInTheDocument();
  });

  it('names the required permission and the user role, and shows the FORBIDDEN code', () => {
    renderDeepLink('/procurement/price-history', sessionFor(['WAREHOUSE_KEEPER']));
    expect(screen.getByText('master.product.view_cost')).toBeInTheDocument();
    expect(screen.getByText('WAREHOUSE_KEEPER')).toBeInTheDocument();
    expect(screen.getByText('FORBIDDEN')).toBeInTheDocument();
  });

  it('announces the refusal to a screen reader', () => {
    renderDeepLink('/procurement/price-history', sessionFor(['WAREHOUSE_KEEPER']));
    expect(screen.getByRole('alert')).toBeInTheDocument();
  });

  it('refuses an anonymous visitor too', () => {
    renderDeepLink('/inventory/balances', null);
    expect(screen.queryByText('Qalıq məzmunu')).not.toBeInTheDocument();
    expect(screen.getByText('Bu ekrana icazəniz yoxdur')).toBeInTheDocument();
  });

  it('lets a screen through on any one of several accepted permissions', () => {
    render(
      <TestAuthProvider session={sessionFor(['WAREHOUSE_KEEPER'])}>
        <MemoryRouter>
          <RequirePermission permission={['proc.po.approve', 'inv.receipt.post']}>
            <div>Sənəd</div>
          </RequirePermission>
        </MemoryRouter>
      </TestAuthProvider>,
    );
    expect(screen.getByText('Sənəd')).toBeInTheDocument();
  });

  it('applies the same rule the AUDITOR really gets from the backend map', () => {
    // Changed with the backend's `Matches` fix: `*.view` now spans one **or more** segments, so
    // the auditor does hold inv.balance.view and the read screen opens. The gateway agrees —
    // the auditor token answers 200 on GET /inventory/balances.
    renderDeepLink('/inventory/balances', sessionFor(['AUDITOR']));
    expect(screen.queryByText('Bu ekrana icazəniz yoxdur')).toBeNull();
  });

  it('still refuses the AUDITOR a write screen, because read-only is read-only', () => {
    renderDeepLink('/inventory/goods-receipts/new', sessionFor(['AUDITOR']));
    expect(screen.getByText('Bu ekrana icazəniz yoxdur')).toBeInTheDocument();
  });
});

/**
 * screen-map §2: a navigation entry the user may not open is not shown — it is not disabled.
 */
describe('navigation filtering', () => {
  it('shows the cost-bound entries to a procurement officer', () => {
    const groups = visibleNavGroups(permissionsForRoles(['PROCUREMENT_OFFICER']));
    const labels = groups.flatMap((g) => g.items.map((i) => i.labelKey));
    expect(labels).toContain('nav.priceHistory');
    expect(labels).toContain('nav.purchaseOrders');
  });

  it('hides the price-history entry from a keeper entirely', () => {
    const groups = visibleNavGroups(permissionsForRoles(['WAREHOUSE_KEEPER']));
    const labels = groups.flatMap((g) => g.items.map((i) => i.labelKey));
    expect(labels).not.toContain('nav.priceHistory');
    expect(labels).toContain('nav.balances');
  });

  it('drops an empty group rather than showing an empty heading', () => {
    const groups = visibleNavGroups(permissionsForRoles(['WAREHOUSE_KEEPER']));
    expect(groups.every((g) => g.items.length > 0)).toBe(true);
    expect(groups.map((g) => g.labelKey)).not.toContain('nav.admin');
  });

  it("shows the full tree to an admin, in the artboards' order", () => {
    const groups = visibleNavGroups(permissionsForRoles(['ADMIN']));
    // The first block is the artboard's ungrouped «Panel»; it carries no label.
    expect(groups.map((g) => g.labelKey)).toEqual([
      null,
      'nav.procurement',
      'nav.inventory',
      'nav.consumption',
      'nav.system',
    ]);
  });

  it('shows nothing to a user with no permissions', () => {
    expect(visibleNavGroups([])).toEqual([]);
  });
});
