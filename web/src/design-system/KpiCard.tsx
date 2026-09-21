import type { ReactNode } from 'react';
import { format } from './format';

/**
 * KpiCard — docs/design-system/components/KpiCard/README.md.
 *
 * The label says what is measured, the unit sits separately. `delta` is coloured by direction,
 * but the direction is not always good news — falling waste is an improvement — so `deltaTone`
 * overrides it. A money KPI is bound to `master.product.view_cost`: without the permission the
 * card is not rendered at all, which the screen decides, not the component.
 */
export interface KpiCardProps {
  label: ReactNode;
  value: number | string;
  decimals?: number;
  unit?: string;
  /** Change against the previous period. The sign is added automatically. */
  delta?: number;
  deltaUnit?: string;
  deltaDecimals?: number;
  deltaTone?: 'up' | 'down' | 'flat';
  badge?: ReactNode;
  hint?: ReactNode;
}

export function KpiCard({
  label,
  value,
  decimals = 0,
  unit,
  delta,
  deltaUnit,
  deltaDecimals = 1,
  deltaTone,
  badge,
  hint,
}: KpiCardProps) {
  const isPreformatted = typeof value === 'string' && !/^-?\d+(\.\d+)?$/.test(value);
  const shown = isPreformatted ? value : format.number(value, decimals);

  let tone = deltaTone;
  if (delta !== undefined && tone === undefined) {
    tone = delta > 0 ? 'up' : delta < 0 ? 'down' : 'flat';
  }

  if (import.meta.env?.DEV && delta !== undefined && hint === undefined) {
    console.warn(
      '[wms] KpiCard: a `delta` without a `hint` says nothing — what is it measured against?',
    );
  }

  return (
    <div className="wms-kpi">
      <div className="wms-kpi__label">{label}</div>
      <div className="wms-kpi__value">
        <span>{shown}</span>
        {unit ? <span className="wms-kpi__unit">{unit}</span> : null}
      </div>
      {delta !== undefined || badge || hint ? (
        <div className="wms-kpi__foot">
          {delta !== undefined ? (
            <span className={`wms-delta wms-delta--${tone ?? 'flat'}`}>
              {format.signed(delta, deltaDecimals)}
              {deltaUnit ? ` ${deltaUnit}` : ''}
            </span>
          ) : null}
          {badge}
          {hint ? <span className="wms-kpi__hint">{hint}</span> : null}
        </div>
      ) : null}
    </div>
  );
}
