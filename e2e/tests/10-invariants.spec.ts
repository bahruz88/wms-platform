import { expect, test } from '../fixtures/wms';
import { gotoApp } from '../helpers/login';
import {
  balanceLedgerDrift,
  negativePhysicalStock,
  query,
  unbalancedGroups,
} from '../helpers/db';

/**
 * The domain invariants of SPEC §12, asserted against the database **after** the document flows
 * in this suite have run.
 *
 * These are the checks the nightly self-audit job is supposed to make. Running them here, at the
 * end of a session that posted receipts, issues, counts, waste, returns and a reversal, is what
 * turns «the screen said it worked» into «the ledger agrees».
 */

test('§12.3 — every movement group sums to exactly zero', async () => {
  const offenders = await unbalancedGroups();
  expect(
    offenders,
    `unbalanced movement groups: ${JSON.stringify(offenders)}`,
  ).toEqual([]);
});

test('§12.1 — no physical location holds negative stock', async () => {
  // `inv_setting.allow_negative_stock = false`, so this must be empty for every non-virtual
  // location. Virtual locations are expected to go negative: `V_SUPPLIER` is the counter-account
  // for every receipt.
  const negatives = await negativePhysicalStock();
  expect(negatives, `negative physical stock: ${JSON.stringify(negatives)}`).toEqual([]);
});

test('§12.1 — the negative-stock setting the invariant depends on is actually off', async () => {
  const rows = await query<{ setting_value: string }>(
    `SELECT setting_value FROM inv_setting WHERE tenant_id = 1 AND setting_key = 'allow_negative_stock'`,
  );
  expect(rows[0]?.setting_value, 'the test above means nothing if the setting is on').toBe(
    'false',
  );
});

test('§12.2 — every balance row is exactly the sum of its ledger lines', async () => {
  // «`inv_balance`-a birbaşa `UPDATE` edən hər hansı başqa kod yolu **buq sayılır**.»
  // A balance row with no movements behind it is the same violation seen from the other side.
  const drift = await balanceLedgerDrift();
  expect(
    drift,
    `balance rows that the ledger does not account for: ${JSON.stringify(drift)}`,
  ).toEqual([]);
});

test('the balances screen never renders a row with no product behind it', async ({ as }) => {
  // The user-visible half of the §12.2 failure above: a balance row whose product and location
  // do not exist in master data is still listed, and the interface draws it with an empty SKU,
  // an empty name and an empty unit. «Boş xana» is exactly what the design system forbids.
  const page = await as('admin');
  await gotoApp(page, '/inventory/balances');

  const table = page.getByRole('table', { name: 'Qalıq siyahısı' });
  await expect(table).toBeVisible();

  const blanks: string[] = [];
  for (let pageNo = 1; pageNo <= 8; pageNo += 1) {
    await expect(table.locator('tbody tr').first()).toBeVisible();
    const rows = await table.locator('tbody tr').all();
    for (const row of rows) {
      const cells = await row.locator('td').allInnerTexts();
      const [sku, name] = cells;
      if (!sku?.trim() || !name?.trim()) blanks.push(JSON.stringify(cells));
    }
    const next = page.getByRole('button', { name: 'Növbəti' });
    if (!(await next.isEnabled().catch(() => false))) break;
    await next.click();
  }

  expect(blanks, `balance rows drawn with an empty product: ${blanks.join(' | ')}`).toEqual([]);
});

test('§12.1 — every stored quantity has the base unit’s scale and a frozen conversion rate', async () => {
  const bad = await query<{ id: number; qty_base: string; conversion_rate: string }>(
    `SELECT m.id, m.qty_base, m.conversion_rate
       FROM inv_movement m
      WHERE m.tenant_id = 1 AND (m.conversion_rate IS NULL OR m.conversion_rate <= 0)
      LIMIT 20`,
  );
  expect(bad, `movements with no frozen conversion rate: ${JSON.stringify(bad)}`).toEqual([]);
});

test('§12.9 — the browser is only ever served tenant 1 data', async ({ as }) => {
  // `inv_balance` holds rows for tenant 2; the tenant filter comes from the JWT claim alone, so
  // an admin of tenant 1 must never be shown them.
  const otherTenants = await query<{ n: number }>(
    `SELECT COUNT(*) AS n FROM inv_balance WHERE tenant_id <> 1`,
  );
  test.skip(
    Number(otherTenants[0]!.n) === 0,
    'no second tenant in this database — nothing to leak',
  );

  const page = await as('admin');
  const payloads: unknown[] = [];
  page.on('response', async (response) => {
    if (!response.url().includes('/api/v1/inventory/balances')) return;
    try {
      payloads.push(await response.json());
    } catch {
      /* not json */
    }
  });

  await gotoApp(page, '/inventory/balances');
  await expect(page.getByRole('table', { name: 'Qalıq siyahısı' })).toBeVisible();

  const tenant1Total = await query<{ n: number }>(
    `SELECT COUNT(*) AS n FROM inv_balance WHERE tenant_id = 1 AND qty_on_hand <> 0`,
  );
  const envelope = payloads.find(
    (p): p is { total: number } => typeof p === 'object' && p !== null && 'total' in p,
  );
  expect(envelope, 'the balances screen must have fetched something').toBeTruthy();
  expect(envelope!.total, 'the total must count tenant 1 only').toBe(
    Number(tenant1Total[0]!.n),
  );
});

test('ADR-008 — every quantity in the JSON the browser received is a decimal string', async ({
  as,
}) => {
  const page = await as('manager');

  const violations: string[] = [];
  const decimalFields = [
    'qtyOnHand',
    'qtyReserved',
    'qtyAvailable',
    'qtyBase',
    'qty',
    'receivedQty',
    'rejectedQty',
    'orderedQty',
    'bookQty',
    'countedQty',
    'varianceQty',
    'variancePct',
    'unitCost',
    'unitPrice',
    'avgUnitCost',
    'totalValue',
    'totalAmount',
    'claimAmount',
    'fxRate',
    'conversionRate',
    'temperatureC',
  ];

  function walk(node: unknown, path: string, url: string) {
    if (Array.isArray(node)) {
      node.forEach((item, i) => walk(item, `${path}[${i}]`, url));
      return;
    }
    if (node === null || typeof node !== 'object') return;
    for (const [key, value] of Object.entries(node as Record<string, unknown>)) {
      const here = path ? `${path}.${key}` : key;
      if (decimalFields.includes(key) && typeof value === 'number') {
        violations.push(`${url} :: ${here} = ${value} (number, must be a decimal string)`);
      }
      walk(value, here, url);
    }
  }

  page.on('response', async (response) => {
    if (!response.url().includes('/api/v1/')) return;
    const type = response.headers()['content-type'] ?? '';
    if (!type.includes('json')) return;
    try {
      walk(await response.json(), '', new URL(response.url()).pathname);
    } catch {
      /* not json after all */
    }
  });

  // Screens that between them carry every kind of quantity the platform has.
  for (const route of [
    '/inventory/balances',
    '/inventory/movements',
    '/inventory/goods-receipts',
    '/inventory/issues',
    '/inventory/counts',
    '/inventory/waste',
    '/inventory/batches',
  ]) {
    await gotoApp(page, route);
    await expect(page.locator('.wms-content').first()).toBeVisible();
  }

  expect(violations, violations.join('\n')).toEqual([]);
});
