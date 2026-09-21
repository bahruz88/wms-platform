import { useEffect, useRef, useState } from 'react';
import { NavLink, Outlet } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { Badge, Button, Icons } from '@ds/index';
import { useAuth } from '@auth/index';
import {
  LANGUAGE_NAMES,
  SUPPORTED_LANGUAGES,
  setLanguage,
  storedLanguage,
  type Language,
} from '@/i18n';
import { useTheme, type ThemePreference } from './theme';
import { visibleNavGroups } from './navigation';

/**
 * Application shell: side navigation filtered by permission, theme toggle, language switch, and
 * the user menu showing tenant, username and roles. Nothing here uppercases interface text —
 * `label` weight and letter-spacing carry the emphasis instead (design-system README).
 */
export function AppShell() {
  const { t } = useTranslation();
  const { session, signOut } = useAuth();
  const { preference, setPreference } = useTheme();
  const [menuOpen, setMenuOpen] = useState(false);
  const [language, setLanguageState] = useState<Language>(storedLanguage);
  const menuRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!menuOpen) return;
    const onClick = (e: MouseEvent) => {
      if (menuRef.current && !menuRef.current.contains(e.target as Node)) setMenuOpen(false);
    };
    document.addEventListener('mousedown', onClick);
    return () => document.removeEventListener('mousedown', onClick);
  }, [menuOpen]);

  const groups = visibleNavGroups(session?.permissions ?? []);

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
          <span className="wms-side__brand-sub">{t('app.name')}</span>
        </div>
        <nav className="wms-side__nav" aria-label={t('nav.dashboard')}>
          {groups.map((group) => (
            <div key={group.labelKey} className="wms-side__group">
              <div className="wms-side__group-label">{t(group.labelKey)}</div>
              {group.items.map((item) => (
                <NavLink
                  key={item.to}
                  to={item.to}
                  end={item.to === '/'}
                  className={({ isActive }) =>
                    isActive ? 'wms-side__link wms-side__link--active' : 'wms-side__link'
                  }
                >
                  {t(item.labelKey)}
                </NavLink>
              ))}
            </div>
          ))}
          {groups.length === 0 ? (
            <div className="wms-side__group-label">
              Rolunuza uyğun veb ekranı yoxdur. Sistem administratoruna müraciət edin.
            </div>
          ) : null}
        </nav>
      </aside>

      <div className="wms-main">
        <header className="wms-topbar">
          <div className="wms-row">
            <Badge tone="accent" variant="outline" title="tenant_id claim">
              {t('app.tenant')} {session?.tenantId ?? '—'}
            </Badge>
            {session?.roles.map((role) => (
              <Badge key={role} tone="neutral" title={`realm_access.roles: ${role}`}>
                {role}
              </Badge>
            ))}
          </div>

          <div className="wms-topbar__right">
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

            <div className="wms-menu" ref={menuRef}>
              <button
                type="button"
                className="wms-btn wms-btn--secondary wms-btn--sm"
                aria-expanded={menuOpen}
                aria-haspopup="menu"
                onClick={() => setMenuOpen((v) => !v)}
              >
                <span className="wms-user__name">{session?.username ?? '—'}</span>
                {Icons.chevron(16)}
              </button>
              {menuOpen ? (
                <div className="wms-menu__panel" role="menu" aria-label={t('app.userMenu')}>
                  <div className="wms-menu__row">
                    <span className="wms-menu__label">{t('app.tenant')}</span>
                    <span className="wms-num">{session?.tenantId ?? '—'}</span>
                  </div>
                  <div className="wms-menu__row">
                    <span className="wms-menu__label">{t('app.role')}</span>
                    <span>{session?.roles.join(', ') || '—'}</span>
                  </div>
                  <div className="wms-menu__row">
                    <span className="wms-menu__label">{t('app.language')}</span>
                    <div className="wms-segmented">
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
                  <Button variant="secondary" size="sm" onClick={() => void signOut()}>
                    {t('app.signOut')}
                  </Button>
                </div>
              ) : null}
            </div>
          </div>
        </header>

        <main className="wms-content">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
