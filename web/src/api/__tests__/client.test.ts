import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import {
  emptyPage,
  guarded,
  inventoryApi,
  newIdempotencyKey,
  pageCount,
  setTokenProvider,
  setUnauthorizedHandler,
  toPage,
} from '../client';
import { ApiError } from '../problem';

const originalFetch = globalThis.fetch;

function jsonResponse(body: unknown, init: ResponseInit = {}) {
  return new Response(JSON.stringify(body), {
    status: 200,
    headers: { 'content-type': 'application/json' },
    ...init,
  });
}

describe('typed API client', () => {
  let calls: Request[];

  beforeEach(() => {
    calls = [];
    globalThis.fetch = vi.fn(async (input: RequestInfo | URL, init?: RequestInit) => {
      const request = input instanceof Request ? input : new Request(input, init);
      calls.push(request);
      if (request.method === 'POST') {
        return jsonResponse({ id: 42, docNo: 'GR-2026-00001' }, { status: 201 });
      }
      return jsonResponse({ items: [], page: 1, size: 50, total: 0 });
    }) as typeof fetch;
    setTokenProvider(() => 'test-token');
    setUnauthorizedHandler(() => {});
  });

  afterEach(() => {
    globalThis.fetch = originalFetch;
    setTokenProvider(() => null);
  });

  it('attaches the bearer token to every request', async () => {
    await inventoryApi.GET('/balances', { params: { query: { page: 1, size: 50 } } });
    expect(calls[0]?.headers.get('authorization')).toBe('Bearer test-token');
  });

  it('sends no Authorization header when there is no session', async () => {
    setTokenProvider(() => null);
    await inventoryApi.GET('/balances', {});
    expect(calls[0]?.headers.get('authorization')).toBeNull();
  });

  it('accepts problem+json alongside json', async () => {
    await inventoryApi.GET('/balances', {});
    expect(calls[0]?.headers.get('accept')).toContain('application/problem+json');
  });

  it('adds an Idempotency-Key UUID to every POST (SPEC §13.2)', async () => {
    await inventoryApi.POST('/goods-receipts', {
      body: {
        docDate: '2026-09-21',
        supplierId: 1,
        locationId: 11,
        qualityStatus: 'ACCEPTED',
        lines: [],
      },
      params: { header: { 'Idempotency-Key': newIdempotencyKey() } },
    });
    const key = calls[0]?.headers.get('idempotency-key');
    expect(key).toMatch(/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i);
  });

  it('does not add an Idempotency-Key to a GET', async () => {
    await inventoryApi.GET('/balances', {});
    expect(calls[0]?.headers.get('idempotency-key')).toBeNull();
  });

  it('generates a distinct key per request', () => {
    const keys = new Set(Array.from({ length: 50 }, () => newIdempotencyKey()));
    expect(keys.size).toBe(50);
  });

  it('throws a typed ApiError carrying the problem code', async () => {
    globalThis.fetch = vi.fn(
      async () =>
        new Response(
          JSON.stringify({
            type: 'https://wms/errors/location-frozen',
            title: 'Lokasiya dondurulub',
            status: 409,
            code: 'LOCATION_FROZEN',
            detail: 'IS-2026-00998 sayımı davam edir',
          }),
          { status: 409, headers: { 'content-type': 'application/problem+json' } },
        ),
    ) as typeof fetch;

    await expect(inventoryApi.GET('/balances', {})).rejects.toSatisfy((error: unknown) => {
      expect(error).toBeInstanceOf(ApiError);
      const apiError = error as ApiError;
      expect(apiError.code).toBe('LOCATION_FROZEN');
      expect(apiError.status).toBe(409);
      expect(apiError.problem.detail).toBe('IS-2026-00998 sayımı davam edir');
      return true;
    });
  });

  it('notifies the unauthorized handler on a 401 so the session can be dropped', async () => {
    const onUnauthorized = vi.fn();
    setUnauthorizedHandler(onUnauthorized);
    globalThis.fetch = vi.fn(
      async () =>
        new Response(JSON.stringify({ title: 'Unauthorized', status: 401, code: 'UNAUTHORIZED' }), {
          status: 401,
          headers: { 'content-type': 'application/problem+json' },
        }),
    ) as typeof fetch;

    await expect(inventoryApi.GET('/balances', {})).rejects.toBeInstanceOf(ApiError);
    expect(onUnauthorized).toHaveBeenCalledOnce();
  });

  it('wraps a transport failure into the same ApiError channel', async () => {
    globalThis.fetch = vi.fn(async () => {
      throw new TypeError('Failed to fetch');
    }) as typeof fetch;

    await expect(guarded(() => inventoryApi.GET('/balances', {}))).rejects.toSatisfy(
      (error: unknown) => {
        expect(error).toBeInstanceOf(ApiError);
        expect((error as ApiError).code).toBe('NETWORK_UNAVAILABLE');
        return true;
      },
    );
  });
});

describe('paging', () => {
  it('passes a well-formed envelope through', () => {
    const page = toPage<number>({ items: [1, 2, 3], page: 2, size: 3, total: 11 });
    expect(page).toEqual({ items: [1, 2, 3], page: 2, size: 3, total: 11 });
  });

  it('wraps a bare array, as GET /menu-items/{id}/recipes returns', () => {
    expect(toPage<number>([1, 2])).toEqual({ items: [1, 2], page: 1, size: 2, total: 2 });
  });

  it('degrades safely on an unexpected payload', () => {
    expect(toPage(null, 25)).toEqual({ items: [], page: 1, size: 25, total: 0 });
    expect(emptyPage(10)).toEqual({ items: [], page: 1, size: 10, total: 0 });
  });

  it('computes the page count', () => {
    expect(pageCount({ items: [], page: 1, size: 50, total: 11 })).toBe(1);
    expect(pageCount({ items: [], page: 1, size: 50, total: 51 })).toBe(2);
    expect(pageCount({ items: [], page: 1, size: 50, total: 0 })).toBe(1);
  });
});
