import { describe, expect, it } from 'vitest';
import { MissingTenantError, decodeAccessToken, oidcSettings, sessionFromToken } from '../session';

function makeToken(payload: Record<string, unknown>): string {
  const b64 = (obj: unknown) =>
    btoa(String.fromCharCode(...new TextEncoder().encode(JSON.stringify(obj))))
      .replace(/\+/g, '-')
      .replace(/\//g, '_')
      .replace(/=+$/, '');
  return `${b64({ alg: 'RS256' })}.${b64(payload)}.signature`;
}

/**
 * The claims the platform requires on every access token (docs/CONVENTIONS.md, "Keycloak realm"):
 * `tenant_id` is mandatory, `preferred_username` names the user, `realm_access.roles` drives the
 * permission model.
 */
describe('sessionFromToken', () => {
  it('reads tenant, username and roles, and resolves permissions from them', () => {
    const token = makeToken({
      tenant_id: 1,
      preferred_username: 'keeper',
      sub: '97f11390-a7b9-4a8c-8039-acf15f459b06',
      realm_access: { roles: ['WAREHOUSE_KEEPER'] },
      aud: 'wms-api',
    });
    const session = sessionFromToken(token);
    expect(session.tenantId).toBe(1);
    expect(session.username).toBe('keeper');
    expect(session.subject).toBe('97f11390-a7b9-4a8c-8039-acf15f459b06');
    expect(session.roles).toEqual(['WAREHOUSE_KEEPER']);
    expect(session.permissions).toContain('inv.receipt.post');
    expect(session.permissions).not.toContain('master.product.view_cost');
  });

  it('accepts tenant_id delivered as a string attribute', () => {
    const token = makeToken({
      tenant_id: '1',
      preferred_username: 'admin',
      realm_access: { roles: ['ADMIN'] },
    });
    expect(sessionFromToken(token).tenantId).toBe(1);
  });

  it('refuses a token without tenant_id — the claim is mandatory', () => {
    const token = makeToken({ preferred_username: 'admin', realm_access: { roles: ['ADMIN'] } });
    expect(() => sessionFromToken(token)).toThrow(MissingTenantError);
  });

  it('handles a token with no roles as a session with no permissions', () => {
    const token = makeToken({ tenant_id: 1, preferred_username: 'nobody' });
    const session = sessionFromToken(token);
    expect(session.roles).toEqual([]);
    expect(session.permissions).toEqual([]);
  });

  it('decodes non-ASCII claims correctly', () => {
    const token = makeToken({
      tenant_id: 1,
      preferred_username: 'bəhruz',
      realm_access: { roles: [] },
    });
    expect(decodeAccessToken(token).preferred_username).toBe('bəhruz');
  });

  it('rejects something that is not a JWT', () => {
    expect(() => decodeAccessToken('not-a-token')).toThrow(/not a JWT/);
  });
});

describe('oidcSettings', () => {
  it('uses Authorization Code with PKCE against the public client', () => {
    expect(oidcSettings.response_type).toBe('code');
    expect(oidcSettings.disablePKCE).toBe(false);
    expect(oidcSettings.client_id).toBe('wms-web');
  });

  it('registers the /callback redirect URI the realm allows', () => {
    expect(oidcSettings.redirect_uri).toMatch(/\/callback$/);
  });

  it('ends the Keycloak session on logout, not just the local one', () => {
    expect(oidcSettings.post_logout_redirect_uri).toBeTruthy();
  });

  it('renews silently through its own iframe entry', () => {
    expect(oidcSettings.automaticSilentRenew).toBe(true);
    expect(oidcSettings.silent_redirect_uri).toMatch(/\/silent-renew\.html$/);
  });

  it('persists the session across a reload', () => {
    expect(oidcSettings.userStore).toBeDefined();
    expect(oidcSettings.stateStore).toBeDefined();
  });
});
