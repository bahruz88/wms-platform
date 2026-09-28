import http from 'k6/http';
import { check, sleep } from 'k6';
import { Counter, Trend } from 'k6/metrics';

/*
 * SPEC §17.3 — the platform's only numeric acceptance criterion:
 *
 *   100 concurrent users, 2 000 movements/hour, with 1 000 000 existing `inv_movement` rows.
 *   Target: p95 < 2 s.
 *
 * Two scenarios run together, because the criterion asks for both at once: a hundred people
 * reading while the warehouse keeps posting. Measuring either alone would flatter the result —
 * reads are fast until writes are holding row locks on the same balances.
 *
 * The p95 threshold applies to `browse` only. Posting a document is a ledger write inside a
 * transaction that locks balance rows (`SKIP LOCKED`, spec §12.3); holding it to the same bar as
 * opening a list would make the number meaningless. `post` has its own, looser threshold and a
 * hard zero on failures — a refused ledger write is a defect, a slow one is not.
 */

const BASE = __ENV.BASE_URL || 'http://host.docker.internal:5001';
const KEYCLOAK = __ENV.KEYCLOAK_URL || 'http://host.docker.internal:8180';
const VUS = Number(__ENV.VUS || 100);
const DURATION = __ENV.DURATION || '3m';

// 2 000 movements/hour. Double-entry means every receipt line writes two movements, so the
// document rate is half the movement rate (spec §12.3, ADR-003).
const MOVEMENTS_PER_HOUR = Number(__ENV.MOVEMENTS_PER_HOUR || 2000);
const DOCS_PER_HOUR = Math.ceil(MOVEMENTS_PER_HOUR / 2);

const postedDocs = new Counter('wms_documents_posted');
const postedMovements = new Counter('wms_movements_posted');
const postDuration = new Trend('wms_post_duration', true);

export const options = {
  scenarios: {
    browse: {
      executor: 'constant-vus',
      vus: VUS,
      duration: DURATION,
      exec: 'browse',
      tags: { scenario: 'browse' },
    },
    post: {
      executor: 'constant-arrival-rate',
      rate: DOCS_PER_HOUR,
      timeUnit: '1h',
      duration: DURATION,
      preAllocatedVUs: 4,
      maxVUs: 12,
      exec: 'post',
      tags: { scenario: 'post' },
    },
  },
  thresholds: {
    // The criterion itself.
    'http_req_duration{scenario:browse}': ['p(95)<2000'],
    // A read that fails is not a slow read; it is a broken one.
    'http_req_failed{scenario:browse}': ['rate<0.01'],
    // A refused ledger write is a defect at any speed.
    'http_req_failed{scenario:post}': ['rate==0'],
    'wms_post_duration': ['p(95)<10000'],
  },
};

/*
 * Who reads what.
 *
 * A 403 is not a load signal: it returns in a millisecond, so mixing refusals into the measurement
 * flatters p95 while also counting as a failed request. Each role therefore only visits what its
 * permissions allow — verified against the running gateway, not assumed:
 *
 *   procurement  has no inv.movement.view / inv.issue.view
 *   keeper       has no proc.po.view
 */
const READS = {
  admin: [
    '/api/v1/inventory/balances?page=PAGE&size=50',
    '/api/v1/inventory/movements?page=PAGE&size=50',
    '/api/v1/inventory/goods-receipts?page=1&size=50',
    '/api/v1/inventory/issues?page=1&size=50',
    '/api/v1/masterdata/products?page=PAGE&size=50',
    '/api/v1/reporting/dashboard/summary',
    '/api/v1/procurement/purchase-orders?page=1&size=50',
    '/api/v1/notifications/inbox?page=1&size=50',
  ],
  manager: [
    '/api/v1/inventory/balances?page=PAGE&size=50',
    '/api/v1/inventory/movements?page=PAGE&size=50',
    '/api/v1/inventory/goods-receipts?page=1&size=50',
    '/api/v1/masterdata/products?page=PAGE&size=50',
    '/api/v1/reporting/dashboard/summary',
    '/api/v1/procurement/purchase-orders?page=1&size=50',
    '/api/v1/notifications/inbox?page=1&size=50',
  ],
  procurement: [
    '/api/v1/inventory/balances?page=PAGE&size=50',
    '/api/v1/inventory/goods-receipts?page=1&size=50',
    '/api/v1/masterdata/products?page=PAGE&size=50',
    '/api/v1/reporting/dashboard/summary',
    '/api/v1/procurement/purchase-orders?page=1&size=50',
    '/api/v1/notifications/inbox?page=1&size=50',
  ],
  keeper: [
    '/api/v1/inventory/balances?page=PAGE&size=50',
    '/api/v1/inventory/movements?page=PAGE&size=50',
    '/api/v1/inventory/goods-receipts?page=1&size=50',
    '/api/v1/inventory/issues?page=1&size=50',
    '/api/v1/masterdata/products?page=PAGE&size=50',
    '/api/v1/reporting/dashboard/summary',
    '/api/v1/notifications/inbox?page=1&size=50',
  ],
  auditor: [
    '/api/v1/inventory/balances?page=PAGE&size=50',
    '/api/v1/inventory/movements?page=PAGE&size=50',
    '/api/v1/inventory/goods-receipts?page=1&size=50',
    '/api/v1/inventory/issues?page=1&size=50',
    '/api/v1/masterdata/products?page=PAGE&size=50',
    '/api/v1/reporting/dashboard/summary',
    '/api/v1/procurement/purchase-orders?page=1&size=50',
  ],
};

/** Only these may create and post a goods receipt; the rest answer 403. */
const WRITERS = ['keeper', 'admin'];

/** One token per dev user, fetched once. The realm is not part of what is being measured. */
export function setup() {
  const users = Object.keys(READS);
  const tokens = [];
  for (const username of users) {
    const res = http.post(
      `${KEYCLOAK}/realms/wms/protocol/openid-connect/token`,
      { grant_type: 'password', client_id: 'wms-web', scope: 'openid', username, password: username },
      { headers: { 'Content-Type': 'application/x-www-form-urlencoded' } },
    );
    if (res.status === 200) tokens.push({ username, token: res.json('access_token') });
  }
  if (tokens.length === 0) throw new Error('no dev user could sign in — is Keycloak up?');

  // The reference data the write scenario needs. Read once so the measured run does not spend
  // requests discovering ids.
  const admin = tokens[0].token;
  const auth = { headers: { Authorization: `Bearer ${admin}` } };
  // Not every list endpoint answers with a page: `/masterdata/locations` returns a bare array.
  const rows = (res) => {
    const body = res.json();
    return Array.isArray(body) ? body : (body && body.items) || [];
  };

  const products = rows(http.get(`${BASE}/api/v1/masterdata/products?size=20&isActive=true&productType=FOOD`, auth));
  const locations = rows(http.get(`${BASE}/api/v1/masterdata/locations?size=50`, auth));
  const suppliers = rows(http.get(`${BASE}/api/v1/masterdata/suppliers?size=20&isActive=true`, auth));

  const real = locations.filter((l) => !l.isVirtual);
  if (products.length === 0 || real.length === 0 || suppliers.length === 0) {
    throw new Error(
      `reference data missing: ${products.length} products, ${real.length} real locations, ${suppliers.length} suppliers`,
    );
  }

  return { tokens, product: products[0], location: real[0], supplier: suppliers[0] };
}

const pick = (list) => list[Math.floor(Math.random() * list.length)];

function authFor(data, only) {
  const eligible = only ? data.tokens.filter((t) => only.includes(t.username)) : data.tokens;
  const who = pick(eligible.length > 0 ? eligible : data.tokens);
  return {
    username: who.username,
    headers: { Authorization: `Bearer ${who.token}` },
    tags: { user: who.username },
  };
}

/**
 * What a hundred people actually do: open lists, page through them, look at a document.
 *
 * The paths and the page sizes are the ones the screens use, so the numbers mean something for the
 * screens rather than for a synthetic endpoint.
 */
export function browse(data) {
  const auth = authFor(data);
  const page = 1 + Math.floor(Math.random() * 3);
  const path = pick(READS[auth.username]).replace('PAGE', String(page));

  const res = http.get(`${BASE}${path}`, auth);
  check(res, { 'read answered 2xx': (r) => r.status >= 200 && r.status < 300 });

  // A real user reads what they opened before opening the next thing.
  sleep(0.5 + Math.random());
}

/** Creates a goods receipt and posts it, which is what writes to the ledger. */
export function post(data) {
  const auth = authFor(data, WRITERS);
  const headers = {
    ...auth.headers,
    'Content-Type': 'application/json',
    'Idempotency-Key': uuid(),
  };

  const started = Date.now();
  const created = http.post(
    `${BASE}/api/v1/inventory/goods-receipts`,
    JSON.stringify({
      docDate: new Date().toISOString().slice(0, 10),
      supplierId: data.supplier.id,
      locationId: data.location.id,
      qualityStatus: 'ACCEPTED',
      lines: [
        {
          productId: data.product.id,
          // A decimal string all the way to the wire (ADR-008).
          receivedQty: '1.0000',
          uomId: data.product.baseUomId,
        },
      ],
    }),
    { headers, tags: { op: 'createGoodsReceipt' } },
  );
  if (!check(created, { 'receipt created': (r) => r.status === 201 })) return;

  const id = created.json('id');
  const posted = http.post(
    `${BASE}/api/v1/inventory/goods-receipts/${id}/post`,
    '{}',
    {
      headers: { ...auth.headers, 'Content-Type': 'application/json', 'Idempotency-Key': uuid() },
      tags: { op: 'postGoodsReceipt' },
    },
  );
  postDuration.add(Date.now() - started);

  if (check(posted, { 'receipt posted': (r) => r.status === 200 })) {
    postedDocs.add(1);
    // One line, double entry: the warehouse side and the supplier counter-account.
    postedMovements.add(2);
  }
}

/** k6 has no crypto.randomUUID; the key only has to be unique per request. */
function uuid() {
  const hex = '0123456789abcdef';
  let out = '';
  for (let i = 0; i < 36; i++) {
    if (i === 8 || i === 13 || i === 18 || i === 23) out += '-';
    else if (i === 14) out += '4';
    else out += hex[Math.floor(Math.random() * 16)];
  }
  return out;
}
