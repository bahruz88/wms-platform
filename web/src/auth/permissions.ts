/**
 * Role → permission model, ported one-for-one from the backend's
 * `backend/src/BuildingBlocks/Wms.Common.Infrastructure/Tenancy/RolePermissionMap.cs`.
 *
 * `GET /identity/me` returns roles, not permission codes, so the interface resolves them the same
 * way the server does. The interface check is a convenience only: the real check is the server's
 * `x-permission` on every operation (docs/ux/screen-map.md §1). Anything this map gets wrong shows
 * up as a 403 with a `FORBIDDEN` problem code, never as data the user should not have seen.
 */

export const SYSTEM_ROLES = [
  'ADMIN',
  'PROCUREMENT_OFFICER',
  'PROCUREMENT_MANAGER',
  'WAREHOUSE_KEEPER',
  'BRANCH_USER',
  'AUDITOR',
] as const;

export type SystemRole = (typeof SYSTEM_ROLES)[number];

export const ROLE_PERMISSIONS: Record<string, readonly string[]> = {
  ADMIN: ['*'],
  PROCUREMENT_OFFICER: [
    'proc.pr.*',
    'proc.rfq.*',
    'proc.quotation.*',
    'proc.po.create',
    'proc.po.view',
    'proc.po.send',
    'master.product.view',
    'master.product.view_cost',
    'master.supplier.*',
    'master.location.view',
    'inv.balance.view',
    'inv.batch.view',
    'inv.receipt.view',
    'rpt.*',
    'doc.*',
    'notif.*',
  ],
  PROCUREMENT_MANAGER: [
    'proc.*',
    'master.*',
    'inv.*.view',
    'inv.balance.view',
    'inv.adjustment.approve',
    'inv.waste.approve',
    'inv.movement.reverse',
    'rpt.*',
    'doc.*',
    'notif.*',
  ],
  // Deliberately WITHOUT master.product.view_cost (spec §7.1, TOR §3.1, §40).
  WAREHOUSE_KEEPER: [
    'inv.receipt.create',
    'inv.receipt.post',
    'inv.receipt.view',
    'inv.issue.create',
    'inv.issue.dispatch',
    'inv.transfer.create',
    'inv.count.create',
    'inv.count.count',
    'inv.waste.create',
    'inv.sample.create',
    'inv.return.create',
    'inv.balance.view',
    'inv.batch.view',
    'inv.request.view',
    'master.product.view',
    'master.location.view',
    'master.supplier.view',
    'doc.attachment.*',
    'notif.*',
  ],
  BRANCH_USER: [
    'inv.request.create',
    'inv.request.view',
    'inv.transfer.confirm',
    'inv.waste.create',
    'inv.count.count',
    'inv.balance.view',
    'inv.batch.view',
    'master.product.view',
    'master.location.view',
    'doc.attachment.*',
    'notif.*',
  ],
  AUDITOR: ['*.view', '*.view_cost', 'rpt.*', 'audit.view', 'notif.*'],
};

/**
 * Matches dot-separated permission codes where `*` stands for one segment or the whole remainder.
 * Same algorithm as `RolePermissionMap.Matches`, including the trailing length equality — so
 * `inv.*.view` matches `inv.receipt.view` but `*.view` does not match `inv.balance.view`.
 */
export function matchesPermission(pattern: string, permission: string): boolean {
  if (pattern === '*') return true;

  const patternParts = pattern.split('.');
  const permissionParts = permission.split('.');

  for (let i = 0; i < patternParts.length; i += 1) {
    if (i >= permissionParts.length) return false;
    const p = patternParts[i] as string;
    if (p === '*') {
      if (i === patternParts.length - 1) return true;
      continue;
    }
    if (p.toLowerCase() !== (permissionParts[i] as string).toLowerCase()) return false;
  }

  return patternParts.length === permissionParts.length;
}

/** Role codes are matched case-insensitively, as `RolePermissionMap` does with OrdinalIgnoreCase. */
const ROLE_LOOKUP: Record<string, readonly string[]> = Object.fromEntries(
  Object.entries(ROLE_PERMISSIONS).map(([role, patterns]) => [role.toLowerCase(), patterns]),
);

export function roleAllows(roles: readonly string[], permission: string): boolean {
  return roles.some((role) => {
    const patterns = ROLE_LOOKUP[role.toLowerCase()];
    return patterns?.some((pattern) => matchesPermission(pattern, permission)) ?? false;
  });
}

/**
 * The permission codes used by the interface, harvested from the `x-permission` keys in
 * `contracts/openapi/*.v1.yaml`. Resolving roles against this closed list gives `DataTable` the
 * `permissions` array it expects, without needing an endpoint that does not exist yet
 * (`GET /identity/permissions` is not implemented on the gateway).
 */
export const PERMISSION_CATALOGUE: readonly string[] = [
  // identity
  'iam.me.view',
  'iam.user.view',
  'iam.user.manage',
  'iam.role.view',
  'iam.role.manage',
  'iam.delegation.view',
  'iam.delegation.create',
  // master data
  'master.product.view',
  'master.product.manage',
  'master.product.view_cost',
  'master.category.manage',
  'master.uom.manage',
  'master.supplier.view',
  'master.supplier.manage',
  'master.location.view',
  'master.location.manage',
  'master.currency.view',
  'master.currency.manage',
  'master.reason.view',
  'master.reason.manage',
  'master.sequence.view',
  // inventory
  'inv.receipt.view',
  'inv.receipt.create',
  'inv.receipt.post',
  'inv.balance.view',
  'inv.batch.view',
  'inv.batch.manage',
  'inv.request.view',
  'inv.request.create',
  'inv.request.submit',
  'inv.issue.view',
  'inv.issue.create',
  'inv.issue.dispatch',
  'inv.issue.confirm',
  'inv.count.view',
  'inv.count.create',
  'inv.count.freeze',
  'inv.count.enter',
  'inv.count.post',
  'inv.adjustment.approve',
  'inv.waste.view',
  'inv.waste.create',
  'inv.waste.approve',
  'inv.waste.post',
  'inv.sample.view',
  'inv.sample.create',
  'inv.sample.post',
  'inv.rtv.view',
  'inv.rtv.create',
  'inv.rtv.post',
  'inv.movement.view',
  'inv.movement.reverse',
  'inv.settings.view',
  'inv.settings.manage',
  // procurement
  'proc.pr.view',
  'proc.pr.create',
  'proc.pr.submit',
  'proc.pr.reject',
  'proc.rfq.view',
  'proc.rfq.create',
  'proc.quotation.view',
  'proc.quotation.create',
  'proc.quotation.select',
  'proc.po.view',
  'proc.po.view_for_receipt',
  'proc.po.create',
  'proc.po.submit',
  'proc.po.approve',
  'proc.po.send',
  'proc.po.close',
  'proc.approval.view',
  'proc.approval.decide',
  'proc.approval_rule.view',
  'proc.approval_rule.manage',
  // consumption
  'cons.recipe.view',
  'cons.recipe.manage',
  'cons.sales.import',
  'cons.run.calculate',
  'cons.run.post',
  'cons.variance.view',
  // reporting / documents / notifications / audit
  'rpt.dashboard.view',
  'rpt.report.view',
  'rpt.export.create',
  'doc.attachment.view',
  'doc.attachment.upload',
  'notif.inbox.view',
  'notif.rule.view',
  'notif.rule.manage',
  'audit.log.view',
  'audit.view',
];

/** Expands a user's roles into the concrete permission codes the interface knows about. */
export function permissionsForRoles(roles: readonly string[]): string[] {
  return PERMISSION_CATALOGUE.filter((code) => roleAllows(roles, code));
}

export function hasPermission(granted: readonly string[], permission: string): boolean {
  return granted.includes(permission);
}

export function hasAnyPermission(
  granted: readonly string[],
  permissions: readonly string[],
): boolean {
  return permissions.some((p) => granted.includes(p));
}
