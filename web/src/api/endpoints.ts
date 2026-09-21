import {
  consumptionApi,
  identityApi,
  inventoryApi,
  masterDataApi,
  procurementApi,
  reportingApi,
  unwrap,
} from './client';
import type {
  components as ConsumptionComponents,
  paths as ConsumptionPaths,
} from './generated/consumption';
import type {
  components as IdentityComponents,
  paths as IdentityPaths,
} from './generated/identity';
import type {
  components as InventoryComponents,
  paths as InventoryPaths,
} from './generated/inventory';
import type {
  components as MasterDataComponents,
  paths as MasterDataPaths,
} from './generated/masterdata';
import type {
  components as ProcurementComponents,
  paths as ProcurementPaths,
} from './generated/procurement';
import type {
  components as ReportingComponents,
  paths as ReportingPaths,
} from './generated/reporting';

/**
 * Domain-shaped calls over the generated clients. Screens import from here so request shapes stay
 * in one place.
 *
 * Nothing is hand-written: every query object is `Query<Paths, '/route'>`, derived straight from
 * `paths[...]['get']['parameters']['query']` in the generated types. When the contract changes a
 * filter, this file stops compiling instead of silently sending a stale parameter.
 */

/** The query parameters a GET operation accepts, exactly as the contract declares them. */
type Query<P, R extends keyof P> = P[R] extends { get: { parameters: { query?: infer Q } } }
  ? NonNullable<Q>
  : never;

// --- model aliases, straight from the generated schemas ---------------------------------------
export type Me = IdentityComponents['schemas']['Me'];
export type UserSummary = IdentityComponents['schemas']['UserSummary'];
export type RoleSummary = IdentityComponents['schemas']['RoleSummary'];
export type Permission = IdentityComponents['schemas']['Permission'];

export type Product = MasterDataComponents['schemas']['Product'];
export type ProductSummary = MasterDataComponents['schemas']['ProductSummary'];
export type Location = MasterDataComponents['schemas']['Location'];
export type SupplierSummary = MasterDataComponents['schemas']['SupplierSummary'];
export type Uom = MasterDataComponents['schemas']['Uom'];
export type ReasonCode = MasterDataComponents['schemas']['ReasonCode'];
export type CurrencyRate = MasterDataComponents['schemas']['CurrencyRate'];
export type ProductUomRow = MasterDataComponents['schemas']['ProductUom'];

export type Balance = InventoryComponents['schemas']['Balance'];
export type Batch = InventoryComponents['schemas']['Batch'];
export type GoodsReceipt = InventoryComponents['schemas']['GoodsReceipt'];
export type GoodsReceiptSummary = InventoryComponents['schemas']['GoodsReceiptSummary'];
export type GoodsReceiptCreate = InventoryComponents['schemas']['GoodsReceiptCreate'];
export type Movement = InventoryComponents['schemas']['Movement'];
export type MovementGroup = InventoryComponents['schemas']['MovementGroup'];
export type CountSummary = InventoryComponents['schemas']['CountSummary'];
export type WasteSummary = InventoryComponents['schemas']['WasteSummary'];
export type SampleSummary = InventoryComponents['schemas']['SampleSummary'];
export type InventorySetting = InventoryComponents['schemas']['InventorySetting'];

export type RequisitionSummary = ProcurementComponents['schemas']['RequisitionSummary'];
export type RfqSummary = ProcurementComponents['schemas']['RfqSummary'];
export type QuotationSummary = ProcurementComponents['schemas']['QuotationSummary'];
export type RfqComparison = ProcurementComponents['schemas']['RfqComparison'];
export type RfqComparisonRow = ProcurementComponents['schemas']['RfqComparisonRow'];
export type RfqComparisonCell = ProcurementComponents['schemas']['RfqComparisonCell'];
export type PurchaseOrder = ProcurementComponents['schemas']['PurchaseOrder'];
export type PurchaseOrderSummary = ProcurementComponents['schemas']['PurchaseOrderSummary'];
export type PendingApproval = ProcurementComponents['schemas']['PendingApproval'];
export type ApprovalStepDto = ProcurementComponents['schemas']['ApprovalStep'];
export type PriceHistoryEntry = ProcurementComponents['schemas']['PriceHistoryEntry'];

export type MenuItem = ConsumptionComponents['schemas']['MenuItem'];
export type MenuItemDetail = ConsumptionComponents['schemas']['MenuItemDetail'];
export type Recipe = ConsumptionComponents['schemas']['Recipe'];
export type RecipeSummary = ConsumptionComponents['schemas']['RecipeSummary'];
export type RecipeLine = ConsumptionComponents['schemas']['RecipeLine'];
export type RecipeExplosion = ConsumptionComponents['schemas']['RecipeExplosion'];
export type SalesImport = ConsumptionComponents['schemas']['SalesImport'];
export type SalesImportDetail = ConsumptionComponents['schemas']['SalesImportDetail'];
export type SalesImportParseResult = ConsumptionComponents['schemas']['SalesImportParseResult'];
export type SalesLine = ConsumptionComponents['schemas']['SalesLine'];
export type ConsumptionRun = ConsumptionComponents['schemas']['ConsumptionRun'];
export type ConsumptionRunDetail = ConsumptionComponents['schemas']['ConsumptionRunDetail'];
export type ConsumptionRunLine = ConsumptionComponents['schemas']['ConsumptionRunLine'];
export type VarianceLine = ConsumptionComponents['schemas']['VarianceLine'];

export type ReportDefinitionSummary = ReportingComponents['schemas']['ReportDefinition'];
export type ExportJob = ReportingComponents['schemas']['ExportJob'];
export type DashboardSummary = ReportingComponents['schemas']['DashboardSummary'];
export type DashboardAlert = ReportingComponents['schemas']['DashboardAlert'];
export type Kpi = ReportingComponents['schemas']['Kpi'];

// --- identity -----------------------------------------------------------------------------------
export const getMe = async (): Promise<Me> => unwrap(await identityApi.GET('/me'));

export const getTenant = async () => unwrap(await identityApi.GET('/tenant'));

export const listUsers = async (query: Query<IdentityPaths, '/users'> = {}) =>
  unwrap(await identityApi.GET('/users', { params: { query } }));

export const listRoles = async () => unwrap(await identityApi.GET('/roles'));

export const listPermissions = async () => unwrap(await identityApi.GET('/permissions'));

// --- master data --------------------------------------------------------------------------------
export const listProducts = async (query: Query<MasterDataPaths, '/products'> = {}) =>
  unwrap(await masterDataApi.GET('/products', { params: { query } }));

export const getProduct = async (id: number) =>
  unwrap(await masterDataApi.GET('/products/{id}', { params: { path: { id } } }));

export const listProductUoms = async (id: number) =>
  unwrap(await masterDataApi.GET('/products/{id}/uoms', { params: { path: { id } } }));

export const listLocations = async (query: Query<MasterDataPaths, '/locations'> = {}) =>
  unwrap(await masterDataApi.GET('/locations', { params: { query } }));

export const listSuppliers = async (query: Query<MasterDataPaths, '/suppliers'> = {}) =>
  unwrap(await masterDataApi.GET('/suppliers', { params: { query } }));

export const listUoms = async (query: Query<MasterDataPaths, '/uoms'> = {}) =>
  unwrap(await masterDataApi.GET('/uoms', { params: { query } }));

export const listReasonCodes = async (query: Query<MasterDataPaths, '/reason-codes'> = {}) =>
  unwrap(await masterDataApi.GET('/reason-codes', { params: { query } }));

export const listCurrencyRates = async (query: Query<MasterDataPaths, '/currency-rates'> = {}) =>
  unwrap(await masterDataApi.GET('/currency-rates', { params: { query } }));

export const listNumberSequences = async () => unwrap(await masterDataApi.GET('/number-sequences'));

// --- inventory ------------------------------------------------------------------------------------
export const listBalances = async (query: Query<InventoryPaths, '/balances'> = {}) =>
  unwrap(await inventoryApi.GET('/balances', { params: { query } }));

export const getBalanceSummary = async (query: Query<InventoryPaths, '/balances/summary'>) =>
  unwrap(await inventoryApi.GET('/balances/summary', { params: { query } }));

export const listBatches = async (query: Query<InventoryPaths, '/batches'> = {}) =>
  unwrap(await inventoryApi.GET('/batches', { params: { query } }));

export const listGoodsReceipts = async (query: Query<InventoryPaths, '/goods-receipts'> = {}) =>
  unwrap(await inventoryApi.GET('/goods-receipts', { params: { query } }));

export const getGoodsReceipt = async (id: number) =>
  unwrap(await inventoryApi.GET('/goods-receipts/{id}', { params: { path: { id } } }));

/** POST — the client adds `Idempotency-Key` on its own (SPEC §13.2). */
export const createGoodsReceipt = async (body: GoodsReceiptCreate) =>
  unwrap(
    await inventoryApi.POST('/goods-receipts', {
      params: { header: { 'Idempotency-Key': crypto.randomUUID() } },
      body,
    }),
  );

export const postGoodsReceipt = async (id: number, rowVersion: number) =>
  unwrap(
    await inventoryApi.POST('/goods-receipts/{id}/post', {
      params: { path: { id }, header: { 'Idempotency-Key': crypto.randomUUID() } },
      body: { rowVersion },
    }),
  );

export const listMovements = async (query: Query<InventoryPaths, '/movements'> = {}) =>
  unwrap(await inventoryApi.GET('/movements', { params: { query } }));

export const getMovementGroup = async (id: number) =>
  unwrap(await inventoryApi.GET('/movement-groups/{id}', { params: { path: { id } } }));

export const listCounts = async (query: Query<InventoryPaths, '/counts'> = {}) =>
  unwrap(await inventoryApi.GET('/counts', { params: { query } }));

export const listWaste = async (query: Query<InventoryPaths, '/waste'> = {}) =>
  unwrap(await inventoryApi.GET('/waste', { params: { query } }));

export const listSamples = async (query: Query<InventoryPaths, '/samples'> = {}) =>
  unwrap(await inventoryApi.GET('/samples', { params: { query } }));

export const listInventorySettings = async () => unwrap(await inventoryApi.GET('/settings'));

// --- procurement ------------------------------------------------------------------------------------
export const listRequisitions = async (query: Query<ProcurementPaths, '/requisitions'> = {}) =>
  unwrap(await procurementApi.GET('/requisitions', { params: { query } }));

export const listRfqs = async (query: Query<ProcurementPaths, '/rfqs'> = {}) =>
  unwrap(await procurementApi.GET('/rfqs', { params: { query } }));

export const getRfqComparison = async (id: number) =>
  unwrap(await procurementApi.GET('/rfqs/{id}/comparison', { params: { path: { id } } }));

export const selectQuotation = async (id: number, rowVersion: number, selectionNote?: string) =>
  unwrap(
    await procurementApi.POST('/quotations/{id}/select', {
      params: { path: { id }, header: { 'Idempotency-Key': crypto.randomUUID() } },
      body: { rowVersion, selectionNote },
    }),
  );

export const listQuotations = async (query: Query<ProcurementPaths, '/quotations'> = {}) =>
  unwrap(await procurementApi.GET('/quotations', { params: { query } }));

export const listPurchaseOrders = async (query: Query<ProcurementPaths, '/purchase-orders'> = {}) =>
  unwrap(await procurementApi.GET('/purchase-orders', { params: { query } }));

export const getPurchaseOrder = async (id: number) =>
  unwrap(await procurementApi.GET('/purchase-orders/{id}', { params: { path: { id } } }));

export const approvePurchaseOrder = async (id: number, rowVersion: number, comment?: string) =>
  unwrap(
    await procurementApi.POST('/purchase-orders/{id}/approve', {
      params: { path: { id }, header: { 'Idempotency-Key': crypto.randomUUID() } },
      body: { rowVersion, comment },
    }),
  );

export const rejectPurchaseOrder = async (id: number, rowVersion: number, comment: string) =>
  unwrap(
    await procurementApi.POST('/purchase-orders/{id}/reject', {
      params: { path: { id }, header: { 'Idempotency-Key': crypto.randomUUID() } },
      body: { rowVersion, comment },
    }),
  );

export const listPendingApprovals = async (
  query: Query<ProcurementPaths, '/approvals/pending'> = {},
) => unwrap(await procurementApi.GET('/approvals/pending', { params: { query } }));

export const listPriceHistory = async (query: Query<ProcurementPaths, '/price-history'> = {}) =>
  unwrap(await procurementApi.GET('/price-history', { params: { query } }));

// --- consumption ---------------------------------------------------------------------------------------
export const listMenuItems = async (query: Query<ConsumptionPaths, '/menu-items'> = {}) =>
  unwrap(await consumptionApi.GET('/menu-items', { params: { query } }));

export const getMenuItem = async (id: number) =>
  unwrap(await consumptionApi.GET('/menu-items/{id}', { params: { path: { id } } }));

export const listRecipeVersions = async (id: number) =>
  unwrap(await consumptionApi.GET('/menu-items/{id}/recipes', { params: { path: { id } } }));

export const getRecipe = async (id: number) =>
  unwrap(await consumptionApi.GET('/recipes/{id}', { params: { path: { id } } }));

export const explodeRecipe = async (
  id: number,
  query: Query<ConsumptionPaths, '/recipes/{id}/explosion'>,
) =>
  unwrap(await consumptionApi.GET('/recipes/{id}/explosion', { params: { path: { id }, query } }));

export const listSalesImports = async (query: Query<ConsumptionPaths, '/sales-imports'> = {}) =>
  unwrap(await consumptionApi.GET('/sales-imports', { params: { query } }));

export const getSalesImport = async (id: number) =>
  unwrap(await consumptionApi.GET('/sales-imports/{id}', { params: { path: { id } } }));

export const uploadSalesCsv = async (body: ConsumptionComponents['schemas']['SalesCsvUpload']) =>
  unwrap(
    await consumptionApi.POST('/sales-imports/upload-csv', {
      params: { header: { 'Idempotency-Key': crypto.randomUUID() } },
      body,
    }),
  );

export const listConsumptionRuns = async (query: Query<ConsumptionPaths, '/runs'> = {}) =>
  unwrap(await consumptionApi.GET('/runs', { params: { query } }));

export const getConsumptionRun = async (id: number) =>
  unwrap(await consumptionApi.GET('/runs/{id}', { params: { path: { id } } }));

export const calculateConsumptionRun = async (id: number, rowVersion: number) =>
  unwrap(
    await consumptionApi.POST('/runs/{id}/calculate', {
      params: { path: { id }, header: { 'Idempotency-Key': crypto.randomUUID() } },
      body: { rowVersion },
    }),
  );

export const postConsumptionRun = async (id: number, rowVersion: number) =>
  unwrap(
    await consumptionApi.POST('/runs/{id}/post', {
      params: { path: { id }, header: { 'Idempotency-Key': crypto.randomUUID() } },
      body: { rowVersion },
    }),
  );

export const reverseConsumptionRun = async (
  id: number,
  rowVersion: number,
  reasonCodeId: number,
  note?: string,
) =>
  unwrap(
    await consumptionApi.POST('/runs/{id}/reverse', {
      params: { path: { id }, header: { 'Idempotency-Key': crypto.randomUUID() } },
      body: { rowVersion, reasonCodeId, note },
    }),
  );

export const getConsumptionVariance = async (query: Query<ConsumptionPaths, '/variance'>) =>
  unwrap(await consumptionApi.GET('/variance', { params: { query } }));

// --- reporting ------------------------------------------------------------------------------------------
export const getDashboardSummary = async () => unwrap(await reportingApi.GET('/dashboard/summary'));

export const listReports = async () => unwrap(await reportingApi.GET('/reports'));

export const getReportDefinition = async (code: string) =>
  unwrap(await reportingApi.GET('/reports/{code}', { params: { path: { code } } }));

export const listExports = async (query: Query<ReportingPaths, '/exports'> = {}) =>
  unwrap(await reportingApi.GET('/exports', { params: { query } }));

export const createExport = async (body: ReportingComponents['schemas']['ExportCreateRequest']) =>
  unwrap(
    await reportingApi.POST('/exports', {
      params: { header: { 'Idempotency-Key': crypto.randomUUID() } },
      body,
    }),
  );
