import { useMemo } from 'react';
import type { ReactNode } from 'react';
import { Select, TextField, type SelectOption } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listReasonCodes, type ReasonCode, type ReasonGroup } from '@api/endpoints';
import { isApiError } from '@api/problem';

/**
 * The mandatory reason code, as a control that explains itself.
 *
 * Every cancellation, waste, adjustment, batch block, off-FEFO pick and reversal in the spec
 * needs a reason code, and every one of them is blocked when the code cannot be chosen. A plain
 * `Select` bound to `GET /master-data/reason-codes` renders an **empty dropdown with no
 * explanation** while that endpoint is unrouted (it answers 404 on the gateway today), which
 * silently stops the user without telling them why.
 *
 * So this control has three states and never a silent one:
 *
 *   · the list answers → an ordinary `Select`, grouped by `reasonGroup`;
 *   · the list is not routed (404 / 405) → a mono id field that names the missing operation and
 *     its status, so the document can still be written by someone who knows the id;
 *   · the list answers but is empty for this group → the select stays, and says which group was
 *     asked for and that master data has to define one first.
 *
 * It owns its own query so that a screen cannot forget `retry: false` and leave the user waiting
 * on three retries of a route that does not exist.
 */
export interface ReasonCodePickerProps {
  label?: ReactNode;
  /** Filters the list server-side. The contract closes the set (`master-data.v1.yaml`). */
  reasonGroup?: ReasonGroup;
  required?: boolean;
  disabled?: boolean;
  value: string;
  placeholder?: string;
  hint?: ReactNode;
  error?: ReactNode;
  /** Distinguishes this picker's cache entry from another screen's. */
  cacheKey?: string;
  onChange: (value: string) => void;
}

export const REASON_CODES_OPERATION = 'GET /master-data/reason-codes';

/**
 * True when the failure is "the gateway does not route this yet", not "the request was wrong".
 *
 * Takes `unknown` because `useMutation` types its error as `Error`: a 404 that carries no
 * problem `code` is an unmatched route, and that has to be said out loud rather than shown as a
 * failure the user caused.
 */
export function isUnrouted(error: unknown): boolean {
  if (!isApiError(error)) return false;
  return error.status === 404 || error.status === 405;
}

export function ReasonCodePicker({
  label = 'Səbəb kodu',
  reasonGroup,
  required = true,
  disabled,
  value,
  placeholder = 'Səbəb seçin',
  hint,
  error,
  cacheKey,
  onChange,
}: ReasonCodePickerProps) {
  const query = reasonGroup ? { reasonGroup } : {};
  const reasons = useApiPage<ReasonCode>(
    ['reason-codes', reasonGroup ?? 'all', cacheKey ?? ''],
    () => listReasonCodes(query),
    200,
    { retry: false },
  );

  const options: SelectOption[] = useMemo(
    () =>
      (reasons.data?.items ?? []).map((r) => ({
        value: String(r.id),
        label: `${r.code} · ${r.name}`,
      })),
    [reasons.data],
  );

  const groupNote = reasonGroup ? `Qrup: ${reasonGroup}` : 'Bütün səbəb qrupları';

  if (isUnrouted(reasons.error)) {
    const status = reasons.error?.status ?? 404;
    return (
      <TextField
        label={label}
        required={required}
        mono
        value={value}
        disabled={disabled}
        placeholder="id"
        hint={`${REASON_CODES_OPERATION} hələ açılmayıb (${status}) — seçim siyahısı yoxdur, səbəb kodunun id-sini yazın. ${groupNote}.`}
        error={error}
        onChange={(e) => onChange(e.target.value)}
      />
    );
  }

  if (reasons.isError) {
    // A real failure (500, network) is not the same as a missing route and does not read as one.
    return (
      <TextField
        label={label}
        required={required}
        mono
        value={value}
        disabled={disabled}
        placeholder="id"
        hint={`Səbəb kodu siyahısı yüklənmədi — ${reasons.error?.code ?? 'XƏTA'} (${
          reasons.error?.status ?? 0
        }). Yenidən cəhd edin və ya id yazın.`}
        error={error}
        onChange={(e) => onChange(e.target.value)}
      />
    );
  }

  const empty = !reasons.isLoading && options.length === 0;

  return (
    <Select
      label={label}
      required={required}
      disabled={disabled || reasons.isLoading}
      value={value}
      placeholder={reasons.isLoading ? 'Səbəb kodları yüklənir…' : placeholder}
      options={options}
      hint={
        empty
          ? `Bu qrupda səbəb kodu yoxdur (${groupNote}). Master data-da ən azı bir kod təyin edilməlidir.`
          : (hint ?? groupNote)
      }
      error={error}
      onChange={(e) => onChange(e.target.value)}
    />
  );
}
