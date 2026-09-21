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
 *
 * These tests pin the wildcard semantics exactly. They were **changed deliberately** when the
 * backend fixed `Matches`: `*` used to stand for a single segment and the whole pattern had to
 * have the same number of segments as the code, which silently reduced `*.view` to two-segment
 * codes and locked AUDITOR out of every three-segment read permission. `*` now stands for one or
 * more whole segments, and the length equality is gone. The old expectations (`*.view` not
 * matching `inv.balance.view`) are inverted below, on purpose.
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

  it('lets a middle * span one segment or several', () => {
    expect(matchesPermission('inv.*.view', 'inv.receipt.view')).toBe(true);
    expect(matchesPermission('inv.*.view', 'inv.receipt.post')).toBe(false);
    // Changed: `*` is one **or more** segments, so a deeper code matches too.
    expect(matchesPermission('inv.*.view', 'inv.receipt.line.view')).toBe(true);
  });

  it('no longer requires the same segment count — this is the fix', () => {
    // Was `false` under the old length-equality rule; AUDITOR depends on it being true.
    expect(matchesPermission('*.view', 'inv.balance.view')).toBe(true);
    expect(matchesPermission('*.view', 'audit.view')).toBe(true);
    expect(matchesPermission('*.view', 'inv.movement.view')).toBe(true);
  });

  it('still matches a segment as a whole, so view never reaches view_cost', () => {
    expect(matchesPermission('*.view', 'master.product.view_cost')).toBe(false);
    expect(matchesPermission('master.product.view', 'master.product.view_cost')).toBe(false);
    expect(matchesPermission('*.view_cost', 'master.product.view_cost')).toBe(true);
  });

  it('requires * to consume at least one segment', () => {
    expect(matchesPermission('inv.*', 'inv')).toBe(false);
    expect(matchesPermission('inv.*.view', 'inv.view')).toBe(false);
  });

  it('refuses an empty pattern or an empty code', () => {
    expect(matchesPermission('', 'inv.balance.view')).toBe(false);
    expect(matchesPermission('inv.*', '')).toBe(false);
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

  it('gives the keeper the whole warehouse cycle the service enforces', () => {
    // Verified against the live gateway: every one of these answers 200 for the keeper token.
    for (const code of [
      'inv.waste.view',
      'inv.waste.post',
      'inv.sample.view',
      'inv.return.view',
      'inv.return.create',
      'inv.movement.view',
      'inv.count.view',
      'inv.count.enter',
      'inv.batch.manage',
      'inv.issue.view',
    ]) {
      expect(roleAllows(['WAREHOUSE_KEEPER'], code), code).toBe(true);
    }
    // Still not the keeper's to give: reversal and waste approval are the manager's.
    expect(roleAllows(['WAREHOUSE_KEEPER'], 'inv.movement.reverse')).toBe(false);
    expect(roleAllows(['WAREHOUSE_KEEPER'], 'inv.waste.approve')).toBe(false);
  });

  it('refuses the branch user the documents the gateway refuses them', () => {
    // Gateway evidence: branch1 gets 403 on /return-to-vendor, /samples and /goods-receipts.
    expect(roleAllows(['BRANCH_USER'], 'inv.return.view')).toBe(false);
    expect(roleAllows(['BRANCH_USER'], 'inv.sample.view')).toBe(false);
    expect(roleAllows(['BRANCH_USER'], 'inv.receipt.view')).toBe(false);
    // ... and grants the ones that answer 200.
    expect(roleAllows(['BRANCH_USER'], 'inv.waste.view')).toBe(true);
    expect(roleAllows(['BRANCH_USER'], 'inv.movement.view')).toBe(true);
    expect(roleAllows(['BRANCH_USER'], 'inv.count.enter')).toBe(true);
  });

  it('gives AUDITOR every three-segment read, which the old matcher denied', () => {
    expect(roleAllows(['AUDITOR'], 'inv.balance.view')).toBe(true);
    expect(roleAllows(['AUDITOR'], 'inv.movement.view')).toBe(true);
    expect(roleAllows(['AUDITOR'], 'master.product.view_cost')).toBe(true);
    expect(roleAllows(['AUDITOR'], 'audit.view')).toBe(true);
    // Read-only stays read-only.
    expect(roleAllows(['AUDITOR'], 'inv.receipt.post')).toBe(false);
    expect(roleAllows(['AUDITOR'], 'inv.movement.reverse')).toBe(false);
  });

  it('gives PROCUREMENT_OFFICER the cost permission', () => {
    expect(roleAllows(['PROCUREMENT_OFFICER'], 'master.product.view_cost')).toBe(true);
  });

  it('gives PROCUREMENT_MANAGER approval rights but not receipt creation', () => {
    expect(roleAllows(['PROCUREMENT_MANAGER'], 'proc.po.approve')).toBe(true);
    expect(roleAllows(['PROCUREMENT_MANAGER'], 'inv.adjustment.approve')).toBe(true);
    expect(roleAllows(['PROCUREMENT_MANAGER'], 'inv.receipt.create')).toBe(false);
    // `inv.*.view` now reaches the deeper reads as well.
    expect(roleAllows(['PROCUREMENT_MANAGER'], 'inv.return.view')).toBe(true);
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

  it('carries every pattern the role map names, so no grant is unreachable', () => {
    // A concrete pattern (no wildcard) that is not in the catalogue would grant nothing.
    for (const [role, patterns] of Object.entries(ROLE_PERMISSIONS)) {
      for (const pattern of patterns) {
        if (pattern.includes('*')) continue;
        expect(PERMISSION_CATALOGUE, `${role} → ${pattern}`).toContain(pattern);
      }
    }
  });
});
