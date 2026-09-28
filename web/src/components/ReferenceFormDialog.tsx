import { useEffect, useState, type ReactNode } from 'react';
import { Button, Dialog, Select, TextField } from '@ds/index';
import { ErrorState } from '@/components/Page';

/**
 * The create/edit dialog behind the simple reference tables — categories, units, reason codes,
 * locations, currency rates.
 *
 * Those five are the same shape of work: a handful of fields, no lines, no document lifecycle, and
 * a code that cannot be changed once anything points at it. One dialog driven by a field list keeps
 * them consistent and keeps the five screens from drifting apart in validation and wording.
 *
 * Products and suppliers deliberately do **not** use it. They carry fifteen and thirteen fields,
 * cost data behind a permission, and child collections — a form that describes them through a field
 * list would be harder to read than the form it replaced.
 */
export type FieldKind = 'text' | 'number' | 'decimal' | 'date' | 'select' | 'switch';

export interface FieldSpec {
  name: string;
  label: string;
  kind: FieldKind;
  required?: boolean;
  hint?: string;
  /** `select` only. */
  options?: Array<{ value: string; label: string }>;
  /** `true` keeps the field out of the edit form — a code other rows already reference. */
  createOnly?: boolean;
  /** Validation beyond «required»; returns the message to show, or undefined when fine. */
  validate?: (value: string, all: Record<string, string>) => string | undefined;
}

export type FormValues = Record<string, string>;

export function ReferenceFormDialog({
  open,
  mode,
  title,
  subtitle,
  fields,
  initial,
  pending,
  error,
  onClose,
  onSubmit,
  children,
}: {
  open: boolean;
  mode: 'create' | 'edit';
  title: string;
  subtitle?: string;
  fields: FieldSpec[];
  initial?: FormValues;
  pending?: boolean;
  error?: unknown;
  onClose: () => void;
  onSubmit: (values: FormValues) => void;
  children?: ReactNode;
}) {
  const [values, setValues] = useState<FormValues>({});
  const [touched, setTouched] = useState<Record<string, boolean>>({});

  // Re-seeded whenever the dialog opens, so editing one row never shows the previous row's values.
  useEffect(() => {
    if (!open) return;
    setValues(initial ?? {});
    setTouched({});
  }, [open, initial]);

  const visible = fields.filter((f) => mode === 'create' || !f.createOnly);

  const errorOf = (field: FieldSpec): string | undefined => {
    const value = values[field.name] ?? '';
    if (field.required && value.trim().length === 0) return `${field.label} məcburidir.`;
    return field.validate?.(value, values);
  };

  const blocking = visible.filter((f) => errorOf(f) !== undefined);
  const set = (name: string, value: string) => setValues((prev) => ({ ...prev, [name]: value }));

  return (
    <Dialog
      open={open}
      title={title}
      subtitle={subtitle}
      onClose={pending ? undefined : onClose}
      footer={
        <>
          <Button disabled={pending} onClick={onClose}>
            İmtina
          </Button>
          <Button
            variant="primary"
            loading={pending}
            disabled={blocking.length > 0}
            title={
              blocking.length > 0
                ? `Əvvəlcə doldurun: ${blocking.map((f) => f.label.toLocaleLowerCase('az')).join(', ')}`
                : undefined
            }
            onClick={() => onSubmit(values)}
          >
            {mode === 'create' ? 'Yarat' : 'Yadda saxla'}
          </Button>
        </>
      }
    >
      <div className="wms-stack">
        {error ? <ErrorState error={error} /> : null}
        {visible.map((field) => {
          const value = values[field.name] ?? '';
          const message = touched[field.name] ? errorOf(field) : undefined;
          if (field.kind === 'select' || field.kind === 'switch') {
            const options =
              field.kind === 'switch'
                ? [
                    { value: 'false', label: 'Xeyr' },
                    { value: 'true', label: 'Bəli' },
                  ]
                : (field.options ?? []);
            return (
              <Select
                key={field.name}
                label={field.label}
                required={field.required}
                value={value}
                hint={field.hint}
                error={message}
                options={options}
                onChange={(e) => {
                  set(field.name, e.target.value);
                  setTouched((prev) => ({ ...prev, [field.name]: true }));
                }}
              />
            );
          }
          return (
            <TextField
              key={field.name}
              label={field.label}
              required={field.required}
              mono={field.kind !== 'text'}
              type={field.kind === 'date' ? 'date' : 'text'}
              value={value}
              hint={field.hint}
              error={message}
              onChange={(e) => {
                const next =
                  field.kind === 'number' ? e.target.value.replace(/[^0-9]/g, '') : e.target.value;
                set(field.name, next);
                setTouched((prev) => ({ ...prev, [field.name]: true }));
              }}
            />
          );
        })}
        {children}
      </div>
    </Dialog>
  );
}

/**
 * A field's value, trimmed. `FormValues` is an index signature, so every read is `string |
 * undefined`; this keeps the call sites from repeating `?? ''` and from sending untrimmed text.
 */
export function text(values: FormValues, name: string): string {
  return (values[name] ?? '').trim();
}

/** Rejects anything that is not a decimal the contract would accept. */
export function decimalField(value: string): string | undefined {
  if (value.trim().length === 0) return undefined;
  return /^-?\d+([.,]\d+)?$/.test(value.trim()) ? undefined : 'Onluq ədəd yazın.';
}

/** A code is upper-case ASCII with digits, dashes and underscores — never localised text. */
export function codeField(value: string): string | undefined {
  if (value.trim().length === 0) return undefined;
  return /^[A-Z0-9_-]+$/.test(value.trim())
    ? undefined
    : 'Kod yalnız böyük latın hərfləri, rəqəm, «-» və «_» ola bilər.';
}
