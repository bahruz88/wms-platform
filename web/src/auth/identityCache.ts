/**
 * A session-scoped cache for the two identity reads the shell needs on every boot:
 * `GET /identity/me` and `GET /identity/tenant`.
 *
 * Both answer the same thing for the whole of a signed-in session — the effective permission
 * codes and the tenant's own name change when the user signs in, not when they open another
 * screen. But the application boots from scratch on every *document* load: a deep link, a
 * refresh, a link opened in a new tab, the browser's back button after a hard navigation. Each
 * of those re-asked the identity module for facts it had already been told, and since the
 * gateway limits a user to `RateLimiting:PermitPerMinute` (100) requests per minute, a handful
 * of navigations in quick succession spent the whole budget on `/me` and `/tenant` and the real
 * screen calls came back `429 RATE_LIMITED`.
 *
 * Rules the cache follows:
 *
 *   · it lives in `sessionStorage`, so it dies with the tab and is never written to disk;
 *   · every entry records the `sub` it was fetched for, so one user's answer can never be served
 *     to another on a shared machine — a different subject is a miss, not a hit;
 *   · it carries a short TTL, so a permission granted or revoked mid-session still reaches the
 *     interface without a sign-out;
 *   · `clearIdentityCache()` empties it on sign-out.
 *
 * It is a convenience, never a control. The gateway's `x-permission` is the only real check on
 * every operation (SPEC §16, docs/ux/screen-map.md §1), so the worst a stale entry can do is
 * offer a menu entry whose screen then answers `FORBIDDEN` in place.
 */

const PREFIX = 'wms.identity.';

/**
 * Long enough to cover a burst of navigations, short enough that a role change lands without a
 * sign-out. The realm's access token lives 15 minutes; this deliberately expires well inside it.
 */
export const IDENTITY_CACHE_TTL_MS = 60_000;

interface CacheEnvelope<T> {
  /** `sub` of the access token the answer was fetched with. */
  subject: string;
  fetchedAt: number;
  data: T;
}

function storage(): Storage | null {
  try {
    // Safari in private mode and a sandboxed iframe both throw on access, not on use.
    return typeof window === 'undefined' ? null : window.sessionStorage;
  } catch {
    return null;
  }
}

function read<T>(name: string, subject: string, now: number): T | undefined {
  const store = storage();
  if (!store) return undefined;
  try {
    const raw = store.getItem(PREFIX + name);
    if (!raw) return undefined;
    const envelope = JSON.parse(raw) as CacheEnvelope<T>;
    if (envelope.subject !== subject) return undefined;
    if (!(now - envelope.fetchedAt < IDENTITY_CACHE_TTL_MS)) return undefined;
    return envelope.data;
  } catch {
    return undefined;
  }
}

function write<T>(name: string, subject: string, now: number, data: T): void {
  const store = storage();
  if (!store) return;
  try {
    const envelope: CacheEnvelope<T> = { subject, fetchedAt: now, data };
    store.setItem(PREFIX + name, JSON.stringify(envelope));
  } catch {
    // A full or unavailable quota costs a cache hit, never the request itself.
  }
}

/**
 * Returns the cached answer for `name` when one was fetched for this `subject` inside the TTL,
 * otherwise calls `load` and caches what it returns.
 *
 * A rejected `load` is passed straight through and nothing is cached: a failed `/me` must be
 * retried on the next boot, not remembered as an answer.
 */
export async function identityCached<T>(
  name: 'me' | 'tenant',
  subject: string,
  load: () => Promise<T>,
): Promise<T> {
  // An anonymous or malformed token has no subject to key on; such a session is never cached.
  if (!subject) return load();

  const now = Date.now();
  const hit = read<T>(name, subject, now);
  if (hit !== undefined) return hit;

  const data = await load();
  write(name, subject, now, data);
  return data;
}

/** Drops every cached identity answer — called on sign-out and when a session is torn down. */
export function clearIdentityCache(): void {
  const store = storage();
  if (!store) return;
  try {
    for (const name of ['me', 'tenant']) store.removeItem(PREFIX + name);
  } catch {
    // nothing to do: the cache is advisory
  }
}
