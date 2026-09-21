import type { Balance, GoodsReceipt, Location, Movement, ProductSummary, Uom } from './endpoints';

/**
 * Contract-shape adapters.
 *
 * `contracts/openapi/*.v1.yaml` model a product, location or batch on a row as an embedded
 * reference object (`ProductRef`, `LocationRef`, `BatchRef`). Several endpoints that are live on
 * the gateway today still answer with the flat foreign keys instead — `GET /inventory/balances`
 * returns `productId` / `locationId` / `batchId`, and `GET /inventory/goods-receipts/{id}` returns
 * `productId` / `uomId` on each line.
 *
 * Rather than weaken the generated types or scatter `?.` through the screens, the divergence is
 * absorbed here: each adapter accepts either shape and always yields the contract shape, filling
 * the reference from the master-data lists the same gateway serves. When the endpoints are
 * corrected to match the contract, these functions become pass-throughs and can be deleted.
 *
 * Nothing here invents data: an id with no matching master-data row is shown as `#<id>`, which
 * reads as "this id, name not resolved" rather than as a name.
 */

type Loose = Record<string, unknown>;

const asRecord = (value: unknown): Loose =>
  typeof value === 'object' && value !== null ? (value as Loose) : {};
const num = (value: unknown): number | undefined => (typeof value === 'number' ? value : undefined);
const str = (value: unknown): string | undefined => (typeof value === 'string' ? value : undefined);

export type ProductIndex = ReadonlyMap<number, ProductSummary>;
export type LocationIndex = ReadonlyMap<number, Location>;
export type UomIndex = ReadonlyMap<number, Uom>;

export const indexById = <T extends { id: number }>(rows: readonly T[]): Map<number, T> =>
  new Map(rows.map((row) => [row.id, row]));

type ProductRef = Balance['product'];
type LocationRef = Balance['location'];
type BatchRef = NonNullable<Balance['batch']>;

/** Builds the contract's `ProductRef` from either the embedded object or a bare `productId`. */
export function productRef(row: unknown, products?: ProductIndex): ProductRef {
  const record = asRecord(row);
  const embedded = asRecord(record.product);
  const id = num(embedded.id) ?? num(record.productId) ?? 0;
  const known = products?.get(id);
  return {
    id,
    sku: str(embedded.sku) ?? known?.sku ?? `#${id}`,
    name: str(embedded.name) ?? known?.name ?? `#${id}`,
    baseUomId: num(embedded.baseUomId) ?? known?.baseUomId ?? 0,
    baseUomCode: str(embedded.baseUomCode) ?? str(record.baseUomCode) ?? known?.baseUomCode ?? '',
    requiresBatch:
      typeof embedded.requiresBatch === 'boolean' ? embedded.requiresBatch : known?.requiresBatch,
    requiresExpiry:
      typeof embedded.requiresExpiry === 'boolean'
        ? embedded.requiresExpiry
        : known?.requiresExpiry,
  };
}

/** Builds the contract's `LocationRef` from either the embedded object or a bare `locationId`. */
export function locationRef(row: unknown, locations?: LocationIndex): LocationRef {
  const record = asRecord(row);
  const embedded = asRecord(record.location);
  const id = num(embedded.id) ?? num(record.locationId) ?? 0;
  const known = locations?.get(id);
  return {
    id,
    code: str(embedded.code) ?? known?.code ?? `#${id}`,
    name: str(embedded.name) ?? str(record.locationName) ?? known?.name ?? `#${id}`,
    isVirtual:
      typeof embedded.isVirtual === 'boolean' ? embedded.isVirtual : (known?.isVirtual ?? false),
  };
}

/** `batchId = 0` means "no batch" in the projection, not "batch number zero". */
export function batchRef(row: unknown): BatchRef | null {
  const record = asRecord(row);
  const embedded = asRecord(record.batch);
  const id = num(embedded.id) ?? num(record.batchId) ?? 0;
  if (id === 0) return null;
  return {
    id,
    batchNo: str(embedded.batchNo) ?? str(record.batchNo) ?? `#${id}`,
    expiryDate: str(embedded.expiryDate) ?? str(record.expiryDate) ?? null,
    status: (str(embedded.status) ?? 'ACTIVE') as BatchRef['status'],
  };
}

export function normalizeBalance(
  raw: unknown,
  products?: ProductIndex,
  locations?: LocationIndex,
): Balance {
  const record = asRecord(raw);
  return {
    ...(record as unknown as Balance),
    product: productRef(raw, products),
    location: locationRef(raw, locations),
    batch: batchRef(raw),
    baseUomId: num(record.baseUomId) ?? productRef(raw, products).baseUomId,
    baseUomCode: str(record.baseUomCode) ?? productRef(raw, products).baseUomCode,
  };
}

export function normalizeMovement(
  raw: unknown,
  products?: ProductIndex,
  locations?: LocationIndex,
): Movement {
  const record = asRecord(raw);
  return {
    ...(record as unknown as Movement),
    product: productRef(raw, products),
    location: locationRef(raw, locations),
    batch: batchRef(raw),
  };
}

export function normalizeGoodsReceipt(
  raw: unknown,
  products?: ProductIndex,
  uoms?: UomIndex,
): GoodsReceipt {
  const record = asRecord(raw);
  const lines = Array.isArray(record.lines) ? record.lines : [];
  return {
    ...(record as unknown as GoodsReceipt),
    lines: lines.map((line) => {
      const lineRecord = asRecord(line);
      const uomId = num(lineRecord.uomId) ?? 0;
      return {
        ...(lineRecord as unknown as GoodsReceipt['lines'][number]),
        product: productRef(line, products),
        uomId,
        uomCode: str(lineRecord.uomCode) ?? uoms?.get(uomId)?.code ?? `#${uomId}`,
        // The server computes acceptedQtyBase; older responses omit it.
        acceptedQtyBase: str(lineRecord.acceptedQtyBase) ?? str(lineRecord.receivedQty) ?? '0',
      };
    }),
  };
}

/**
 * `Money` from a field the contract declares as `{ amount, currency }` but the live service
 * answers with as a bare decimal string.
 *
 * `GET /inventory/return-to-vendor/{id}` returns `"claimAmount": "40.0000"`. Reading
 * `.amount` off that yields `undefined`, which reaches `Decimal` and throws
 * `[DecimalError] Invalid argument: undefined` — the whole screen goes blank. Rather than let a
 * shape divergence take a document down, both shapes are accepted here and the screen always
 * gets the contract's object back.
 */
export function moneyRef(
  value: unknown,
  defaultCurrency = 'AZN',
): { amount: string; currency: string } | null {
  if (value === null || value === undefined) return null;
  if (typeof value === 'string') {
    return value.trim() === '' ? null : { amount: value, currency: defaultCurrency };
  }
  if (typeof value === 'number') return { amount: String(value), currency: defaultCurrency };
  const row = asRecord(value);
  const amount =
    str(row.amount) ?? (num(row.amount) !== undefined ? String(row.amount) : undefined);
  if (amount === undefined) return null;
  return { amount, currency: str(row.currency) ?? defaultCurrency };
}
