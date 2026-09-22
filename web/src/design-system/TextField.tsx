import { useId, type ChangeEvent } from 'react';
import { Field, type FieldProps } from './Field';

/**
 * TextField — docs/design-system/components/TextField/README.md.
 *
 * `mono` for every identifier field (SKU, barcode, batch no, document no, VÖEN): those get
 * compared character by character. Quantities do not belong here — use `QtyUomInput`.
 * A read-only value uses `readOnly`, not `disabled`, so it stays focusable and copyable.
 */
export interface TextFieldProps extends FieldProps {
  id?: string;
  name?: string;
  type?: string;
  value?: string | number;
  onChange?: (e: ChangeEvent<HTMLInputElement>) => void;
  placeholder?: string;
  disabled?: boolean;
  readOnly?: boolean;
  maxLength?: number;
  /** Mono family for SKU, barcode, document number. */
  mono?: boolean;
  align?: 'left' | 'right';
  autoFocus?: boolean;
  /**
   * Accessible name for a control with no visible `label` — an input inside a table cell, where
   * the column header names it for a sighted user but not for a screen reader. Brand book §
   * "Əlçatanlıq": every control carries a name.
   */
  ariaLabel?: string;
}

export function TextField({
  id,
  name,
  type = 'text',
  value,
  onChange,
  placeholder,
  disabled,
  readOnly,
  maxLength,
  mono,
  align,
  autoFocus,
  ariaLabel,
  label,
  required,
  hint,
  error,
}: TextFieldProps) {
  const generatedId = useId();
  const inputId = id ?? `${generatedId}-input`;
  const describeId = `${generatedId}-desc`;

  return (
    <Field
      label={label}
      htmlFor={inputId}
      required={required}
      hint={hint}
      error={error}
      describedById={describeId}
    >
      <input
        id={inputId}
        name={name}
        type={type}
        className={mono ? 'wms-input wms-num' : 'wms-input'}
        value={value ?? ''}
        onChange={onChange}
        placeholder={placeholder}
        disabled={disabled}
        readOnly={readOnly}
        maxLength={maxLength}
        autoFocus={autoFocus}
        required={required}
        aria-label={label === undefined ? ariaLabel : undefined}
        aria-invalid={error ? true : undefined}
        aria-describedby={hint || error ? describeId : undefined}
        style={align === 'right' ? { textAlign: 'right' } : undefined}
      />
    </Field>
  );
}
