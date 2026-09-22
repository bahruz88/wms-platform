import { useId, type ChangeEvent } from 'react';
import { Field, type FieldProps } from './Field';
import { Icons } from './Icons';

export interface SelectOption {
  value: string | number;
  label: string;
  disabled?: boolean;
}

/**
 * Select — docs/design-system/components/Select/README.md.
 *
 * An option the user may not pick stays in the list as `disabled` with the reason in its label —
 * removing it would leave the user wondering whether it exists at all.
 * Options are expected pre-sorted by `name_sort_key`; the browser's `localeCompare` places `ə`
 * wrongly for Azerbaijani.
 */
export interface SelectProps extends FieldProps {
  id?: string;
  name?: string;
  value?: string | number;
  options: SelectOption[];
  placeholder?: string;
  onChange?: (e: ChangeEvent<HTMLSelectElement>) => void;
  disabled?: boolean;
  /**
   * Accessible name for a control with no visible `label` — a select inside a table cell, where
   * the column header names it for a sighted user but not for a screen reader. Brand book §
   * "Əlçatanlıq": every control carries a name.
   */
  ariaLabel?: string;
}

export function Select({
  id,
  name,
  value,
  options,
  placeholder,
  onChange,
  disabled,
  ariaLabel,
  label,
  required,
  hint,
  error,
}: SelectProps) {
  const generatedId = useId();
  const selectId = id ?? `${generatedId}-select`;
  const describeId = `${generatedId}-desc`;

  return (
    <Field
      label={label}
      htmlFor={selectId}
      required={required}
      hint={hint}
      error={error}
      describedById={describeId}
    >
      <span className="wms-select-wrap">
        <select
          id={selectId}
          name={name}
          className="wms-select"
          value={value ?? ''}
          onChange={onChange}
          disabled={disabled}
          required={required}
          aria-label={label === undefined ? ariaLabel : undefined}
          aria-invalid={error ? true : undefined}
          aria-describedby={hint || error ? describeId : undefined}
        >
          {placeholder !== undefined ? (
            <option value="" disabled={required}>
              {placeholder}
            </option>
          ) : null}
          {options.map((option) => (
            <option key={String(option.value)} value={option.value} disabled={option.disabled}>
              {option.label}
            </option>
          ))}
        </select>
        <span className="wms-select-wrap__chevron">{Icons.chevron(16)}</span>
      </span>
    </Field>
  );
}
