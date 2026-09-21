import { Decimal, type DecimalString } from '@core/decimal';
import { daysUntil } from '@core/format';
import { Badge } from './Badge';
import { Icons } from './Icons';
import { format } from './format';

/**
 * BatchPicker — docs/design-system/components/BatchPicker/README.md.
 *
 *   · the FEFO/FIFO suggestion is flagged, never applied silently;
 *   · picking something else is not silent: the component warns, and the form must then require
 *     `reason_code_id` + `note` (SPEC §12.4, `422 REASON_CODE_REQUIRED`);
 *   · non-ACTIVE batches (BLOCKED, EXPIRED, QUARANTINE) stay visible but cannot be selected —
 *     the keeper has to see where the 42 expired units are;
 *   · a batch with less than `requiredQty` is not hidden: partial allocation is normal;
 *   · order: ACTIVE, then QUARANTINE, BLOCKED, EXPIRED; by expiry inside each group.
 */
export interface Batch {
  id: string | number;
  batchNo: string;
  expiryDate?: string;
  receivedAt?: string;
  /** ACTIVE | BLOCKED | EXPIRED | QUARANTINE — anything but ACTIVE cannot be selected. */
  status?: string;
  available: DecimalString | number;
}

export interface BatchPickerProps {
  batches: Batch[];
  /** `master_product.issue_strategy`. The suggested batch is flagged by this rule. */
  strategy?: 'FEFO' | 'FIFO';
  value?: string | number;
  onChange?: (id: string | number, batch: Batch) => void;
  // eslint-disable-next-line wms/no-number-for-decimal -- docs/design-system/components/index.d.ts declares this presentation prop as `number`; the contract decimal string is accepted alongside it and is what screens pass.
  requiredQty?: DecimalString | number;
  uom?: string;
  decimals?: number;
  /** `inv_setting.expiry_warning_days` / `expiry_critical_days`. */
  warningDays?: number;
  criticalDays?: number;
  /** Today's date (ISO), for tests. */
  today?: string;
}

const STATUS_RANK: Record<string, number> = {
  ACTIVE: 0,
  QUARANTINE: 1,
  BLOCKED: 2,
  EXPIRED: 3,
};

const STATUS_REASON: Record<string, string> = {
  BLOCKED: 'Bloklanıb — ayrıla bilməz',
  EXPIRED: 'Vaxtı keçib — ayrıla bilməz',
  QUARANTINE: 'Karantində — ayrıla bilməz',
};

const num = (v: DecimalString | number | undefined): DecimalString =>
  v === undefined ? '0' : typeof v === 'number' ? String(v) : v;

export function isSelectableBatch(batch: Batch): boolean {
  return (batch.status ?? 'ACTIVE') === 'ACTIVE';
}

/** ACTIVE first, then QUARANTINE / BLOCKED / EXPIRED; inside a group by expiry then batch no. */
export function sortBatches(batches: Batch[]): Batch[] {
  return [...batches].sort((a, b) => {
    const ra = STATUS_RANK[a.status ?? 'ACTIVE'] ?? 0;
    const rb = STATUS_RANK[b.status ?? 'ACTIVE'] ?? 0;
    if (ra !== rb) return ra - rb;
    const ea = a.expiryDate ?? '9999-12-31';
    const eb = b.expiryDate ?? '9999-12-31';
    if (ea !== eb) return ea < eb ? -1 : 1;
    return a.batchNo < b.batchNo ? -1 : a.batchNo > b.batchNo ? 1 : 0;
  });
}

/** The batch the strategy suggests: earliest expiry for FEFO, earliest receipt for FIFO. */
export function suggestedBatchId(
  batches: Batch[],
  strategy: 'FEFO' | 'FIFO' = 'FEFO',
): string | number | undefined {
  const selectable = batches.filter(isSelectableBatch);
  if (selectable.length === 0) return undefined;
  const key = (b: Batch) =>
    strategy === 'FIFO' ? (b.receivedAt ?? '9999-12-31') : (b.expiryDate ?? '9999-12-31');
  return selectable.reduce((best, b) => (key(b) < key(best) ? b : best), selectable[0] as Batch).id;
}

export function BatchPicker({
  batches,
  strategy = 'FEFO',
  value,
  onChange,
  requiredQty,
  uom,
  decimals = 4,
  warningDays = 30,
  criticalDays = 7,
  today,
}: BatchPickerProps) {
  const ordered = sortBatches(batches);
  const suggested = suggestedBatchId(batches, strategy);
  const offSuggestion =
    value !== undefined && suggested !== undefined && String(value) !== String(suggested);

  const required = requiredQty === undefined ? null : new Decimal(num(requiredQty));

  return (
    <div>
      <div className="wms-batches">
        <div className="wms-batches__head">
          <span>Partiya seçin</span>
          <span>
            {required
              ? `Tələb olunan: ${format.number(required, decimals)}${uom ? ` ${uom}` : ''}`
              : `Strategiya: ${strategy}`}
          </span>
        </div>
        {ordered.length === 0 ? (
          <div className="wms-table__empty">
            Bu məhsul üçün bu lokasiyada partiya yoxdur. Qəbul sənədi yaradın.
          </div>
        ) : (
          ordered.map((batch) => {
            const selectable = isSelectableBatch(batch);
            const selected = value !== undefined && String(value) === String(batch.id);
            const isSuggested = suggested !== undefined && String(suggested) === String(batch.id);
            const days = daysUntil(batch.expiryDate, today);
            const available = new Decimal(num(batch.available));
            const short = required !== null && available.lessThan(required);

            let expiryBadge = null;
            if (days !== null) {
              if (days < 0) {
                expiryBadge = <Badge tone="danger">{`${Math.abs(days)} gün keçib`}</Badge>;
              } else if (days <= criticalDays) {
                expiryBadge = <Badge tone="danger">{`${days} gün qalıb`}</Badge>;
              } else if (days <= warningDays) {
                expiryBadge = <Badge tone="warning">{`${days} gün qalıb`}</Badge>;
              }
            }

            const status = batch.status ?? 'ACTIVE';
            const reason = selectable ? undefined : STATUS_REASON[status];

            return (
              <button
                key={String(batch.id)}
                type="button"
                className="wms-batch"
                aria-pressed={selected}
                disabled={!selectable}
                title={reason}
                onClick={() => onChange?.(batch.id, batch)}
              >
                <span className="wms-batch__radio" aria-hidden="true" />
                <span className="wms-batch__main">
                  <span className="wms-batch__no">{batch.batchNo}</span>
                  <span className="wms-batch__meta">
                    {batch.expiryDate ? (
                      <span>Son istifadə: {format.date(batch.expiryDate)}</span>
                    ) : null}
                    {batch.receivedAt ? <span>Qəbul: {format.date(batch.receivedAt)}</span> : null}
                    {isSuggested ? <Badge tone="accent">{strategy} təklifi</Badge> : null}
                    {expiryBadge}
                    {!selectable ? <Badge tone="danger">{reason ?? status}</Badge> : null}
                    {short ? <Badge tone="warning">Qismən ayırma</Badge> : null}
                  </span>
                </span>
                <span className="wms-batch__qty">
                  {format.number(available, decimals)}
                  {uom ? ` ${uom}` : ''}
                </span>
              </button>
            );
          })
        )}
      </div>
      {offSuggestion ? (
        <div
          className="wms-ledger__check wms-ledger__check--fail"
          role="alert"
          data-testid="wms-batch-off-suggestion"
        >
          {Icons.warn(16)}
          <span>
            {strategy} təklifindən kənar partiya seçildi. Səbəb kodu və qeyd məcburidir; seçim audit
            jurnalına düşür.
          </span>
        </div>
      ) : null}
    </div>
  );
}
