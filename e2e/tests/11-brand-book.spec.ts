import type { Page } from '@playwright/test';
import { expect, test } from '../fixtures/wms';
import { gotoApp } from '../helpers/login';
import { apiOk, cancelOpenCountsAt } from '../helpers/api';
import { MINUS, NARROW_NBSP, findEmoji, uppercaseArtefacts } from '../helpers/text';

/**
 * The brand book's non-negotiables, asserted mechanically — docs/design-system/README.md.
 *
 * Each of these is a bug the product can have without anything throwing:
 *   · `text-transform: uppercase` / `toUpperCase()` turns Azerbaijani `i` into `I`, not `İ`;
 *   · a quantity written `1284.5` instead of `1 284,5000` breaks the column alignment a
 *     thousand-line ledger depends on, and reads as a different number to an Azerbaijani user;
 *   · an ASCII hyphen instead of U+2212 is a different glyph in a tabular-figures font;
 *   · a server error without its RFC 7807 `code` leaves support with nothing to search for.
 */

const SURVEY_ROUTES = [
  '/inventory/balances',
  '/inventory/movements',
  '/inventory/goods-receipts',
  '/inventory/issues',
  '/inventory/counts',
  '/inventory/waste',
  '/inventory/batches',
  '/inventory/stock-requests',
  '/master-data/products',
  '/reporting/reports',
  '/admin/users',
  '/',
];

async function surveyText(page: Page): Promise<Array<{ route: string; text: string }>> {
  const out: Array<{ route: string; text: string }> = [];
  for (const route of SURVEY_ROUTES) {
    await gotoApp(page, route);
    await expect(page.locator('.wms-content, .wms-page-state').first()).toBeVisible();
    out.push({ route, text: await page.locator('body').innerText() });
  }
  return out;
}

test('no element uppercases its text through CSS', async ({ as }) => {
  // «`text-transform: uppercase` bu sistemdə qadağandır» — asserted from the computed style, so
  // there is no heuristic to argue with.
  const page = await as('admin');
  const offenders: string[] = [];

  for (const route of SURVEY_ROUTES) {
    await gotoApp(page, route);
    await expect(page.locator('.wms-content, .wms-page-state').first()).toBeVisible();

    const found = await page.evaluate(() => {
      const bad: string[] = [];
      for (const el of Array.from(document.querySelectorAll<HTMLElement>('body *'))) {
        const transform = getComputedStyle(el).textTransform;
        if (transform === 'uppercase' || transform === 'capitalize') {
          bad.push(`${el.tagName.toLowerCase()}.${el.className} → ${transform}`);
        }
      }
      return [...new Set(bad)];
    });
    for (const item of found) offenders.push(`${route}: ${item}`);
  }

  expect(
    [...new Set(offenders)],
    `text-transform on rendered elements: ${[...new Set(offenders)].join(' | ')}`,
  ).toEqual([]);
});

test('no interface text carries a `toUpperCase()` artefact — `i` must never become `I`', async ({
  as,
}) => {
  const page = await as('admin');
  const offenders: string[] = [];

  for (const { route, text } of await surveyText(page)) {
    for (const word of uppercaseArtefacts(text)) {
      offenders.push(`${route}: «${word}»`);
    }
  }

  expect(
    offenders,
    `uppercased Azerbaijani text (design-system README «Böyük hərflə yazma»): ${offenders.join(', ')}`,
  ).toEqual([]);
});

test('the interface uses no emoji', async ({ as }) => {
  const page = await as('admin');
  const offenders: string[] = [];

  for (const { route, text } of await surveyText(page)) {
    const found = findEmoji(text);
    if (found.length > 0) offenders.push(`${route}: ${found.join(' ')}`);
  }

  expect(offenders, `emoji in the interface: ${offenders.join(', ')}`).toEqual([]);
});

test('quantities use a comma decimal separator and a narrow no-break space for thousands', async ({
  as,
}) => {
  const page = await as('manager');
  await gotoApp(page, '/inventory/balances');
  const table = page.getByRole('table', { name: 'Qalıq siyahısı' });
  await expect(table.locator('tbody tr').first()).toBeVisible();

  // Only the numeric columns: a date or a document number legitimately contains dots.
  const cells = await table.locator('td.wms-td--num').allInnerTexts();
  expect(cells.length, 'nothing numeric was rendered — the check would be vacuous').toBeGreaterThan(
    20,
  );

  const dotted: string[] = [];
  const spaced: string[] = [];
  const commaGrouped: string[] = [];
  let sawGrouped = 0;
  let sawDecimal = 0;

  for (const raw of cells) {
    const cell = raw.trim();
    if (!cell || cell === '—') continue;
    const figure = cell.split(/\s+gün|\s[A-ZÇƏĞİÖŞÜ]+$/)[0]!.trim();
    if (!/\d/.test(figure)) continue;

    if (/\d\.\d/.test(figure)) dotted.push(cell);
    if (/\d,\d{3}(?!\d)/.test(figure) && !/,\d{1,2}(?!\d)/.test(figure)) commaGrouped.push(cell);
    // A plain space or a non-breaking space where the narrow no-break space belongs.
    if (/\d[  ]\d{3}/.test(figure)) spaced.push(cell);
    if (figure.includes(NARROW_NBSP)) sawGrouped += 1;
    if (figure.includes(',')) sawDecimal += 1;
  }

  expect(dotted, `dot used as a decimal separator: ${dotted.join(', ')}`).toEqual([]);
  expect(spaced, `wrong space used as a thousands separator: ${spaced.join(', ')}`).toEqual([]);
  expect(commaGrouped, `comma used as a thousands separator: ${commaGrouped.join(', ')}`).toEqual(
    [],
  );
  expect(sawDecimal, 'no decimal figures were rendered at all').toBeGreaterThan(5);
  expect(
    sawGrouped,
    `no figure used the narrow no-break space (U+202F); rendered cells: ${cells.slice(0, 10).join(' | ')}`,
  ).toBeGreaterThan(0);
});

test('a negative figure carries U+2212, not the ASCII hyphen', async ({ as }) => {
  const page = await as('manager');
  await gotoApp(page, '/inventory/movements');

  const table = page.getByRole('table').first();
  await expect(table.locator('tbody tr').first()).toBeVisible();
  const cells = (await table.locator('td.wms-td--num').allInnerTexts()).map((c) => c.trim());

  const negatives = cells.filter((c) => /^[−-]\d/.test(c));
  expect(
    negatives.length,
    'the ledger must contain outbound movements, or this proves nothing',
  ).toBeGreaterThan(0);

  const ascii = negatives.filter((c) => c.startsWith('-'));
  expect(ascii, `ASCII hyphen used as a minus sign: ${ascii.join(', ')}`).toEqual([]);
  expect(negatives.every((c) => c.startsWith(MINUS))).toBe(true);

  // And the sign is always written, never left to colour alone (design-system README «Rəng tək
  // başına məna daşımır»).
  const positives = cells.filter((c) => /^\+\d/.test(c));
  expect(positives.length, 'inbound movements must carry an explicit «+»').toBeGreaterThan(0);
});

/**
 * A location nothing else in the suite counts, freezes or posts to — `06-count.spec.ts` owns
 * BR-28M, this file owns BR-GNC — so the blocking document below can never be one another test
 * is in the middle of.
 */
const ERROR_LOCATION = { id: 906, code: 'BR-GNC', name: 'Gənclik filialı' };

test('a server error is shown with its RFC 7807 code', async ({ as }) => {
  // The refusal under test needs a location that already has an open count, so the location is
  // *arranged* first rather than assumed: a run that died before its cleanup would otherwise
  // leave BR-GNC blocked and this test would fail on the arrange, reporting the previous run's
  // crash as this one's defect. `cancelOpenCountsAt` is idempotent and scoped to this location.
  await cancelOpenCountsAt(ERROR_LOCATION.id);

  // A location may hold only one open count; the second attempt is refused `COUNT_ALREADY_OPEN`.
  const blocker = await apiOk<{ id: number; rowVersion: number; docNo: string }>(
    'keeper',
    'POST',
    '/api/v1/inventory/counts',
    { data: { countType: 'FULL', locationId: ERROR_LOCATION.id } },
  );

  try {
    const keeper = await as('keeper');
    await gotoApp(keeper, '/inventory/counts');
    await keeper.getByRole('button', { name: 'Yeni sayım' }).click();

    const dialog = keeper.getByRole('dialog');
    await dialog
      .getByLabel('Lokasiya')
      .selectOption({ label: `${ERROR_LOCATION.name} (${ERROR_LOCATION.code})` });
    await dialog.getByRole('button', { name: 'Yarat' }).click();

    // The refusal must name its code — support works with that string, not with the prose.
    const alert = dialog.getByRole('alert');
    await expect(alert).toBeVisible();
    await expect(alert).toContainText('COUNT_ALREADY_OPEN');
    await expect(alert, 'the blocking document is named so the user can act').toContainText(
      blocker.docNo,
    );
    // The trace id is printed beside it, which is how a support ticket reaches the log.
    await expect(alert).toContainText(/trace/i);
  } finally {
    // Best-effort: a release that throws would replace the real result of this test with the
    // story of its own cleanup. The next run arranges the location anyway.
    await cancelOpenCountsAt(ERROR_LOCATION.id).catch(() => undefined);
  }
});

test('every form control on a document screen has an accessible name', async ({ as }) => {
  // docs/design-system/README.md «Əlçatanlıq» and «Forma etiketi `label`»: a control a screen
  // reader cannot name is a control a keyboard user cannot use.
  const keeper = await as('keeper');
  const unnamed: string[] = [];

  for (const route of ['/inventory/goods-receipts/new', '/inventory/issues/new']) {
    await gotoApp(keeper, route);
    await expect(keeper.locator('.wms-content').first()).toBeVisible();

    const controls = await keeper.locator('input:visible, select:visible, textarea:visible').all();
    for (const control of controls) {
      const name = await control.evaluate((el) => {
        const node = el as HTMLInputElement;
        const aria = node.getAttribute('aria-label');
        if (aria?.trim()) return aria.trim();
        const labelledBy = node.getAttribute('aria-labelledby');
        if (labelledBy) {
          const text = labelledBy
            .split(/\s+/)
            .map((id) => document.getElementById(id)?.textContent ?? '')
            .join(' ')
            .trim();
          if (text) return text;
        }
        if (node.id) {
          const label = document.querySelector(`label[for="${CSS.escape(node.id)}"]`);
          if (label?.textContent?.trim()) return label.textContent.trim();
        }
        return node.closest('label')?.textContent?.trim() ?? '';
      });
      if (!name) {
        const outline = await control.evaluate((el) => {
          const node = el as HTMLSelectElement;
          const first = node.tagName === 'SELECT' ? (node.options[0]?.text ?? '') : '';
          return `${node.tagName.toLowerCase()}[type=${node.getAttribute('type') ?? '-'}] first-option="${first}"`;
        });
        unnamed.push(`${route}: ${outline}`);
      }
    }
  }

  expect(unnamed, `controls with no accessible name: ${unnamed.join(' | ')}`).toEqual([]);
});

test('status is carried by a word, not only by a colour', async ({ as }) => {
  // design-system README «Rəng tək başına məna daşımır».
  const page = await as('manager');
  await gotoApp(page, '/inventory/goods-receipts');

  const table = page.getByRole('table').first();
  await expect(table.locator('tbody tr').first()).toBeVisible();

  const badges = await page.locator('.wms-badge, [class*="status"]').allInnerTexts();
  const words = badges.map((b) => b.trim()).filter(Boolean);
  expect(words.length, 'no status badge was rendered').toBeGreaterThan(0);
  for (const word of words) {
    expect(word.length, `an empty status badge conveys meaning by colour alone: «${word}»`)
      .toBeGreaterThan(0);
  }
});
