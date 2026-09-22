import mysql from 'mysql2/promise';

/**
 * Read-only MySQL access for the assertions the browser cannot make.
 *
 * A screen saying «Post edildi» proves nothing on its own — the ledger has to have moved. Every
 * document flow in this suite ends here: the movement group sums to zero, the balance rose by
 * exactly the posted quantity, the group carries the expected `doc_type`.
 *
 * Decimals are read as strings (`decimalNumbers: false`, the driver default): `DECIMAL(18,4)`
 * through a JS `number` would quietly lose the precision the whole platform is built to keep
 * (ADR-008).
 */

const CONFIG = {
  host: process.env.WMS_DB_HOST ?? '127.0.0.1',
  port: Number(process.env.WMS_DB_PORT ?? 3308),
  user: process.env.WMS_DB_USER ?? 'root',
  password: process.env.WMS_DB_PASSWORD ?? 'wms_root',
  database: process.env.WMS_DB_NAME ?? 'wms',
  decimalNumbers: false,
  supportBigNumbers: true,
  bigNumberStrings: true,
};

let pool: mysql.Pool | null = null;

function db(): mysql.Pool {
  pool ??= mysql.createPool({ ...CONFIG, connectionLimit: 4, waitForConnections: true });
  return pool;
}

export async function closeDb(): Promise<void> {
  if (pool) {
    await pool.end();
    pool = null;
  }
}

export async function query<T = Record<string, unknown>>(
  sql: string,
  params: unknown[] = [],
): Promise<T[]> {
  const [rows] = await db().query(sql, params);
  return rows as T[];
}

export async function one<T = Record<string, unknown>>(
  sql: string,
  params: unknown[] = [],
): Promise<T | null> {
  const rows = await query<T>(sql, params);
  return rows[0] ?? null;
}

export async function scalar(sql: string, params: unknown[] = []): Promise<string | null> {
  const row = await one<Record<string, unknown>>(sql, params);
  if (!row) return null;
  const value = Object.values(row)[0];
  return value === null || value === undefined ? null : String(value);
}

/* ------------------------------------------------------------------ balances */

/**
 * `inv_balance.qty_on_hand` for one product at one location, summed over batches.
 * Returns `"0"` when the row does not exist yet, which is the same thing for an assertion.
 */
export async function balanceOf(productId: number, locationId: number): Promise<string> {
  const value = await scalar(
    `SELECT COALESCE(SUM(qty_on_hand), 0) FROM inv_balance
      WHERE tenant_id = 1 AND product_id = ? AND location_id = ?`,
    [productId, locationId],
  );
  return value ?? '0';
}

export async function balanceOfBatch(
  productId: number,
  locationId: number,
  batchId: number,
): Promise<string> {
  const value = await scalar(
    `SELECT COALESCE(SUM(qty_on_hand), 0) FROM inv_balance
      WHERE tenant_id = 1 AND product_id = ? AND location_id = ? AND batch_id = ?`,
    [productId, locationId, batchId],
  );
  return value ?? '0';
}

/* ------------------------------------------------------------------ movements */

export interface MovementRow {
  id: number;
  group_id: number;
  product_id: number;
  location_id: number;
  batch_id: number | null;
  qty_base: string;
  line_no: number;
  entered_qty: string;
  conversion_rate: string;
  unit_cost: string | null;
}

export interface GroupRow {
  id: number;
  doc_no: string;
  doc_type: string;
  source_doc_type: string | null;
  source_doc_id: number | null;
  reverses_group_id: number | null;
}

export async function movementGroup(groupId: number): Promise<GroupRow | null> {
  return one<GroupRow>(
    `SELECT id, doc_no, doc_type, source_doc_type, source_doc_id, reverses_group_id
       FROM inv_movement_group WHERE id = ?`,
    [groupId],
  );
}

export async function movementsOfGroup(groupId: number): Promise<MovementRow[]> {
  return query<MovementRow>(
    `SELECT id, group_id, product_id, location_id, batch_id, qty_base,
            line_no, entered_qty, conversion_rate, unit_cost
       FROM inv_movement WHERE group_id = ? ORDER BY id`,
    [groupId],
  );
}

/** The group a source document produced, e.g. ('RECEIPT', receiptId). */
export async function groupForSource(
  sourceDocType: string,
  sourceDocId: number,
): Promise<GroupRow | null> {
  return one<GroupRow>(
    `SELECT id, doc_no, doc_type, source_doc_type, source_doc_id, reverses_group_id
       FROM inv_movement_group
      WHERE tenant_id = 1 AND source_doc_type = ? AND source_doc_id = ?
      ORDER BY id DESC LIMIT 1`,
    [sourceDocType, sourceDocId],
  );
}

/** Every group this source document produced, oldest first (dispatch, then confirm). */
export async function groupsForSource(
  sourceDocType: string,
  sourceDocId: number,
): Promise<GroupRow[]> {
  return query<GroupRow>(
    `SELECT id, doc_no, doc_type, source_doc_type, source_doc_id, reverses_group_id
       FROM inv_movement_group
      WHERE tenant_id = 1 AND source_doc_type = ? AND source_doc_id = ?
      ORDER BY id`,
    [sourceDocType, sourceDocId],
  );
}

/** Sum of `qty_base` over one group, as a decimal string. SPEC §12.3 requires exactly zero. */
export async function groupSum(groupId: number): Promise<string> {
  return (await scalar(`SELECT COALESCE(SUM(qty_base), 0) FROM inv_movement WHERE group_id = ?`, [
    groupId,
  ]))!;
}

/* ------------------------------------------------------------------ invariants (SPEC §12) */

/** §12.3 — every movement group must balance to zero. Empty result is the only pass. */
export async function unbalancedGroups(): Promise<Array<{ group_id: number; total: string }>> {
  return query(
    `SELECT group_id, SUM(qty_base) AS total
       FROM inv_movement GROUP BY group_id HAVING SUM(qty_base) <> 0`,
  );
}

/** §12.1 — `allow_negative_stock = false`, so no physical location may hold a negative balance. */
export async function negativePhysicalStock(): Promise<
  Array<{ product_id: number; location_id: number; code: string; qty_on_hand: string }>
> {
  return query(
    `SELECT b.product_id, b.location_id, l.code, b.qty_on_hand
       FROM inv_balance b
       JOIN master_location l ON l.id = b.location_id
      WHERE l.is_virtual = 0 AND b.qty_on_hand < 0`,
  );
}

/** §12.2 — a balance row must never exceed what the ledger says it holds. */
export async function balanceLedgerDrift(): Promise<
  Array<{ product_id: number; location_id: number; batch_id: number; balance: string; ledger: string }>
> {
  return query(
    `SELECT b.product_id, b.location_id, b.batch_id,
            b.qty_on_hand AS balance,
            COALESCE(m.total, 0) AS ledger
       FROM inv_balance b
       LEFT JOIN (
            SELECT product_id, location_id, COALESCE(batch_id, 0) AS batch_id, SUM(qty_base) AS total
              FROM inv_movement WHERE tenant_id = 1
             GROUP BY product_id, location_id, COALESCE(batch_id, 0)
       ) m ON m.product_id = b.product_id
          AND m.location_id = b.location_id
          AND m.batch_id = COALESCE(b.batch_id, 0)
      WHERE b.tenant_id = 1 AND b.qty_on_hand <> COALESCE(m.total, 0)`,
  );
}

/* ------------------------------------------------------------------ documents */

export async function receiptRow(id: number) {
  return one<{ id: number; doc_no: string; status: string; movement_group_id: number | null }>(
    `SELECT id, doc_no, status, movement_group_id FROM inv_goods_receipt WHERE id = ?`,
    [id],
  );
}

export async function issueRow(id: number) {
  return one<{
    id: number;
    doc_no: string;
    status: string;
    dispatch_group_id: number | null;
    receipt_group_id: number | null;
  }>(
    `SELECT id, doc_no, status, dispatch_group_id, receipt_group_id FROM inv_issue WHERE id = ?`,
    [id],
  );
}

export async function countRow(id: number) {
  return one<{
    id: number;
    doc_no: string;
    status: string;
    location_id: number;
    adjust_group_id: number | null;
  }>(
    `SELECT id, doc_no, status, location_id, adjust_group_id FROM inv_count WHERE id = ?`,
    [id],
  );
}

/** `inv_movement_group` has no `reversed_by_group_id`; the back-reference is a self-join. */
export async function reversalOf(groupId: number): Promise<GroupRow | null> {
  return one<GroupRow>(
    `SELECT id, doc_no, doc_type, source_doc_type, source_doc_id, reverses_group_id
       FROM inv_movement_group WHERE reverses_group_id = ? ORDER BY id DESC LIMIT 1`,
    [groupId],
  );
}

export async function wasteRow(id: number) {
  return one<{
    id: number;
    doc_no: string;
    status: string;
    created_by: number;
    approved_by: number | null;
    movement_group_id: number | null;
  }>(
    `SELECT id, doc_no, status, created_by, approved_by, movement_group_id
       FROM inv_waste WHERE id = ?`,
    [id],
  );
}

export async function returnRow(id: number) {
  return one<{
    id: number;
    doc_no: string;
    status: string;
    movement_group_id: number | null;
  }>(
    `SELECT id, doc_no, status, movement_group_id FROM inv_return_to_vendor WHERE id = ?`,
    [id],
  );
}

/** Distinct location ids that currently hold a non-zero balance, for the scoping assertions. */
export async function locationsWithStock(): Promise<string[]> {
  const rows = await query<{ code: string }>(
    `SELECT DISTINCT l.code
       FROM inv_balance b JOIN master_location l ON l.id = b.location_id
      WHERE b.tenant_id = 1 AND b.qty_on_hand <> 0
      ORDER BY l.code`,
  );
  return rows.map((r) => r.code);
}

/** Decimal-safe equality for the strings MySQL and the API hand back. */
export function decimalEquals(a: string, b: string): boolean {
  return normalizeDecimal(a) === normalizeDecimal(b);
}

export function normalizeDecimal(value: string): string {
  const trimmed = String(value).trim().replace('−', '-');
  if (!/^-?\d+(\.\d+)?$/.test(trimmed)) return trimmed;
  const negative = trimmed.startsWith('-');
  const [int = '0', frac = ''] = trimmed.replace('-', '').split('.');
  const cleanFrac = frac.replace(/0+$/, '');
  const cleanInt = int.replace(/^0+(?=\d)/, '');
  const body = cleanFrac ? `${cleanInt}.${cleanFrac}` : cleanInt;
  return negative && body !== '0' ? `-${body}` : body;
}

/** a + b over decimal strings, without going through a float. */
export function decimalAdd(a: string, b: string): string {
  const scale = Math.max(fractionDigits(a), fractionDigits(b));
  const factor = 10n ** BigInt(scale);
  return formatScaled(toScaled(a, scale) + toScaled(b, scale), scale, factor);
}

export function decimalSub(a: string, b: string): string {
  const scale = Math.max(fractionDigits(a), fractionDigits(b));
  const factor = 10n ** BigInt(scale);
  return formatScaled(toScaled(a, scale) - toScaled(b, scale), scale, factor);
}

function fractionDigits(value: string): number {
  const [, frac = ''] = String(value).trim().split('.');
  return frac.length;
}

function toScaled(value: string, scale: number): bigint {
  const trimmed = String(value).trim();
  const negative = trimmed.startsWith('-');
  const [int = '0', frac = ''] = trimmed.replace('-', '').split('.');
  const padded = (frac + '0'.repeat(scale)).slice(0, scale);
  const magnitude = BigInt(int || '0') * 10n ** BigInt(scale) + BigInt(padded || '0');
  return negative ? -magnitude : magnitude;
}

function formatScaled(scaled: bigint, scale: number, factor: bigint): string {
  const negative = scaled < 0n;
  const magnitude = negative ? -scaled : scaled;
  const int = magnitude / factor;
  const frac = (magnitude % factor).toString().padStart(scale, '0');
  const body = scale > 0 ? `${int}.${frac}` : `${int}`;
  return normalizeDecimal(negative ? `-${body}` : body);
}
