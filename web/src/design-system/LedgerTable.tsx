import { Decimal, sumDecimals, type DecimalString } from '@core/decimal';
import { Badge } from './Badge';
import { Icons } from './Icons';
import { format } from './format';

/**
 * LedgerTable — docs/design-system/components/LedgerTable/README.md.
 *
 * Shows one `movement_group` with double-entry logic and checks in front of the user that the
 * group sums to zero. Three rules are structural:
 *
 *   · the sign is never hidden — `+` / `−` is written, colour only repeats it;
 *   · virtual locations (V_SUPPLIER, V_WASTE, V_SAMPLE, V_ADJUSTMENT, IN_TRANSIT) are badged so
 *     they cannot be mistaken for a physical warehouse;
 *   · the balance-check row is always rendered — it is the interface twin of the nightly
 *     `DoubleEntryCheck` job.
 *
 * Lines are append-only: there is no edit control here, and there must never be one. A correction
 * is a `REVERSAL` group.
 *
 * `qtyBase` / `unitCost` accept the contract's decimal string as well as the `number` that
 * index.d.ts declares, so screens can hand the API value straight through without going via
 * IEEE-754.
 */
export interface LedgerLine {
  lineNo: number;
  product: string;
  sku?: string;
  batchNo?: string;
  location: string;
  /** CENTRAL_WAREHOUSE, RESTAURANT, IN_TRANSIT, V_SUPPLIER, V_WASTE, V_SAMPLE, V_ADJUSTMENT */
  locationType?: string;
  /** Signed quantity: + receipt, − issue. */
  // eslint-disable-next-line wms/no-number-for-decimal -- docs/design-system/components/index.d.ts declares this presentation prop as `number`; the contract decimal string is accepted alongside it and is what screens pass.
  qtyBase: DecimalString | number;
  uom?: string;
  // eslint-disable-next-line wms/no-number-for-decimal -- docs/design-system/components/index.d.ts declares this presentation prop as `number`; the contract decimal string is accepted alongside it and is what screens pass.
  unitCost?: DecimalString | number;
}

export interface LedgerTableProps {
  lines: LedgerLine[];
  decimals?: number;
  /** Do not pass without the `master.product.view_cost` permission. */
  showCost?: boolean;
  /** Set to false only to hide the group zero-sum check. */
  showBalanceCheck?: boolean;
  label?: string;
}

const VIRTUAL_TYPES = new Set([
  'V_SUPPLIER',
  'V_WASTE',
  'V_SAMPLE',
  'V_ADJUSTMENT',
  'V_CONSUMPTION',
  'IN_TRANSIT',
]);

export function isVirtualLocationType(type: string | undefined): boolean {
  return type !== undefined && VIRTUAL_TYPES.has(type);
}

const toDecimalString = (v: DecimalString | number | undefined): DecimalString =>
  v === undefined ? '0' : typeof v === 'number' ? String(v) : v;

export function LedgerTable({
  lines,
  decimals = 4,
  showCost = false,
  showBalanceCheck = true,
  label,
}: LedgerTableProps) {
  const total = sumDecimals(lines.map((l) => toDecimalString(l.qtyBase)));
  const balanced = total.isZero();

  return (
    <div>
      <div className="wms-table-wrap">
        <table className="wms-table wms-table--dense" aria-label={label ?? 'Hərəkət sətirləri'}>
          <thead>
            <tr>
              <th scope="col" style={{ width: '48px', textAlign: 'right' }}>
                №
              </th>
              <th scope="col">Məhsul</th>
              <th scope="col">Partiya</th>
              <th scope="col">Lokasiya</th>
              <th scope="col" style={{ textAlign: 'right' }}>
                Miqdar (base)
              </th>
              <th scope="col">Vahid</th>
              {showCost ? (
                <th scope="col" style={{ textAlign: 'right' }}>
                  Vahid dəyəri
                </th>
              ) : null}
            </tr>
          </thead>
          <tbody>
            {lines.length === 0 ? (
              <tr>
                <td className="wms-table__empty" colSpan={showCost ? 7 : 6}>
                  Bu sənəddə hərəkət sətri yoxdur. Sənəd post edilməyib.
                </td>
              </tr>
            ) : (
              lines.map((line) => {
                const qty = new Decimal(toDecimalString(line.qtyBase));
                const direction = qty.isNegative() ? 'out' : 'in';
                return (
                  <tr key={line.lineNo}>
                    <td className="wms-td--num">{line.lineNo}</td>
                    <td>
                      <div>{line.product}</div>
                      {line.sku ? (
                        <div
                          className="wms-num"
                          style={{ fontSize: 12, color: 'var(--ink-muted)' }}
                        >
                          {line.sku}
                        </div>
                      ) : null}
                    </td>
                    <td className="wms-num" style={{ fontSize: 13 }}>
                      {line.batchNo ?? '—'}
                    </td>
                    <td>
                      {isVirtualLocationType(line.locationType) ? (
                        <Badge tone="virtual" title={line.locationType}>
                          {line.location}
                        </Badge>
                      ) : (
                        line.location
                      )}
                    </td>
                    <td className={`wms-td--num wms-ledger__qty--${direction}`}>
                      {format.signed(qty, decimals)}
                    </td>
                    <td>{line.uom ?? ''}</td>
                    {showCost ? (
                      <td className="wms-td--num">
                        {line.unitCost === undefined
                          ? '—'
                          : format.number(toDecimalString(line.unitCost), 4)}
                      </td>
                    ) : null}
                  </tr>
                );
              })
            )}
          </tbody>
        </table>
      </div>
      {showBalanceCheck ? (
        <div
          className={`wms-ledger__check ${balanced ? 'wms-ledger__check--ok' : 'wms-ledger__check--fail'}`}
          role={balanced ? 'status' : 'alert'}
          data-testid="wms-ledger-balance-check"
        >
          {balanced ? Icons.check(16) : Icons.warn(16)}
          <span>
            {balanced
              ? `Qrup cəmi sıfırdır (${format.signed(total, decimals)}) — ikili yazılış tamdır.`
              : `Qrup cəmi sıfır deyil: ${format.signed(total, decimals)}. Sənəd post edilə bilməz.`}
          </span>
        </div>
      ) : null}
    </div>
  );
}
