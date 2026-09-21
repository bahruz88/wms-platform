/// Permission codes (`iam_permission.code`). The first group is fixed by the
/// spec (§7.1); the rest follow the same `module.resource.action` scheme and
/// mirror the endpoint policies (`.RequirePermission("inv.receipt.create")`).
abstract final class Permissions {
  // --- Spec §7.1: critical permissions ---------------------------------
  /// Warehouse keepers must NOT hold this; cost fields are stripped from DTOs.
  static const String productViewCost = 'master.product.view_cost';
  static const String adjustmentApprove = 'inv.adjustment.approve';
  static const String wasteApprove = 'inv.waste.approve';
  static const String poApprove = 'proc.po.approve';
  static const String movementReverse = 'inv.movement.reverse';

  // --- Inventory ----------------------------------------------------------
  static const String balanceView = 'inv.balance.view';
  static const String receiptCreate = 'inv.receipt.create';
  static const String receiptPost = 'inv.receipt.post';
  static const String stockRequestCreate = 'inv.stock_request.create';
  static const String issueCreate = 'inv.issue.create';
  static const String issueDispatch = 'inv.issue.dispatch';
  static const String issueConfirm = 'inv.issue.confirm';
  static const String countCreate = 'inv.count.create';
  static const String countEnter = 'inv.count.enter';
  static const String wasteCreate = 'inv.waste.create';
  static const String sampleCreate = 'inv.sample.create';

  // --- Procurement --------------------------------------------------------
  static const String requisitionCreate = 'proc.requisition.create';
  static const String rfqManage = 'proc.rfq.manage';
  static const String quotationSelect = 'proc.quotation.select';
  static const String poCreate = 'proc.po.create';
  static const String poView = 'proc.po.view';
  static const String priceHistoryView = 'proc.price_history.view';

  // --- Consumption (ADR-012, branch-operations.md §8) ---------------------
  /// Create and version recipes (manager).
  static const String recipeManage = 'cons.recipe.manage';
  static const String recipeView = 'cons.recipe.view';

  /// Feed daily sales in (branch + manager).
  static const String salesImport = 'cons.sales.import';
  static const String runCalculate = 'cons.run.calculate';
  static const String runPost = 'cons.run.post';
  static const String varianceView = 'cons.variance.view';

  // --- Master data --------------------------------------------------------
  static const String productView = 'master.product.view';
  static const String productManage = 'master.product.manage';
  static const String supplierManage = 'master.supplier.manage';
  static const String locationManage = 'master.location.manage';

  // --- Identity / admin ---------------------------------------------------
  static const String userManage = 'iam.user.manage';
  static const String roleManage = 'iam.role.manage';

  // --- Reporting ----------------------------------------------------------
  static const String reportView = 'rpt.report.view';
  static const String reportExport = 'rpt.report.export';

  static const Set<String> all = {
    productViewCost,
    adjustmentApprove,
    wasteApprove,
    poApprove,
    movementReverse,
    balanceView,
    receiptCreate,
    receiptPost,
    stockRequestCreate,
    issueCreate,
    issueDispatch,
    issueConfirm,
    countCreate,
    countEnter,
    wasteCreate,
    sampleCreate,
    requisitionCreate,
    rfqManage,
    quotationSelect,
    poCreate,
    poView,
    priceHistoryView,
    recipeManage,
    recipeView,
    salesImport,
    runCalculate,
    runPost,
    varianceView,
    productView,
    productManage,
    supplierManage,
    locationManage,
    userManage,
    roleManage,
    reportView,
    reportExport,
  };
}

/// Realm roles from the Keycloak `wms` realm (CONVENTIONS.md).
abstract final class Roles {
  static const String admin = 'ADMIN';
  static const String procurementOfficer = 'PROCUREMENT_OFFICER';
  static const String procurementManager = 'PROCUREMENT_MANAGER';
  static const String warehouseKeeper = 'WAREHOUSE_KEEPER';
  static const String branchUser = 'BRANCH_USER';
  static const String auditor = 'AUDITOR';
}
