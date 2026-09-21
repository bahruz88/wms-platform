import { Decimal, type DecimalString } from '@core/decimal';
import { Badge } from './Badge';
import { format } from './format';

/**
 * VarianceIndicator — docs/design-system/components/VarianceIndicator/README.md.
 *
 *   · the difference is always signed, with the percentage beside it;
 *   · above `thresholdPct` it takes a "Təsdiq tələb edir" badge — such a document cannot be posted
 *     directly, it passes an `inv.adjustment.approve` holder;
 *   · **a non-zero variance with no reason code shows "Səbəb kodu yoxdur"** — the visual twin of
 *     the form rule that `reason_code_id` is mandatory for a non-zero variance;
 *   · zero variance is neutral — in a count that is the expected result, not an achievement;
 *   · `book = 0` shows 100 %: "stock counted that the system does not have", always approved.
 */
export interface VarianceIndicatorProps {
  /** System quantity at the moment of freezing. */
  book: DecimalString | number;
  counted: DecimalString | number;
  uom?: string;
  decimals?: number;
  /** `inv_setting.count_variance_approval_threshold_pct`. */
  thresholdPct?: number;
  /** The chosen reason code. A variance with this empty raises the warning badge. */
  reasonCode?: string;
}

const num = (v: DecimalString | number): DecimalString => (typeof v === 'number' ? String(v) : v);

export interface VarianceResult {
  variance: Decimal;
  pct: Decimal | null;
  needsApproval: boolean;
  missingReason: boolean;
}

/** Pure calculation, exported so screens and tests use exactly the badge's logic. */
export function computeVariance(
  book: DecimalString | number,
  counted: DecimalString | number,
  thresholdPct?: number,
  reasonCode?: string,
): VarianceResult {
  const b = new Decimal(num(book));
  const c = new Decimal(num(counted));
  const variance = c.minus(b);
  // book = 0 with something counted is 100 % — stock the system does not know about.
  const pct = variance.isZero()
    ? new Decimal(0)
    : b.isZero()
      ? new Decimal(100)
      : variance.dividedBy(b).times(100);
  const needsApproval =
    !variance.isZero() &&
    (b.isZero() ||
      (thresholdPct !== undefined && pct.abs().greaterThan(new Decimal(thresholdPct))));
  return {
    variance,
    pct,
    needsApproval,
    missingReason: !variance.isZero() && !reasonCode,
  };
}

export function VarianceIndicator({
  book,
  counted,
  uom,
  decimals = 4,
  thresholdPct,
  reasonCode,
}: VarianceIndicatorProps) {
  const { variance, pct, needsApproval, missingReason } = computeVariance(
    book,
    counted,
    thresholdPct,
    reasonCode,
  );

  const tone = variance.isZero() ? 'zero' : variance.isNegative() ? 'short' : 'over';

  return (
    <span className="wms-variance">
      <span className={`wms-variance__val wms-variance__val--${tone}`}>
        {format.signed(variance, decimals)}
        {uom ? ` ${uom}` : ''}
      </span>
      {pct ? <span className="wms-variance__pct">{format.signed(pct, 2)} %</span> : null}
      {needsApproval ? <Badge tone="warning">Təsdiq tələb edir</Badge> : null}
      {missingReason ? <Badge tone="danger">Səbəb kodu yoxdur</Badge> : null}
    </span>
  );
}
