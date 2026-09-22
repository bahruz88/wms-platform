import { useEffect, useRef, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Alert } from '@ds/index';
import { userManager } from '@auth/index';

/**
 * `/callback` — the redirect URI registered for the public client `wms-web`
 * (docs/CONVENTIONS.md). `signinRedirectCallback` exchanges the authorization code using the PKCE
 * verifier that `signinRedirect` stored, then the user lands back where they started.
 *
 * A sign-in can arrive here with no usable state. It happens when the flow began on a different
 * origin (the dev web container has moved between ports 3000/3001/3002), when `/callback` is
 * reloaded after the code was already redeemed, or when storage was cleared mid-flight. None of
 * those are the user's mistake and none are recoverable by reading an error, so we clear the stale
 * entries and start a fresh sign-in instead of dead-ending on `UNAUTHORIZED`.
 */
const RECOVERABLE = [
  'no matching state',
  'matching state not found',
  'state not found',
  'code_verifier',
  'invalid_grant',
];

function isRecoverable(message: string): boolean {
  const m = message.toLowerCase();
  return RECOVERABLE.some((s) => m.includes(s));
}

export function CallbackScreen() {
  const navigate = useNavigate();
  const [error, setError] = useState<string | null>(null);
  const [restarting, setRestarting] = useState(false);
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
        const message = e instanceof Error ? e.message : String(e);
        if (!isRecoverable(message)) {
          setError(message);
          return;
        }
        // Retrying only helps once: a second failure means something else is wrong, and the
        // marker keeps a broken configuration from bouncing the browser in a loop.
        const alreadyRetried = sessionStorage.getItem('wms.signin.retried') === '1';
        if (alreadyRetried) {
          sessionStorage.removeItem('wms.signin.retried');
          setError(message);
          return;
        }
        setRestarting(true);
        sessionStorage.setItem('wms.signin.retried', '1');
        const manager = userManager();
        void manager
          .clearStaleState()
          .catch(() => undefined)
          .then(() => manager.signinRedirect())
          .catch(() => {
            sessionStorage.removeItem('wms.signin.retried');
            setError(message);
            setRestarting(false);
          });
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
        <span>{restarting ? 'Giriş yenidən başladılır…' : 'Giriş tamamlanır…'}</span>
      </div>
    </div>
  );
}
