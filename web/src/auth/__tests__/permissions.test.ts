import { describe, expect, it } from 'vitest';
import {
  PERMISSION_CATALOGUE,
  ROLE_PERMISSIONS,
  SYSTEM_ROLES,
  matchesPermission,
  permissionsForRoles,
  roleAllows,
} from '../permissions';

/**
 * Ported from backend/src/BuildingBlocks/Wms.Common.Infrastructure/Tenancy/RolePermissionMap.cs.
 * These tests pin the wildcard semantics exactly, including the trailing length equality that
 * makes `*.view` narrower than it looks.
 */
describe('matchesPermission', () => {
  it('matches an exact code', () => {
    expect(matchesPermission('inv.receipt.post', 'inv.receipt.post')).toBe(true);
    expect(matchesPermission('inv.receipt.post', 'inv.receipt.view')).toBe(false);
  });

  it('treats a bare * as everything', () => {
    expect(matchesPermission('*', 'anything.at.all')).toBe(true);
  });

  it('lets a trailing * stand for the whole remainder', () => {
    expect(matchesPermission('proc.*', 'proc.po.approve')).toBe(true);
    expect(matchesPermission('proc.*', 'inv.po.approve')).toBe(false);
  });

  it('lets a middle * stand for exactly one segment', () => {
    expect(matchesPermission('inv.*.view', 'inv.receipt.view')).toBe(true);
    expect(matchesPermission('inv.*.view', 'inv.receipt.post')).toBe(false);
  });

  it('requires the same segment count when there is no trailing wildcard', () => {
    // This is why AUDITOR's `*.view` does not grant the three-segment `inv.balance.view`.
    expect(matchesPermission('*.view', 'inv.balance.view')).toBe(false);
    expect(matchesPermission('*.view', 'audit.view')).toBe(true);
  });

  it('compares segments case-insensitively, as OrdinalIgnoreCase does', () => {
    expect(matchesPermission('INV.receipt.*', 'inv.RECEIPT.post')).toBe(true);
  });
});

describe('roleAllows', () => {
  it('gives ADMIN everything', () => {
    expect(roleAllows(['ADMIN'], 'master.product.view_cost')).toBe(true);
    expect(roleAllows(['ADMIN'], 'cons.run.post')).toBe(true);
  });

  it('withholds master.product.view_cost from WAREHOUSE_KEEPER (SoD, SPEC §7.1)', () => {
    expect(roleAllows(['WAREHOUSE_KEEPER'], 'master.product.view')).toBe(true);
    expect(roleAllows(['WAREHOUSE_KEEPER'], 'master.product.view_cost')).toBe(false);
    expect(ROLE_PERMISSIONS.WAREHOUSE_KEEPER).not.toContain('master.product.view_cost');
  });

  it('gives PROCUREMENT_OFFICER the cost permission', () => {
    expect(roleAllows(['PROCUREMENT_OFFICER'], 'master.product.view_cost')).toBe(true);
  });

  it('gives PROCUREMENT_MANAGER approval rights but not receipt creation', () => {
    expect(roleAllows(['PROCUREMENT_MANAGER'], 'proc.po.approve')).toBe(true);
    expect(roleAllows(['PROCUREMENT_MANAGER'], 'inv.adjustment.approve')).toBe(true);
    expect(roleAllows(['PROCUREMENT_MANAGER'], 'inv.receipt.create')).toBe(false);
  });

  it('unions permissions across several roles', () => {
    expect(
      roleAllows(['WAREHOUSE_KEEPER', 'PROCUREMENT_OFFICER'], 'master.product.view_cost'),
    ).toBe(true);
  });

  it('ignores an unknown role instead of throwing', () => {
    expect(roleAllows(['NOT_A_ROLE'], 'inv.balance.view')).toBe(false);
  });

  it('matches roles case-insensitively', () => {
    expect(roleAllows(['admin'], 'inv.receipt.post')).toBe(true);
  });
});

describe('permissionsForRoles', () => {
  it('resolves ADMIN to the whole catalogue', () => {
    expect(permissionsForRoles(['ADMIN'])).toEqual([...PERMISSION_CATALOGUE]);
  });

  it('resolves the keeper without any cost permission', () => {
    const permissions = permissionsForRoles(['WAREHOUSE_KEEPER']);
    expect(permissions).toContain('inv.receipt.post');
    expect(permissions).toContain('inv.balance.view');
    expect(permissions).not.toContain('master.product.view_cost');
  });

  it('returns nothing for an anonymous user', () => {
    expect(permissionsForRoles([])).toEqual([]);
  });

  it('covers every system role declared in the realm', () => {
    for (const role of SYSTEM_ROLES) {
      expect(ROLE_PERMISSIONS[role], role).toBeDefined();
    }
  });

  it('only ever returns codes from the catalogue, which comes from the specs x-permission keys', () => {
    for (const role of SYSTEM_ROLES) {
      for (const code of permissionsForRoles([role])) {
        expect(PERMISSION_CATALOGUE).toContain(code);
      }
    }
  });
});
