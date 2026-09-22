import { expect, test } from '../fixtures/wms';
import { gotoApp } from '../helpers/login';
import {
  balanceOf,
  decimalAdd,
  decimalEquals,
  groupForSource,
  movementsOfGroup,
  normalizeDecimal,
  receiptRow,
} from '../helpers/db';
import { LOCATIONS } from '../helpers/users';

/**
 * Goods receipt, end to end through the browser — screen-map §3.2, SPEC §12.3.
 *
 * A keeper writes a draft, posts it, and then the ledger is asked whether it agrees. The
 * assertions that matter are the last three:
 *
 *   · the movement group sums to **exactly zero** (§12.3, double entry);
 *   · the two lines are `V_SUPPLIER −qty` and `WH-01 +qty`, in that shape, not merely two rows;
 *   · the balance rose by **exactly** the posted quantity — measured before and after, so a
 *     concurrent movement elsewhere cannot make a broken posting look right.
 *
 * The quantity is unique per run (a 4-decimal tail derived from the clock), so reruns never
 * collide and a stale row can never be mistaken for this one's.
 */

const PRODUCT = { id: 1, sku: 'LETTUCE', name: 'Kahı', uom: 'G' };

/** A quantity no other run will produce: 300 + a millisecond-derived 4-decimal tail. */
function uniqueQty(): string {
  const tail = String(Date.now() % 10_000).padStart(4, '0');
  return `300.${tail}`;
}

test('a keeper receives goods, posts them, and the ledger and the balance agree', async ({
  as,
}) => {
  const page = await as('keeper');
  const qty = uniqueQty();
  const before = await balanceOf(PRODUCT.id, LOCATIONS.WH01.id);

  await gotoApp(page, '/inventory/goods-receipts/new');
  await expect(page.getByText('Yeni qəbul')).toBeVisible();

  // ---- header ------------------------------------------------------------------
  await page.getByLabel('Təchizatçı').selectOption({ label: 'Baku Food Supply' });
  await page
    .getByLabel('Qəbul lokasiyası')
    .selectOption({ label: `${LOCATIONS.WH01.name} (${LOCATIONS.WH01.code})` });

  // ---- line --------------------------------------------------------------------
  const lineTable = page.getByRole('table', { name: 'Qəbul sətirləri' });
  await expect(lineTable).toBeVisible();
  await lineTable.getByRole('combobox').first().selectOption({ label: `${PRODUCT.sku} · ${PRODUCT.name}` });
  // The quantity control is `QtyUomInput`: a text input with a unit select beside it.
  await lineTable.locator('input.wms-qty__num').first().fill(qty);

  // The keeper holds no `master.product.view_cost`, so the price column must not exist here
  // either — this is the write side of the same rule as the balances screen.
  const headers = await lineTable.getByRole('columnheader').allInnerTexts();
  expect(headers).not.toContain('Vahid qiymət');

  const create = page.getByRole('button', { name: 'Qaralama yarat' });
  await expect(create).toBeEnabled();
  await create.click();

  // ---- the draft ---------------------------------------------------------------
  await page.waitForURL(/\/inventory\/goods-receipts\/\d+$/);
  const receiptId = Number(page.url().split('/').pop());
  const docNo = (await page.locator('.wms-header__docno').innerText()).trim();
  expect(docNo, 'a goods receipt number is GR-yyyy-nnnnn').toMatch(/^GR-\d{4}-\d{5}$/);
  await expect(page.getByText('Qaralama', { exact: true })).toBeVisible();

  let row = await receiptRow(receiptId);
  expect(row?.status).toBe('DRAFT');
  expect(row?.movement_group_id ?? null).toBeNull();
  expect(
    await balanceOf(PRODUCT.id, LOCATIONS.WH01.id),
    'a draft must not touch the balance',
  ).toBe(before);

  // ---- post --------------------------------------------------------------------
  await page.getByRole('button', { name: 'Post et', exact: true }).click();
  const dialog = page.getByRole('dialog');
  await expect(dialog).toBeVisible();
  await expect(dialog).toContainText(docNo);
  await dialog.getByRole('button', { name: 'Post et', exact: true }).click();

  await expect(page.getByText(`Post edildi — ${docNo}`)).toBeVisible();
  await expect(page.getByText('Post edilmiş sənəd redaktə olunmur')).toBeVisible();
  // SPEC §9.4 — a posted document offers no edit, only a reversal.
  await expect(page.getByRole('button', { name: 'Redaktə et' })).toHaveCount(0);

  // ---- the ledger --------------------------------------------------------------
  row = await receiptRow(receiptId);
  expect(row?.status).toBe('POSTED');
  expect(row?.movement_group_id).toBeTruthy();

  // `inv_movement_group.source_doc_type` for a receipt is `GOODS_RECEIPT`.
  const group = await groupForSource('GOODS_RECEIPT', receiptId);
  expect(group, 'a posted receipt must produce a movement group').not.toBeNull();
  expect(group!.doc_type).toBe('RECEIPT');
  expect(Number(row!.movement_group_id)).toBe(Number(group!.id));

  const movements = await movementsOfGroup(group!.id);
  expect(movements, 'double entry: one line out of V_SUPPLIER, one into the warehouse').toHaveLength(2);

  const sum = movements.reduce((acc, m) => decimalAdd(acc, m.qty_base), '0');
  expect(normalizeDecimal(sum), 'SPEC §12.3 — the group must sum to exactly zero').toBe('0');

  const supplierLine = movements.find((m) => Number(m.location_id) === LOCATIONS.V_SUPPLIER.id);
  const warehouseLine = movements.find((m) => Number(m.location_id) === LOCATIONS.WH01.id);
  expect(supplierLine, 'the counter-entry must be at V_SUPPLIER').toBeTruthy();
  expect(warehouseLine, 'the stock entry must be at WH-01').toBeTruthy();
  expect(decimalEquals(warehouseLine!.qty_base, qty)).toBe(true);
  expect(decimalEquals(supplierLine!.qty_base, `-${qty}`)).toBe(true);
  expect(Number(warehouseLine!.product_id)).toBe(PRODUCT.id);

  // ---- the balance -------------------------------------------------------------
  const after = await balanceOf(PRODUCT.id, LOCATIONS.WH01.id);
  expect(
    normalizeDecimal(after),
    `balance must rise by exactly ${qty}: ${before} → ${after}`,
  ).toBe(normalizeDecimal(decimalAdd(before, qty)));

  // ---- and the screen says the same thing --------------------------------------
  await gotoApp(page, `/inventory/movement-groups/${group!.id}`);
  await expect(page.locator('.wms-header__docno')).toContainText(group!.doc_no);
  const ledgerTable = page.getByRole('table', { name: new RegExp(`${group!.doc_no}`) });
  await expect(ledgerTable).toBeVisible();
  // The zero-sum check row is the interface twin of the nightly DoubleEntryCheck job.
  await expect(page.getByTestId('wms-ledger-balance-check')).toBeVisible();
  await expect(page.getByTestId('wms-ledger-balance-check')).toContainText('0');
});

test('a receipt line that differs from the ordered quantity demands a variance note', async ({
  as,
}) => {
  // SPEC §12.8 — `receipt_under_tolerance_pct = 0`, so any shortfall needs a reason in writing.
  const page = await as('keeper');
  await gotoApp(page, '/inventory/goods-receipts/new');

  await page.getByLabel('Təchizatçı').selectOption({ label: 'Baku Food Supply' });
  await page
    .getByLabel('Qəbul lokasiyası')
    .selectOption({ label: `${LOCATIONS.WH01.name} (${LOCATIONS.WH01.code})` });

  const lineTable = page.getByRole('table', { name: 'Qəbul sətirləri' });
  await lineTable.getByRole('combobox').first().selectOption({ label: `${PRODUCT.sku} · ${PRODUCT.name}` });
  // «Sifariş» is the PO quantity; its placeholder says «PO-suz» while it is empty.
  await lineTable.getByPlaceholder('PO-suz').fill('100');
  await lineTable.locator('input.wms-qty__num').first().fill('90');

  // The document-level warning appears, the field error names the server code, and the primary
  // action is refused with the reason in its `title`.
  await expect(page.getByText('1 sətirdə PO ilə fərq var')).toBeVisible();
  await expect(page.getByText('VARIANCE_NOTE_REQUIRED')).toBeVisible();
  const create = page.getByRole('button', { name: 'Qaralama yarat' });
  await expect(create).toBeDisabled();
  await expect(create).toHaveAttribute('title', /xəta/);

  // Writing the reason releases it.
  await lineTable.getByPlaceholder('Fərqin səbəbi — məcburi').fill('Çatdırılmada əskik gəldi');
  await expect(create).toBeEnabled();
});

test('a product that requires a batch cannot be received without one', async ({ as }) => {
  // SPEC §9.2 — TOMATO carries requiresBatch and requiresExpiry.
  const page = await as('keeper');
  await gotoApp(page, '/inventory/goods-receipts/new');

  await page.getByLabel('Təchizatçı').selectOption({ label: 'Baku Food Supply' });
  await page
    .getByLabel('Qəbul lokasiyası')
    .selectOption({ label: `${LOCATIONS.WH01.name} (${LOCATIONS.WH01.code})` });

  const lineTable = page.getByRole('table', { name: 'Qəbul sətirləri' });
  await lineTable.getByRole('combobox').first().selectOption({ label: 'TOMATO · Pomidor' });
  await lineTable.locator('input.wms-qty__num').first().fill('5');

  await expect(
    page.getByText('Bu məhsul partiya tələb edir — partiya nömrəsi yazın.'),
  ).toBeVisible();
  await expect(page.getByText('Bu məhsul son istifadə tarixi tələb edir.')).toBeVisible();
  await expect(page.getByRole('button', { name: 'Qaralama yarat' })).toBeDisabled();
});
