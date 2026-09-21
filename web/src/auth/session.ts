import { User, UserManager, WebStorageStateStore, type UserManagerSettings } from 'oidc-client-ts';
import { permissionsForRoles } from './permissions';

/**
 * Keycloak OIDC — Authorization Code + PKCE (S256) against the public client `wms-web`
 * (ADR-009, docs/CONVENTIONS.md "Keycloak realm `wms`").
 *
 * The session lives in `localStorage` so a reload keeps the user signed in; silent renew runs in a
 * hidden iframe against `/silent-renew.html`. Logout goes through the realm's end-session endpoint
 * with `post_logout_redirect_uri` so the Keycloak SSO session ends too, not just the local one.
 */

const ISSUER: string =
  (import.meta.env?.VITE_KEYCLOAK_ISSUER as string | undefined) ??
  'http://localhost:8180/realms/wms';
const CLIENT_ID: string =
  (import.meta.env?.VITE_KEYCLOAK_CLIENT_ID as string | undefined) ?? 'wms-web';

const origin = typeof window !== 'undefined' ? window.location.origin : 'http://localhost:3000';

export const oidcSettings: UserManagerSettings = {
  authority: ISSUER,
  client_id: CLIENT_ID,
  redirect_uri: `${origin}/callback`,
  post_logout_redirect_uri: `${origin}/`,
  silent_redirect_uri: `${origin}/silent-renew.html`,
  response_type: 'code',
  scope: 'openid profile email',
  // Public client: PKCE with S256 is the only protection on the code exchange.
  disablePKCE: false,
  automaticSilentRenew: true,
  // Keycloak only rotates the refresh token when the session is renewed early enough.
  accessTokenExpiringNotificationTimeInSeconds: 60,
  loadUserInfo: false,
  monitorSession: false,
  stateStore:
    typeof window !== 'undefined'
      ? new WebStorageStateStore({ store: window.localStorage })
      : undefined,
  userStore:
    typeof window !== 'undefined'
      ? new WebStorageStateStore({ store: window.localStorage })
      : undefined,
};

let manager: UserManager | null = null;

export function userManager(): UserManager {
  if (!manager) manager = new UserManager(oidcSettings);
  return manager;
}

/** Only for tests, which need a fresh manager per case. */
export function resetUserManager(): void {
  manager = null;
}

/** The claims the platform requires on every access token (`tenant_id` is mandatory). */
export interface AccessTokenClaims {
  tenant_id?: number | string;
  preferred_username?: string;
  realm_access?: { roles?: string[] };
  aud?: string | string[];
  exp?: number;
  sub?: string;
}

/** The signed-in user as the interface uses it. */
export interface WmsSession {
  tenantId: number;
  username: string;
  subject: string;
  roles: string[];
  permissions: string[];
  accessToken: string;
  expiresAt?: number;
}

function base64UrlDecode(segment: string): string {
  const padded = segment.replace(/-/g, '+').replace(/_/g, '/');
  const withPadding = padded + '='.repeat((4 - (padded.length % 4)) % 4);
  const binary = atob(withPadding);
  const bytes = Uint8Array.from(binary, (c) => c.charCodeAt(0));
  return new TextDecoder('utf-8').decode(bytes);
}

/**
 * Reads the JWT payload. The signature is not verified here — the gateway does that on every
 * request; the client only needs the claims to shape the interface.
 */
export function decodeAccessToken(token: string): AccessTokenClaims {
  const parts = token.split('.');
  if (parts.length < 2) throw new Error('Access token is not a JWT');
  return JSON.parse(base64UrlDecode(parts[1] as string)) as AccessTokenClaims;
}

export class MissingTenantError extends Error {
  constructor() {
    super('Access token-də `tenant_id` claim-i yoxdur — realm konfiqurasiyası natamamdır.');
    this.name = 'MissingTenantError';
  }
}

/** Builds the session from the token's claims: tenant, username, roles → permissions. */
export function sessionFromToken(accessToken: string, expiresAt?: number): WmsSession {
  const claims = decodeAccessToken(accessToken);
  const rawTenant = claims.tenant_id;
  const tenantId = typeof rawTenant === 'string' ? Number.parseInt(rawTenant, 10) : rawTenant;
  if (tenantId === undefined || Number.isNaN(tenantId)) throw new MissingTenantError();

  const roles = claims.realm_access?.roles ?? [];
  return {
    tenantId,
    username: claims.preferred_username ?? claims.sub ?? 'naməlum',
    subject: claims.sub ?? '',
    roles,
    permissions: permissionsForRoles(roles),
    accessToken,
    expiresAt,
  };
}

export function sessionFromUser(user: User): WmsSession {
  return sessionFromToken(user.access_token, user.expires_at);
}
