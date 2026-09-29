import { navItemMatches, type NavGroup } from './navigation';

/**
 * Which sidebar groups the user has folded shut.
 *
 * The set is keyed by the group's `labelKey` (`nav.procurement`, …) — the one stable identity a
 * group has across languages and permission filters. It is remembered per browser, like the theme
 * and the language, because a keeper who never touches purchasing should not have to fold
 * «Satınalma» away again on every visit.
 *
 * The ungrouped «Panel» block has no label and is never collapsible: the dashboard entry is the
 * one thing that must always be one click away.
 */

const STORAGE_KEY = 'wms.nav.collapsed';

export type CollapsedGroups = ReadonlySet<string>;

export function readCollapsedGroups(): Set<string> {
  if (typeof window === 'undefined') return new Set();
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    if (!raw) return new Set();
    const parsed: unknown = JSON.parse(raw);
    return new Set(
      Array.isArray(parsed) ? parsed.filter((k): k is string => typeof k === 'string') : [],
    );
  } catch {
    // Unreadable storage (private mode, blocked site data, a hand-edited value) is the same as
    // nothing remembered — every group opens, which is the safe default.
    return new Set();
  }
}

export function writeCollapsedGroups(collapsed: CollapsedGroups): void {
  if (typeof window === 'undefined') return;
  try {
    if (collapsed.size === 0) window.localStorage.removeItem(STORAGE_KEY);
    else window.localStorage.setItem(STORAGE_KEY, JSON.stringify([...collapsed]));
  } catch {
    // Storage may refuse the write; the state still holds for the life of the page.
  }
}

export function toggleGroup(collapsed: CollapsedGroups, key: string): Set<string> {
  const next = new Set(collapsed);
  if (next.has(key)) next.delete(key);
  else next.add(key);
  return next;
}

/** The group one of whose entries owns `pathname`, or `null` for a route outside the menu. */
export function groupForPath(groups: readonly NavGroup[], pathname: string): NavGroup | null {
  return groups.find((group) => group.items.some((item) => navItemMatches(item, pathname))) ?? null;
}

/**
 * Opens the group that holds `pathname`, so the active entry is never hidden behind a folded
 * header. Returns `collapsed` itself when there is nothing to open, so callers can compare by
 * reference and skip a write.
 */
export function revealActiveGroup(
  collapsed: CollapsedGroups,
  groups: readonly NavGroup[],
  pathname: string,
): CollapsedGroups {
  const group = groupForPath(groups, pathname);
  if (!group?.labelKey || !collapsed.has(group.labelKey)) return collapsed;
  const next = new Set(collapsed);
  next.delete(group.labelKey);
  return next;
}

/** DOM id of a group's entry list, for `aria-controls`: `nav.procurement` → `wms-nav-procurement`. */
export function groupDomId(labelKey: string): string {
  return `wms-${labelKey.replace(/[^a-zA-Z0-9]+/g, '-')}`;
}
