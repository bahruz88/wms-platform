import type { ReactElement } from 'react';
import { Navigate, Route, Routes } from 'react-router-dom';
import { RequireAuth, RequirePermission, useAuth } from '@auth/index';
import { AppShell } from './AppShell';
import { visibleNavGroups } from './navigation';
import { CallbackScreen } from '@features/auth/CallbackScreen';
import { LoginScreen } from '@features/auth/LoginScreen';
import { NotFoundScreen } from '@features/auth/NotFoundScreen';
import { DashboardScreen } from '@features/dashboard/DashboardScreen';
import { RequisitionsScreen } from '@features/procurement/RequisitionsScreen';
import { RfqsScreen } from '@features/procurement/RfqsScreen';
import { RfqComparisonScreen } from '@features/procurement/RfqComparisonScreen';
import { QuotationsScreen } from '@features/procurement/QuotationsScreen';
import { PurchaseOrdersScreen } from '@features/procurement/PurchaseOrdersScreen';
import { PurchaseOrderDetailScreen } from '@features/procurement/PurchaseOrderDetailScreen';
import { ApprovalsScreen } from '@features/procurement/ApprovalsScreen';
import { PriceHistoryScreen } from '@features/procurement/PriceHistoryScreen';
import { BalancesScreen } from '@features/inventory/BalancesScreen';
import { BatchesScreen } from '@features/inventory/BatchesScreen';
import { GoodsReceiptsScreen } from '@features/inventory/GoodsReceiptsScreen';
import { GoodsReceiptDetailScreen } from '@features/inventory/GoodsReceiptDetailScreen';
import { GoodsReceiptCreateScreen } from '@features/inventory/GoodsReceiptCreateScreen';
import { MovementsScreen } from '@features/inventory/MovementsScreen';
import { MovementGroupScreen } from '@features/inventory/MovementGroupScreen';
import { CountsScreen } from '@features/inventory/CountsScreen';
import { CountDetailScreen } from '@features/inventory/CountDetailScreen';
import { IssuesScreen } from '@features/inventory/IssuesScreen';
import { IssueCreateScreen } from '@features/inventory/IssueCreateScreen';
import { IssueDetailScreen } from '@features/inventory/IssueDetailScreen';
import { StockRequestsScreen } from '@features/inventory/StockRequestsScreen';
import { StockRequestCreateScreen } from '@features/inventory/StockRequestCreateScreen';
import { StockRequestDetailScreen } from '@features/inventory/StockRequestDetailScreen';
import { WasteScreen } from '@features/inventory/WasteScreen';
import { WasteDetailScreen } from '@features/inventory/WasteDetailScreen';
import { SamplesScreen } from '@features/inventory/SamplesScreen';
import { SampleDetailScreen } from '@features/inventory/SampleDetailScreen';
import { ReturnsScreen } from '@features/inventory/ReturnsScreen';
import { ReturnCreateScreen } from '@features/inventory/ReturnCreateScreen';
import { ReturnDetailScreen } from '@features/inventory/ReturnDetailScreen';
import { ProductsScreen } from '@features/masterdata/ProductsScreen';
import { SuppliersScreen } from '@features/masterdata/SuppliersScreen';
import { LocationsScreen } from '@features/masterdata/LocationsScreen';
import { UomsScreen } from '@features/masterdata/UomsScreen';
import { ReasonCodesScreen } from '@features/masterdata/ReasonCodesScreen';
import { CurrencyRatesScreen } from '@features/masterdata/CurrencyRatesScreen';
import { RecipesScreen } from '@features/consumption/RecipesScreen';
import { RecipeEditorScreen } from '@features/consumption/RecipeEditorScreen';
import { SalesImportsScreen } from '@features/consumption/SalesImportsScreen';
import { SalesImportDetailScreen } from '@features/consumption/SalesImportDetailScreen';
import { SalesImportCsvScreen } from '@features/consumption/SalesImportCsvScreen';
import { ConsumptionRunsScreen } from '@features/consumption/ConsumptionRunsScreen';
import { ConsumptionRunDetailScreen } from '@features/consumption/ConsumptionRunDetailScreen';
import { ConsumptionVarianceScreen } from '@features/consumption/ConsumptionVarianceScreen';
import { UsersScreen } from '@features/admin/UsersScreen';
import { RolesScreen } from '@features/admin/RolesScreen';
import { InventorySettingsScreen } from '@features/admin/InventorySettingsScreen';
import { ReportsScreen } from '@features/reporting/ReportsScreen';
import { ExportsScreen } from '@features/reporting/ExportsScreen';

/**
 * Route table. Each guarded route names the same `x-permission` the contract puts on its
 * operation, so a deep link is refused with the reason rather than silently rendering an empty
 * screen. The server checks again on every request — this is the interface half only.
 */
function Guarded({
  permission,
  children,
  redirectTo,
}: {
  permission: string | string[];
  children: ReactElement;
  redirectTo?: string;
}) {
  return (
    <RequirePermission permission={permission} redirectTo={redirectTo}>
      {children}
    </RequirePermission>
  );
}

/**
 * The index route is where sign-in lands, so a user without `rpt.dashboard.view` must not be
 * met by a refusal: they are sent to the first screen their own navigation offers — the keeper
 * to «Qəbul», the branch user to «Mal tələbi». The dashboard is still not rendered for them,
 * which is the point; only the destination is kinder than a dead end.
 *
 * A user whose navigation is empty has genuinely nothing to open, and then the refusal with its
 * `FORBIDDEN` code is the honest answer.
 */
function Home() {
  const { session, can } = useAuth();
  const first = visibleNavGroups(session?.permissions ?? [])
    .flatMap((group) => group.items)
    .find((item) => item.to !== '/');

  if (!can('rpt.dashboard.view') && first) return <Navigate to={first.to} replace />;

  return (
    <Guarded permission="rpt.dashboard.view">
      <DashboardScreen />
    </Guarded>
  );
}

export function AppRoutes() {
  return (
    <Routes>
      <Route path="/callback" element={<CallbackScreen />} />
      <Route path="/login" element={<LoginScreen />} />

      <Route
        element={
          <RequireAuth>
            <AppShell />
          </RequireAuth>
        }
      >
        {/* The dashboard is `rpt.dashboard.view` like every other screen: the navigation hides
            the entry without it, and the route has to refuse it too, or `/` would be the one
            screen a deep link walks straight into. */}
        <Route index element={<Home />} />

        <Route path="procurement">
          <Route
            path="requisitions"
            element={
              <Guarded permission="proc.pr.view">
                <RequisitionsScreen />
              </Guarded>
            }
          />
          <Route
            path="rfqs"
            element={
              <Guarded permission="proc.rfq.view">
                <RfqsScreen />
              </Guarded>
            }
          />
          <Route
            path="rfqs/:id/comparison"
            element={
              <Guarded permission="proc.quotation.view">
                <RfqComparisonScreen />
              </Guarded>
            }
          />
          <Route
            path="quotations"
            element={
              <Guarded permission="proc.quotation.view">
                <QuotationsScreen />
              </Guarded>
            }
          />
          <Route
            path="purchase-orders"
            element={
              <Guarded permission="proc.po.view">
                <PurchaseOrdersScreen />
              </Guarded>
            }
          />
          <Route
            path="purchase-orders/:id"
            element={
              <Guarded permission="proc.po.view">
                <PurchaseOrderDetailScreen />
              </Guarded>
            }
          />
          <Route
            path="approvals"
            element={
              <Guarded permission="proc.approval.view">
                <ApprovalsScreen />
              </Guarded>
            }
          />
          <Route
            path="price-history"
            element={
              <Guarded permission="master.product.view_cost">
                <PriceHistoryScreen />
              </Guarded>
            }
          />
        </Route>

        <Route path="inventory">
          <Route
            path="balances"
            element={
              <Guarded permission="inv.balance.view">
                <BalancesScreen />
              </Guarded>
            }
          />
          <Route
            path="batches"
            element={
              <Guarded permission="inv.batch.view">
                <BatchesScreen />
              </Guarded>
            }
          />
          <Route
            path="goods-receipts"
            element={
              <Guarded permission="inv.receipt.view">
                <GoodsReceiptsScreen />
              </Guarded>
            }
          />
          <Route
            path="goods-receipts/new"
            element={
              <Guarded permission="inv.receipt.create">
                <GoodsReceiptCreateScreen />
              </Guarded>
            }
          />
          <Route
            path="goods-receipts/:id"
            element={
              <Guarded permission="inv.receipt.view">
                <GoodsReceiptDetailScreen />
              </Guarded>
            }
          />
          <Route
            path="movements"
            element={
              <Guarded permission="inv.movement.view">
                <MovementsScreen />
              </Guarded>
            }
          />
          <Route
            path="movement-groups/:id"
            element={
              <Guarded permission="inv.movement.view">
                <MovementGroupScreen />
              </Guarded>
            }
          />
          <Route
            path="issues"
            element={
              <Guarded permission={['inv.issue.view', 'inv.issue.create']}>
                <IssuesScreen />
              </Guarded>
            }
          />
          <Route
            path="issues/new"
            element={
              <Guarded permission="inv.issue.create">
                <IssueCreateScreen />
              </Guarded>
            }
          />
          <Route
            path="issues/:id"
            element={
              <Guarded permission="inv.issue.view">
                <IssueDetailScreen />
              </Guarded>
            }
          />
          <Route
            path="stock-requests"
            element={
              <Guarded permission="inv.request.view">
                <StockRequestsScreen />
              </Guarded>
            }
          />
          <Route
            path="stock-requests/new"
            element={
              <Guarded permission="inv.request.create">
                <StockRequestCreateScreen />
              </Guarded>
            }
          />
          <Route
            path="stock-requests/:id"
            element={
              <Guarded permission="inv.request.view">
                <StockRequestDetailScreen />
              </Guarded>
            }
          />
          <Route
            path="counts"
            element={
              <Guarded permission={['inv.count.view', 'inv.count.create']}>
                <CountsScreen />
              </Guarded>
            }
          />
          <Route
            path="counts/:id"
            element={
              <Guarded permission="inv.count.view">
                <CountDetailScreen />
              </Guarded>
            }
          />
          <Route
            path="waste"
            element={
              <Guarded permission="inv.waste.view">
                <WasteScreen />
              </Guarded>
            }
          />
          {/* The dashboard's pending-approval link for a WASTE document points here. Without
              this route it landed on NotFoundScreen. */}
          <Route
            path="waste/:id"
            element={
              <Guarded permission="inv.waste.view">
                <WasteDetailScreen />
              </Guarded>
            }
          />
          <Route
            path="samples"
            element={
              <Guarded permission="inv.sample.view">
                <SamplesScreen />
              </Guarded>
            }
          />
          <Route
            path="samples/:id"
            element={
              <Guarded permission="inv.sample.view">
                <SampleDetailScreen />
              </Guarded>
            }
          />
          {/* Return to vendor — screen-map §3.11. The contract writes the permission as
              `inv.rtv.*`; the service enforces `inv.return.*`, and the guard follows the
              service, which is the only real check. */}
          <Route
            path="returns"
            element={
              <Guarded permission="inv.return.view">
                <ReturnsScreen />
              </Guarded>
            }
          />
          <Route
            path="returns/new"
            element={
              <Guarded permission="inv.return.create">
                <ReturnCreateScreen />
              </Guarded>
            }
          />
          <Route
            path="returns/:id"
            element={
              <Guarded permission="inv.return.view">
                <ReturnDetailScreen />
              </Guarded>
            }
          />
        </Route>

        <Route path="master-data">
          <Route
            path="products"
            element={
              <Guarded permission="master.product.view">
                <ProductsScreen />
              </Guarded>
            }
          />
          <Route
            path="suppliers"
            element={
              <Guarded permission="master.supplier.view">
                <SuppliersScreen />
              </Guarded>
            }
          />
          <Route
            path="locations"
            element={
              <Guarded permission="master.location.view">
                <LocationsScreen />
              </Guarded>
            }
          />
          <Route
            path="uoms"
            element={
              <Guarded permission="master.product.view">
                <UomsScreen />
              </Guarded>
            }
          />
          <Route
            path="reason-codes"
            element={
              <Guarded permission="master.reason.view">
                <ReasonCodesScreen />
              </Guarded>
            }
          />
          <Route
            path="currency-rates"
            element={
              <Guarded permission="master.currency.view">
                <CurrencyRatesScreen />
              </Guarded>
            }
          />
        </Route>

        <Route path="consumption">
          <Route
            path="recipes"
            element={
              <Guarded permission="cons.recipe.view">
                <RecipesScreen />
              </Guarded>
            }
          />
          <Route
            path="recipes/:menuItemId"
            element={
              <Guarded permission="cons.recipe.view">
                <RecipeEditorScreen />
              </Guarded>
            }
          />
          <Route
            path="sales-imports"
            element={
              <Guarded permission="cons.sales.import">
                <SalesImportsScreen />
              </Guarded>
            }
          />
          <Route
            path="sales-imports/csv"
            element={
              <Guarded permission="cons.sales.import">
                <SalesImportCsvScreen />
              </Guarded>
            }
          />
          <Route
            path="sales-imports/:id"
            element={
              <Guarded permission="cons.sales.import">
                <SalesImportDetailScreen />
              </Guarded>
            }
          />
          <Route
            path="runs"
            element={
              <Guarded permission="cons.run.calculate">
                <ConsumptionRunsScreen />
              </Guarded>
            }
          />
          <Route
            path="runs/:id"
            element={
              <Guarded permission="cons.run.calculate">
                <ConsumptionRunDetailScreen />
              </Guarded>
            }
          />
          <Route
            path="variance"
            element={
              <Guarded permission="cons.variance.view">
                <ConsumptionVarianceScreen />
              </Guarded>
            }
          />
        </Route>

        <Route path="reporting">
          <Route
            path="reports"
            element={
              <Guarded permission="rpt.report.view">
                <ReportsScreen />
              </Guarded>
            }
          />
          <Route
            path="exports"
            element={
              <Guarded permission="rpt.export.create">
                <ExportsScreen />
              </Guarded>
            }
          />
        </Route>

        <Route path="admin">
          <Route
            path="users"
            element={
              <Guarded permission="iam.user.view">
                <UsersScreen />
              </Guarded>
            }
          />
          <Route
            path="roles"
            element={
              <Guarded permission="iam.role.view">
                <RolesScreen />
              </Guarded>
            }
          />
          <Route
            path="settings"
            element={
              <Guarded permission="inv.settings.view">
                <InventorySettingsScreen />
              </Guarded>
            }
          />
        </Route>

        <Route path="*" element={<NotFoundScreen />} />
      </Route>

      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}
