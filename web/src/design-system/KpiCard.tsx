import type { ReactNode } from 'react';
import { format } from './format';

/**
 * KpiCard — docs/design-system/components/KpiCard/README.md.
 *
 * The label says what is measured, the unit sits separately. `delta` is coloured by direction,
 * but the direction is not always good news — falling waste is an improvement — so `deltaTone`
 * overrides it. A money KPI is bound to `master.product.view_cost`: without the permission the
 * card is not rendered at all, which the screen decides, not the component.
 *
 * `tone` is the dashboard artboard's tinted card (Main.dc.html): a soft background and a 4px
 * accent bar that group the card, never judge it — the figure and the delta still say what
 * happened in words. `spark` sits at the right end of the foot row.
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
  tone?: 'accent' | 'warning' | 'virtual' | 'success';
  /** A small trend chart for the foot row, e.g. the dashboard's `Sparkline`. */
  spark?: ReactNode;
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
  tone,
  spark,
}: KpiCardProps) {
  const isPreformatted = typeof value === 'string' && !/^-?\d+(\.\d+)?$/.test(value);
  const shown = isPreformatted ? value : format.number(value, decimals);

  let direction = deltaTone;
  if (delta !== undefined && direction === undefined) {
    direction = delta > 0 ? 'up' : delta < 0 ? 'down' : 'flat';
  }

  if (import.meta.env?.DEV && delta !== undefined && hint === undefined) {
    console.warn(
      '[wms] KpiCard: a `delta` without a `hint` says nothing — what is it measured against?',
    );
  }

  return (
    <div className={tone ? `wms-kpi wms-kpi--${tone}` : 'wms-kpi'}>
      <div className="wms-kpi__label">{label}</div>
      <div className="wms-kpi__value">
        <span>{shown}</span>
        {unit ? <span className="wms-kpi__unit">{unit}</span> : null}
      </div>
      {delta !== undefined || badge || hint || spark ? (
        <div className="wms-kpi__foot">
          <div className="wms-kpi__foot-text">
            {delta !== undefined ? (
              <span className={`wms-delta wms-delta--${direction ?? 'flat'}`}>
                {delta !== 0 ? (
                  <span className="wms-delta__arrow" aria-hidden="true">
                    {delta > 0 ? '▲' : '▼'}
                  </span>
                ) : null}
                {format.signed(delta, deltaDecimals)}
                {deltaUnit ? ` ${deltaUnit}` : ''}
              </span>
            ) : null}
            {badge}
            {hint ? <span className="wms-kpi__hint">{hint}</span> : null}
          </div>
          {spark}
        </div>
      ) : null}
    </div>
  );
}
