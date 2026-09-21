import { useEffect, useRef, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Alert } from '@ds/index';
import { userManager } from '@auth/index';

/**
 * `/callback` — the redirect URI registered for the public client `wms-web`
 * (docs/CONVENTIONS.md). `signinRedirectCallback` exchanges the authorization code using the PKCE
 * verifier that `signinRedirect` stored, then the user lands back where they started.
 */
export function CallbackScreen() {
  const navigate = useNavigate();
  const [error, setError] = useState<string | null>(null);
  const done = useRef(false);

  useEffect(() => {
    // React 18 StrictMode mounts effects twice in development; the code may be redeemed once.
    if (done.current) return;
    done.current = true;

    userManager()
      .signinRedirectCallback()
      .then((user) => {
        const state = user.state as { returnTo?: string } | undefined;
        navigate(state?.returnTo ?? '/', { replace: true });
      })
      .catch((e: unknown) => {
        setError(e instanceof Error ? e.message : String(e));
      });
  }, [navigate]);

  if (error) {
    return (
      <div className="wms-login wms-root">
        <div className="wms-login__card">
          <Alert tone="danger" title="Giriş tamamlanmadı" code="UNAUTHORIZED">
            {error}
          </Alert>
          <a className="wms-btn wms-btn--primary" href="/">
            Yenidən cəhd et
          </a>
        </div>
      </div>
    );
  }

  return (
    <div className="wms-login wms-root">
      <div className="wms-login__card" role="status">
        <span className="wms-spinner" aria-hidden="true" />
        <span>Giriş tamamlanır…</span>
      </div>
    </div>
  );
}
