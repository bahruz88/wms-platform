/**
 * Web side navigation.
 *
 * The tree and its group names come from the approved artboards
 * (docs/design-system/screens/*.dc.html): an ungrouped «Panel» at the top, then
 * «Satınalma», «Anbar» and «Sistem». The artboards draw eleven entries for a product that has
 * thirty-nine screens, so the two dense corners of the app — master data and administration —
 * are single entries here and fan out through a tab strip on the screen itself, exactly as the
 * artboard's single «Master data» and «Hesabatlar» entries imply. Consumption is the one group
 * the artboards do not show; it is not warehouse work and it is not purchasing, so it keeps its
 * own label rather than being folded into a neighbour.
 *
 * Every item is filtered by the permissions the signed-in user's roles resolve to. An item the
 * user may not open is **not shown** — it is not disabled (docs/ux/screen-map.md §2).
 */
export interface NavItem {
  to: string;
  labelKey: string;
  /** At least one of these is required for the item to appear. */
  permission: string | string[];
  /** Routes that should also light this item up (tab siblings, detail screens). */
  match?: string[];
}

export interface NavGroup {
  /** `null` renders the items with no group label — the artboard's «Panel» block. */
  labelKey: string | null;
  items: NavItem[];
}

export const NAV_GROUPS: NavGroup[] = [
  {
    labelKey: null,
    items: [{ to: '/', labelKey: 'nav.dashboard', permission: 'rpt.dashboard.view' }],
  },
  {
    labelKey: 'nav.procurement',
    items: [
      { to: '/procurement/requisitions', labelKey: 'nav.requisitions', permission: 'proc.pr.view' },
      { to: '/procurement/rfqs', labelKey: 'nav.rfqs', permission: 'proc.rfq.view' },
      {
        to: '/procurement/quotations',
        labelKey: 'nav.quotations',
        permission: 'proc.quotation.view',
      },
      {
        to: '/procurement/purchase-orders',
        labelKey: 'nav.purchaseOrders',
        permission: 'proc.po.view',
      },
      { to: '/procurement/approvals', labelKey: 'nav.approvals', permission: 'proc.approval.view' },
      {
        to: '/procurement/price-history',
        labelKey: 'nav.priceHistory',
        permission: 'master.product.view_cost',
      },
    ],
  },
  {
    labelKey: 'nav.inventory',
    items: [
      {
        to: '/inventory/goods-receipts',
        labelKey: 'nav.goodsReceipts',
        permission: 'inv.receipt.view',
      },
      {
        to: '/inventory/issues',
        labelKey: 'nav.issues',
        // A keeper may create and dispatch an issue without holding `inv.issue.view`
        // (RolePermissionMap.cs); the area has to be reachable for them too.
        permission: ['inv.issue.view', 'inv.issue.create'],
      },
      {
        to: '/inventory/stock-requests',
        labelKey: 'nav.stockRequests',
        permission: 'inv.request.view',
      },
      {
        to: '/inventory/counts',
        labelKey: 'nav.counts',
        permission: ['inv.count.view', 'inv.count.create'],
      },
      {
        to: '/inventory/waste',
        labelKey: 'nav.wasteAndSamples',
        permission: ['inv.waste.view', 'inv.sample.view'],
        match: ['/inventory/samples'],
      },
      {
        // Screen-map §3.11. The contract spells the permission `inv.rtv.view`; the running
        // service enforces `inv.rtv.view`, so that is what the entry is filtered on.
        to: '/inventory/returns',
        labelKey: 'nav.returns',
        permission: 'inv.rtv.view',
      },
      { to: '/inventory/balances', labelKey: 'nav.balances', permission: 'inv.balance.view' },
      { to: '/inventory/batches', labelKey: 'nav.batches', permission: 'inv.batch.view' },
      { to: '/inventory/movements', labelKey: 'nav.movements', permission: 'inv.movement.view' },
    ],
  },
  {
    labelKey: 'nav.consumption',
    items: [
      { to: '/consumption/recipes', labelKey: 'nav.recipes', permission: 'cons.recipe.view' },
      {
        to: '/consumption/sales-imports',
        labelKey: 'nav.salesImports',
        permission: 'cons.sales.import',
      },
      { to: '/consumption/runs', labelKey: 'nav.runs', permission: 'cons.run.calculate' },
      { to: '/consumption/variance', labelKey: 'nav.variance', permission: 'cons.variance.view' },
    ],
  },
  {
    labelKey: 'nav.system',
    items: [
      {
        to: '/master-data/products',
        labelKey: 'nav.masterData',
        permission: [
          'master.product.view',
          'master.supplier.view',
          'master.location.view',
          'master.reason.view',
          'master.currency.view',
        ],
        match: [
          '/master-data/categories',
          '/master-data/suppliers',
          '/master-data/locations',
          '/master-data/uoms',
          '/master-data/reason-codes',
          '/master-data/currency-rates',
        ],
      },
      {
        to: '/reporting/reports',
        labelKey: 'nav.reporting',
        permission: ['rpt.report.view', 'rpt.export.create'],
        match: ['/reporting/exports'],
      },
      {
        to: '/admin/users',
        labelKey: 'nav.admin',
        permission: ['iam.user.view', 'iam.role.view', 'inv.settings.view'],
        match: ['/admin/roles', '/admin/settings'],
      },
    ],
  },
];

const codes = (permission: string | string[]): string[] =>
  typeof permission === 'string' ? [permission] : permission;

export function visibleNavGroups(permissions: readonly string[]): NavGroup[] {
  return NAV_GROUPS.map((group) => ({
    ...group,
    items: group.items.filter((item) =>
      codes(item.permission).some((p) => permissions.includes(p)),
    ),
  })).filter((group) => group.items.length > 0);
}

/** True when `pathname` belongs to `item` — its own route, a tab sibling, or a child route. */
export function navItemMatches(item: NavItem, pathname: string): boolean {
  const routes = [item.to, ...(item.match ?? [])];
  if (item.to === '/') return pathname === '/';
  return routes.some((route) => pathname === route || pathname.startsWith(`${route}/`));
}
