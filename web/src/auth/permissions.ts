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
    'inv.issue.create',
    'inv.count.create',
    'inv.count.freeze',
    'inv.count.enter',
    'inv.count.post',
    'inv.count.view',
    'inv.waste.create',
    'inv.waste.view',
    'inv.waste.post',
    'inv.sample.create',
    'inv.sample.view',
    'inv.rtv.view',
    'inv.issue.view',
    'inv.movement.view',
    'inv.batch.manage',
    'inv.issue.confirm',
    'inv.rtv.create',
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
    'inv.issue.confirm',
    'inv.waste.create',
    'inv.count.enter',
    'inv.count.view',
    'inv.waste.view',
    'inv.issue.view',
    'inv.movement.view',
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
 * Greedy-with-backtracking segment matcher — the port of `RolePermissionMap.IsMatch`.
 *
 * `*` stands for **one or more** whole segments, so `*.view` covers `audit.view` as well as
 * `inv.balance.view`, and `inv.*.view` covers `inv.balance.view` as well as a deeper
 * `inv.receipt.line.view`. Patterns are a handful of segments long, so the recursion is cheap.
 */
function isMatch(pattern: readonly string[], p: number, permission: readonly string[], s: number) {
  let pi = p;
  let si = s;

  while (pi < pattern.length) {
    if (pattern[pi] === '*') {
      // '*' consumes at least one segment; the last '*' swallows the whole remainder.
      if (pi === pattern.length - 1) return si < permission.length;

      for (let take = si + 1; take <= permission.length; take += 1) {
        if (isMatch(pattern, pi + 1, permission, take)) return true;
      }
      return false;
    }

    const segment = permission[si];
    if (segment === undefined) return false;
    if ((pattern[pi] as string).toLowerCase() !== segment.toLowerCase()) return false;

    pi += 1;
    si += 1;
  }

  return si === permission.length;
}

/**
 * Matches dot-separated permission codes exactly as `RolePermissionMap.Matches` does.
 *
 * A segment is matched as a whole: `master.product.view` never matches
 * `master.product.view_cost` (spec §7.1 keeps the two apart).
 *
 * The earlier port required the pattern and the permission to have the same number of segments,
 * which silently reduced `*.view` to two-segment codes only and locked AUDITOR out of every
 * three-segment read permission. The backend dropped that rule; this follows it.
 */
export function matchesPermission(pattern: string, permission: string): boolean {
  if (pattern.length === 0 || permission.length === 0) return false;
  return isMatch(pattern.split('.'), 0, permission.split('.'), 0);
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
 * The permission codes used by the interface. The base is the `x-permission` keys in
 * `contracts/openapi/*.v1.yaml`; where the running service enforces a different spelling, the
 * **service's** code is the one that matters and both are listed, because a guard that disagrees
 * with the server either hides a screen the user may open or shows one the server will refuse.
 *
 * Three such divergences are live today (verified against the gateway on :5001):
 *
 *   · return to vendor — contract `inv.rtv.{view,create,post}`,
 *     service `inv.rtv.{view,create,post}` (`InventoryPermissions.cs`), aligned to the contract 22.09.2026;
 *   · branch confirmation — contract `inv.issue.confirm`, service `inv.issue.confirm`;
 *   · count entry — contract and service agree on `inv.count.enter`; the old `inv.count.count`
 *     this file used existed in neither and is gone.
 *
 * Resolving roles against a closed list gives `DataTable` the `permissions` array it expects
 * without an endpoint that does not exist yet (`GET /identity/permissions` answers 404).
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
  'inv.issue.create',
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
  'inv.rtv.view',
  'inv.rtv.create',
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
