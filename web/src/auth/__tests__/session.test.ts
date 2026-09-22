import { describe, expect, it } from 'vitest';
import {
  MissingTenantError,
  decodeAccessToken,
  oidcSettings,
  sessionFromToken,
  withServerPermissions,
} from '../session';

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

/**
 * `GET /identity/me` is the authority on what the signed-in user may do.
 *
 * The client's `RolePermissionMap` port was the only source until the endpoint carried
 * `permissions`; keeping both in step by hand is exactly the failure this replaces — the running
 * realm has a `STOCKTAKER` role that no constant in this repo knows about, and a client-side
 * resolution grants it nothing. These tests pin the handover: the server wins when it answers,
 * the port is what is left when it does not, and the session says which one is in force.
 */
describe('withServerPermissions', () => {
  const token = makeToken({
    tenant_id: 1,
    preferred_username: 'keeper',
    realm_access: { roles: ['WAREHOUSE_KEEPER'] },
  });

  it('replaces the client-resolved codes with the server`s list', () => {
    const base = sessionFromToken(token);
    expect(base.permissionSource).toBe('roles');

    const merged = withServerPermissions(base, {
      permissions: ['inv.receipt.post', 'inv.count.enter'],
      roles: ['WAREHOUSE_KEEPER'],
      user: { id: 4 },
      tenant: { name: 'WMS platforması' },
    });

    expect(merged.permissions).toEqual(['inv.receipt.post', 'inv.count.enter']);
    expect(merged.permissionSource).toBe('server');
    expect(merged.userId).toBe(4);
    expect(merged.tenantName).toBe('WMS platforması');
  });

  it('takes a permission the client map does not know about', () => {
    const base = sessionFromToken(token);
    expect(base.permissions).not.toContain('inv.count.recount');
    const merged = withServerPermissions(base, { permissions: ['inv.count.recount'] });
    expect(merged.permissions).toContain('inv.count.recount');
  });

  it('drops a permission the client map granted but the server did not', () => {
    const base = sessionFromToken(token);
    expect(base.permissions).toContain('inv.receipt.post');
    const merged = withServerPermissions(base, { permissions: ['inv.balance.view'] });
    expect(merged.permissions).not.toContain('inv.receipt.post');
  });

  it('keeps the client fallback, and says so, when /me carries no permissions', () => {
    const base = sessionFromToken(token);
    const merged = withServerPermissions(base, { roles: ['WAREHOUSE_KEEPER'] });
    expect(merged.permissions).toEqual(base.permissions);
    expect(merged.permissionSource).toBe('roles');
  });

  it('takes a tenant role the token does not carry', () => {
    const base = sessionFromToken(token);
    const merged = withServerPermissions(base, {
      roles: ['WAREHOUSE_KEEPER', 'STOCKTAKER'],
      permissions: ['inv.count.enter'],
    });
    expect(merged.roles).toEqual(['WAREHOUSE_KEEPER', 'STOCKTAKER']);
  });
});
