import { Decimal, Money, Quantity } from './decimal';

/**
 * Number and date formatting, exactly as the brand book specifies
 * (docs/design-system/README.md, "Dil və mətn"):
 *
 *   decimal separator  comma            `1 284,5000`
 *   thousands          U+202F narrow no-break space
 *   minus              U+2212 minus sign (not the hyphen-minus U+002D)
 *   dates              dd.MM.yyyy   ·   dd.MM.yyyy HH:mm
 *
 * `Intl.NumberFormat` is deliberately not used: its `az` locale puts a full space (or a comma)
 * in the group position depending on the ICU build, and it has no option for U+2212.
 */

export const NARROW_NBSP = ' ';
export const MINUS_SIGN = '−';

export type FormattableNumber = string | number | Decimal | Quantity | Money | null | undefined;

function toDecimalOrNull(value: FormattableNumber): Decimal | null {
  if (value === null || value === undefined || value === '') return null;
  if (value instanceof Quantity) return value.value;
  if (value instanceof Money) return value.amount;
  if (value instanceof Decimal) return value;
  if (typeof value === 'number') {
    if (!Number.isFinite(value)) return null;
    return new Decimal(value);
  }
  try {
    const d = new Decimal(value);
    return d.isFinite() ? d : null;
  } catch {
    return null;
  }
}

function groupIntegerPart(digits: string): string {
  let out = '';
  for (let i = digits.length; i > 0; i -= 3) {
    const start = Math.max(0, i - 3);
    out = digits.slice(start, i) + (out ? NARROW_NBSP + out : '');
  }
  return out || '0';
}

/**
 * `1234.5` → `1 284,5000` shape. `decimals` is the field's declared scale
 * (`base_uom.decimals` for quantities); the value is not truncated beyond it.
 */
export function formatNumber(value: FormattableNumber, decimals = 4): string {
  const d = toDecimalOrNull(value);
  if (d === null) return '—';
  const fixed = d.abs().toFixed(decimals);
  const [intPart = '0', fracPart] = fixed.split('.');
  const grouped = groupIntegerPart(intPart);
  const body = fracPart ? `${grouped},${fracPart}` : grouped;
  return d.isNegative() && !d.isZero() ? MINUS_SIGN + body : body;
}

/** Always signed: `+12,0000` / `−12,0000`. Zero carries no sign. */
export function formatSigned(value: FormattableNumber, decimals = 4): string {
  const d = toDecimalOrNull(value);
  if (d === null) return '—';
  if (d.isZero()) return formatNumber(d, decimals);
  const body = formatNumber(d.abs(), decimals);
  return (d.isNegative() ? MINUS_SIGN : '+') + body;
}

/** Percent values are DECIMAL(9,4) in the contract; two decimals read best in the interface. */
export function formatPercent(value: FormattableNumber, decimals = 2): string {
  const d = toDecimalOrNull(value);
  if (d === null) return '—';
  return `${formatNumber(d, decimals)} %`;
}

export function formatSignedPercent(value: FormattableNumber, decimals = 2): string {
  const d = toDecimalOrNull(value);
  if (d === null) return '—';
  return `${formatSigned(d, decimals)} %`;
}

/** `Money` → `1 284,50 AZN`. Currency code is never translated. */
export function formatMoney(value: Money | null | undefined, decimals = 2): string {
  if (!value) return '—';
  return `${formatNumber(value.amount, decimals)}${NARROW_NBSP}${value.currency}`;
}

/** `Quantity` → `1 284,5000 KG` when the unit is known, otherwise the bare figure. */
export function formatQuantity(value: Quantity | null | undefined, decimals = 4): string {
  if (!value) return '—';
  const body = formatNumber(value.value, decimals);
  return value.uomCode ? `${body}${NARROW_NBSP}${value.uomCode}` : body;
}

function pad2(n: number): string {
  return n < 10 ? `0${n}` : String(n);
}

function parseDate(value: string | Date | null | undefined): Date | null {
  if (!value) return null;
  const d = value instanceof Date ? value : new Date(value);
  return Number.isNaN(d.getTime()) ? null : d;
}

/** ISO (`2026-09-20` or a full timestamp) → `20.09.2026`. Storage is UTC, display is local. */
export function formatDate(value: string | Date | null | undefined): string {
  const d = parseDate(value);
  if (!d) return '—';
  return `${pad2(d.getDate())}.${pad2(d.getMonth() + 1)}.${d.getFullYear()}`;
}

/** ISO → `20.09.2026 14:35`. */
export function formatDateTime(value: string | Date | null | undefined): string {
  const d = parseDate(value);
  if (!d) return '—';
  return `${formatDate(d)} ${pad2(d.getHours())}:${pad2(d.getMinutes())}`;
}

/** Whole counts (rows, documents, days) — grouped, but never given a fractional part. */
export function formatCount(value: number | null | undefined): string {
  if (value === null || value === undefined || !Number.isFinite(value)) return '—';
  return formatNumber(new Decimal(Math.trunc(value)), 0);
}

/**
 * Sorts by `name_sort_key` when the server supplies it — the browser's `localeCompare` places
 * `ə` wrongly for Azerbaijani (design-system README).
 */
export function compareBySortKey<T extends { nameSortKey?: string | null; name?: string | null }>(
  a: T,
  b: T,
): number {
  const ka = a.nameSortKey ?? a.name ?? '';
  const kb = b.nameSortKey ?? b.name ?? '';
  if (ka === kb) return 0;
  return ka < kb ? -1 : 1;
}

/** Days between today and an ISO date; negative means the date has passed. */
export function daysUntil(iso: string | null | undefined, today?: string | Date): number | null {
  const target = parseDate(iso);
  if (!target) return null;
  const base = parseDate(today ?? new Date()) ?? new Date();
  const a = Date.UTC(target.getFullYear(), target.getMonth(), target.getDate());
  const b = Date.UTC(base.getFullYear(), base.getMonth(), base.getDate());
  return Math.round((a - b) / 86_400_000);
}
