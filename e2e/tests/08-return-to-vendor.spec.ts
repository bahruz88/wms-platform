import { expect, test } from '../fixtures/wms';
import { gotoApp, navLabels } from '../helpers/login';
import { apiCall, apiOk, identityMe } from '../helpers/api';
import {
  balanceOf,
  decimalAdd,
  decimalEquals,
  decimalSub,
  groupForSource,
  movementsOfGroup,
  normalizeDecimal,
  returnRow,
} from '../helpers/db';
import { LOCATIONS } from '../helpers/users';

/**
 * Return to vendor — screen-map §3.11, SPEC §12.3 («Qaytarma: Food WH −8, V_SUPPLIER +8»).
 *
 * The state machine is `DRAFT → SENT → CLOSED`: sending credits the supplier and debits the
 * warehouse, closing records what the supplier agreed to.
 *
 * The first test drives it through the browser, which is the point of this suite. The second
 * drives the same flow through the gateway. Keeping both is deliberate: when only the first
 * fails, the defect is in the interface and the domain is sound.
 */

/** This spec owns CUCUMBER — see the note in `05-issue.spec.ts` on per-spec products. */
const PRODUCT = { id: 5, sku: 'CUCUMBER', name: 'Xiyar', baseUomId: 1, batchId: 8 };
const REASON_QUALITY = 9; // RET-QUAL, reason_group RETURN

function uniqueQty(): string {
  return `2.${String(Date.now() % 10_000).padStart(4, '0')}`;
}

/**
 * The interface half of §3.11, driven end to end.
 *
 * This test carried a «DEFECT — unreachable from the browser» notice for as long as
 * `navigation.ts` and `routes.tsx` gated the screens on the retired `inv.return.*` while the
 * server issued `inv.rtv.*`. Both sides now spell it `inv.rtv.*`, the «Qaytarma» entry is back
 * and the route opens, so the notice is gone and the flow is asserted for real.
 *
 * Two things in this test were wrong about the screen rather than about the product, and are
 * written down so they are not "fixed" back:
 *
 *   · **the reason code.** The document genuinely requires one — the screen keeps «Qaralama
 *     yarat» disabled and names the missing field in its `title`, and the domain demands
 *     `reasonCodeId` on create (the gateway-driven test below has always sent it). The browser
 *     test used to skip the field and never got as far as finding out.
 *   · **the confirm button of the close dialog.** It reads «Bağla», not «Yaz»; «Yaz» is a name
 *     the screen has never had. The dialog's own dismiss icon is labelled «Bağla» too
 *     (`design-system/Dialog.tsx`), so the footer button is the last of the two — the same
 *     disambiguation `web/src/features/inventory/__tests__/screens.test.tsx` uses.
 */
test('a keeper can open return to vendor and walk a document from draft to closed', async ({
  as,
}) => {
  const keeper = await as('keeper');
  const me = await identityMe('keeper');
  expect(me.permissions, 'the server grants the keeper return-to-vendor').toContain('inv.rtv.view');
  expect(me.permissions).toContain('inv.rtv.create');

  await gotoApp(keeper, '/inventory/balances');
  expect(
    await navLabels(keeper),
    'a user the server lets return goods must be offered «Qaytarma»',
  ).toContain('Qaytarma');

  await gotoApp(keeper, '/inventory/returns');
  await expect(
    keeper.getByRole('alert').filter({ hasText: 'Bu ekrana icazəniz yoxdur' }),
    'the return-to-vendor list must open for a keeper',
  ).toHaveCount(0);
  await expect(keeper.getByRole('heading', { name: 'Təchizatçıya qaytarma', level: 1 })).toBeVisible();

  // ---- create ---------------------------------------------------------------------------
  const qty = uniqueQty();
  await keeper.getByRole('button', { name: 'Yeni qaytarma' }).click();
  await keeper.waitForURL(/\/inventory\/returns\/new$/);

  await keeper.getByLabel('Təchizatçı').selectOption({ label: 'Baku Food Supply' });
  await keeper
    .getByLabel('Lokasiya')
    .selectOption({ label: `${LOCATIONS.WH01.name} (${LOCATIONS.WH01.code})` });
  // `ReasonCodePicker` labels each option «CODE · name» (components/ReasonCodePicker.tsx) and
  // this document's group is RETURN, so RET-QUAL is the same code the API-driven test sends.
  await keeper.getByLabel('Səbəb kodu').selectOption({ label: 'RET-QUAL · Keyfiyyət uyğunsuzluğu' });
  await keeper.getByLabel('Sətir 1 · məhsul').selectOption({ label: `${PRODUCT.sku} · ${PRODUCT.name}` });
  await keeper.getByLabel('Qaytarılan miqdar').fill(qty);

  const create = keeper.getByRole('button', { name: 'Qaralama yarat' });
  // The button names what is still missing when it is disabled; assert it is not, so a future
  // mandatory field shows up as «still blocked on X» rather than as a bare click timeout.
  await expect(create, (await create.getAttribute('title')) ?? undefined).toBeEnabled();
  await create.click();

  await keeper.waitForURL(/\/inventory\/returns\/\d+$/);
  const id = Number(keeper.url().split('/').pop());
  expect((await returnRow(id))?.status).toBe('DRAFT');

  // ---- send -----------------------------------------------------------------------------
  const before = await balanceOf(PRODUCT.id, LOCATIONS.WH01.id);
  await keeper.getByRole('button', { name: 'Təchizatçıya göndər' }).click();
  let dialog = keeper.getByRole('dialog');
  await dialog.getByRole('button', { name: 'Göndər' }).click();
  await expect(dialog).toBeHidden();
  await expect.poll(async () => (await returnRow(id))?.status).toBe('SENT');

  expect(normalizeDecimal(await balanceOf(PRODUCT.id, LOCATIONS.WH01.id))).toBe(
    normalizeDecimal(decimalSub(before, qty)),
  );

  // ---- close ------------------------------------------------------------------------------
  await keeper.getByRole('button', { name: 'Cavabı qeyd et' }).click();
  dialog = keeper.getByRole('dialog');
  await dialog.getByLabel('Nəticə').selectOption('ACCEPTED');
  // Two buttons in this dialog answer to «Bağla» — the header's dismiss icon and the footer's
  // confirm. The footer one is last; see the note in the docblock.
  await dialog.getByRole('button', { name: 'Bağla' }).last().click();
  await expect(dialog).toBeHidden();
  await expect.poll(async () => (await returnRow(id))?.status).toBe('CLOSED');
});

test('the return-to-vendor domain writes a balanced RETURN group against V_SUPPLIER', async () => {
  // Driven through the gateway, so a defect in the interface can never hide whether the domain
  // half of screen-map §3.11 works — when this passes and the browser test above does not, the
  // finding is «the screen», not «the ledger». Everything asserted here is the ledger.
  const qty = uniqueQty();
  const before = await balanceOf(PRODUCT.id, LOCATIONS.WH01.id);
  const supplierBefore = await balanceOf(PRODUCT.id, LOCATIONS.V_SUPPLIER.id);

  const created = await apiOk<{ id: number; docNo: string; rowVersion: number }>(
    'keeper',
    'POST',
    '/api/v1/inventory/return-to-vendor',
    {
      data: {
        docDate: new Date().toISOString().slice(0, 10),
        supplierId: 1,
        locationId: LOCATIONS.WH01.id,
        reasonCodeId: REASON_QUALITY,
        note: 'e2e — keyfiyyət uyğunsuzluğu',
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
  expect(created.docNo).toMatch(/^RV-\d{4}-\d{5}$/);
  expect((await returnRow(created.id))?.status).toBe('DRAFT');

  const doc = await apiOk<{ rowVersion: number }>(
    'keeper',
    'GET',
    `/api/v1/inventory/return-to-vendor/${created.id}`,
  );
  const sent = await apiCall(
    'keeper',
    'POST',
    `/api/v1/inventory/return-to-vendor/${created.id}/send`,
    { data: { rowVersion: doc.rowVersion } },
  );
  expect(sent.status, sent.raw.slice(0, 300)).toBe(200);
  expect((await returnRow(created.id))?.status).toBe('SENT');

  const group = await groupForSource('RTV', created.id);
  expect(group, 'sending a return writes the movement group').not.toBeNull();
  expect(group!.doc_type).toBe('RETURN');

  const movements = await movementsOfGroup(group!.id);
  expect(movements).toHaveLength(2);
  expect(normalizeDecimal(movements.reduce((a, m) => decimalAdd(a, m.qty_base), '0'))).toBe('0');

  const out = movements.find((m) => Number(m.location_id) === LOCATIONS.WH01.id);
  const toSupplier = movements.find((m) => Number(m.location_id) === LOCATIONS.V_SUPPLIER.id);
  expect(decimalEquals(out!.qty_base, `-${qty}`)).toBe(true);
  expect(decimalEquals(toSupplier!.qty_base, qty)).toBe(true);

  expect(normalizeDecimal(await balanceOf(PRODUCT.id, LOCATIONS.WH01.id))).toBe(
    normalizeDecimal(decimalSub(before, qty)),
  );
  expect(normalizeDecimal(await balanceOf(PRODUCT.id, LOCATIONS.V_SUPPLIER.id))).toBe(
    normalizeDecimal(decimalAdd(supplierBefore, qty)),
  );

  // Closing records the supplier's answer and does not move stock again.
  const afterSend = await apiOk<{ rowVersion: number }>(
    'keeper',
    'GET',
    `/api/v1/inventory/return-to-vendor/${created.id}`,
  );
  const closed = await apiCall(
    'keeper',
    'POST',
    `/api/v1/inventory/return-to-vendor/${created.id}/close`,
    {
      data: {
        rowVersion: afterSend.rowVersion,
        outcome: 'ACCEPTED',
        claimAmount: { amount: '10.0000', currency: 'AZN' },
        outcomeNote: 'e2e — təchizatçı qəbul etdi',
      },
    },
  );
  expect(closed.status, closed.raw.slice(0, 300)).toBe(200);
  expect((await returnRow(created.id))?.status).toBe('CLOSED');
  expect(
    normalizeDecimal(await balanceOf(PRODUCT.id, LOCATIONS.WH01.id)),
    'closing is paperwork; it must not move stock a second time',
  ).toBe(normalizeDecimal(decimalSub(before, qty)));
});
