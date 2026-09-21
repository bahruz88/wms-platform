import createClient, { type Client, type Middleware } from 'openapi-fetch';
import type { paths as CommonPaths } from './generated/common';
import type { paths as ConsumptionPaths } from './generated/consumption';
import type { paths as DocumentsPaths } from './generated/documents';
import type { paths as IdentityPaths } from './generated/identity';
import type { paths as InventoryPaths } from './generated/inventory';
import type { paths as MasterDataPaths } from './generated/masterdata';
import type { paths as NotificationsPaths } from './generated/notifications';
import type { paths as ProcurementPaths } from './generated/procurement';
import type { paths as ReportingPaths } from './generated/reporting';
import { ApiError, networkProblem, toProblemDetails, type ProblemDetails } from './problem';

/**
 * A thin typed layer on top of the generated types:
 *   · attaches the bearer token from the OIDC session;
 *   · adds an `Idempotency-Key` UUID to every POST (SPEC §13.2, mandatory);
 *   · parses `application/problem+json` into `ProblemDetails` and throws `ApiError`;
 *   · exposes paging as `{ items, page, size, total }` (SPEC §13.4).
 *
 * Module route prefixes come from each spec's `servers[0].url` (`/api/v1/<module>`); the base URL
 * is `VITE_API_BASE_URL` (docs/CONVENTIONS.md).
 */

/**
 * Empty (or unset) means same origin: requests go to `/api/v1/...` and the dev server, the preview
 * server or nginx proxies them to the gateway. Set it to an absolute URL only when the gateway
 * itself sends CORS headers for this origin.
 */
export const API_BASE_URL: string = import.meta.env?.VITE_API_BASE_URL ?? '';

export type TokenProvider = () => string | null | undefined;

let tokenProvider: TokenProvider = () => null;

/** Wired once by the auth provider so the client never imports the session directly. */
export function setTokenProvider(provider: TokenProvider): void {
  tokenProvider = provider;
}

type UnauthorizedHandler = (problem: ProblemDetails) => void;
let onUnauthorized: UnauthorizedHandler = () => {};

export function setUnauthorizedHandler(handler: UnauthorizedHandler): void {
  onUnauthorized = handler;
}

/** RFC 4122 v4. `crypto.randomUUID` is present in every browser the app targets. */
export function newIdempotencyKey(): string {
  if (typeof crypto !== 'undefined' && typeof crypto.randomUUID === 'function') {
    return crypto.randomUUID();
  }
  // Deterministic fallback for non-secure contexts and old test environments.
  const bytes = new Uint8Array(16);
  for (let i = 0; i < 16; i += 1) bytes[i] = Math.floor(Math.random() * 256);
  bytes[6] = ((bytes[6] as number) & 0x0f) | 0x40;
  bytes[8] = ((bytes[8] as number) & 0x3f) | 0x80;
  const hex = [...bytes].map((b) => b.toString(16).padStart(2, '0')).join('');
  return `${hex.slice(0, 8)}-${hex.slice(8, 12)}-${hex.slice(12, 16)}-${hex.slice(16, 20)}-${hex.slice(20)}`;
}

const authMiddleware: Middleware = {
  onRequest({ request }) {
    const token = tokenProvider();
    if (token) request.headers.set('Authorization', `Bearer ${token}`);
    request.headers.set('Accept', 'application/json, application/problem+json');
    if (request.method === 'POST' && !request.headers.has('Idempotency-Key')) {
      request.headers.set('Idempotency-Key', newIdempotencyKey());
    }
    return request;
  },
  async onResponse({ request, response }) {
    if (response.ok) return response;

    const contentType = response.headers.get('content-type') ?? '';
    let body: unknown = null;
    try {
      body = contentType.includes('json')
        ? await response.clone().json()
        : await response.clone().text();
    } catch {
      body = null;
    }

    const problem = toProblemDetails(
      body,
      response.status,
      response.statusText || 'Sorğu yerinə yetirilmədi',
      new URL(request.url).pathname,
    );
    if (problem.status === 401) onUnauthorized(problem);
    throw new ApiError(problem);
  },
};

// openapi-fetch's Client<Paths> constrains its parameter to `{}`; the generated `paths`
// interfaces satisfy it. `object` is not accepted by the library's own signature.
// eslint-disable-next-line @typescript-eslint/no-empty-object-type
function moduleClient<P extends {}>(prefix: string): Client<P> {
  const client = createClient<P>({
    baseUrl: `${API_BASE_URL}${prefix}`,
    // Resolve `fetch` at call time rather than at client-creation time, so a test (or a future
    // instrumentation wrapper) can replace it without rebuilding every module client.
    fetch: (request) => globalThis.fetch(request),
  });
  client.use(authMiddleware);
  return client;
}

export const identityApi = moduleClient<IdentityPaths>('/api/v1/identity');
export const masterDataApi = moduleClient<MasterDataPaths>('/api/v1/masterdata');
export const inventoryApi = moduleClient<InventoryPaths>('/api/v1/inventory');
export const procurementApi = moduleClient<ProcurementPaths>('/api/v1/procurement');
export const documentsApi = moduleClient<DocumentsPaths>('/api/v1/documents');
export const notificationsApi = moduleClient<NotificationsPaths>('/api/v1/notifications');
export const consumptionApi = moduleClient<ConsumptionPaths>('/api/v1/consumption');
export const reportingApi = moduleClient<ReportingPaths>('/api/v1/reporting');

/** `common.v1.yaml` has no paths of its own; the alias keeps the module list complete. */
export type CommonApiPaths = CommonPaths;

/** The paging envelope every list endpoint returns (SPEC §13.4). */
export interface Page<T> {
  items: T[];
  page: number;
  size: number;
  total: number;
}

export const MAX_PAGE_SIZE = 200;

export const emptyPage = <T>(size = 50): Page<T> => ({ items: [], page: 1, size, total: 0 });

/**
 * Normalises a list response. Some endpoints (`GET /menu-items/{id}/recipes`) return a bare array;
 * they are wrapped so screens always see the same shape.
 */
export function toPage<T>(payload: unknown, fallbackSize = 50): Page<T> {
  if (Array.isArray(payload)) {
    return {
      items: payload as T[],
      page: 1,
      size: payload.length || fallbackSize,
      total: payload.length,
    };
  }
  if (payload && typeof payload === 'object') {
    const p = payload as Record<string, unknown>;
    const items = Array.isArray(p.items) ? (p.items as T[]) : [];
    return {
      items,
      page: typeof p.page === 'number' ? p.page : 1,
      size: typeof p.size === 'number' ? p.size : fallbackSize,
      total: typeof p.total === 'number' ? p.total : items.length,
    };
  }
  return emptyPage<T>(fallbackSize);
}

export function pageCount(page: Page<unknown>): number {
  if (page.size <= 0) return 1;
  return Math.max(1, Math.ceil(page.total / page.size));
}

/**
 * Unwraps an `openapi-fetch` result. Non-2xx responses already threw inside the middleware; this
 * only guards the "204 with no body where a body was expected" case.
 */
export function unwrap<T>(result: { data?: T; error?: unknown }): T {
  if (result.data === undefined) {
    throw new ApiError(toProblemDetails(result.error ?? null, 0, 'Server boş cavab qaytardı'));
  }
  return result.data;
}

/** Wraps a fetch that may fail at the transport level into the same `ApiError` channel. */
export async function guarded<T>(fn: () => Promise<T>, instance?: string): Promise<T> {
  try {
    return await fn();
  } catch (error) {
    if (error instanceof ApiError) throw error;
    throw new ApiError(networkProblem(error, instance));
  }
}
