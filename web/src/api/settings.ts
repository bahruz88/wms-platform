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
 * `GET /inventory/settings` is not routed on the gateway yet (404). Until it is, this hook keeps
 * one copy of every fallback, in one file, and tells the screen it is using one — so the screen
 * can say so on the surface instead of presenting a guess as the tenant's configuration. When
 * the endpoint lands nothing else has to change.
 */

/** The keys the interface reads, with the value used while the endpoint is unavailable. */
export const SETTING_FALLBACKS = {
  expiry_warning_days: 30,
  expiry_critical_days: 7,
  count_variance_approval_threshold_pct: 2,
  receipt_over_tolerance_pct: 0,
} as const;

export type SettingKey = keyof typeof SETTING_FALLBACKS;

export interface InventorySettings {
  /** The tenant's value, or the documented fallback when the endpoint has not answered. */
  get: (key: SettingKey) => number;
  /** True when `key` came from `SETTING_FALLBACKS` rather than from the server. */
  isFallback: (key: SettingKey) => boolean;
  /** True when no setting at all could be read — the endpoint is unrouted or failed. */
  unavailable: boolean;
  /** The status the endpoint answered with, for the notice the screen shows. */
  status: number | null;
}

export function useInventorySettings(scope: string): InventorySettings {
  const settings = useApiPage<InventorySetting>(
    ['inventory-settings', scope],
    listInventorySettings,
    100,
    { retry: false },
  );

  const raw = (key: SettingKey): number | null => {
    const found = (settings.data?.items ?? []).find((s) => s.key === key)?.value;
    if (found === undefined) return null;
    const parsed = Number(found);
    return Number.isFinite(parsed) ? parsed : null;
  };

  return {
    get: (key) => raw(key) ?? SETTING_FALLBACKS[key],
    isFallback: (key) => raw(key) === null,
    unavailable: settings.isError || (settings.data?.items ?? []).length === 0,
    status: settings.error?.status ?? null,
  };
}

/** The sentence a screen shows when it is displaying fallbacks rather than tenant settings. */
export function settingsFallbackNote(status: number | null): string {
  const suffix = status ? ` (${status})` : '';
  return `GET /inventory/settings hələ açılmayıb${suffix} — aşağıdakı hədlər tenant parametri deyil, sənəddə yazılmış standart dəyərlərdir. Endpoint açılan kimi tenant dəyərləri işləyəcək.`;
}
