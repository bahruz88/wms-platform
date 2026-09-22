import type { Page } from '@playwright/test';
import { expect, test } from '../fixtures/wms';
import { gotoApp } from '../helpers/login';
import {
  balanceOf,
  decimalAdd,
  decimalEquals,
  decimalSub,
  groupsForSource,
  issueRow,
  movementsOfGroup,
  normalizeDecimal,
} from '../helpers/db';
import { LOCATIONS } from '../helpers/users';

/**
 * Issue to a branch — screen-map §3.6 and §3.7, SPEC §12.3.
 *
 * The flow is deliberately two-sided: the warehouse dispatches, the branch confirms, and between
 * the two the stock sits in `IN_TRANSIT` where it belongs to nobody. That is the point of the
 * design — a loss cannot hide in the gap — so the test asserts the middle state as hard as the
 * ends: after dispatch the source is down, the destination is unchanged, and `IN_TRANSIT` holds
 * the difference.
 */

/**
 * Each document-flow spec owns a different product, so two of them running in parallel can never
 * move the same `inv_balance` row and make each other's before/after arithmetic wrong.
 * This file: CHICKEN.
 */
const PRODUCT = { id: 2, sku: 'CHICKEN', name: 'Toyuq' };

function uniqueQty(): string {
  return `12.${String(Date.now() % 10_000).padStart(4, '0')}`;
}

/** Writes and saves a draft issue WH-01 → BR-ELM through the browser. Returns its id and number. */
async function createIssueDraft(page: Page, qty: string) {
  await gotoApp(page, '/inventory/issues/new');
  await expect(page.getByText('Yeni məxaric')).toBeVisible();

  await page.getByLabel('Məxaric tipi').selectOption('BRANCH_ISSUE');
  await page
    .getByLabel('Mənbə lokasiya')
    .selectOption({ label: `${LOCATIONS.WH01.name} (${LOCATIONS.WH01.code})` });
  await page
    .getByLabel('Hədəf lokasiya')
    .selectOption({ label: `${LOCATIONS.BR_ELM.name} (${LOCATIONS.BR_ELM.code})` });

  // The line's product picker is named «Məhsul» now that `Select` carries `ariaLabel`, but the
  // screen renders one per line, so a name alone is ambiguous. It is located by the placeholder
  // option the user reads, «Məhsul seçin», which only an unfilled line has.
  await page
    .getByRole('combobox')
    .filter({ has: page.getByRole('option', { name: 'Məhsul seçin' }) })
    .selectOption({ label: `${PRODUCT.sku} · ${PRODUCT.name}` });
  await page.getByLabel('Veriləcək miqdar').fill(qty);

  // The FEFO suggestion is always on screen — SPEC §12.4, «FEFO təklifi görünür olmalıdır».
  await expect(page.getByText('FEFO', { exact: true }).first()).toBeVisible();

  const create = page.getByRole('button', { name: 'Qaralama yarat' });
  await expect(create).toBeEnabled();
  await create.click();

  await page.waitForURL(/\/inventory\/issues\/\d+$/);
  const id = Number(page.url().split('/').pop());
  const docNo = (await page.locator('.wms-header__docno').innerText()).trim();
  return { id, docNo };
}

/** Dispatches a draft issue through the browser. */
async function dispatchIssue(page: Page) {
  await page.getByRole('button', { name: 'Yola sal', exact: true }).click();
  const dialog = page.getByRole('dialog');
  await expect(dialog).toBeVisible();
  await dialog.getByRole('button', { name: 'Yola sal', exact: true }).click();
  await expect(dialog).toBeHidden();
  // The status the user reads, then the explanation that goes with it.
  await expect(page.locator('.wms-header__docline')).toContainText('Yola salınıb');
  await expect(page.getByText('Mal yoldadır')).toBeVisible();
}

test('dispatching an issue moves the stock into IN_TRANSIT and nowhere else', async ({ as }) => {
  const page = await as('keeper');
  const qty = uniqueQty();

  const sourceBefore = await balanceOf(PRODUCT.id, LOCATIONS.WH01.id);
  const transitBefore = await balanceOf(PRODUCT.id, LOCATIONS.IN_TRANSIT.id);
  const targetBefore = await balanceOf(PRODUCT.id, LOCATIONS.BR_ELM.id);

  const { id, docNo } = await createIssueDraft(page, qty);
  expect(docNo).toMatch(/^IS-\d{4}-\d{5}$/);

  // A draft moves nothing.
  expect(await balanceOf(PRODUCT.id, LOCATIONS.WH01.id)).toBe(sourceBefore);
  expect((await issueRow(id))?.status).toBe('DRAFT');

  await dispatchIssue(page);

  const row = await issueRow(id);
  expect(row?.status).toBe('DISPATCHED');
  expect(row?.dispatch_group_id, 'dispatch must write a movement group').toBeTruthy();
  expect(row?.receipt_group_id ?? null, 'nothing has been confirmed yet').toBeNull();

  const movements = await movementsOfGroup(Number(row!.dispatch_group_id));
  expect(movements).toHaveLength(2);
  expect(normalizeDecimal(movements.reduce((a, m) => decimalAdd(a, m.qty_base), '0'))).toBe('0');

  const out = movements.find((m) => Number(m.location_id) === LOCATIONS.WH01.id);
  const inTransit = movements.find((m) => Number(m.location_id) === LOCATIONS.IN_TRANSIT.id);
  expect(out, 'the source warehouse must be debited').toBeTruthy();
  expect(inTransit, 'IN_TRANSIT must be credited').toBeTruthy();
  expect(decimalEquals(out!.qty_base, `-${qty}`)).toBe(true);
  expect(decimalEquals(inTransit!.qty_base, qty)).toBe(true);

  expect(normalizeDecimal(await balanceOf(PRODUCT.id, LOCATIONS.WH01.id))).toBe(
    normalizeDecimal(decimalSub(sourceBefore, qty)),
  );
  expect(normalizeDecimal(await balanceOf(PRODUCT.id, LOCATIONS.IN_TRANSIT.id))).toBe(
    normalizeDecimal(decimalAdd(transitBefore, qty)),
  );
  expect(
    normalizeDecimal(await balanceOf(PRODUCT.id, LOCATIONS.BR_ELM.id)),
    'the branch must not see the goods until it confirms them',
  ).toBe(normalizeDecimal(targetBefore));
});

test('confirming at the branch empties IN_TRANSIT and credits the branch', async ({ as }) => {
  const keeper = await as('keeper');
  const qty = uniqueQty();

  const sourceBefore = await balanceOf(PRODUCT.id, LOCATIONS.WH01.id);
  const transitBefore = await balanceOf(PRODUCT.id, LOCATIONS.IN_TRANSIT.id);
  const targetBefore = await balanceOf(PRODUCT.id, LOCATIONS.BR_ELM.id);

  const { id, docNo } = await createIssueDraft(keeper, qty);
  await dispatchIssue(keeper);

  // The receiving side. `admin` is used here only because it is the role the running interface
  // lets confirm at all — see the defect test below, which is about exactly that.
  const receiver = await as('admin');
  await gotoApp(receiver, `/inventory/issues/${id}`);
  await receiver.getByRole('button', { name: 'Qəbulu təsdiqlə' }).click();

  const dialog = receiver.getByRole('dialog');
  await expect(dialog).toBeVisible();
  // The quantity is pre-filled with what was sent; accepting it means «all of it arrived».
  await expect(dialog.getByLabel('Qəbul edilən miqdar')).toHaveValue(new RegExp(`^${qty}`));
  // No discrepancy, so the reason fields stay closed.
  await expect(dialog.getByLabel('Fərqin səbəbi')).toBeDisabled();
  await dialog.getByRole('button', { name: 'Təsdiqlə' }).click();
  await expect(dialog).toBeHidden();

  await expect(receiver.getByText('Sənəd bağlanıb — düzəliş storno ilə olur')).toBeVisible();

  const row = await issueRow(id);
  expect(row?.status, `${docNo} must be RECEIVED`).toBe('RECEIVED');
  expect(row?.receipt_group_id).toBeTruthy();

  // Two groups: the dispatch and the confirmation, each balancing to zero on its own.
  const groups = await groupsForSource('ISSUE', id);
  expect(groups.length, 'an issue writes one group on dispatch and one on confirmation').toBe(2);
  for (const group of groups) {
    const lines = await movementsOfGroup(group.id);
    expect(lines).toHaveLength(2);
    expect(normalizeDecimal(lines.reduce((a, m) => decimalAdd(a, m.qty_base), '0'))).toBe('0');
  }

  const receiptLines = await movementsOfGroup(Number(row!.receipt_group_id));
  const transitOut = receiptLines.find((m) => Number(m.location_id) === LOCATIONS.IN_TRANSIT.id);
  const branchIn = receiptLines.find((m) => Number(m.location_id) === LOCATIONS.BR_ELM.id);
  expect(decimalEquals(transitOut!.qty_base, `-${qty}`)).toBe(true);
  expect(decimalEquals(branchIn!.qty_base, qty)).toBe(true);

  // Both balances, measured against where they started.
  expect(normalizeDecimal(await balanceOf(PRODUCT.id, LOCATIONS.WH01.id))).toBe(
    normalizeDecimal(decimalSub(sourceBefore, qty)),
  );
  expect(normalizeDecimal(await balanceOf(PRODUCT.id, LOCATIONS.BR_ELM.id))).toBe(
    normalizeDecimal(decimalAdd(targetBefore, qty)),
  );
  expect(
    normalizeDecimal(await balanceOf(PRODUCT.id, LOCATIONS.IN_TRANSIT.id)),
    'IN_TRANSIT must be back where it started — nothing may be stranded there',
  ).toBe(normalizeDecimal(transitBefore));
});

/**
 * DEFECT — the branch user cannot confirm its own delivery.
 *
 * `RolePermissionMap.cs` grants BRANCH_USER `inv.issue.confirm`, and the service enforces that
 * exact code (`InventoryPermissions.IssueConfirm`). The web's client-side port in
 * `web/src/auth/permissions.ts` still grants the retired alias `inv.transfer.confirm`, so the
 * interface disables the one button this role exists to press. Left failing on purpose.
 */
test('the branch user can confirm the delivery addressed to it', async ({ as }) => {
  const keeper = await as('keeper');
  const qty = uniqueQty();
  const { id } = await createIssueDraft(keeper, qty);
  await dispatchIssue(keeper);

  const branch = await as('branch1');
  await gotoApp(branch, `/inventory/issues/${id}`);

  const confirm = branch.getByRole('button', { name: 'Qəbulu təsdiqlə' });
  await expect(confirm).toBeVisible();
  await expect(
    confirm,
    'BRANCH_USER holds inv.issue.confirm on the server; the interface must not disable it',
  ).toBeEnabled();
});

test('a discrepancy at confirmation demands a reason code and a note', async ({ as }) => {
  // SPEC §12.4 / screen-map §3.7 — receivedQty ≠ dispatchedQty is only accepted with a reason.
  const keeper = await as('keeper');
  const qty = uniqueQty();
  const { id } = await createIssueDraft(keeper, qty);
  await dispatchIssue(keeper);

  const receiver = await as('admin');
  await gotoApp(receiver, `/inventory/issues/${id}`);
  await receiver.getByRole('button', { name: 'Qəbulu təsdiqlə' }).click();

  const dialog = receiver.getByRole('dialog');
  const short = normalizeDecimal(decimalSub(qty, '1'));
  await dialog.getByLabel('Qəbul edilən miqdar').fill(short);

  const submit = dialog.getByRole('button', { name: 'Təsdiqlə' });
  await expect(submit).toBeDisabled();
  await expect(submit).toHaveAttribute('title', /səbəb kodu və qeyd məcburidir/i);

  // Reason alone is not enough; the note is mandatory too.
  await dialog.getByLabel('Fərqin səbəbi').selectOption({ index: 1 });
  await expect(submit).toBeDisabled();
  await dialog.getByLabel('Qeyd').fill('Çatdırılmada bir vahid əskik gəldi');
  await expect(submit).toBeEnabled();
});
