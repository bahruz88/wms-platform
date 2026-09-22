import type { ReactNode } from 'react';
import { Select, TextField, type SelectOption } from '@ds/index';
import type { ApiError } from '@api/problem';

/**
 * A master-data reference field that degrades honestly.
 *
 * While the list endpoint answers, this is an ordinary `Select`. When the gateway does not route
 * it yet (404 / 405) the field becomes a mono id input and says exactly which operation is
 * missing, so the document can still be written and the user is never shown an empty picker with
 * no explanation. It never pretends the list is empty when the truth is that it was never asked.
 */
export function RefPicker({
  label,
  required,
  value,
  options,
  placeholder,
  hint,
  error,
  disabled,
  listError,
  operation,
  onChange,
}: {
  label: ReactNode;
  required?: boolean;
  value: string;
  options: SelectOption[];
  placeholder?: string;
  hint?: ReactNode;
  error?: ReactNode;
  disabled?: boolean;
  /** The list query's error, when it failed. */
  listError?: ApiError | null;
  /** The contract operation the picker reads, e.g. `GET /masterdata/suppliers`. */
  operation: string;
  onChange: (value: string) => void;
}) {
  const notRouted = listError != null && (listError.status === 404 || listError.status === 405);

  if (notRouted) {
    return (
      <TextField
        label={label}
        required={required}
        mono
        value={value}
        disabled={disabled}
        placeholder="id"
        hint={`${operation} hələ açılmayıb (${listError.status}) — seçim siyahısı yoxdur, id yazın.`}
        error={error}
        onChange={(e) => onChange(e.target.value)}
      />
    );
  }

  return (
    <Select
      label={label}
      required={required}
      value={value}
      options={options}
      placeholder={placeholder}
      hint={hint}
      error={error}
      disabled={disabled}
      onChange={(e) => onChange(e.target.value)}
    />
  );
}
