import type { ReactNode } from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import { Alert } from '@ds/index';
import { useAuth } from './AuthContext';

/**
 * Route guards. A deep link cannot get past these: `RequirePermission` renders the refusal in
 * place of the screen, it does not merely hide the navigation entry. Even so, the guard is a
 * convenience — the server's `x-permission` check is the only real one (screen-map §1), and the
 * gateway answers 403 with a `FORBIDDEN` problem code regardless of what the interface allowed.
 */

export function RequireAuth({ children }: { children: ReactNode }) {
  const { status, signIn } = useAuth();
  const location = useLocation();

  if (status === 'loading') {
    return <div className="wms-page-state">Sessiya yoxlanılır…</div>;
  }

  if (status === 'error') {
    return (
      <div className="wms-page-state">
        <Alert tone="danger" title="Sessiya qurulmadı" code="UNAUTHORIZED">
          Access token-də tələb olunan claim yoxdur. Sistem administratoruna müraciət edin.
        </Alert>
      </div>
    );
  }

  if (status !== 'authenticated') {
    void signIn(location.pathname + location.search);
    return <div className="wms-page-state">Keycloak-a yönləndirilir…</div>;
  }

  return <>{children}</>;
}

export interface RequirePermissionProps {
  /** A single code, or several of which at least one must be held. */
  permission: string | readonly string[];
  children: ReactNode;
  /** Where to send the user instead of showing the refusal. */
  redirectTo?: string;
}

export function RequirePermission({ permission, children, redirectTo }: RequirePermissionProps) {
  const { session, canAny } = useAuth();
  const needed = typeof permission === 'string' ? [permission] : permission;
  const allowed = canAny(needed);

  if (allowed) return <>{children}</>;
  if (redirectTo) return <Navigate to={redirectTo} replace />;

  return (
    <div className="wms-page-state">
      <Alert tone="danger" title="Bu ekrana icazəniz yoxdur" code="FORBIDDEN">
        Tələb olunan icazə: <span className="wms-num">{needed.join(' və ya ')}</span>. Sizin
        rolunuz: <span className="wms-num">{session?.roles.join(', ') || '—'}</span>. İcazə üçün
        sistem administratoruna müraciət edin.
      </Alert>
    </div>
  );
}
