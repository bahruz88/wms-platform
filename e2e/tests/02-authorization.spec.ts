import { expect, test } from '../fixtures/wms';
import { gotoApp, navLabels, sidebar } from '../helpers/login';
import { apiCall, identityMe } from '../helpers/api';
import { ALL_NAV_LABELS, expectedNav, USER_LIST, USERS } from '../helpers/users';

/**
 * Authorization — the part most likely to regress, so it is asserted from three angles at once:
 *
 *   1. **what the navigation offers.** An entry the user may not open is *not shown*; it is not
 *      disabled (docs/ux/screen-map.md §2). The expectation is computed from the server's own
 *      `GET /identity/me` → `permissions[]`, so a code renamed on one side of the wire shows up
 *      here as a menu that does not match what the user is allowed to do.
 *   2. **what a deep link does.** `RequirePermission` has to refuse *in place*, printing the
 *      permission it wanted and the `FORBIDDEN` code — a hidden menu entry is not a control.
 *   3. **what the server says.** The interface guard is a convenience; the gateway's
 *      `x-permission` is the only real check, so the same refusal is demanded of the API.
 *
 * The cost columns get their own test because the rule is stricter than «hidden»: without
 * `master.product.view_cost` the column must be **absent from the DOM**, not blanked and not
 * masked (design-system README «Qiymət icazəyə bağlıdır», SPEC §16).
 */

for (const user of USER_LIST) {
  test(`${user.username} is offered exactly the navigation the server permits`, async ({ as }) => {
    const page = await as(user.username);
    await gotoApp(page, '/inventory/balances');

    const me = await identityMe(user.username);
    expect(me.roles, `${user.username} must hold ${user.role}`).toContain(user.role);

    const rendered = await navLabels(page);
    const expected = expectedNav(me.permissions);

    // Sorted comparison: the order is the artboard's business, the membership is the rule's.
    expect(
      [...rendered].sort(),
      `the sidebar must match what GET /identity/me permits for ${user.username}`,
    ).toEqual([...expected].sort());

    // A second opinion, written by hand from screen-map §1.
    for (const label of user.navMust) {
      expect(rendered, `${user.username} must be offered «${label}»`).toContain(label);
    }
    for (const label of user.navMustNot) {
      expect(rendered, `${user.username} must not be offered «${label}»`).not.toContain(label);
    }

    // Nothing outside the known set, and hidden rather than disabled: every entry is a live link.
    for (const label of rendered) {
      expect(ALL_NAV_LABELS, `unknown nav entry «${label}»`).toContain(label);
    }
    expect(await sidebar(page).getByRole('link').count()).toBe(rendered.length);
  });
}

for (const user of USER_LIST.filter((u) => u.forbiddenRoute)) {
  test(`${user.username} is refused ${user.forbiddenRoute} in place, with the code`, async ({
    as,
  }) => {
    const page = await as(user.username);
    await gotoApp(page, user.forbiddenRoute);

    const alert = page.getByRole('alert').filter({ hasText: 'Bu ekrana icazəniz yoxdur' });
    await expect(alert).toBeVisible();
    await expect(alert).toContainText('FORBIDDEN');
    await expect(alert).toContainText(user.forbiddenNeeds);
    await expect(alert).toContainText(user.role);

    // Refused in place: the URL is unchanged, and the screen behind it never rendered.
    await expect(page).toHaveURL(new RegExp(`${user.forbiddenRoute.replace(/\//g, '\\/')}$`));
    await expect(sidebar(page)).toBeVisible();
  });
}

test('the branch user is refused the goods receipt list and the gateway agrees', async ({ as }) => {
  const page = await as('branch1');
  await gotoApp(page, '/inventory/goods-receipts');
  await expect(
    page.getByRole('alert').filter({ hasText: 'Bu ekrana icazəniz yoxdur' }),
  ).toBeVisible();

  // The interface guard is only half of it — the server refuses the same call.
  const res = await apiCall('branch1', 'GET', '/api/v1/inventory/goods-receipts?page=1&size=1');
  expect(res.status, `gateway answered ${res.status}: ${res.raw.slice(0, 200)}`).toBe(403);
  expect(res.code).toBe('FORBIDDEN');
});

test('the auditor may read everything and write nothing', async ({ as }) => {
  const page = await as('auditor');

  await gotoApp(page, '/inventory/movements');
  await expect(page.getByRole('heading', { name: 'Ledger', level: 1 })).toBeVisible();

  // The server refuses the mutation itself, not just the screen.
  const res = await apiCall('auditor', 'POST', '/api/v1/inventory/counts', {
    data: { countType: 'SPOT', locationId: 1 },
  });
  expect(res.status, `gateway answered ${res.status}: ${res.raw.slice(0, 200)}`).toBe(403);
  expect(res.code).toBe('FORBIDDEN');
});

test('cost columns are absent from the DOM for a keeper and present for a manager', async ({
  as,
}) => {
  const keeper = await as('keeper');
  const manager = await as('manager');

  expect((await identityMe('keeper')).canViewCost, 'the keeper must not hold view_cost').toBe(
    false,
  );
  expect((await identityMe('manager')).canViewCost).toBe(true);

  await gotoApp(keeper, '/inventory/balances');
  await gotoApp(manager, '/inventory/balances');

  const keeperTable = keeper.getByRole('table', { name: 'Qalıq siyahısı' });
  const managerTable = manager.getByRole('table', { name: 'Qalıq siyahısı' });
  await expect(keeperTable).toBeVisible();
  await expect(managerTable).toBeVisible();

  // Both tables must have rows, or «no cost column» would be trivially true.
  await expect(keeperTable.locator('tbody tr').first()).toBeVisible();
  await expect(managerTable.locator('tbody tr').first()).toBeVisible();

  const keeperHeaders = await keeperTable.getByRole('columnheader').allInnerTexts();
  const managerHeaders = await managerTable.getByRole('columnheader').allInnerTexts();

  expect(keeperHeaders).not.toContain('Orta maya');
  expect(keeperHeaders).not.toContain('Dəyər (AZN)');
  expect(managerHeaders).toContain('Orta maya');
  expect(managerHeaders).toContain('Dəyər (AZN)');

  // Absent, not masked: no placeholder made it into the markup either.
  const keeperHtml = await keeperTable.innerHTML();
  expect(keeperHtml).not.toContain('***');
  expect(keeperHtml).not.toContain('Orta maya');
  expect(keeperHtml).not.toContain('avgUnitCost');

  // Every keeper row is exactly two cells shorter than the manager's — the two cost columns.
  const keeperCells = await keeperTable.locator('tbody tr').first().locator('td').count();
  const managerCells = await managerTable.locator('tbody tr').first().locator('td').count();
  expect(managerCells - keeperCells).toBe(2);
});

test('the gateway leaves cost out of the JSON a keeper receives', async () => {
  // The interface repeats the server's decision; it does not stand in for it (SPEC §16).
  const keeper = await apiCall<{ items: Array<Record<string, unknown>> }>(
    'keeper',
    'GET',
    '/api/v1/inventory/balances?page=1&size=5',
  );
  expect(keeper.status).toBe(200);
  expect(keeper.body.items.length).toBeGreaterThan(0);
  for (const row of keeper.body.items) {
    expect(row, 'a keeper must never be sent avgUnitCost').not.toHaveProperty('avgUnitCost');
    expect(row, 'a keeper must never be sent totalValue').not.toHaveProperty('totalValue');
  }

  const manager = await apiCall<{ items: Array<Record<string, unknown>> }>(
    'manager',
    'GET',
    '/api/v1/inventory/balances?page=1&size=5',
  );
  expect(manager.status).toBe(200);
  expect(manager.body.items[0]).toHaveProperty('avgUnitCost');
});

test('the price history screen is gated on view_cost, not on being in procurement', async ({
  as,
}) => {
  const keeper = await as('keeper');
  await gotoApp(keeper, '/procurement/price-history');
  const alert = keeper.getByRole('alert').filter({ hasText: 'Bu ekrana icazəniz yoxdur' });
  await expect(alert).toBeVisible();
  await expect(alert).toContainText('master.product.view_cost');

  const auditor = await as('auditor');
  await gotoApp(auditor, '/procurement/price-history');
  await expect(
    auditor.getByRole('alert').filter({ hasText: 'Bu ekrana icazəniz yoxdur' }),
  ).toHaveCount(0);
});

test('an unknown route inside the shell is a not-found screen, not a blank page', async ({
  as,
}) => {
  const page = await as('admin');
  await gotoApp(page, '/inventory/this-does-not-exist');
  await expect(sidebar(page)).toBeVisible();
  await expect(page.locator('.wms-content, .wms-page-state').first()).toBeVisible();
  const body = await page.locator('body').innerText();
  expect(body.trim().length).toBeGreaterThan(50);
});

test('every guarded route refuses the roles that lack its permission', async ({ as }) => {
  /*
   * One sweep across the role matrix, so a permission renamed on one side shows up here.
   *
   * `keeper → /reporting/reports (rpt.report.view)` used to be the first case. It was wrong and
   * is recorded here rather than dropped silently, so the next reader does not reinstate it:
   * `RolePermissionMap.cs` grants WAREHOUSE_KEEPER `rpt.dashboard.view`, `rpt.report.view` and
   * `rpt.export.create`. The Reporting work granted them deliberately — the dashboard is the
   * keeper's own home screen, and without the codes the role met a 403 on the first screen it
   * saw. A keeper reaching the report list is therefore correct behaviour, not a hole.
   *
   * What a keeper genuinely may not reach is the purchasing side and everything `cons.*`, so
   * the slot is taken by a route that still tests the guard: `/consumption/recipes`.
   */
  const cases: Array<{ user: keyof typeof USERS; route: string; needs: string }> = [
    { user: 'keeper', route: '/consumption/recipes', needs: 'cons.recipe.view' },
    { user: 'branch1', route: '/procurement/requisitions', needs: 'proc.pr.view' },
    { user: 'branch1', route: '/admin/settings', needs: 'inv.settings.view' },
    { user: 'procurement', route: '/inventory/movements', needs: 'inv.movement.view' },
    { user: 'auditor', route: '/inventory/issues/new', needs: 'inv.issue.create' },
  ];

  for (const c of cases) {
    const page = await as(c.user);
    await gotoApp(page, c.route);
    const alert = page.getByRole('alert').filter({ hasText: 'Bu ekrana icazəniz yoxdur' });
    await expect(alert, `${c.user} must be refused ${c.route}`).toBeVisible();
    await expect(alert).toContainText('FORBIDDEN');
    await expect(alert).toContainText(c.needs);
  }
});
