import { expect, test } from '../fixtures/wms';
import { gotoApp } from '../helpers/login';
import { apiCall, apiOk } from '../helpers/api';
import {
  balanceOf,
  decimalAdd,
  decimalEquals,
  decimalSub,
  groupForSource,
  movementsOfGroup,
  normalizeDecimal,
  wasteRow,
} from '../helpers/db';
import { LOCATIONS } from '../helpers/users';

/**
 * Waste — screen-map §3.9, SPEC §12.3 and §7.1.
 *
 * The rule this flow exists to prove is separation of duties: **the person who raised the waste
 * may not approve it**. The roadmap records that the check had been silently disabled because
 * the token carried no internal user id, so it is asserted twice here — once as the interface
 * refusing the button, and once as the server refusing the call.
 *
 * Raising the document with its photo is the mobile flow (`docs/ux/screen-map.md` §3.9 — the web
 * list says so: «Sənəd mobil tətbiqdə foto ilə yaradılır»), so the document is created through
 * the API the mobile app uses. Submit, approve and post all go through the browser.
 */

/** This spec owns TOMATO, so it cannot collide with a parallel spec's balance arithmetic. */
const PRODUCT = { id: 4, sku: 'TOMATO', name: 'Pomidor', baseUomId: 1, batchId: 5 };
// `WST-DMG` — reason_group WASTE, requiresApproval = true, which is what puts the document in
// front of a second person.
const REASON_DAMAGED = 6;

function uniqueQty(): string {
  return `4.${String(Date.now() % 10_000).padStart(4, '0')}`;
}

async function raiseWaste(qty: string) {
  const created = await apiOk<{ id: number; docNo: string; rowVersion: number }>(
    'keeper',
    'POST',
    '/api/v1/inventory/waste',
    {
      data: {
        docDate: new Date().toISOString().slice(0, 10),
        locationId: LOCATIONS.WH01.id,
        reasonCodeId: REASON_DAMAGED,
        note: 'e2e — zədələnmiş qablaşdırma',
        lines: [
          {
            productId: PRODUCT.id,
            batchId: PRODUCT.batchId,
            quantity: { value: qty, uomId: PRODUCT.baseUomId },
          },
        ],
      },
    },
  );
  return created;
}

test('waste goes draft → approval → posted, and the author may not approve it', async ({ as }) => {
  const qty = uniqueQty();
  const before = await balanceOf(PRODUCT.id, LOCATIONS.WH01.id);
  const wasteBefore = await balanceOf(PRODUCT.id, LOCATIONS.V_WASTE.id);

  const doc = await raiseWaste(qty);
  expect(doc.docNo).toMatch(/^WS-\d{4}-\d{5}$/);
  expect((await wasteRow(doc.id))?.status).toBe('DRAFT');

  // ---- the keeper who raised it sends it for approval, through the browser -------------
  const keeper = await as('keeper');
  await gotoApp(keeper, `/inventory/waste/${doc.id}`);
  await expect(keeper.locator('.wms-header__docno')).toContainText(doc.docNo);

  // A keeper must not see what the waste cost (SPEC §16).
  const lineTable = keeper.getByRole('table').first();
  expect(await lineTable.getByRole('columnheader').allInnerTexts()).not.toContain('Dəyər, AZN');

  await keeper.getByRole('button', { name: 'Təsdiqə göndər' }).click();
  let dialog = keeper.getByRole('dialog');
  await dialog.getByRole('button', { name: 'Təsdiqə göndər' }).click();
  await expect(dialog).toBeHidden();
  await expect.poll(async () => (await wasteRow(doc.id))?.status).toBe('PENDING_APPROVAL');

  // Nothing has moved yet — approval is not posting.
  expect(await balanceOf(PRODUCT.id, LOCATIONS.WH01.id)).toBe(before);

  // ---- SoD: the author is refused, by the interface and by the server -------------------
  await gotoApp(keeper, `/inventory/waste/${doc.id}`);
  const keeperApprove = keeper.getByRole('button', { name: 'Təsdiqlə' });
  await expect(keeperApprove, 'the keeper raised this document').toBeDisabled();
  await expect(keeperApprove).toHaveAttribute('title', /inv\.waste\.approve/);

  const selfApproval = await apiCall('keeper', 'POST', `/api/v1/inventory/waste/${doc.id}/approve`, {
    data: { rowVersion: (await wasteDoc(doc.id)).rowVersion, decision: 'APPROVED' },
  });
  expect(
    selfApproval.status,
    `the server must refuse a self-approval, answered ${selfApproval.status}: ${selfApproval.raw.slice(0, 200)}`,
  ).toBe(403);

  // ---- a second person approves ----------------------------------------------------------
  const manager = await as('manager');
  await gotoApp(manager, `/inventory/waste/${doc.id}`);
  await manager.getByRole('button', { name: 'Təsdiqlə' }).click();
  dialog = manager.getByRole('dialog');
  await dialog.getByRole('button', { name: 'Təsdiqlə' }).click();
  await expect(dialog).toBeHidden();
  await expect.poll(async () => (await wasteRow(doc.id))?.status).toBe('APPROVED');

  const approved = await wasteRow(doc.id);
  expect(Number(approved!.approved_by), 'the approver is recorded and is not the author').not.toBe(
    Number(approved!.created_by),
  );

  // ---- post ---------------------------------------------------------------------------------
  await gotoApp(keeper, `/inventory/waste/${doc.id}`);
  await keeper.getByRole('button', { name: 'Post et', exact: true }).click();
  dialog = keeper.getByRole('dialog');
  await expect(dialog).toContainText('Post geri alınmır');
  await dialog.getByRole('button', { name: 'Post et', exact: true }).click();
  await expect(dialog).toBeHidden();
  await expect.poll(async () => (await wasteRow(doc.id))?.status, { timeout: 20_000 }).toBe(
    'POSTED',
  );

  // ---- the ledger ------------------------------------------------------------------------
  const group = await groupForSource('WASTE', doc.id);
  expect(group, 'a posted waste must write a movement group').not.toBeNull();
  expect(group!.doc_type).toBe('WASTE');

  const movements = await movementsOfGroup(group!.id);
  expect(movements).toHaveLength(2);
  expect(
    normalizeDecimal(movements.reduce((a, m) => decimalAdd(a, m.qty_base), '0')),
    'waste is part of the ledger, not a column beside it (SPEC §12.3)',
  ).toBe('0');

  const out = movements.find((m) => Number(m.location_id) === LOCATIONS.WH01.id);
  const intoWaste = movements.find((m) => Number(m.location_id) === LOCATIONS.V_WASTE.id);
  expect(out, 'the warehouse is debited').toBeTruthy();
  expect(intoWaste, 'V_WASTE is credited — the loss is visible, not lost').toBeTruthy();
  expect(decimalEquals(out!.qty_base, `-${qty}`)).toBe(true);
  expect(decimalEquals(intoWaste!.qty_base, qty)).toBe(true);

  expect(normalizeDecimal(await balanceOf(PRODUCT.id, LOCATIONS.WH01.id))).toBe(
    normalizeDecimal(decimalSub(before, qty)),
  );
  expect(normalizeDecimal(await balanceOf(PRODUCT.id, LOCATIONS.V_WASTE.id))).toBe(
    normalizeDecimal(decimalAdd(wasteBefore, qty)),
  );
});

test('a waste document appears in the list with its reason code and status', async ({ as }) => {
  const qty = uniqueQty();
  const doc = await raiseWaste(qty);

  const page = await as('keeper');
  await gotoApp(page, '/inventory/waste');

  const table = page.getByRole('table', { name: 'Tullantı siyahısı' });
  await expect(table).toBeVisible();
  const row = table.getByRole('row').filter({ hasText: doc.docNo });
  await expect(row).toBeVisible();
  await expect(row).toContainText('Zədələnmiş');
  await expect(row).toContainText('Qaralama');
  await expect(row).toContainText(LOCATIONS.WH01.name);

  // The keeper never sees the money column, here either.
  expect(await table.getByRole('columnheader').allInnerTexts()).not.toContain('Dəyər, AZN');
});

async function wasteDoc(id: number) {
  return apiOk<{ rowVersion: number; status: string }>(
    'admin',
    'GET',
    `/api/v1/inventory/waste/${id}`,
  );
}
