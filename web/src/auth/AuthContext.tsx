import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
  type ReactNode,
} from 'react';
import type { User } from 'oidc-client-ts';
import { setTokenProvider, setUnauthorizedHandler } from '@api/client';
import { getMe } from '@api/endpoints';
import { sessionFromUser, userManager, withServerPermissions, type WmsSession } from './session';

export type AuthStatus = 'loading' | 'anonymous' | 'authenticated' | 'error';

export interface AuthContextValue {
  status: AuthStatus;
  session: WmsSession | null;
  error: string | null;
  signIn: (returnTo?: string) => Promise<void>;
  signOut: () => Promise<void>;
  /** Interface-side convenience; the server's `x-permission` is the real check. */
  can: (permission: string) => boolean;
  canAny: (permissions: readonly string[]) => boolean;
  hasRole: (role: string) => boolean;
  /**
   * Why the client's own role → permission port is still being used, when it is. `null` means
   * the codes came from `GET /identity/me`, which is the normal path.
   */
  permissionFallbackReason: string | null;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [status, setStatus] = useState<AuthStatus>('loading');
  const [session, setSession] = useState<WmsSession | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [permissionFallbackReason, setPermissionFallbackReason] = useState<string | null>(null);
  const sessionRef = useRef<WmsSession | null>(null);

  // The API client pulls the token through a getter so it never imports React state.
  useEffect(() => {
    setTokenProvider(() => sessionRef.current?.accessToken ?? null);
    setUnauthorizedHandler(() => {
      sessionRef.current = null;
      setSession(null);
      setStatus('anonymous');
    });
  }, []);

  const apply = useCallback((user: User | null) => {
    if (!user || user.expired) {
      sessionRef.current = null;
      setSession(null);
      setStatus('anonymous');
      return;
    }
    try {
      const next = sessionFromUser(user);
      sessionRef.current = next;
      setSession(next);
      setStatus('authenticated');
      setError(null);

      /*
       * The permissions the server will actually enforce.
       *
       * `sessionRef` is already set, so the API client can read the bearer token; the screen
       * renders immediately on the token-derived codes and is corrected the moment `/me`
       * answers. A `/me` that fails is not fatal — the client port keeps the interface usable
       * and the reason is recorded so a screen can say which list is on display.
       */
      void getMe()
        .then((me) => {
          if (sessionRef.current?.accessToken !== next.accessToken) return;
          const merged = withServerPermissions(next, me);
          sessionRef.current = merged;
          setSession(merged);
          setPermissionFallbackReason(
            merged.permissionSource === 'server'
              ? null
              : 'GET /identity/me cavabında `permissions` sahəsi yoxdur — icazələr token rollarından hesablanır.',
          );
        })
        .catch((meError: unknown) => {
          if (sessionRef.current?.accessToken !== next.accessToken) return;
          const detail =
            typeof meError === 'object' && meError !== null && 'status' in meError
              ? ` (${String((meError as { code?: string }).code ?? 'XƏTA')} ${String((meError as { status?: number }).status ?? 0)})`
              : '';
          setPermissionFallbackReason(
            `GET /identity/me cavab vermədi${detail} — icazələr token rollarından hesablanır, serverin siyahısından yox.`,
          );
        });
    } catch (e) {
      sessionRef.current = null;
      setSession(null);
      setError(e instanceof Error ? e.message : String(e));
      setStatus('error');
    }
  }, []);

  useEffect(() => {
    const mgr = userManager();
    let cancelled = false;

    mgr
      .getUser()
      .then((user) => {
        if (!cancelled) apply(user);
      })
      .catch(() => {
        if (!cancelled) setStatus('anonymous');
      });

    const onLoaded = (user: User) => apply(user);
    const onUnloaded = () => apply(null);
    const onSilentError = (e: Error) => {
      // A failed silent renew is not fatal on its own: the access token may still be valid.
      console.warn('[wms] silent renew failed:', e.message);
    };

    mgr.events.addUserLoaded(onLoaded);
    mgr.events.addUserUnloaded(onUnloaded);
    mgr.events.addSilentRenewError(onSilentError);
    mgr.events.addAccessTokenExpired(onUnloaded);

    return () => {
      cancelled = true;
      mgr.events.removeUserLoaded(onLoaded);
      mgr.events.removeUserUnloaded(onUnloaded);
      mgr.events.removeSilentRenewError(onSilentError);
      mgr.events.removeAccessTokenExpired(onUnloaded);
    };
  }, [apply]);

  const signIn = useCallback(async (returnTo?: string) => {
    await userManager().signinRedirect({
      state: { returnTo: returnTo ?? window.location.pathname + window.location.search },
    });
  }, []);

  const signOut = useCallback(async () => {
    // post_logout_redirect_uri ends the Keycloak SSO session, not just the local one.
    await userManager().signoutRedirect();
  }, []);

  const value = useMemo<AuthContextValue>(
    () => ({
      status,
      session,
      error,
      signIn,
      signOut,
      can: (permission) => session?.permissions.includes(permission) ?? false,
      canAny: (permissions) => permissions.some((p) => session?.permissions.includes(p) ?? false),
      hasRole: (role) => session?.roles.includes(role) ?? false,
      permissionFallbackReason,
    }),
    [status, session, error, signIn, signOut, permissionFallbackReason],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth(): AuthContextValue {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used inside <AuthProvider>');
  return ctx;
}

/** For tests and stories: injects a fixed session without touching Keycloak. */
export function TestAuthProvider({
  session,
  children,
}: {
  session: WmsSession | null;
  children: ReactNode;
}) {
  const value = useMemo<AuthContextValue>(
    () => ({
      status: session ? 'authenticated' : 'anonymous',
      session,
      error: null,
      signIn: async () => {},
      signOut: async () => {},
      can: (permission) => session?.permissions.includes(permission) ?? false,
      canAny: (permissions) => permissions.some((p) => session?.permissions.includes(p) ?? false),
      hasRole: (role) => session?.roles.includes(role) ?? false,
      permissionFallbackReason: null,
    }),
    [session],
  );
  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}
