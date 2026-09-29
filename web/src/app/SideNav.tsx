import { useEffect, useMemo, useState } from 'react';
import { Link } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { Icons } from '@ds/index';
import { navItemMatches, type NavGroup } from './navigation';
import {
  groupDomId,
  readCollapsedGroups,
  revealActiveGroup,
  toggleGroup,
  writeCollapsedGroups,
  type CollapsedGroups,
} from './navCollapse';

/**
 * The sidebar's entry list, one disclosure per labelled group.
 *
 * Each group header is a button that folds its entries away (`aria-expanded` / `aria-controls`,
 * the WAI-ARIA disclosure pattern). Folded entries stay in the DOM under `hidden`, so the header
 * keeps a real target to control and a screen reader sees one fewer region rather than a broken
 * reference. The ungrouped «Panel» block has no header and never folds.
 *
 * A folded header still tells the user what it hides: it turns `accent` when the current screen
 * is inside it, and it takes over the inbox's unread count so the number is not lost with the
 * entry. The group holding the current route is opened whenever the route changes — a link from
 * a dashboard tile, the back button, a bookmark — because a menu that hides where you are is
 * worse than one that ignores a fold you made earlier.
 */

export interface SideNavProps {
  groups: readonly NavGroup[];
  pathname: string;
  /** Unread inbox count; shown beside the inbox entry, or on its group's header when folded. */
  unreadCount: number;
}

export function SideNav({ groups, pathname, unreadCount }: SideNavProps) {
  const { t } = useTranslation();
  const [collapsed, setCollapsed] = useState<CollapsedGroups>(readCollapsedGroups);

  // The route moved: make sure its group is open. Same reference back means nothing to do.
  useEffect(() => {
    setCollapsed((current) => revealActiveGroup(current, groups, pathname));
  }, [groups, pathname]);

  useEffect(() => writeCollapsedGroups(collapsed), [collapsed]);

  const unreadLabel = useMemo(
    () => (unreadCount > 99 ? '99+' : String(unreadCount)),
    [unreadCount],
  );

  return (
    <>
      {groups.map((group, groupIndex) => {
        const labelKey = group.labelKey;
        const key = labelKey ?? `group-${groupIndex}`;
        const folded = labelKey !== null && collapsed.has(labelKey);
        const holdsActive = group.items.some((item) => navItemMatches(item, pathname));
        const hidesUnread =
          folded && unreadCount > 0 && group.items.some((i) => i.badge === 'unreadNotifications');
        const panelId = labelKey ? groupDomId(labelKey) : undefined;
        const headerClass = [
          'wms-side__group-btn',
          folded ? 'wms-side__group-btn--collapsed' : '',
          folded && holdsActive ? 'wms-side__group-btn--active' : '',
        ]
          .filter(Boolean)
          .join(' ');

        return (
          <div key={key} className="wms-side__group">
            {labelKey ? (
              <button
                type="button"
                className={headerClass}
                aria-expanded={!folded}
                aria-controls={panelId}
                // The accessible name is the group label alone; the unread count it may carry is
                // a decoration, exactly as on the inbox link itself.
                aria-label={t(labelKey)}
                onClick={() => setCollapsed((current) => toggleGroup(current, labelKey))}
              >
                <span className="wms-side__group-text">{t(labelKey)}</span>
                {hidesUnread ? (
                  <span
                    className="wms-side__badge"
                    title={t('app.unreadCount', { count: unreadCount })}
                    aria-hidden="true"
                  >
                    {unreadLabel}
                  </span>
                ) : null}
                <span className="wms-side__group-chevron" aria-hidden="true">
                  {Icons.chevron(14)}
                </span>
              </button>
            ) : null}

            <div id={panelId} className="wms-side__group-items" hidden={folded}>
              {group.items.map((item) => {
                const active = navItemMatches(item, pathname);
                return (
                  <Link
                    key={item.to}
                    to={item.to}
                    // The accessible name is the label alone. Without this the unread count joins
                    // the link's text, so a screen reader announces «Bildirişlər 5» and any test
                    // that lists the navigation sees a different entry once the badge appears.
                    aria-label={t(item.labelKey)}
                    aria-current={active ? 'page' : undefined}
                    className={active ? 'wms-side__link wms-side__link--active' : 'wms-side__link'}
                  >
                    {t(item.labelKey)}
                    {item.badge === 'unreadNotifications' && unreadCount > 0 ? (
                      <span
                        className="wms-side__badge"
                        title={t('app.unreadCount', { count: unreadCount })}
                        aria-hidden="true"
                      >
                        {unreadLabel}
                      </span>
                    ) : null}
                  </Link>
                );
              })}
            </div>
          </div>
        );
      })}
    </>
  );
}
