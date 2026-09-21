import { useEffect, useRef, useState } from 'react';
import { Link, Outlet, useLocation } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { Button, Icons } from '@ds/index';
import { useApiQuery } from '@api/hooks';
import { getTenant } from '@api/endpoints';
import { useAuth } from '@auth/index';
import {
  LANGUAGE_NAMES,
  SUPPORTED_LANGUAGES,
  setLanguage,
  storedLanguage,
  type Language,
} from '@/i18n';
import { useTheme, type ThemePreference } from './theme';
import { navItemMatches, visibleNavGroups } from './navigation';

/**
 * Application shell — docs/design-system/screens/README.md «Layout qaydaları».
 *
 * 248px sidebar on `surface` with a right border; the groups are labelled at 12px / 600 in
 * `ink-subtle`; the active entry is `accent-soft` with `accent` text; the user block is pinned to
 * the bottom with a 32px round monogram on `accent-soft`, the name and the role code. Tenant,
 * theme, language and sign-out hang off that block, so the header belongs entirely to the screen
 * — which is what lets it be 72px on a list and 84px on a document.
 *
 * Nothing here uppercases interface text (`label` weight and letter-spacing carry the emphasis);
 * the one uppercase call is the monogram, and it goes through the Azerbaijani locale so `i`
 * becomes `İ` rather than `I`.
 */

/** Two-letter monogram, Azerbaijani casing. Never `toUpperCase()`: `i` → `İ`, not `I`. */
export function monogram(name: string): string {
  const parts = name
    .split(/[\s._-]+/)
    .map((p) => p.trim())
    .filter(Boolean);
  const [first, second] = parts;
  if (!first) return '—';
  const letters = second ? `${first.slice(0, 1)}${second.slice(0, 1)}` : first.slice(0, 2);
  return letters.toLocaleUpperCase('az');
}

export function AppShell() {
  const { t } = useTranslation();
  const { session, signOut } = useAuth();
  const { preference, setPreference } = useTheme();
  const { pathname } = useLocation();
  const [menuOpen, setMenuOpen] = useState(false);
  const [language, setLanguageState] = useState<Language>(storedLanguage);
  const userRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!menuOpen) return;
    const onClick = (e: MouseEvent) => {
      if (userRef.current && !userRef.current.contains(e.target as Node)) setMenuOpen(false);
    };
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') setMenuOpen(false);
    };
    document.addEventListener('mousedown', onClick);
    document.addEventListener('keydown', onKey);
    return () => {
      document.removeEventListener('mousedown', onClick);
      document.removeEventListener('keydown', onKey);
    };
  }, [menuOpen]);

  // Closes the menu when the route changes, so it never hangs over the next screen.
  useEffect(() => setMenuOpen(false), [pathname]);

  // `GET /identity/tenant` carries the tenant's own name for the brand line. Until the gateway
  // routes it the line falls back to the `tenant_id` claim — an id, not an invented name.
  const tenant = useApiQuery(['identity', 'tenant'], getTenant, {
    retry: false,
    staleTime: Infinity,
    gcTime: Infinity,
  });

  const groups = visibleNavGroups(session?.permissions ?? []);
  const username = session?.username ?? '—';
  const roleCode = session?.roles[0] ?? '—';
  const tenantName =
    (tenant.data as { name?: string } | undefined)?.name ??
    `${t('app.tenant')} ${session?.tenantId ?? '—'}`;

  const themes: Array<[ThemePreference, string]> = [
    ['system', t('app.themeSystem')],
    ['light', t('app.themeLight')],
    ['dark', t('app.themeDark')],
  ];

  return (
    <div className="wms-app wms-root">
      <aside className="wms-side">
        <div className="wms-side__brand">
          <span className="wms-side__brand-name">{t('app.shortName')}</span>
          <span className="wms-side__brand-sub">{tenantName}</span>
        </div>

        <nav className="wms-side__nav" aria-label={t('app.mainNav')}>
          {groups.map((group, groupIndex) => (
            <div key={group.labelKey ?? `group-${groupIndex}`}>
              {group.labelKey ? (
                <div className="wms-side__group-label">{t(group.labelKey)}</div>
              ) : null}
              {group.items.map((item) => {
                const active = navItemMatches(item, pathname);
                return (
                  <Link
                    key={item.to}
                    to={item.to}
                    aria-current={active ? 'page' : undefined}
                    className={active ? 'wms-side__link wms-side__link--active' : 'wms-side__link'}
                  >
                    {t(item.labelKey)}
                  </Link>
                );
              })}
            </div>
          ))}
          {groups.length === 0 ? <div className="wms-side__note">{t('app.noScreens')}</div> : null}
        </nav>

        <div className="wms-side__user" ref={userRef}>
          {menuOpen ? (
            <div className="wms-side__usermenu" role="menu" aria-label={t('app.userMenu')}>
              <div className="wms-menu__row">
                <span className="wms-menu__label">{t('app.tenant')}</span>
                <span className="wms-num">{session?.tenantId ?? '—'}</span>
              </div>
              <div className="wms-menu__row">
                <span className="wms-menu__label">{t('app.role')}</span>
                <span>{session?.roles.join(', ') || '—'}</span>
              </div>
              <div className="wms-menu__row">
                <span className="wms-menu__label">{t('app.theme')}</span>
                <div className="wms-segmented" role="group" aria-label={t('app.theme')}>
                  {themes.map(([value, label]) => (
                    <button
                      key={value}
                      type="button"
                      aria-pressed={preference === value}
                      onClick={() => setPreference(value)}
                    >
                      {label}
                    </button>
                  ))}
                </div>
              </div>
              <div className="wms-menu__row">
                <span className="wms-menu__label">{t('app.language')}</span>
                <div className="wms-segmented" role="group" aria-label={t('app.language')}>
                  {SUPPORTED_LANGUAGES.map((code) => (
                    <button
                      key={code}
                      type="button"
                      aria-pressed={language === code}
                      onClick={() => {
                        setLanguage(code);
                        setLanguageState(code);
                      }}
                    >
                      {LANGUAGE_NAMES[code]}
                    </button>
                  ))}
                </div>
              </div>
              <Button variant="secondary" onClick={() => void signOut()}>
                {t('app.signOut')}
              </Button>
            </div>
          ) : null}

          <button
            type="button"
            className="wms-side__user-btn"
            aria-expanded={menuOpen}
            aria-haspopup="menu"
            onClick={() => setMenuOpen((v) => !v)}
          >
            <span className="wms-side__avatar" aria-hidden="true">
              {monogram(username)}
            </span>
            <span className="wms-side__user-text">
              <span className="wms-side__user-name">{username}</span>
              <span className="wms-side__user-role">{roleCode}</span>
            </span>
            {Icons.chevron(16)}
          </button>
        </div>
      </aside>

      <div className="wms-main">
        <Outlet />
      </div>
    </div>
  );
}
