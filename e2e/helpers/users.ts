/**
 * The six dev users of realm `wms`, and the navigation table the sidebar is built from.
 *
 * The expected navigation is **not** hard-coded per role. It is computed from two things that
 * must agree:
 *
 *   · `GET /identity/me` → `permissions[]`, which is what the server will actually enforce and,
 *     since the interface started reading it, what the sidebar filters on;
 *   · `NAV_TABLE` below — the entries and the permission each one requires, transcribed from
 *     `docs/ux/screen-map.md` §2 and the contract's `x-permission` keys.
 *
 * Writing the expectation that way is the point: a permission renamed on one side of the wire
 * makes the navigation disagree with what the user is allowed to do, and the test says so. A
 * hand-maintained list of labels per role would have been updated to match the bug.
 */

export type UserName = 'admin' | 'manager' | 'procurement' | 'keeper' | 'branch1' | 'auditor';

export interface NavEntry {
  /** The label as rendered, in Azerbaijani. */
  label: string;
  /** Route the entry opens. */
  to: string;
  /**
   * The permission codes that entitle a user to this entry — **as the server spells them**
   * (`GET /identity/me`, `contracts/openapi/*.v1.yaml` `x-permission`). Holding any one is enough.
   */
  permissions: string[];
}

export const NAV_TABLE: NavEntry[] = [
  { label: 'Panel', to: '/', permissions: ['rpt.dashboard.view'] },
  { label: 'Tələbnamə', to: '/procurement/requisitions', permissions: ['proc.pr.view'] },
  { label: 'RFQ', to: '/procurement/rfqs', permissions: ['proc.rfq.view'] },
  { label: 'Təkliflər', to: '/procurement/quotations', permissions: ['proc.quotation.view'] },
  { label: 'Sifarişlər', to: '/procurement/purchase-orders', permissions: ['proc.po.view'] },
  { label: 'Təsdiqlər', to: '/procurement/approvals', permissions: ['proc.approval.view'] },
  {
    label: 'Qiymət tarixçəsi',
    to: '/procurement/price-history',
    permissions: ['master.product.view_cost'],
  },
  { label: 'Qəbul', to: '/inventory/goods-receipts', permissions: ['inv.receipt.view'] },
  {
    label: 'Məxaric və transfer',
    to: '/inventory/issues',
    permissions: ['inv.issue.view', 'inv.issue.create'],
  },
  { label: 'Mal tələbi', to: '/inventory/stock-requests', permissions: ['inv.request.view'] },
  {
    label: 'Sayım',
    to: '/inventory/counts',
    permissions: ['inv.count.view', 'inv.count.create'],
  },
  {
    label: 'Tullantı və nümunə',
    to: '/inventory/waste',
    permissions: ['inv.waste.view', 'inv.sample.view'],
  },
  // screen-map §3.11. The contract and the running service both spell this `inv.rtv.*`.
  { label: 'Qaytarma', to: '/inventory/returns', permissions: ['inv.rtv.view'] },
  { label: 'Qalıqlar', to: '/inventory/balances', permissions: ['inv.balance.view'] },
  { label: 'Partiyalar', to: '/inventory/batches', permissions: ['inv.batch.view'] },
  { label: 'Ledger', to: '/inventory/movements', permissions: ['inv.movement.view'] },
  { label: 'Reseptlər', to: '/consumption/recipes', permissions: ['cons.recipe.view'] },
  { label: 'Satış importu', to: '/consumption/sales-imports', permissions: ['cons.sales.import'] },
  { label: 'İstehlak jurnalı', to: '/consumption/runs', permissions: ['cons.run.calculate'] },
  { label: 'Fərq hesabatı', to: '/consumption/variance', permissions: ['cons.variance.view'] },
  {
    label: 'Master data',
    to: '/master-data/products',
    permissions: [
      'master.product.view',
      'master.supplier.view',
      'master.location.view',
      'master.reason.view',
      'master.currency.view',
    ],
  },
  {
    label: 'Hesabatlar',
    to: '/reporting/reports',
    permissions: ['rpt.report.view', 'rpt.export.create'],
  },
  {
    label: 'İdarəetmə',
    to: '/admin/users',
    permissions: ['iam.user.view', 'iam.role.view', 'inv.settings.view'],
  },
];

export const ALL_NAV_LABELS = NAV_TABLE.map((e) => e.label);

/** The entries a user holding `permissions` must be offered — screen-map §2. */
export function expectedNav(permissions: readonly string[]): string[] {
  const held = new Set(permissions);
  return NAV_TABLE.filter((entry) => entry.permissions.some((p) => held.has(p))).map(
    (e) => e.label,
  );
}

export interface DevUser {
  username: UserName;
  /** Password equals the username in the dev realm (web/README.md). */
  password: string;
  role: string;
  /**
   * A handful of entries the role matrix in screen-map §1 nails down, kept by hand as a second
   * opinion on the computed list: if both the navigation and `/identity/me` drifted together,
   * the computed test would still pass and this would not.
   *
   * `navMustNot` is a *hand-written claim about the role model*, not a restatement of the nav
   * table. Every entry in it therefore has to name the grant it denies, or the next person to
   * see it fail will delete the grant instead of the line.
   */
  navMust: string[];
  navMustNot: string[];
  /** A route the role may not open; the guard must refuse it in place. */
  forbiddenRoute: string;
  /** The permission the refusal must name. */
  forbiddenNeeds: string;
}

export const USERS: Record<UserName, DevUser> = {
  admin: {
    username: 'admin',
    password: 'admin',
    role: 'ADMIN',
    navMust: ['Panel', 'Qəbul', 'Sayım', 'Qalıqlar', 'Master data', 'İdarəetmə'],
    navMustNot: [],
    forbiddenRoute: '',
    forbiddenNeeds: '',
  },
  manager: {
    username: 'manager',
    password: 'manager',
    role: 'PROCUREMENT_MANAGER',
    navMust: ['Panel', 'Sifarişlər', 'Təsdiqlər', 'Qiymət tarixçəsi', 'Sayım', 'Hesabatlar'],
    navMustNot: ['Satış importu', 'İstehlak jurnalı'],
    forbiddenRoute: '/consumption/recipes',
    forbiddenNeeds: 'cons.recipe.view',
  },
  procurement: {
    username: 'procurement',
    password: 'procurement',
    role: 'PROCUREMENT_OFFICER',
    navMust: ['Panel', 'Tələbnamə', 'RFQ', 'Sifarişlər', 'Qiymət tarixçəsi', 'Qəbul'],
    navMustNot: ['Sayım', 'Tullantı və nümunə', 'İdarəetmə'],
    forbiddenRoute: '/inventory/counts',
    forbiddenNeeds: 'inv.count',
  },
  keeper: {
    username: 'keeper',
    password: 'keeper',
    role: 'WAREHOUSE_KEEPER',
    // «Panel» and «Hesabatlar» are here deliberately — see the note on `navMustNot` below.
    navMust: ['Panel', 'Qəbul', 'Məxaric və transfer', 'Sayım', 'Tullantı və nümunə', 'Qalıqlar'],
    /*
     * Spec §7.1 / TOR §3.1: the keeper must never be offered cost or purchasing. That is the
     * whole of the rule, and «Panel» is not part of it.
     *
     * «Panel» used to be listed here. It was wrong, and it is recorded rather than removed
     * quietly so that the next reader does not "fix" the product back:
     * `RolePermissionMap.cs` grants WAREHOUSE_KEEPER `rpt.dashboard.view`, `rpt.report.view`
     * and `rpt.export.create`. The dashboard is the keeper's own home screen — screen-map
     * puts it on both platforms and restricts it to nobody — and before the Reporting work
     * granted those codes a keeper signing in was met by a 403 on the first screen they saw.
     * So the server permits «Panel» and «Hesabatlar» for this role, the sidebar offers them,
     * and the computed expectation above (built from `GET /identity/me`) already agrees.
     */
    navMustNot: ['Qiymət tarixçəsi', 'Sifarişlər', 'Tələbnamə'],
    forbiddenRoute: '/procurement/purchase-orders',
    forbiddenNeeds: 'proc.po.view',
  },
  branch1: {
    username: 'branch1',
    password: 'branch1',
    role: 'BRANCH_USER',
    navMust: ['Panel', 'Mal tələbi', 'Qalıqlar', 'Tullantı və nümunə'],
    /*
     * «Panel» used to be listed here too, and for the same reason it was wrong: BRANCH_USER
     * holds `rpt.dashboard.view` and `rpt.report.view` in `RolePermissionMap.cs`. A branch
     * user's home screen *is* the dashboard; denying it left the role with a 403 on sign-in.
     * What a branch user must still never be offered is the warehouse's own intake, cost, and
     * administration — that is what is left in the list.
     */
    navMustNot: ['Qəbul', 'Qiymət tarixçəsi', 'İdarəetmə'],
    forbiddenRoute: '/inventory/goods-receipts',
    forbiddenNeeds: 'inv.receipt.view',
  },
  auditor: {
    username: 'auditor',
    password: 'auditor',
    role: 'AUDITOR',
    navMust: ['Panel', 'Ledger', 'Qalıqlar', 'Hesabatlar', 'Qiymət tarixçəsi'],
    navMustNot: ['Satış importu', 'İstehlak jurnalı'],
    // Read-only: no mutation screen may open.
    forbiddenRoute: '/inventory/goods-receipts/new',
    forbiddenNeeds: 'inv.receipt.create',
  },
};

export const USER_LIST = Object.values(USERS);

/** Where the signed-in storage state for a user is parked. */
export function storageStatePath(username: UserName): string {
  return new URL(`../.auth/${username}.json`, import.meta.url).pathname;
}

/** Locations seeded in `master_location` that the suite relies on. */
export const LOCATIONS = {
  WH01: { id: 1, code: 'WH-01', name: 'Mərkəzi anbar' },
  WH02: { id: 903, code: 'WH-02', name: 'Soyuducu anbar' },
  BR_ELM: { id: 2, code: 'BR-ELM', name: 'Elmlər filialı' },
  BR_NIZ: { id: 904, code: 'BR-NIZ', name: 'Nizami filialı' },
  V_SUPPLIER: { id: 900, code: 'V-SUP', name: 'Təchizatçı (virtual)' },
  V_ADJUSTMENT: { id: 902, code: 'V-ADJ', name: 'Düzəliş (virtual)' },
  V_WASTE: { id: 918, code: 'V-WASTE', name: 'Tullantı (virtual)' },
  IN_TRANSIT: { id: 920, code: 'V-TRANSIT', name: 'Yolda (virtual)' },
} as const;
