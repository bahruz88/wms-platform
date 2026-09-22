import { expect, newSignedInContext, problemsOf, resetProblems, test, watch } from '../fixtures/wms';
import { gotoApp, sidebar } from '../helpers/login';
import { one } from '../helpers/db';

/**
 * A smoke pass over every route the application declares, driven as `admin`.
 *
 * Three separate questions are asked, because they have three different answers:
 *
 *   1. does the screen render at all, and without the browser complaining? A console error, an
 *      unhandled rejection or a request that never completed is a failure, not a log line.
 *   2. did the gateway answer any request with a 5xx? That is always a defect.
 *   3. did the gateway answer any request with a 4xx? Part of the contract is still not built
 *      (docs/ROADMAP.md §1), so this one is asserted against `UNROUTED_OPERATIONS` below: every
 *      operation the product is known to be missing is written down, with what is missing and
 *      why, and *anything else* is a failure. Kept separate from the 5xx check so that a new
 *      broken screen is visible the moment it appears rather than buried in the backlog.
 */

/**
 * Operations the product does not serve yet, and which a screen therefore calls into a 404.
 *
 * Matched on `METHOD path` with the query string ignored. Nothing goes on this list because it
 * is inconvenient — each entry is an operation whose implementation does not exist in the
 * repository at all, verified against the module's source, not merely a call that happens to
 * fail today. Anything that is not on the list fails the test.
 *
 * All five belong to the procurement module. `backend/src/Modules/Procurement` implements
 * purchase orders and nothing else: there is no requisition, RFQ, quotation, approval or price
 * history endpoint to route to, so the gateway forwards the call and the module answers 404.
 * The screens are built and waiting for them (docs/ROADMAP.md §1). The list shrinks as that
 * module lands; a leftover entry costs nothing, because an operation that starts answering
 * simply stops matching.
 */
const UNROUTED_OPERATIONS: ReadonlyArray<{ operation: string; why: string }> = [
  {
    operation: 'GET /api/v1/procurement/requisitions',
    why: 'Wms.Procurement has no requisition endpoint — ROADMAP §1',
  },
  {
    operation: 'GET /api/v1/procurement/rfqs',
    why: 'Wms.Procurement has no RFQ endpoint — ROADMAP §1',
  },
  {
    operation: 'GET /api/v1/procurement/quotations',
    why: 'Wms.Procurement has no quotation endpoint — ROADMAP §1',
  },
  {
    operation: 'GET /api/v1/procurement/approvals/pending',
    why: 'Wms.Procurement has no approval endpoint — ROADMAP §1',
  },
  {
    operation: 'GET /api/v1/procurement/price-history',
    why: 'Wms.Procurement has no price history endpoint — ROADMAP §1',
  },
];

/** `"404 GET http://host/api/v1/x?page=1"` → `"GET /api/v1/x"`. */
function operationOf(httpError: string): string {
  const [, method, url] = /^\d{3} (\S+) (\S+)$/.exec(httpError) ?? [];
  if (!method || !url) return httpError;
  try {
    return `${method} ${new URL(url).pathname}`;
  } catch {
    return `${method} ${url}`;
  }
}

function isKnownUnrouted(httpError: string): boolean {
  const operation = operationOf(httpError);
  return UNROUTED_OPERATIONS.some((known) => known.operation === operation);
}

const STATIC_ROUTES = [
  '/',
  '/procurement/requisitions',
  '/procurement/rfqs',
  '/procurement/quotations',
  '/procurement/purchase-orders',
  '/procurement/approvals',
  '/procurement/price-history',
  '/inventory/balances',
  '/inventory/batches',
  '/inventory/goods-receipts',
  '/inventory/goods-receipts/new',
  '/inventory/movements',
  '/inventory/issues',
  '/inventory/issues/new',
  '/inventory/stock-requests',
  '/inventory/stock-requests/new',
  '/inventory/counts',
  '/inventory/waste',
  '/inventory/samples',
  '/inventory/returns',
  '/inventory/returns/new',
  '/master-data/products',
  '/master-data/suppliers',
  '/master-data/locations',
  '/master-data/uoms',
  '/master-data/reason-codes',
  '/master-data/currency-rates',
  '/consumption/recipes',
  '/consumption/sales-imports',
  '/consumption/sales-imports/csv',
  '/consumption/runs',
  '/consumption/variance',
  '/reporting/reports',
  '/reporting/exports',
  '/admin/users',
  '/admin/roles',
  '/admin/settings',
];

/** Detail routes need a real id, so they are resolved from the database at run time. */
async function detailRoutes(): Promise<string[]> {
  const rows = await Promise.all([
    one<{ id: number }>('SELECT id FROM inv_goods_receipt ORDER BY id DESC LIMIT 1'),
    one<{ id: number }>('SELECT id FROM inv_issue ORDER BY id DESC LIMIT 1'),
    one<{ id: number }>('SELECT id FROM inv_count ORDER BY id DESC LIMIT 1'),
    one<{ id: number }>('SELECT id FROM inv_waste ORDER BY id DESC LIMIT 1'),
    one<{ id: number }>('SELECT id FROM inv_sample ORDER BY id DESC LIMIT 1'),
    one<{ id: number }>('SELECT id FROM inv_return_to_vendor ORDER BY id DESC LIMIT 1'),
    one<{ id: number }>('SELECT id FROM inv_movement_group ORDER BY id DESC LIMIT 1'),
    one<{ id: number }>('SELECT id FROM inv_stock_request ORDER BY id DESC LIMIT 1'),
  ]);
  const [receipt, issue, count, waste, sample, rtv, group, request] = rows;

  const routes: string[] = [];
  if (receipt) routes.push(`/inventory/goods-receipts/${receipt.id}`);
  if (issue) routes.push(`/inventory/issues/${issue.id}`);
  if (count) routes.push(`/inventory/counts/${count.id}`);
  if (waste) routes.push(`/inventory/waste/${waste.id}`);
  if (sample) routes.push(`/inventory/samples/${sample.id}`);
  if (rtv) routes.push(`/inventory/returns/${rtv.id}`);
  if (group) routes.push(`/inventory/movement-groups/${group.id}`);
  if (request) routes.push(`/inventory/stock-requests/${request.id}`);
  return routes;
}

interface RouteReport {
  route: string;
  consoleErrors: string[];
  pageErrors: string[];
  failedRequests: string[];
  httpErrors: string[];
  rendered: boolean;
}

/** Walks every route once and records what the browser complained about on each. */
async function walk(page: import('@playwright/test').Page): Promise<RouteReport[]> {
  const routes = [...STATIC_ROUTES, ...(await detailRoutes())];
  const reports: RouteReport[] = [];
  const problems = problemsOf(page);

  for (const route of routes) {
    resetProblems(page);
    await gotoApp(page, route);
    await expect(sidebar(page)).toBeVisible();
    // Let the screen's queries settle before reading the tally.
    await page.waitForLoadState('networkidle').catch(() => undefined);

    const body = (await page.locator('body').innerText()).trim();
    reports.push({
      route,
      consoleErrors: [...problems.consoleErrors],
      pageErrors: [...problems.pageErrors],
      failedRequests: [...problems.failedRequests],
      httpErrors: [...problems.httpErrors],
      rendered: body.length > 80,
    });
  }
  return reports;
}

/**
 * The walk is expensive, so it runs once for the whole file and each test below asserts on one
 * dimension of the result. They stay independent of each other: none of them can fail because
 * another one did.
 */
let reports: RouteReport[] = [];

test.beforeAll(async ({ browser }) => {
  // Forty-five routes, each waited on until its queries settle.
  test.setTimeout(420_000);
  const context = await newSignedInContext(browser, 'admin');
  const page = await context.newPage();
  watch(page);
  try {
    reports = await walk(page);
  } finally {
    await context.close();
  }
});

test('every route renders something for an admin', async () => {
  const blank = reports.filter((r) => !r.rendered).map((r) => r.route);
  expect(reports.length, 'the walk produced no reports at all').toBeGreaterThan(30);
  expect(blank, `routes that rendered nothing: ${blank.join(', ')}`).toEqual([]);
});

test('no route logs a console error or an unhandled rejection', async () => {
  const offenders = reports
    .filter((r) => r.consoleErrors.length > 0 || r.pageErrors.length > 0)
    .map((r) => `${r.route} → ${[...r.consoleErrors, ...r.pageErrors].join(' ; ')}`);

  expect(offenders, `console / page errors:\n${offenders.join('\n')}`).toEqual([]);
});

test('no route leaves a request unfinished', async () => {
  const offenders = reports
    .filter((r) => r.failedRequests.length > 0)
    .map((r) => `${r.route} → ${r.failedRequests.join(' ; ')}`);

  expect(offenders, `requests that never completed:\n${offenders.join('\n')}`).toEqual([]);
});

test('no route provokes a 5xx from the gateway', async () => {
  const offenders = reports.flatMap((r) =>
    r.httpErrors.filter((e) => /^5\d\d /.test(e)).map((e) => `${r.route} → ${e}`),
  );

  expect(offenders, `server errors:\n${offenders.join('\n')}`).toEqual([]);
});

test('no route calls an endpoint the gateway does not serve', async ({}, testInfo) => {
  const clientErrors = reports.flatMap((r) =>
    r.httpErrors.filter((e) => /^4\d\d /.test(e)).map((e) => ({ route: r.route, error: e })),
  );

  // The recorded backlog, for the record — it is reported, never asserted away.
  const seen = new Set(clientErrors.map((e) => operationOf(e.error)));
  for (const known of UNROUTED_OPERATIONS) {
    testInfo.annotations.push({
      type: seen.has(known.operation) ? 'unrouted' : 'unrouted (no longer seen)',
      description: `${known.operation} — ${known.why}`,
    });
  }

  const offenders = clientErrors
    .filter((e) => !isKnownUnrouted(e.error))
    .map((e) => `${e.route} → ${e.error}`);

  expect(
    offenders,
    `client errors from the gateway that are NOT in the recorded backlog:\n${offenders.join('\n')}`,
  ).toEqual([]);
});
