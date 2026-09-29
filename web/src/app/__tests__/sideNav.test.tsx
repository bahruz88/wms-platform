import { beforeEach, describe, expect, it } from 'vitest';
import { fireEvent, render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import i18n from '@/i18n';
import { SideNav } from '../SideNav';
import { NAV_GROUPS, visibleNavGroups, type NavGroup } from '../navigation';
import { permissionsForRoles } from '@auth/permissions';
import {
  groupDomId,
  groupForPath,
  readCollapsedGroups,
  revealActiveGroup,
  toggleGroup,
  writeCollapsedGroups,
} from '../navCollapse';

/**
 * The sidebar folds by group. The rules that matter: every group opens by default (nothing is
 * hidden from a first-time user or from the e2e suite that counts links); a fold is remembered
 * per browser; the group holding the current route is opened when the route changes; a folded
 * header still shows the inbox count and whether the current screen is inside it.
 */

const STORAGE_KEY = 'wms.nav.collapsed';
const label = (key: string) => i18n.t(key);

function renderNav(groups: readonly NavGroup[], pathname: string, unreadCount = 0) {
  return render(
    <MemoryRouter initialEntries={[pathname]}>
      <nav aria-label="nav">
        <SideNav groups={groups} pathname={pathname} unreadCount={unreadCount} />
      </nav>
    </MemoryRouter>,
  );
}

beforeEach(() => {
  window.localStorage.clear();
});

describe('collapsed-group helpers', () => {
  it('reads nothing as «all open», and survives garbage in storage', () => {
    expect(readCollapsedGroups().size).toBe(0);
    window.localStorage.setItem(STORAGE_KEY, '{not json');
    expect(readCollapsedGroups().size).toBe(0);
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(['nav.procurement', 7, null]));
    expect([...readCollapsedGroups()]).toEqual(['nav.procurement']);
  });

  it('round-trips through storage and clears the key when nothing is folded', () => {
    writeCollapsedGroups(new Set(['nav.system']));
    expect([...readCollapsedGroups()]).toEqual(['nav.system']);
    writeCollapsedGroups(new Set());
    expect(window.localStorage.getItem(STORAGE_KEY)).toBeNull();
  });

  it('toggles without mutating the previous set', () => {
    const before = new Set(['nav.system']);
    const after = toggleGroup(before, 'nav.inventory');
    expect([...after].sort()).toEqual(['nav.inventory', 'nav.system']);
    expect([...before]).toEqual(['nav.system']);
    expect([...toggleGroup(after, 'nav.system')]).toEqual(['nav.inventory']);
  });

  it('finds the group a route belongs to, including detail and tab-sibling routes', () => {
    expect(groupForPath(NAV_GROUPS, '/inventory/issues/42')?.labelKey).toBe('nav.inventory');
    expect(groupForPath(NAV_GROUPS, '/inventory/samples')?.labelKey).toBe('nav.inventory');
    expect(groupForPath(NAV_GROUPS, '/')?.labelKey).toBeNull();
    expect(groupForPath(NAV_GROUPS, '/nowhere')).toBeNull();
  });

  it('reveals the active group and returns the same set when there is nothing to reveal', () => {
    const folded = new Set(['nav.procurement', 'nav.system']);
    expect(revealActiveGroup(folded, NAV_GROUPS, '/inventory/counts')).toBe(folded);
    expect(revealActiveGroup(folded, NAV_GROUPS, '/nowhere')).toBe(folded);
    const opened = revealActiveGroup(folded, NAV_GROUPS, '/procurement/rfqs');
    expect([...opened]).toEqual(['nav.system']);
    expect(folded.size).toBe(2);
  });

  it('derives a stable DOM id from the label key', () => {
    expect(groupDomId('nav.procurement')).toBe('wms-nav-procurement');
  });
});

describe('SideNav', () => {
  const groups = visibleNavGroups(permissionsForRoles(['ADMIN']));
  const requisitions = () => screen.queryByRole('link', { name: label('nav.requisitions') });
  const header = (key: string) => screen.getByRole('button', { name: label(key) });

  it('opens every group by default and wires each header to its entry list', () => {
    renderNav(groups, '/');
    for (const group of groups) {
      if (!group.labelKey) continue;
      const btn = header(group.labelKey);
      expect(btn).toHaveAttribute('aria-expanded', 'true');
      expect(btn).toHaveAttribute('aria-controls', groupDomId(group.labelKey));
      expect(document.getElementById(groupDomId(group.labelKey))).not.toBeNull();
    }
    // The dashboard block has no header: it is never foldable.
    expect(screen.getByRole('link', { name: label('nav.dashboard') })).toBeInTheDocument();
    expect(screen.queryByRole('button', { name: label('nav.dashboard') })).toBeNull();
  });

  it('folds a group on click, hides its entries, and remembers the fold', () => {
    renderNav(groups, '/');
    expect(requisitions()).toBeInTheDocument();
    fireEvent.click(header('nav.procurement'));
    expect(header('nav.procurement')).toHaveAttribute('aria-expanded', 'false');
    // Hidden from the accessibility tree — not merely styled away.
    expect(requisitions()).toBeNull();
    expect(JSON.parse(window.localStorage.getItem(STORAGE_KEY) ?? '[]')).toEqual([
      'nav.procurement',
    ]);
    fireEvent.click(header('nav.procurement'));
    expect(requisitions()).toBeInTheDocument();
    expect(window.localStorage.getItem(STORAGE_KEY)).toBeNull();
  });

  it('comes back folded on the next visit', () => {
    writeCollapsedGroups(new Set(['nav.procurement']));
    renderNav(groups, '/');
    expect(header('nav.procurement')).toHaveAttribute('aria-expanded', 'false');
    expect(requisitions()).toBeNull();
    expect(header('nav.inventory')).toHaveAttribute('aria-expanded', 'true');
  });

  it('opens the group that holds the current route, and marks a folded one that holds it', () => {
    writeCollapsedGroups(new Set(['nav.procurement', 'nav.inventory']));
    renderNav(groups, '/procurement/rfqs');
    // The route's own group was opened so the active entry is visible…
    expect(header('nav.procurement')).toHaveAttribute('aria-expanded', 'true');
    expect(screen.getByRole('link', { name: label('nav.rfqs') })).toHaveAttribute(
      'aria-current',
      'page',
    );
    // …and the other fold was left alone.
    expect(header('nav.inventory')).toHaveAttribute('aria-expanded', 'false');
    expect([...readCollapsedGroups()]).toEqual(['nav.inventory']);
  });

  it('keeps a fold made while inside the group, and lights the header instead', () => {
    renderNav(groups, '/procurement/rfqs');
    fireEvent.click(header('nav.procurement'));
    const btn = header('nav.procurement');
    expect(btn).toHaveAttribute('aria-expanded', 'false');
    expect(btn.className).toContain('wms-side__group-btn--active');
    expect(header('nav.inventory').className).not.toContain('wms-side__group-btn--active');
  });

  it('moves the unread count onto the header when the inbox is folded away', () => {
    const { container } = renderNav(groups, '/', 7);
    const inbox = screen.getByRole('link', { name: label('nav.notifications') });
    expect(inbox.querySelector('.wms-side__badge')?.textContent).toBe('7');
    expect(header('nav.system').querySelector('.wms-side__badge')).toBeNull();

    fireEvent.click(header('nav.system'));
    expect(header('nav.system').querySelector('.wms-side__badge')?.textContent).toBe('7');
    // The header's accessible name stays the label; the count is decoration.
    expect(header('nav.system')).toHaveAttribute('aria-label', label('nav.system'));
    // The inbox link keeps its badge under `hidden`; only the header's is left in the tree.
    const visibleBadges = [...container.querySelectorAll('.wms-side__badge')].filter(
      (badge) => !badge.closest('[hidden]'),
    );
    expect(visibleBadges).toHaveLength(1);
  });
});
