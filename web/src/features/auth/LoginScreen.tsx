import { useTranslation } from 'react-i18next';
import { Button } from '@ds/index';
import { useAuth } from '@auth/index';

/** Explicit sign-in page. The guard normally redirects on its own; this is the manual entry. */
export function LoginScreen() {
  const { t } = useTranslation();
  const { status, signIn, session } = useAuth();

  return (
    <div className="wms-login wms-root">
      <div className="wms-login__card">
        <div>
          <div className="wms-page__title">{t('app.shortName')}</div>
          <div className="wms-page__subtitle">{t('app.name')}</div>
        </div>
        {status === 'authenticated' ? (
          <>
            <p className="wms-muted">
              Daxil olmusunuz: <strong>{session?.username}</strong>
            </p>
            <a className="wms-btn wms-btn--primary" href="/">
              Dashboard-a keç
            </a>
          </>
        ) : (
          <>
            <p className="wms-muted">
              Keycloak realm <span className="wms-num">wms</span> üzərindən Authorization Code +
              PKCE ilə daxil olun.
            </p>
            <Button variant="primary" onClick={() => void signIn('/')}>
              {t('app.signIn')}
            </Button>
          </>
        )}
      </div>
    </div>
  );
}
