import { useId, useLayoutEffect, useRef, useState, type KeyboardEvent } from 'react';
import { Decimal } from '@core/decimal';
import { formatDate, formatNumber, formatPercent, formatSigned } from '@core/format';
import { flowScale, niceStep, signedTick, type CategorySlice } from './series';

/**
 * The dashboard's three charts, drawn as inline SVG to the geometry of Main.dc.html. No chart
 * library: the artboard fixes every coordinate, and a dependency would bring its own colours,
 * number formats and minus sign — all three of which the brand book already decides.
 *
 * Colours come from `.wms-viz` (app.css): `--viz-in` / `--viz-out` are the status tokens, the
 * five category slots are the artboard's validated palette. Text never takes a series colour.
 */

// ---------------------------------------------------------------------------------- sparkline

/**
 * KPI trend line: 120×32 viewBox drawn into 90×26, soft area under a 2px line, a ringed dot on
 * the latest value. A flat or single-point series is drawn as a level line, not a fake slope.
 */
export function Sparkline({
  values,
  color,
  ring,
  label,
}: {
  values: readonly Decimal[];
  /** CSS colour of line, area and dot, e.g. `var(--accent)`. */
  color: string;
  /** The card's background, so the dot's ring reads as a gap. */
  ring: string;
  /** Accessible summary; the figures themselves are on the card. */
  label: string;
}) {
  if (values.length < 2) return null;
  const ys = values.map((v) => v.toNumber());
  const min = Math.min(...ys);
  const max = Math.max(...ys);
  const span = max - min;
  const step = 116 / (ys.length - 1);
  const pts = ys.map((y, i) => {
    const px = 2 + i * step;
    const py = span === 0 ? 17 : 30 - ((y - min) / span) * 26;
    return [Number(px.toFixed(1)), Number(py.toFixed(1))] as const;
  });
  const line = pts.map(([x, y]) => `${x},${y}`).join(' ');
  const area = `M${pts.map(([x, y]) => `${x},${y}`).join(' L')} L118,32 L2,32 Z`;
  const [lastX, lastY] = pts[pts.length - 1] ?? [118, 17];

  return (
    <svg
      className="wms-spark"
      width="90"
      height="26"
      viewBox="0 0 120 32"
      preserveAspectRatio="none"
      role="img"
      aria-label={label}
    >
      <title>{label}</title>
      <path d={area} fill={color} fillOpacity={0.16} />
      <polyline
        points={line}
        fill="none"
        stroke={color}
        strokeWidth={2}
        strokeLinejoin="round"
        strokeLinecap="round"
        vectorEffect="non-scaling-stroke"
      />
      <circle cx={lastX} cy={lastY} r={3.5} fill={color} stroke={ring} strokeWidth={2} />
    </svg>
  );
}

// ------------------------------------------------------------------------ inbound / outbound

export interface FlowDay {
  date: string;
  inbound: Decimal;
  outbound: Decimal;
}

/** Vertical geometry is the artboard's; the width is the card's own, measured. */
const FLOW = { height: 204, left: 42, top: 24, bottom: 176, labelY: 196, fallbackWidth: 660 };

/**
 * Diverging daily bars: receipts up in `--viz-in`, everything that left the location down in
 * `--viz-out`, one shared zero line — the ledger's own sign convention. The tallest inflow gets
 * its figure printed; every other value is in the tooltip and in the table under the chart.
 *
 * `money` draws ledger value in AZN; without it the same bars count documents, for the roles
 * that may not see cost.
 */
export function FlowChart({
  days,
  money,
  labels,
}: {
  days: readonly FlowDay[];
  money: boolean;
  labels: { inbound: string; outbound: string; net: string; caption: string; docs: string };
}) {
  const [active, setActive] = useState<number | null>(null);
  const tableId = useId();

  // Drawn at the card's real pixel width rather than scaled: axis text stays 11px on a wide
  // screen and the tooltip can be placed in the same pixels as the bar it describes.
  const wrapRef = useRef<HTMLDivElement>(null);
  const [width, setWidth] = useState(FLOW.fallbackWidth);
  useLayoutEffect(() => {
    const el = wrapRef.current;
    if (!el || typeof ResizeObserver === 'undefined') return;
    const measure = () => {
      if (el.clientWidth > 0) setWidth(Math.max(320, Math.round(el.clientWidth)));
    };
    measure();
    const observer = new ResizeObserver(measure);
    observer.observe(el);
    return () => observer.disconnect();
  }, []);
  const right = width - 8;

  const maxIn = days.reduce((m, d) => (d.inbound.gt(m) ? d.inbound : m), new Decimal(0));
  const maxOut = days.reduce((m, d) => (d.outbound.gt(m) ? d.outbound : m), new Decimal(0));
  const scale = money
    ? flowScale(Decimal.max(maxIn, maxOut))
    : { divisor: 1, unit: labels.docs, decimals: 0 };
  const toUnits = (v: Decimal) => v.toNumber() / scale.divisor;

  const up = toUnits(maxIn);
  const down = toUnits(maxOut);
  let step = niceStep(up + down || 1);
  // Documents come in whole numbers; an axis at 2,5 would promise half a receipt.
  if (!money && !Number.isInteger(step)) step = Math.max(1, Math.floor(step));
  // The plot spans exactly the data, as the artboard does: gridlines mark the steps inside it,
  // and the tallest bar may rise past the last one instead of leaving a band of empty axis.
  const topUnits = up;
  const bottomUnits = down;
  const spanUnits = topUnits + bottomUnits || 1;
  const pxPerUnit = (FLOW.bottom - FLOW.top) / spanUnits;
  const zeroY = FLOW.top + topUnits * pxPerUnit;

  const tickDecimals = Number.isInteger(step) ? 0 : 1;
  const ticks: number[] = [];
  for (let t = step; t <= topUnits + 1e-9; t += step) ticks.push(Number(t.toFixed(6)));
  for (let t = step; t <= bottomUnits + 1e-9; t += step) ticks.push(-Number(t.toFixed(6)));

  const band = (right - FLOW.left) / Math.max(days.length, 1);
  const barW = Math.min(24, band * 0.42);
  const labelEvery = Math.max(1, Math.ceil(24 / band));
  const peakIndex = maxIn.gt(0) ? days.findIndex((d) => d.inbound.eq(maxIn)) : -1;

  const onKey = (e: KeyboardEvent<SVGSVGElement>) => {
    if (days.length === 0) return;
    if (e.key === 'ArrowRight' || e.key === 'ArrowLeft') {
      e.preventDefault();
      const delta = e.key === 'ArrowRight' ? 1 : -1;
      setActive((i) => {
        const from = i ?? (delta > 0 ? -1 : days.length);
        return Math.min(days.length - 1, Math.max(0, from + delta));
      });
    } else if (e.key === 'Escape') {
      setActive(null);
    }
  };

  const activeDay = active === null ? null : days[active];
  const show = (v: Decimal) =>
    money ? `${formatNumber(v, 2)} AZN` : `${formatNumber(v, 0)} ${labels.docs}`;

  return (
    <div className="wms-flow" ref={wrapRef} onMouseLeave={() => setActive(null)}>
      <svg
        viewBox={`0 0 ${width} ${FLOW.height}`}
        width={width}
        height={FLOW.height}
        role="img"
        aria-label={labels.caption}
        aria-describedby={tableId}
        tabIndex={0}
        onKeyDown={onKey}
        onBlur={() => setActive(null)}
        className="wms-flow__svg"
      >
        {ticks.map((t) => {
          const y = zeroY - t * pxPerUnit;
          return (
            <g key={t}>
              <line x1={FLOW.left} y1={y} x2={right} y2={y} className="wms-flow__grid" />
              <text x={FLOW.left - 8} y={y + 4} textAnchor="end" className="wms-flow__axis">
                {signedTick(t, tickDecimals)}
              </text>
            </g>
          );
        })}

        {activeDay && active !== null ? (
          <rect
            x={FLOW.left + active * band + 1}
            y={FLOW.top - 14}
            width={band - 2}
            height={FLOW.bottom - FLOW.top + 18}
            rx={4}
            className="wms-flow__hover"
          />
        ) : null}

        {days.map((d, i) => {
          const cx = FLOW.left + band * (i + 0.5);
          const x = cx - barW / 2;
          const hIn = toUnits(d.inbound) * pxPerUnit;
          const hOut = toUnits(d.outbound) * pxPerUnit;
          return (
            <g key={d.date}>
              {hIn > 0 ? <path d={barPath(x, zeroY, barW, -hIn)} fill="var(--viz-in)" /> : null}
              {hOut > 0 ? <path d={barPath(x, zeroY, barW, hOut)} fill="var(--viz-out)" /> : null}
              {i % labelEvery === 0 || i === days.length - 1 ? (
                <text x={cx} y={FLOW.labelY} textAnchor="middle" className="wms-flow__axis">
                  {d.date.slice(8, 10)}
                </text>
              ) : null}
              {/* The hit target is the whole column, not the painted bar. */}
              <rect
                x={FLOW.left + i * band}
                y={0}
                width={band}
                height={FLOW.bottom + 4}
                fill="transparent"
                onMouseEnter={() => setActive(i)}
                onMouseMove={() => setActive(i)}
              />
            </g>
          );
        })}

        <line x1={FLOW.left} y1={zeroY} x2={right} y2={zeroY} className="wms-flow__zero" />
        <text x={FLOW.left - 8} y={zeroY + 4} textAnchor="end" className="wms-flow__axis">
          0
        </text>

        {peakIndex >= 0 ? (
          <text
            x={FLOW.left + band * (peakIndex + 0.5)}
            y={zeroY - toUnits(maxIn) * pxPerUnit - 7}
            textAnchor="middle"
            className="wms-flow__peak"
          >
            {signedTick(toUnits(maxIn), scale.decimals)}
          </text>
        ) : null}
      </svg>

      {activeDay && active !== null ? (
        <div
          className="wms-flow__tip"
          role="status"
          style={{
            left: FLOW.left + band * (active + 0.5),
            transform:
              active >= days.length / 2 ? 'translateX(calc(-100% - 14px))' : 'translateX(14px)',
          }}
        >
          <div className="wms-flow__tip-date wms-num">{formatDate(activeDay.date)}</div>
          <div className="wms-flow__tip-row">
            <i style={{ background: 'var(--viz-in)' }} />
            <b className="wms-num">{show(activeDay.inbound)}</b>
            <span>{labels.inbound}</span>
          </div>
          <div className="wms-flow__tip-row">
            <i style={{ background: 'var(--viz-out)' }} />
            <b className="wms-num">{show(activeDay.outbound)}</b>
            <span>{labels.outbound}</span>
          </div>
          {money ? (
            <div className="wms-flow__tip-row wms-flow__tip-net">
              <b className="wms-num">
                {formatSigned(activeDay.inbound.minus(activeDay.outbound), 2)} AZN
              </b>
              <span>{labels.net}</span>
            </div>
          ) : null}
        </div>
      ) : null}

      {/* The table view: every value the tooltip shows, reachable without a pointer. */}
      <table id={tableId} className="wms-sr-only">
        <caption>{labels.caption}</caption>
        <thead>
          <tr>
            <th scope="col">Tarix</th>
            <th scope="col">{labels.inbound}</th>
            <th scope="col">{labels.outbound}</th>
          </tr>
        </thead>
        <tbody>
          {days.map((d) => (
            <tr key={d.date}>
              <th scope="row">{formatDate(d.date)}</th>
              <td>{show(d.inbound)}</td>
              <td>{show(d.outbound)}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

/** A bar anchored on the baseline with 4px rounded data end. `h` < 0 grows upwards. */
function barPath(x: number, baseY: number, w: number, h: number): string {
  const r = Math.min(4, w / 2, Math.abs(h));
  const endY = baseY + h;
  const dir = h < 0 ? 1 : -1; // from the data end back towards the baseline
  const f = (n: number) => n.toFixed(1);
  return [
    `M${f(x)},${f(baseY)}`,
    `L${f(x)},${f(endY + dir * r)}`,
    `Q${f(x)},${f(endY)} ${f(x + r)},${f(endY)}`,
    `L${f(x + w - r)},${f(endY)}`,
    `Q${f(x + w)},${f(endY)} ${f(x + w)},${f(endY + dir * r)}`,
    `L${f(x + w)},${f(baseY)}`,
    'Z',
  ].join(' ');
}

// -------------------------------------------------------------------------------- donut

const SLOT_COLORS = [
  'var(--viz-1)',
  'var(--viz-2)',
  'var(--viz-3)',
  'var(--viz-4)',
  'var(--viz-5)',
];

/**
 * Stock value by category: an 82/54 ring with a 2px surface gap between slices, the total in
 * the hole, and a legend that always prints the share — three of the five slot colours are under
 * 3:1 on the light surface, so a colour never carries the number on its own. Hovering or focusing
 * a slice or its legend row puts that slice's value in the hole.
 */
export function CategoryDonut({
  slices,
  total,
  label,
}: {
  slices: readonly CategorySlice[];
  total: Decimal;
  label: string;
}) {
  const [active, setActive] = useState<number | null>(null);
  const R = 82;
  const r = 54;
  const c = 104;

  let angle = 0;
  const arcs = slices.map((s, i) => {
    const sweep = (s.share.toNumber() / 100) * Math.PI * 2;
    const start = angle;
    angle += sweep;
    return { slice: s, i, d: ringPath(c, R, r, start, angle) };
  });

  const current = active === null ? null : slices[active];
  const hole = current ? current.value : total;

  return (
    <div className="wms-donut" onMouseLeave={() => setActive(null)}>
      <svg viewBox="0 0 208 208" width="150" height="150" role="img" aria-label={label}>
        {arcs.map(({ slice, i, d }) => (
          <path
            key={slice.key}
            d={d}
            fill={SLOT_COLORS[i]}
            stroke="var(--surface)"
            strokeWidth={2}
            opacity={active === null || active === i ? 1 : 0.35}
            onMouseEnter={() => setActive(i)}
          >
            <title>{`${slice.label}: ${formatNumber(slice.value, 2)} AZN · ${formatPercent(slice.share, 1)}`}</title>
          </path>
        ))}
        <text x={c} y={current ? 96 : 102} textAnchor="middle" className="wms-donut__value">
          {formatNumber(hole, 0)}
        </text>
        <text x={c} y={current ? 116 : 122} textAnchor="middle" className="wms-donut__unit">
          AZN
        </text>
        {current ? (
          <text x={c} y={136} textAnchor="middle" className="wms-donut__unit">
            {formatPercent(current.share, 1)}
          </text>
        ) : null}
      </svg>
      <ul className="wms-donut__legend">
        {slices.map((s, i) => (
          <li
            key={s.key}
            className={active === i ? 'is-active' : undefined}
            tabIndex={0}
            onMouseEnter={() => setActive(i)}
            onFocus={() => setActive(i)}
            onBlur={() => setActive(null)}
          >
            <span className="wms-donut__swatch" style={{ background: SLOT_COLORS[i] }} />
            <span className="wms-donut__name">{s.label}</span>
            <span className="wms-num wms-donut__share">{formatPercent(s.share, 1)}</span>
          </li>
        ))}
      </ul>
    </div>
  );
}

/** One ring slice from `a0` to `a1` radians, clockwise from twelve o'clock. */
function ringPath(c: number, R: number, r: number, a0: number, a1: number): string {
  // A full circle cannot be one arc: split it so the path still closes.
  if (a1 - a0 >= Math.PI * 2 - 1e-6) {
    return `${ringPath(c, R, r, a0, a0 + Math.PI)} ${ringPath(c, R, r, a0 + Math.PI, a1)}`;
  }
  const pt = (rad: number, a: number) =>
    `${(c + rad * Math.sin(a)).toFixed(2)},${(c - rad * Math.cos(a)).toFixed(2)}`;
  const large = a1 - a0 > Math.PI ? 1 : 0;
  return [
    `M${pt(R, a0)}`,
    `A${R},${R} 0 ${large} 1 ${pt(R, a1)}`,
    `L${pt(r, a1)}`,
    `A${r},${r} 0 ${large} 0 ${pt(r, a0)}`,
    'Z',
  ].join(' ');
}
