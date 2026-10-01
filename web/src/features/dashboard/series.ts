import { Decimal } from '@core/decimal';
import { MINUS_SIGN, formatNumber } from '@core/format';

/**
 * Pure helpers behind the dashboard charts. They take the contract's `DashboardSeries` points
 * (DateOnly + Decimal string) and turn them into what an SVG needs. Values stay `Decimal` until
 * the last step: geometry is the only place a figure becomes a float, and a float never goes back
 * into a label.
 */

export type PeriodDays = 7 | 14 | 30;

export const PERIODS: readonly PeriodDays[] = [7, 14, 30];

/** `GET /reporting/dashboard/summary?period=` for each segment of the header control. */
export const PERIOD_PARAM: Record<PeriodDays, 'WEEK' | 'TWO_WEEKS' | 'MONTH'> = {
  7: 'WEEK',
  14: 'TWO_WEEKS',
  30: 'MONTH',
};

export interface SeriesPoint {
  date: string;
  value: string;
}

export interface DayValue {
  /** ISO `yyyy-MM-dd`. */
  date: string;
  value: Decimal;
}

/** ISO date of a timestamp in UTC — the server's `today` is `clock.UtcNow`, so the axis is too. */
export function utcDate(value: string | Date): string {
  const d = value instanceof Date ? value : new Date(value);
  return d.toISOString().slice(0, 10);
}

/** `yyyy-MM-dd` plus `days` (may be negative), computed in UTC so no DST edge moves a day. */
export function addDays(iso: string, days: number): string {
  const d = new Date(`${iso}T00:00:00Z`);
  d.setUTCDate(d.getUTCDate() + days);
  return d.toISOString().slice(0, 10);
}

/**
 * Every day of the window ending on `end`, oldest first. The server leaves out days with no
 * documents (contract: a missing point is zero), so the axis is built here, not read from it.
 */
export function windowDays(end: string, days: number): string[] {
  return Array.from({ length: days }, (_, i) => addDays(end, i - (days - 1)));
}

export function fillDays(points: readonly SeriesPoint[] | undefined, dates: string[]): DayValue[] {
  const byDate = new Map<string, Decimal>();
  for (const p of points ?? []) {
    byDate.set(p.date, (byDate.get(p.date) ?? new Decimal(0)).plus(new Decimal(p.value)));
  }
  return dates.map((date) => ({ date, value: byDate.get(date) ?? new Decimal(0) }));
}

/** Running total — "how many batches will have expired by this day". */
export function cumulative(values: DayValue[]): DayValue[] {
  let acc = new Decimal(0);
  return values.map((v) => {
    acc = acc.plus(v.value);
    return { date: v.date, value: acc };
  });
}

/**
 * The flow chart's unit. Above ten thousand the axis reads in thousands ("min AZN") so its
 * labels stay two or three digits wide; below it, plain manat.
 */
export function flowScale(max: Decimal): {
  divisor: number;
  unit: 'AZN' | 'min AZN';
  decimals: number;
} {
  return max.gte(10_000)
    ? { divisor: 1000, unit: 'min AZN', decimals: 1 }
    : { divisor: 1, unit: 'AZN', decimals: 0 };
}

/** A tick step of 1, 2, 2.5 or 5 × 10ⁿ that splits `span` into roughly `target` intervals. */
export function niceStep(span: number, target = 4): number {
  if (!(span > 0)) return 1;
  const raw = span / target;
  const magnitude = 10 ** Math.floor(Math.log10(raw));
  const normalized = raw / magnitude;
  const factor =
    normalized <= 1 ? 1 : normalized <= 2 ? 2 : normalized <= 2.5 ? 2.5 : normalized <= 5 ? 5 : 10;
  return factor * magnitude;
}

/** Axis label: always signed except zero, brand-book comma and U+2212 minus. */
export function signedTick(value: number, decimals: number): string {
  if (value === 0) return '0';
  const body = formatNumber(Math.abs(value).toFixed(decimals), decimals);
  return value > 0 ? `+${body}` : `${MINUS_SIGN}${body}`;
}

export interface CategoryRef {
  id: number;
  parentId?: number | null;
  name: string;
}

export interface CategorySlice {
  /** `null` groups everything the catalogue could not place, plus the folded tail. */
  key: string;
  label: string;
  value: Decimal;
  share: Decimal;
}

/**
 * `categoryValues` arrive per leaf category. The donut shows the top of the tree — the first
 * question is "meat or dairy", not which sub-shelf — and at most five slices: the fifth colour
 * slot holds the rest ("digər") rather than a sixth, generated hue.
 */
export function categorySlices(
  values: readonly { categoryId?: number | null; value: string }[],
  categories: readonly CategoryRef[],
  labels: { uncategorised: string; other: string },
  maxSlices = 5,
): CategorySlice[] {
  const byId = new Map(categories.map((c) => [c.id, c]));
  const rootOf = (id: number): CategoryRef | undefined => {
    let node = byId.get(id);
    const seen = new Set<number>();
    while (node?.parentId && byId.has(node.parentId) && !seen.has(node.id)) {
      seen.add(node.id);
      node = byId.get(node.parentId);
    }
    return node;
  };

  const groups = new Map<string, { label: string; value: Decimal }>();
  for (const row of values) {
    const root = row.categoryId ? rootOf(row.categoryId) : undefined;
    const key = root ? String(root.id) : 'none';
    const label = root?.name ?? labels.uncategorised;
    const prev = groups.get(key);
    groups.set(key, { label, value: (prev?.value ?? new Decimal(0)).plus(new Decimal(row.value)) });
  }

  const sorted = [...groups.entries()]
    .map(([key, g]) => ({ key, ...g }))
    .filter((g) => g.value.gt(0))
    .sort((a, b) => b.value.comparedTo(a.value));

  const total = sorted.reduce((acc, g) => acc.plus(g.value), new Decimal(0));
  if (total.isZero()) return [];

  const head = sorted.length > maxSlices ? sorted.slice(0, maxSlices - 1) : sorted;
  const tail = sorted.length > maxSlices ? sorted.slice(maxSlices - 1) : [];
  const slices = head.map((g) => ({ key: g.key, label: g.label, value: g.value }));
  if (tail.length > 0) {
    slices.push({
      key: 'other',
      label: labels.other,
      value: tail.reduce((acc, g) => acc.plus(g.value), new Decimal(0)),
    });
  }
  return slices.map((s) => ({ ...s, share: s.value.div(total).times(100) }));
}

/**
 * Tone of a batch's remaining shelf life. Critical and warning come from the tenant's
 * `expiry_critical_days` / `expiry_warning_days`; the green band is the later half of the
 * window between them — inside the warning window, but not yet the next thing to issue.
 * A threshold that could not be read colours nothing (src/api/settings.ts: no defaults).
 */
export function expiryTone(
  daysLeft: number,
  criticalDays: number | null,
  warningDays: number | null,
): 'danger' | 'warning' | 'success' | 'neutral' {
  if (criticalDays !== null && daysLeft <= criticalDays) return 'danger';
  if (criticalDays === null || warningDays === null) return 'neutral';
  if (daysLeft <= (criticalDays + warningDays) / 2) return 'warning';
  return 'success';
}
