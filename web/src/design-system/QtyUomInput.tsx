import { useId, type ChangeEvent } from 'react';
import { Decimal } from '@core/decimal';
import { Field, type FieldProps } from './Field';
import { format } from './format';

export interface ProductUom {
  id: string | number;
  code: string;
  factorToBase: number;
}

/**
 * QtyUomInput — docs/design-system/components/QtyUomInput/README.md.
 *
 * Every quantity in the system is entered through this control. The base-UoM equivalent under the
 * field is not optional: the step lost in the spreadsheet process was exactly the `1 QUTUDA`
 * column that took part in no calculation.
 *
 * Changing the unit never silently converts the figure — `8 CASE` switched to `PCS` stays `8`,
 * only the base equivalent moves. Negative input is rejected: the sign comes from the document
 * type, not from the user.
 *
 * `factorToBase` is a `number` only because index.d.ts declares it so; the conversion itself runs
 * through `Decimal` so the preview matches the server's DECIMAL(18,8) arithmetic.
 */
export interface QtyUomInputProps extends FieldProps {
  id?: string;
  name?: string;
  // eslint-disable-next-line wms/no-number-for-decimal -- docs/design-system/components/index.d.ts declares this presentation prop as `number`; the contract decimal string is accepted alongside it and is what screens pass.
  qty?: string | number;
  uomId?: string | number;
  /** `master_product_uom` rows. The base UoM must be in the list, with factor 1. */
  uoms: ProductUom[];
  baseUomCode?: string;
  /** `base_uom.decimals` — the base equivalent is shown with this many decimals. */
  decimals?: number;
  onQtyChange?: (value: string, e: ChangeEvent<HTMLInputElement>) => void;
  onUomChange?: (uomId: string, e: ChangeEvent<HTMLSelectElement>) => void;
  disabled?: boolean;
  placeholder?: string;
}

export function QtyUomInput({
  id,
  name,
  qty,
  uomId,
  uoms,
  baseUomCode,
  decimals = 4,
  onQtyChange,
  onUomChange,
  disabled,
  placeholder,
  label,
  required,
  hint,
  error,
}: QtyUomInputProps) {
  const generatedId = useId();
  const inputId = id ?? `${generatedId}-qty`;
  const describeId = `${generatedId}-desc`;

  const selected = uoms.find((u) => String(u.id) === String(uomId)) ?? uoms[0];
  const factor = selected?.factorToBase ?? 1;
  const isBase = !baseUomCode || !selected || selected.code === baseUomCode || factor === 1;

  let baseEquivalent: string | null = null;
  if (!isBase && qty !== undefined && qty !== '' && baseUomCode) {
    try {
      const base = new Decimal(String(qty)).times(new Decimal(String(factor)));
      baseEquivalent = `= ${format.number(base, decimals)} ${baseUomCode} · əmsal ${format.number(factor, 4)}`;
    } catch {
      baseEquivalent = null;
    }
  }

  const handleQty = (e: ChangeEvent<HTMLInputElement>) => {
    const raw = e.target.value;
    // The sign is derived from the document type (issue is negative), never typed in.
    if (raw.startsWith('-') || raw.startsWith('−')) return;
    onQtyChange?.(raw, e);
  };

  return (
    <Field
      label={label}
      htmlFor={inputId}
      required={required}
      hint={hint}
      error={error}
      describedById={describeId}
    >
      <div className="wms-qty">
        <input
          id={inputId}
          name={name}
          className="wms-qty__num"
          type="text"
          inputMode="decimal"
          value={qty ?? ''}
          onChange={handleQty}
          disabled={disabled}
          placeholder={placeholder}
          required={required}
          aria-invalid={error ? true : undefined}
          aria-describedby={hint || error ? describeId : undefined}
        />
        <select
          className="wms-qty__uom"
          value={selected ? String(selected.id) : ''}
          onChange={(e) => onUomChange?.(e.target.value, e)}
          disabled={disabled || uoms.length <= 1}
          aria-label="Ölçü vahidi"
        >
          {uoms.map((u) => (
            <option key={String(u.id)} value={String(u.id)}>
              {u.code}
            </option>
          ))}
        </select>
      </div>
      {baseEquivalent ? <div className="wms-qty__base">{baseEquivalent}</div> : null}
    </Field>
  );
}
