import { request, type APIRequestContext } from '@playwright/test';
import { GATEWAY_URL, KEYCLOAK_URL } from '../playwright.config';
import { USERS, type UserName } from './users';

/**
 * Direct gateway access — **setup and teardown only**, never as a substitute for the browser.
 *
 * Two things live here legitimately:
 *   1. arranging state a test needs that the *web* product has no screen for. Counting shelf by
 *      shelf and raising a waste document with a photo are the mobile flows (ADR-013,
 *      docs/ux/screen-map.md §3.8, §3.9); the web side of those documents is review, approval and
 *      posting, and that is what the browser drives.
 *   2. reading back what the browser was served, so the assertion is on the real JSON.
 *
 * Nothing that the web app *does* have a screen for is done through here.
 */

const tokenCache = new Map<string, { token: string; expiresAt: number }>();

export async function accessToken(user: UserName): Promise<string> {
  const cached = tokenCache.get(user);
  if (cached && cached.expiresAt > Date.now() + 30_000) return cached.token;

  const ctx = await request.newContext();
  // Keycloak is restarted by the deployment work running alongside this suite; one retry keeps
  // an infrastructure blip from being reported as a product failure.
  let res = await ctx.post(`${KEYCLOAK_URL}/realms/wms/protocol/openid-connect/token`, {
    form: {
      grant_type: 'password',
      client_id: 'wms-web',
      username: user,
      password: USERS[user].password,
    },
  });
  if (!res.ok()) {
    await new Promise((r) => setTimeout(r, 2000));
    res = await ctx.post(`${KEYCLOAK_URL}/realms/wms/protocol/openid-connect/token`, {
      form: {
        grant_type: 'password',
        client_id: 'wms-web',
        username: user,
        password: USERS[user].password,
      },
    });
  }
  if (!res.ok()) {
    throw new Error(`Keycloak refused the password grant for ${user}: ${res.status()} ${await res.text()}`);
  }
  const body = (await res.json()) as { access_token: string; expires_in: number };
  await ctx.dispose();
  tokenCache.set(user, {
    token: body.access_token,
    expiresAt: Date.now() + body.expires_in * 1000,
  });
  return body.access_token;
}

export interface ApiResult<T = unknown> {
  status: number;
  body: T;
  /** RFC 7807 `code`, when the gateway answered a problem document. */
  code?: string;
  raw: string;
}

let sharedContext: APIRequestContext | null = null;

async function ctx(): Promise<APIRequestContext> {
  sharedContext ??= await request.newContext({ baseURL: GATEWAY_URL });
  return sharedContext;
}

export async function disposeApi(): Promise<void> {
  if (sharedContext) {
    await sharedContext.dispose();
    sharedContext = null;
  }
}

function uuid(): string {
  return crypto.randomUUID();
}

export async function apiCall<T = unknown>(
  user: UserName,
  method: 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE',
  path: string,
  options: { data?: unknown; rowVersion?: number } = {},
): Promise<ApiResult<T>> {
  const token = await accessToken(user);
  const headers: Record<string, string> = {
    Authorization: `Bearer ${token}`,
    Accept: 'application/json, application/problem+json',
  };
  if (method === 'POST') headers['Idempotency-Key'] = uuid();
  if (options.rowVersion !== undefined) headers['If-Match'] = String(options.rowVersion);
  if (options.data !== undefined) headers['Content-Type'] = 'application/json';

  const client = await ctx();
  const res = await client.fetch(path, {
    method,
    headers,
    ...(options.data !== undefined ? { data: options.data } : {}),
  });
  const raw = await res.text();
  let body: unknown = null;
  try {
    body = raw ? JSON.parse(raw) : null;
  } catch {
    body = raw;
  }
  const code =
    body && typeof body === 'object' && 'code' in body
      ? String((body as { code: unknown }).code)
      : undefined;
  return { status: res.status(), body: body as T, code, raw };
}

export async function apiOk<T = unknown>(
  user: UserName,
  method: 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE',
  path: string,
  options: { data?: unknown; rowVersion?: number } = {},
): Promise<T> {
  const res = await apiCall<T>(user, method, path, options);
  if (res.status >= 400) {
    throw new Error(`${method} ${path} → ${res.status} ${res.raw.slice(0, 500)}`);
  }
  return res.body;
}

const INV = '/api/v1/inventory';

/** `GET /identity/me` — the permissions and locations the server will actually enforce. */
export interface IdentityMe {
  user: { id: number; username: string; fullName: string };
  tenant: { id: number; code: string; name: string };
  roles: string[];
  permissions: string[];
  locationIds: number[];
  canViewCost: boolean;
}

export async function identityMe(user: UserName): Promise<IdentityMe> {
  return apiOk<IdentityMe>(user, 'GET', '/api/v1/identity/me');
}

/* ----------------------------------------------------- arrangement used by the suite */

/** Counted quantities are entered on mobile (screen-map §3.8); web has no line-entry screen. */
export async function enterCountLines(
  user: UserName,
  countId: number,
  rowVersion: number,
  lines: Array<{ lineId: number; countedQty: string; reasonCodeId?: number; note?: string }>,
) {
  return apiCall(user, 'POST', `${INV}/counts/${countId}/lines`, {
    rowVersion,
    data: { lines },
  });
}

/** Waste is raised on mobile with a photo (screen-map §3.9); web reviews, approves and posts. */
export async function createWaste(
  user: UserName,
  data: {
    docDate: string;
    locationId: number;
    reasonCodeId: number;
    note?: string;
    lines: Array<{ productId: number; batchId?: number; qty: string; uomId: number; note?: string }>;
  },
) {
  return apiCall<{ id: number; docNo: string; rowVersion: number }>(user, 'POST', `${INV}/waste`, {
    data,
  });
}

/**
 * `StockCount.OpenStatuses` — the statuses that make a location "already counted" and refuse a
 * second count there (`Wms.Inventory.Domain/Entities/StockCount.cs`).
 */
export const OPEN_COUNT_STATUSES = ['DRAFT', 'FROZEN', 'COUNTING', 'REVIEW', 'APPROVED'];

/**
 * Cancels every open count at `locationId`.
 *
 * A location may hold only one open count, so a run that died between creating one and cleaning
 * it up leaves the next run's `POST /counts` answering `422 COUNT_ALREADY_OPEN` — a failure that
 * belongs to the previous run, reported against the next one. Every test that opens a count
 * therefore *arranges* the location as well as releasing it: the arrange is idempotent and the
 * release is best-effort, so neither end can wedge the suite.
 *
 * It is scoped to one location on purpose. Each count-using spec owns a location nothing else
 * writes to (`06-count.spec.ts` BR-28M, `11-brand-book.spec.ts` BR-GNC), so this can never
 * cancel a document another test is in the middle of.
 */
export async function cancelOpenCountsAt(locationId: number): Promise<void> {
  const list = await apiCall<{
    items: Array<{ id: number; status: string; location: { id: number } }>;
  }>('admin', 'GET', `${INV}/counts?page=1&size=200`);
  if (list.status !== 200) return;

  for (const row of list.body.items ?? []) {
    if (row.location?.id !== locationId || !OPEN_COUNT_STATUSES.includes(row.status)) continue;
    const doc = await apiCall<{ rowVersion: number }>('admin', 'GET', `${INV}/counts/${row.id}`);
    if (doc.status !== 200) continue;
    await apiCall('admin', 'POST', `${INV}/counts/${row.id}/cancel`, {
      data: { rowVersion: doc.body.rowVersion },
    });
  }
}

export async function getCount(user: UserName, id: number) {
  return apiOk<{
    id: number;
    docNo: string;
    status: string;
    rowVersion: number;
    lines: Array<{
      id: number;
      product: { id: number; sku: string; name: string };
      batch?: { id: number; batchNo: string } | null;
      bookQty: string;
      countedQty: string | null;
      varianceQty: string | null;
      reasonCodeId: number | null;
    }>;
  }>(user, 'GET', `${INV}/counts/${id}`);
}

export async function getReceipt(user: UserName, id: number) {
  return apiOk<{ id: number; docNo: string; status: string; rowVersion: number }>(
    user,
    'GET',
    `${INV}/goods-receipts/${id}`,
  );
}

export async function getWaste(user: UserName, id: number) {
  return apiOk<{ id: number; docNo: string; status: string; rowVersion: number }>(
    user,
    'GET',
    `${INV}/waste/${id}`,
  );
}

export async function listBalances(
  user: UserName,
  query: Record<string, string | number> = {},
) {
  const qs = new URLSearchParams(Object.entries(query).map(([k, v]) => [k, String(v)])).toString();
  return apiCall<{
    items: Array<{
      product: { id: number; sku: string };
      location: { id: number; code: string };
      batch?: { id: number; batchNo: string } | null;
      qtyOnHand: string;
      avgUnitCost?: string;
      totalValue?: string;
    }>;
    total: number;
  }>(user, 'GET', `${INV}/balances${qs ? `?${qs}` : ''}`);
}

/**
 * Every page of a list endpoint.
 *
 * The gateway clamps `size` to 200 and says so in the envelope (`{page, size, total}`), so a
 * single oversized request quietly returns a prefix. Anything asserting «everything is there»
 * has to walk the pages.
 */
export async function allPages<T>(
  user: UserName,
  path: string,
  pageSize = 100,
): Promise<T[]> {
  const items: T[] = [];
  let page = 1;
  for (;;) {
    const joiner = path.includes('?') ? '&' : '?';
    const res = await apiCall<{ items: T[]; page: number; size: number; total: number }>(
      user,
      'GET',
      `${path}${joiner}page=${page}&size=${pageSize}`,
    );
    if (res.status !== 200) throw new Error(`GET ${path} page ${page} → ${res.status} ${res.raw.slice(0, 200)}`);
    items.push(...res.body.items);
    if (items.length >= res.body.total || res.body.items.length === 0) return items;
    page += 1;
    if (page > 100) throw new Error(`refusing to page past 100 pages of ${path}`);
  }
}

/** A batch with stock at a location, for issue and waste lines that must pick a real batch. */
export async function findStockedBatch(
  productId: number,
  locationId: number,
): Promise<{ batchId: number; batchNo: string; qty: string } | null> {
  const res = await listBalances('admin', { productId, locationId, page: 1, size: 50 });
  const row = (res.body.items ?? []).find((r) => r.batch && Number(r.qtyOnHand) > 0);
  if (!row?.batch) return null;
  return { batchId: row.batch.id, batchNo: row.batch.batchNo, qty: row.qtyOnHand };
}
