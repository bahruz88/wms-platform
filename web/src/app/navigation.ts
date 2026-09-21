/**
 * Web side navigation, exactly the tree docs/ux/screen-map.md §2 lays out, filtered by the
 * permissions the signed-in user's roles resolve to. An item the user may not open is **not
 * shown** — it is not disabled (screen-map §2).
 */
export interface NavItem {
  to: string;
  labelKey: string;
  /** At least one of these is required for the item to appear. */
  permission: string | string[];
}

export interface NavGroup {
  labelKey: string;
  items: NavItem[];
}

export const NAV_GROUPS: NavGroup[] = [
  {
    labelKey: 'nav.dashboard',
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
      { to: '/inventory/balances', labelKey: 'nav.balances', permission: 'inv.balance.view' },
      { to: '/inventory/batches', labelKey: 'nav.batches', permission: 'inv.batch.view' },
      {
        to: '/inventory/goods-receipts',
        labelKey: 'nav.goodsReceipts',
        permission: 'inv.receipt.view',
      },
      { to: '/inventory/movements', labelKey: 'nav.movements', permission: 'inv.movement.view' },
      { to: '/inventory/counts', labelKey: 'nav.counts', permission: 'inv.count.view' },
      { to: '/inventory/waste', labelKey: 'nav.waste', permission: 'inv.waste.view' },
      { to: '/inventory/samples', labelKey: 'nav.samples', permission: 'inv.sample.view' },
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
    labelKey: 'nav.masterData',
    items: [
      { to: '/master-data/products', labelKey: 'nav.products', permission: 'master.product.view' },
      {
        to: '/master-data/suppliers',
        labelKey: 'nav.suppliers',
        permission: 'master.supplier.view',
      },
      {
        to: '/master-data/locations',
        labelKey: 'nav.locations',
        permission: 'master.location.view',
      },
      { to: '/master-data/uoms', labelKey: 'nav.uoms', permission: 'master.product.view' },
      {
        to: '/master-data/reason-codes',
        labelKey: 'nav.reasonCodes',
        permission: 'master.reason.view',
      },
      {
        to: '/master-data/currency-rates',
        labelKey: 'nav.currencyRates',
        permission: 'master.currency.view',
      },
    ],
  },
  {
    labelKey: 'nav.reporting',
    items: [
      { to: '/reporting/reports', labelKey: 'nav.reports', permission: 'rpt.report.view' },
      { to: '/reporting/exports', labelKey: 'nav.exports', permission: 'rpt.export.create' },
    ],
  },
  {
    labelKey: 'nav.admin',
    items: [
      { to: '/admin/users', labelKey: 'nav.users', permission: 'iam.user.view' },
      { to: '/admin/roles', labelKey: 'nav.roles', permission: 'iam.role.view' },
      { to: '/admin/settings', labelKey: 'nav.settings', permission: 'inv.settings.view' },
    ],
  },
];

export function visibleNavGroups(permissions: readonly string[]): NavGroup[] {
  return NAV_GROUPS.map((group) => ({
    ...group,
    items: group.items.filter((item) =>
      (typeof item.permission === 'string' ? [item.permission] : item.permission).some((p) =>
        permissions.includes(p),
      ),
    ),
  })).filter((group) => group.items.length > 0);
}
