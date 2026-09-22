import { useApiPage } from './hooks';
import { listInventorySettings, type InventorySetting } from './endpoints';

/**
 * `inv_setting` — the one place the interface reads a tenant threshold from.
 *
 * SPEC/TOR §36 is explicit that expiry windows, tolerance percentages, the costing method and
 * the count threshold are **not** hard-coded. Four screens were each carrying their own
 * `const DEFAULT_…` and silently using it, which is the opposite of that requirement: a tenant
 * whose warning window is 45 days saw 30 with nothing saying where 30 came from.
 *
 * `GET /inventory/settings` serves the tenant's rows now, so there is no default left in this
 * file either: `get()` answers `null` when a key could not be read, and a screen that gets
 * `null` says the threshold is unknown instead of colouring a row against a number nobody
 * configured. The "falling back" wording stayed behind only as an **error state** — the notice a
 * screen shows when the call itself failed.
 */

/** The keys the interface reads. Their values live in the tenant's `inv_setting` rows, not here. */
export const SETTING_KEYS = [
  'expiry_warning_days',
  'expiry_critical_days',
  'count_variance_approval_threshold_pct',
  'receipt_over_tolerance_pct',
] as const;

export type SettingKey = (typeof SETTING_KEYS)[number];

export interface InventorySettings {
  /** The tenant's value, or `null` when this key is not in the answer. Never a guess. */
  get: (key: SettingKey) => number | null;
  /** The stored string, for the keys that are not numbers (`costing_method`, booleans). */
  raw: (key: string) => string | null;
  /** True once the query has settled without a single readable setting. */
  unavailable: boolean;
  /** The status the endpoint answered with, for the notice the screen shows. */
  status: number | null;
  /** The RFC 7807 `code`, so the notice can show it (brand book: the code is always visible). */
  code: string | null;
  isLoading: boolean;
}

export function useInventorySettings(scope: string): InventorySettings {
  const settings = useApiPage<InventorySetting>(
    ['inventory-settings', scope],
    listInventorySettings,
    100,
    { retry: false },
  );

  const rows = settings.data?.items ?? [];
  const raw = (key: string): string | null => rows.find((s) => s.key === key)?.value ?? null;

  const numeric = (key: SettingKey): number | null => {
    const found = raw(key);
    if (found === null) return null;
    const parsed = Number(found);
    return Number.isFinite(parsed) ? parsed : null;
  };

  return {
    get: numeric,
    raw,
    unavailable: !settings.isLoading && (settings.isError || rows.length === 0),
    status: settings.error?.status ?? null,
    code: settings.error?.code ?? null,
    isLoading: settings.isLoading,
  };
}

/**
 * The sentence a screen shows when the settings call did not answer.
 *
 * This is an error state, not a substitute configuration: nothing on the screen is computed
 * from a default, so the notice says which thresholds are simply unknown.
 */
export function settingsUnavailableNote(status: number | null): string {
  const cause =
    status === null
      ? 'Parametrlər hələ təyin edilməyib — standart dəyərlər işlənir.'
      : `GET /inventory/settings cavab vermədi (${status})`;
  return `${cause}. Ekran heç bir standart dəyər işlətmir: hədd tələb edən göstəricilər «—» ilə qalır. Parametrləri «Sistem · Parametrlər» ekranından yoxlayın.`;
}
