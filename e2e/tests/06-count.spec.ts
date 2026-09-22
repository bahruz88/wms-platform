import type { Page } from '@playwright/test';
import { expect, test } from '../fixtures/wms';
import { gotoApp } from '../helpers/login';
import { allPages, apiCall, apiOk, cancelOpenCountsAt, getCount } from '../helpers/api';
import {
  balanceOfBatch,
  countRow,
  decimalAdd,
  decimalEquals,
  decimalSub,
  groupForSource,
  movementsOfGroup,
  normalizeDecimal,
} from '../helpers/db';
import { LOCATIONS } from '../helpers/users';

/**
 * Stock count — screen-map §3.8, SPEC §12.6 and §12.7.
 *
 * This is the flow with the most rules in it, and all of them are asserted:
 *
 *   · freezing a location **blocks** every movement on it — the server answers
 *     `409 LOCATION_FROZEN` and the interface prints that code, because support works with the
 *     string (design-system README «Vəziyyətlər»);
 *   · a non-zero variance without a reason code is refused `422 REASON_CODE_REQUIRED` (§12.6);
 *   · the person who counted may not approve their own count (SoD, §7.1);
 *   · posting writes a `COUNT_ADJUST` group that balances against `V_ADJUSTMENT` and leaves the
 *     balance exactly at the counted quantity.
 *
 * Entering the counted quantities is the **mobile** half of this flow (ADR-013): the web app
 * says so on the screen («sayılan miqdarlar mobil tətbiqdən gəlir») and has no line-entry
 * control. Those two calls therefore go through the API the mobile app uses; everything a web
 * user does — create, freeze, review, submit, approve, post — goes through the browser.
 */

// A location nothing else in the suite writes to, so freezing it cannot disturb another test.
const COUNT_LOCATION = { id: 905, code: 'BR-28M', name: '28 May filialı' };

interface ProductRow {
  id: number;
  baseUomId: number;
}

/** `countedQuantity` is `{ value, uomId }`; the quantity is entered in the product's base UoM. */
function uomIdFor(productId: number, products: ProductRow[]): number {
  const product = products.find((p) => p.id === productId);
  if (!product) throw new Error(`product ${productId} is not in master data`);
  return product.baseUomId;
}

/** Creates a FULL count on `COUNT_LOCATION` through the browser and returns its id. */
async function createCount(page: Page): Promise<{ id: number; docNo: string }> {
  await gotoApp(page, '/inventory/counts');
  await page.getByRole('button', { name: 'Yeni sayım' }).click();

  const dialog = page.getByRole('dialog');
  await expect(dialog).toBeVisible();
  await dialog
    .getByLabel('Lokasiya')
    .selectOption({ label: `${COUNT_LOCATION.name} (${COUNT_LOCATION.code})` });
  await dialog.getByLabel('Sayım tipi').selectOption('FULL');
  await dialog.getByRole('button', { name: 'Yarat' }).click();

  await page.waitForURL(/\/inventory\/counts\/\d+$/);
  const id = Number(page.url().split('/').pop());
  const docNo = (await page.locator('.wms-header__docno').innerText()).trim();
  return { id, docNo };
}

async function freeze(page: Page) {
  await page.getByRole('button', { name: 'Lokasiyanı dondur' }).click();
  const dialog = page.getByRole('dialog');
  await expect(dialog).toBeVisible();
  await dialog.getByRole('button', { name: 'Dondur' }).click();
  await expect(dialog).toBeHidden();
}

test('a frozen location refuses a goods receipt and shows LOCATION_FROZEN on screen', async ({
  as,
}) => {
  await cancelOpenCountsAt(COUNT_LOCATION.id);
  const keeper = await as('keeper');

  const { id, docNo } = await createCount(keeper);
  expect(docNo).toMatch(/^IC-\d{4}-\d{5}$/);
  expect((await countRow(id))?.status).toBe('DRAFT');

  await freeze(keeper);

  // The document says the location is frozen, and it prints the code the server will answer.
  // `Alert` uses role="status" for every tone but `danger` (design-system/Alert.tsx).
  const alert = keeper.getByRole('status').filter({ hasText: 'lokasiyası dondurulub' });
  await expect(alert).toBeVisible();
  await expect(alert).toContainText('LOCATION_FROZEN');
  expect((await countRow(id))?.status).toBe('FROZEN');

  // Book quantities are captured at the moment of the freeze (§12.7).
  const frozen = await getCount('admin', id);
  expect(frozen.lines.length, 'freezing a FULL count writes a line per balance row').toBeGreaterThan(
    0,
  );

  // Now a receipt into that location, written and posted through the browser, must be refused.
  await gotoApp(keeper, '/inventory/goods-receipts/new');
  await keeper.getByLabel('Təchizatçı').selectOption({ label: 'Baku Food Supply' });
  await keeper
    .getByLabel('Qəbul lokasiyası')
    .selectOption({ label: `${COUNT_LOCATION.name} (${COUNT_LOCATION.code})` });
  const lineTable = keeper.getByRole('table', { name: 'Qəbul sətirləri' });
  await lineTable.getByRole('combobox').first().selectOption({ label: 'LETTUCE · Kahı' });
  await lineTable.locator('input.wms-qty__num').first().fill('5');
  await keeper.getByRole('button', { name: 'Qaralama yarat' }).click();
  await keeper.waitForURL(/\/inventory\/goods-receipts\/\d+$/);
  const receiptId = Number(keeper.url().split('/').pop());

  await keeper.getByRole('button', { name: 'Post et', exact: true }).click();
  const dialog = keeper.getByRole('dialog');
  await dialog.getByRole('button', { name: 'Post et', exact: true }).click();

  // The refusal is shown with its RFC 7807 code, inside the dialog the user is looking at.
  const refusal = dialog.getByRole('alert').filter({ hasText: 'LOCATION_FROZEN' });
  await expect(refusal).toBeVisible();
  await expect(refusal).toContainText('LOCATION_FROZEN');

  // And nothing was posted.
  const { receiptRow } = await import('../helpers/db');
  expect((await receiptRow(receiptId))?.status, 'a refused post must leave the draft alone').toBe(
    'DRAFT',
  );

  await cancelOpenCountsAt(COUNT_LOCATION.id);
});

test('a count runs from freeze to a posted COUNT_ADJUST group', async ({ as }) => {
  await cancelOpenCountsAt(COUNT_LOCATION.id);

  const keeper = await as('keeper');
  const { id, docNo } = await createCount(keeper);
  await freeze(keeper);

  // --- the mobile half: counted quantities, entered line by line -------------------
  let doc = await getCount('keeper', id);
  const line = doc.lines.find((l) => l.batch && Number(l.bookQty) > 10);
  expect(line, 'the frozen count must hold a batch line with stock to work with').toBeTruthy();

  const bookQty = line!.bookQty;
  const countedQty = normalizeDecimal(decimalSub(bookQty, '3'));
  const batchId = line!.batch!.id;
  const productId = line!.product.id;

  const uoms = await allPages<ProductRow>('admin', '/api/v1/masterdata/products');
  const balanceBefore = await balanceOfBatch(productId, COUNT_LOCATION.id, batchId);
  expect(decimalEquals(balanceBefore, bookQty), 'book qty is the balance at the freeze').toBe(true);

  // §12.6 — a variance with no reason code is refused, and the code says which rule.
  const refused = await apiCall('keeper', 'POST', `/api/v1/inventory/counts/${id}/lines`, {
    data: {
      rowVersion: (await getCount('keeper', id) as { rowVersion: number }).rowVersion,
      lines: [{ productId, batchId, countedQuantity: { value: countedQty, uomId: 1 } }],
      // uomId 1 is `G`, the base unit of the product this line is on.
    },
  });
  expect(refused.status, refused.raw.slice(0, 300)).toBe(422);
  expect(refused.code).toBe('REASON_CODE_REQUIRED');

  // With the reason code (`ADJ-COUNT`, group ADJUSTMENT) it is accepted.
  //
  // A FULL count may not go to review with a line left uncounted — the server answers
  // `422 COUNT_LINES_INCOMPLETE` — so every line is entered, as the shelf-by-shelf mobile flow
  // would. Only the one line under test differs from its book quantity.
  doc = await getCount('keeper', id);
  const allLines = doc.lines.map((l) => ({
    productId: l.product.id,
    batchId: l.batch?.id ?? null,
    countedQuantity: {
      value: l.id === line!.id ? countedQty : l.bookQty,
      uomId: uomIdFor(l.product.id, uoms),
    },
    ...(l.id === line!.id ? { reasonCodeId: 2, note: 'e2e sayım fərqi' } : {}),
  }));
  const accepted = await apiCall('keeper', 'POST', `/api/v1/inventory/counts/${id}/lines`, {
    data: { rowVersion: doc.rowVersion, lines: allLines },
  });
  expect(accepted.status, accepted.raw.slice(0, 300)).toBe(200);

  // --- back in the browser: the variance is on screen and explained -----------------
  await gotoApp(keeper, `/inventory/counts/${id}`);
  await expect(keeper.getByText('Bütün fərqlərin səbəbi var')).toBeVisible();
  const varianceTable = keeper.getByRole('table', { name: 'Sayım fərqləri' });
  await expect(varianceTable).toBeVisible();

  // The count screen must not show the value of the variance to a keeper (SPEC §16).
  expect(await varianceTable.getByRole('columnheader').allInnerTexts()).not.toContain('Dəyər, AZN');

  // --- submit for approval ----------------------------------------------------------
  await keeper.getByRole('button', { name: 'Fərqləri təsdiqə göndər' }).click();
  const submitDialog = keeper.getByRole('dialog');
  await submitDialog.getByRole('button', { name: 'Göndər' }).click();
  await expect(submitDialog).toBeHidden();
  await expect.poll(async () => (await countRow(id))?.status).toBe('REVIEW');

  // --- separation of duties ----------------------------------------------------------
  const keeperApprove = keeper.getByRole('button', { name: 'Təsdiqlə' });
  await expect(keeperApprove, 'the keeper who counted must not be able to approve').toBeDisabled();
  await expect(keeperApprove).toHaveAttribute('title', /SoD/);

  // --- approve as the manager ---------------------------------------------------------
  const manager = await as('manager');
  await gotoApp(manager, `/inventory/counts/${id}`);
  await manager.getByRole('button', { name: 'Təsdiqlə' }).click();
  const approveDialog = manager.getByRole('dialog');
  await expect(approveDialog).toContainText('Sayımı aparan özü təsdiqləyə bilməz');
  await approveDialog.getByRole('button', { name: 'Təsdiqlə' }).click();
  await expect(approveDialog).toBeHidden();
  await expect.poll(async () => (await countRow(id))?.status).toBe('APPROVED');

  // --- post ---------------------------------------------------------------------------
  await gotoApp(keeper, `/inventory/counts/${id}`);
  await keeper.getByRole('button', { name: 'Post et', exact: true }).click();
  const postDialog = keeper.getByRole('dialog');
  await postDialog.getByRole('button', { name: 'Post et', exact: true }).click();
  await expect(postDialog).toBeHidden();
  await expect.poll(async () => (await countRow(id))?.status, { timeout: 20_000 }).toBe('POSTED');

  // --- the ledger ----------------------------------------------------------------------
  const row = await countRow(id);
  expect(row?.adjust_group_id, `${docNo} must write an adjustment group`).toBeTruthy();

  const group = await groupForSource('COUNT', id);
  expect(group, 'the posted count must be traceable from the ledger').not.toBeNull();
  expect(group!.doc_type, 'SPEC §12.3 names this group COUNT_ADJUST').toBe('COUNT_ADJUST');
  expect(Number(row!.adjust_group_id)).toBe(Number(group!.id));

  const movements = await movementsOfGroup(group!.id);
  expect(movements.length).toBeGreaterThanOrEqual(2);
  expect(
    normalizeDecimal(movements.reduce((a, m) => decimalAdd(a, m.qty_base), '0')),
    'a COUNT_ADJUST group balances to zero like every other group',
  ).toBe('0');

  const atLocation = movements.filter((m) => Number(m.location_id) === COUNT_LOCATION.id);
  const atAdjustment = movements.filter(
    (m) => Number(m.location_id) === LOCATIONS.V_ADJUSTMENT.id,
  );
  expect(atLocation.length, 'the counted location is one side of the entry').toBeGreaterThan(0);
  expect(atAdjustment.length, 'V_ADJUSTMENT is the other side (§12.3)').toBeGreaterThan(0);

  const ours = atLocation.find(
    (m) => Number(m.product_id) === productId && Number(m.batch_id) === batchId,
  );
  expect(ours, 'the counted line must appear in the group').toBeTruthy();
  expect(decimalEquals(ours!.qty_base, '-3'), `expected −3, got ${ours!.qty_base}`).toBe(true);

  // --- the balance ------------------------------------------------------------------------
  expect(
    normalizeDecimal(await balanceOfBatch(productId, COUNT_LOCATION.id, batchId)),
    'after posting, the balance is exactly what was counted',
  ).toBe(normalizeDecimal(countedQty));

  // --- and the location is open for business again -------------------------------------
  await gotoApp(keeper, `/inventory/counts/${id}`);
  await expect(
    keeper.getByRole('status').filter({ hasText: 'lokasiyası dondurulub' }),
  ).toHaveCount(0);
});
