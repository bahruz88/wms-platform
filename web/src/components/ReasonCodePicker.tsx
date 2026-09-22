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
 * needs a reason code, and every one of them is blocked when the code cannot be chosen.
 *
 * `GET /masterdata/reason-codes` serves now, so the normal path is what it always should have
 * been: a real `Select` of the codes in this document's `reasonGroup`, filtered server-side by
 * the contract's own parameter. The id field is what is left of the period when the list
 * answered 404 — it is an **error state**, not a second normal path, and a user only reaches it
 * when the call genuinely fails. Keeping it means a gateway outage degrades the document to
 * "type the id you know" rather than to "an empty dropdown that silently blocks you".
 *
 * Three states, never a silent one:
 *
 *   · the list answers → an ordinary `Select`, ordered as the server sends it;
 *   · the route is missing (404 / 405) or the call failed → a mono id field naming the
 *     operation and its status;
 *   · the list answers but is empty for this group → the select stays, and says which group was
 *     asked for and that master data has to define a code first.
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

export const REASON_CODES_OPERATION = 'GET /masterdata/reason-codes';

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
        hint={`${REASON_CODES_OPERATION} cavab vermədi (${status}) — seçim siyahısı yüklənmədi, səbəb kodunun id-sini yazın. ${groupNote}.`}
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
