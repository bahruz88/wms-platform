import { expect, test } from '../fixtures/wms';
import { gotoApp } from '../helpers/login';
import {
  balanceOf,
  decimalAdd,
  decimalEquals,
  groupForSource,
  movementGroup,
  movementsOfGroup,
  normalizeDecimal,
  decimalSub,
  receiptRow,
  reversalOf,
} from '../helpers/db';
import { LOCATIONS } from '../helpers/users';

/**
 * Reversal (storno) — SPEC §9.4, design-system README «Storno geri qaytarma deyil».
 *
 * A posted document is never edited and never deleted. The only correction is a new, opposite
 * movement group written against the original, and **both stay in the ledger**. That is the
 * whole assertion set here:
 *
 *   · the original group is untouched after the reversal;
 *   · the reversal group carries `reverses_group_id` and sums to zero on its own;
 *   · line for line it is the negation of the original;
 *   · the balance is back exactly where it was before the document was posted — to the last
 *     decimal, not approximately.
 *
 * `inv.movement.reverse` is the manager's permission: a keeper posts, a manager reverses.
 */

/**
 * This spec owns ONION — see the note in `05-issue.spec.ts` on per-spec products. No other spec
 * moves this product, so `inv_balance` for (ONION, WH-01) is this file's alone and the
 * before/after arithmetic below holds however the suite is scheduled.
 */
const PRODUCT = { id: 6, sku: 'ONION', name: 'Soğan', baseUomCode: 'G' };

function uniqueQty(): string {
  return `21.${String(Date.now() % 10_000).padStart(4, '0')}`;
}

/**
 * The unit the quantity is entered in, chosen explicitly rather than taken from the default.
 *
 * `QtyUomInput` opens a receipt line on the product's **purchase** default (`master_product_uom.
 * is_purchase_default`), because that is how a delivery arrives — ONION is bought in KG and kept
 * in G, `factor_to_base = 1000`. The receipt therefore posts `entered_qty × conversion_rate` to
 * the ledger, and the screen prints that base equivalent under the field.
 *
 * This test used to type a figure and then assert that the base balance had risen by that same
 * figure, which is only true when the entry unit *is* the base unit. It was the test's
 * arithmetic that was wrong, not the ledger: `inv_movement` for the receipt it posted read
 * `entered_qty = 21.1088, conversion_rate = 1000.00000000, qty_base = 21108.8000`, the group
 * summed to zero, and `inv_balance` matched the ledger exactly (`10-invariants.spec.ts` §12.2
 * passed on the same data). Reversal restores the balance; nothing was broken there.
 *
 * So the unit is now pinned to the base one and the assertions are left as strict as they were.
 * The conversion path itself is asserted below, from the row the posting wrote.
 */
async function pickBaseUnit(lineTable: import('@playwright/test').Locator): Promise<void> {
  const unit = lineTable.getByLabel('Ölçü vahidi').first();
  await expect(unit).toBeVisible();
  await unit.selectOption({ label: PRODUCT.baseUomCode });
}

test('reversing a posted receipt puts the balance back exactly where it was', async ({ as }) => {
  const keeper = await as('keeper');
  const qty = uniqueQty();

  const baseline = await balanceOf(PRODUCT.id, LOCATIONS.WH01.id);

  // ---- post a receipt through the browser -------------------------------------------
  await gotoApp(keeper, '/inventory/goods-receipts/new');
  await keeper.getByLabel('Təchizatçı').selectOption({ label: 'Baku Food Supply' });
  await keeper
    .getByLabel('Qəbul lokasiyası')
    .selectOption({ label: `${LOCATIONS.WH01.name} (${LOCATIONS.WH01.code})` });
  const lineTable = keeper.getByRole('table', { name: 'Qəbul sətirləri' });
  await lineTable.getByRole('combobox').first().selectOption({ label: `${PRODUCT.sku} · ${PRODUCT.name}` });
  await pickBaseUnit(lineTable);
  await lineTable.getByLabel('Qəbul edilən miqdar').first().fill(qty);
  await keeper.getByRole('button', { name: 'Qaralama yarat' }).click();
  await keeper.waitForURL(/\/inventory\/goods-receipts\/\d+$/);
  const receiptId = Number(keeper.url().split('/').pop());

  await keeper.getByRole('button', { name: 'Post et', exact: true }).click();
  let dialog = keeper.getByRole('dialog');
  await dialog.getByRole('button', { name: 'Post et', exact: true }).click();
  await expect.poll(async () => (await receiptRow(receiptId))?.status, { timeout: 20_000 }).toBe(
    'POSTED',
  );

  const original = await groupForSource('GOODS_RECEIPT', receiptId);
  expect(original).not.toBeNull();

  // Entered in the base unit, so the ledger stores the figure as typed and freezes the rate it
  // used — ADR-008 / SPEC §12.1: a movement never depends on the conversion table of the day.
  const postedLines = await movementsOfGroup(original!.id);
  const postedIn = postedLines.find((m) => Number(m.location_id) === LOCATIONS.WH01.id);
  expect(decimalEquals(postedIn!.conversion_rate, '1')).toBe(true);
  expect(decimalEquals(postedIn!.entered_qty, qty)).toBe(true);
  expect(decimalEquals(postedIn!.qty_base, qty)).toBe(true);

  const afterPost = await balanceOf(PRODUCT.id, LOCATIONS.WH01.id);
  expect(normalizeDecimal(afterPost)).toBe(normalizeDecimal(decimalAdd(baseline, qty)));

  // ---- a keeper may not reverse ----------------------------------------------------------
  await gotoApp(keeper, `/inventory/movement-groups/${original!.id}`);
  const keeperButton = keeper.getByRole('button', { name: 'Storno et' });
  await expect(keeperButton, 'reversal belongs to the manager, not the keeper').toBeDisabled();
  await expect(keeperButton).toHaveAttribute('title', /inv\.movement\.reverse/);

  // ---- the manager reverses it -------------------------------------------------------------
  const manager = await as('manager');
  await gotoApp(manager, `/inventory/movement-groups/${original!.id}`);
  await expect(manager.locator('.wms-header__docno')).toContainText(original!.doc_no);

  // A posted group offers no edit — only the reversal (SPEC §9.4).
  await expect(manager.getByRole('button', { name: 'Redaktə et' })).toHaveCount(0);

  await manager.getByRole('button', { name: 'Storno et' }).click();
  dialog = manager.getByRole('dialog');
  await expect(dialog).toBeVisible();

  // A reversal without a reason code is refused by the interface before it is sent.
  const confirm = dialog.getByRole('button', { name: 'Storno et' });
  await expect(confirm).toBeDisabled();
  await expect(confirm).toHaveAttribute('title', /Səbəb kodu məcburidir/);

  // `ReasonCodePicker` labels each option «CODE · name» (components/ReasonCodePicker.tsx).
  await dialog.getByLabel('Səbəb kodu').selectOption({ label: 'ADJ-ERR · Səhv sənəd — düzəliş' });
  await dialog.getByLabel('Qeyd').fill('e2e — storno yoxlaması');
  await expect(confirm).toBeEnabled();
  await confirm.click();

  // The interface navigates to the reversal it just created.
  await manager.waitForURL(
    (url) =>
      /\/inventory\/movement-groups\/\d+$/.test(url.pathname) &&
      url.pathname !== `/inventory/movement-groups/${original!.id}`,
    { timeout: 30_000 },
  );
  const reversalId = Number(manager.url().split('/').pop());

  // ---- the ledger -----------------------------------------------------------------------------
  const reversal = await movementGroup(reversalId);
  expect(reversal, 'the reversal group must exist').not.toBeNull();
  expect(reversal!.doc_type).toBe('REVERSAL');
  expect(Number(reversal!.reverses_group_id)).toBe(Number(original!.id));
  expect(reversal!.doc_no, 'a reversal document number starts with REV-').toMatch(/^REV-/);

  const back = await reversalOf(original!.id);
  expect(Number(back?.id), 'the original must be reachable from its reversal').toBe(reversalId);

  // The original is untouched — a correction is never an edit.
  const originalLines = await movementsOfGroup(original!.id);
  expect(originalLines).toHaveLength(2);
  expect(normalizeDecimal(originalLines.reduce((a, m) => decimalAdd(a, m.qty_base), '0'))).toBe(
    '0',
  );

  const reversalLines = await movementsOfGroup(reversalId);
  expect(reversalLines).toHaveLength(originalLines.length);
  expect(normalizeDecimal(reversalLines.reduce((a, m) => decimalAdd(a, m.qty_base), '0'))).toBe(
    '0',
  );

  // Line for line, the reversal is the negation of the original.
  for (const line of originalLines) {
    const mirror = reversalLines.find(
      (r) =>
        Number(r.location_id) === Number(line.location_id) &&
        Number(r.product_id) === Number(line.product_id) &&
        Number(r.batch_id ?? 0) === Number(line.batch_id ?? 0),
    );
    expect(mirror, `no opposite line for location ${line.location_id}`).toBeTruthy();
    expect(
      decimalEquals(mirror!.qty_base, decimalSub('0', line.qty_base)),
      `${line.qty_base} should be mirrored by ${mirror!.qty_base}`,
    ).toBe(true);
  }

  // ---- the balance -------------------------------------------------------------------------
  expect(
    normalizeDecimal(await balanceOf(PRODUCT.id, LOCATIONS.WH01.id)),
    'the balance must return to exactly its value before the receipt was posted',
  ).toBe(normalizeDecimal(baseline));

  // ---- and the screen says so ----------------------------------------------------------------
  await gotoApp(manager, `/inventory/movement-groups/${original!.id}`);
  // The badge, the alert title and the alert body all say it; one visible instance is enough.
  await expect(manager.getByText('Storno edilib').first()).toBeVisible();
  await expect(
    manager.getByRole('status').filter({ hasText: 'Bu qrup artıq storno edilib' }),
  ).toContainText('INVALID_STATE_TRANSITION');
  await expect(
    manager.getByRole('button', { name: 'Storno et' }),
    'a group may be reversed only once',
  ).toHaveCount(0);

  await gotoApp(manager, `/inventory/movement-groups/${reversalId}`);
  await expect(manager.getByText('Storno sənədi').first()).toBeVisible();
  await expect(manager.getByTestId('wms-ledger-balance-check')).toContainText('0');
});
