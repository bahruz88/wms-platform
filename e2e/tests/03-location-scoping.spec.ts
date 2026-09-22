import { expect, test } from '../fixtures/wms';
import { gotoApp } from '../helpers/login';
import { allPages, apiCall } from '../helpers/api';
import { query } from '../helpers/db';
import { LOCATIONS } from '../helpers/users';

/**
 * Location scoping — SPEC §16, the gap the roadmap calls out as a security hole (§2) and which
 * has just been closed. This suite locks it down from both ends.
 *
 * `iam_user_location` is the source of truth: `branch1` is confined to `BR-NIZ`, `keeper` holds
 * `WH-01` and `WH-02` **and** `iam.location.view_all`, so a keeper legitimately sees everything.
 * The assertions therefore are:
 *
 *   · the rows `branch1` is shown come from exactly one location, and it is its own;
 *   · the count of those rows equals the count the database holds for that location — a filter
 *     that silently truncates is as wrong as one that leaks;
 *   · `admin` sees strictly more locations than `branch1`, including ones `branch1` must not see.
 *
 * Fail-open is the failure mode being guarded against, so «branch1 sees nothing» would also be a
 * failure: an empty table proves nothing.
 */

async function renderedLocations(page: import('@playwright/test').Page, tableName: string) {
  const table = page.getByRole('table', { name: tableName });
  await expect(table).toBeVisible();
  const rows = table.locator('tbody tr');
  await expect(rows.first()).toBeVisible();
  return { table, rows };
}

test('branch1 is shown balances from its own branch only', async ({ as }) => {
  const page = await as('branch1');
  await gotoApp(page, '/inventory/balances');

  const { table, rows } = await renderedLocations(page, 'Qalıq siyahısı');

  // The «Lokasiya» column is the third; read it for every rendered row.
  const headers = await table.getByRole('columnheader').allInnerTexts();
  const locationIndex = headers.indexOf('Lokasiya');
  expect(locationIndex, 'the balances table must have a «Lokasiya» column').toBeGreaterThanOrEqual(
    0,
  );

  const rowCount = await rows.count();
  expect(rowCount, 'a branch user with stock must see rows, or nothing is being proved').toBeGreaterThan(0);

  const rendered = new Set<string>();
  for (let i = 0; i < rowCount; i += 1) {
    rendered.add((await rows.nth(i).locator('td').nth(locationIndex).innerText()).trim());
  }
  expect([...rendered]).toEqual([LOCATIONS.BR_NIZ.name]);

  // And the total the pager reports equals what the database holds for that branch alone.
  const dbRows = await query<{ n: number }>(
    `SELECT COUNT(*) AS n FROM inv_balance
      WHERE tenant_id = 1 AND location_id = ? AND qty_on_hand <> 0`,
    [LOCATIONS.BR_NIZ.id],
  );
  const api = await apiCall<{ total: number; items: Array<{ location: { code: string } }> }>(
    'branch1',
    'GET',
    '/api/v1/inventory/balances?page=1&size=200',
  );
  expect(api.status).toBe(200);
  expect(api.body.total).toBe(Number(dbRows[0]!.n));
  expect([...new Set(api.body.items.map((i) => i.location.code))]).toEqual([LOCATIONS.BR_NIZ.code]);
});

test('branch1 is shown ledger movements from its own branch only', async ({ as }) => {
  const page = await as('branch1');
  await gotoApp(page, '/inventory/movements');

  const table = page.getByRole('table').first();
  await expect(table).toBeVisible();
  const headers = await table.getByRole('columnheader').allInnerTexts();
  const locationIndex = headers.findIndex((h) => h.trim() === 'Lokasiya');
  expect(locationIndex).toBeGreaterThanOrEqual(0);

  const rows = table.locator('tbody tr');
  await expect(rows.first()).toBeVisible();
  const rowCount = await rows.count();
  expect(rowCount).toBeGreaterThan(0);

  const rendered = new Set<string>();
  for (let i = 0; i < rowCount; i += 1) {
    rendered.add((await rows.nth(i).locator('td').nth(locationIndex).innerText()).trim());
  }
  // Movements are only ever shown for the branch itself, never the warehouse it came from.
  for (const name of rendered) {
    expect(name, `branch1 was shown a movement at «${name}»`).toContain(LOCATIONS.BR_NIZ.name);
  }

  const dbTotal = await query<{ n: number }>(
    `SELECT COUNT(*) AS n FROM inv_movement WHERE tenant_id = 1 AND location_id = ?`,
    [LOCATIONS.BR_NIZ.id],
  );
  const api = await apiCall<{ total: number }>(
    'branch1',
    'GET',
    '/api/v1/inventory/movements?page=1&size=1',
  );
  expect(api.body.total).toBe(Number(dbTotal[0]!.n));
});

test('branch1 cannot reach another branch by asking for it directly', async () => {
  // The filter is the server's, so a hand-written query string must not get past it.
  const other = await apiCall<{ items: unknown[]; total: number }>(
    'branch1',
    'GET',
    `/api/v1/inventory/balances?locationId=${LOCATIONS.WH01.id}&page=1&size=50`,
  );
  expect([200, 403]).toContain(other.status);
  if (other.status === 200) {
    expect(other.body.items, 'branch1 asked for WH-01 and was given rows').toHaveLength(0);
    expect(other.body.total).toBe(0);
  }
});

test('admin sees every location that holds stock', async ({ as }) => {
  const page = await as('admin');
  await gotoApp(page, '/inventory/balances');
  await expect(page.getByRole('table', { name: 'Qalıq siyahısı' })).toBeVisible();

  // The location filter the screen offers is the list the user is scoped to.
  const filter = page.getByLabel('Lokasiya', { exact: false }).first();
  const options = await filter.locator('option').allInnerTexts();
  for (const location of [LOCATIONS.WH01, LOCATIONS.WH02, LOCATIONS.BR_NIZ, LOCATIONS.BR_ELM]) {
    expect(options.join(' | ')).toContain(location.code);
  }

  // The gateway clamps `size` to 200, so «everything» means walking every page.
  const items = await allPages<{ location: { code: string } }>(
    'admin',
    '/api/v1/inventory/balances',
  );
  const seen = new Set(items.map((i) => i.location.code));
  const dbCodes = await query<{ code: string }>(
    `SELECT DISTINCT l.code FROM inv_balance b JOIN master_location l ON l.id = b.location_id
      WHERE b.tenant_id = 1 AND b.qty_on_hand <> 0`,
  );
  for (const row of dbCodes) {
    expect(seen, `admin must be shown ${row.code}`).toContain(row.code);
  }
  // Strictly more than the branch user, and it includes locations the branch user must not see.
  expect(seen.size).toBeGreaterThan(1);
  expect(seen).toContain(LOCATIONS.WH01.code);
  expect(seen).toContain(LOCATIONS.BR_ELM.code);
});

test('the scoped user list in the database is what the interface enforces', async () => {
  // If this drifts, the two tests above would pass while enforcing the wrong thing.
  const rows = await query<{ username: string; location_id: number }>(
    `SELECT u.username, ul.location_id
       FROM iam_user_location ul JOIN iam_user u ON u.id = ul.user_id
      WHERE u.username IN ('branch1', 'keeper') ORDER BY u.username, ul.location_id`,
  );
  const branch = rows.filter((r) => r.username === 'branch1').map((r) => Number(r.location_id));
  expect(branch, '`branch1` must be confined to BR-NIZ in iam_user_location').toEqual([
    LOCATIONS.BR_NIZ.id,
  ]);
});
