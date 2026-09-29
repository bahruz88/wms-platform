import 'package:go_router/go_router.dart';

import 'navigation.dart';
import 'presentation/balances/balances_screen.dart';
import 'presentation/balances/barcode_entry_screen.dart';
import 'presentation/counts/count_list_screen.dart';
import 'presentation/counts/count_screen.dart';
import 'presentation/issues/issue_confirm_screen.dart';
import 'presentation/issues/issue_list_screen.dart';
import 'presentation/receipts/goods_receipt_form_screen.dart';
import 'presentation/receipts/goods_receipt_list_screen.dart';
import 'presentation/requests/stock_request_form_screen.dart';
import 'presentation/samples/sample_form_screen.dart';
import 'presentation/settings/inventory_settings_screen.dart';
import 'presentation/waste/waste_form_screen.dart';
import 'presentation/waste/waste_list_screen.dart';

/// Stock routes (balances + barcode entry point).
List<RouteBase> inventoryStockRoutes() => [
  GoRoute(
    name: InventoryRoutes.balancesName,
    path: InventoryRoutes.balancesPath,
    builder: (context, state) => const BalancesScreen(),
  ),
  GoRoute(
    name: InventoryRoutes.scanName,
    path: InventoryRoutes.scanPath,
    builder: (context, state) => const BarcodeEntryScreen(),
  ),
];

/// The document lists: what a tab shows.
List<RouteBase> inventoryDocumentRoutes() => [
  GoRoute(
    name: InventoryRoutes.receiptsName,
    path: InventoryRoutes.receiptsPath,
    builder: (context, state) => const GoodsReceiptListScreen(),
  ),
  GoRoute(
    name: InventoryRoutes.issuesName,
    path: InventoryRoutes.issuesPath,
    builder: (context, state) => const IssueListScreen(),
  ),
  GoRoute(
    name: InventoryRoutes.countsName,
    path: InventoryRoutes.countsPath,
    builder: (context, state) => const CountListScreen(),
  ),
  GoRoute(
    name: InventoryRoutes.wasteName,
    path: InventoryRoutes.wastePath,
    builder: (context, state) => const WasteListScreen(),
  ),
  GoRoute(
    name: InventoryRoutes.samplesName,
    path: InventoryRoutes.samplesPath,
    redirect: (context, state) => InventoryRoutes.sampleCreateFullPath,
  ),
];

/// The screens someone *works in*: confirming a receipt, entering a count,
/// writing off stock.
///
/// Kept apart from the lists because of where they are mounted, not what they
/// do. On a phone the app mounts these outside the navigation shell, so the
/// screen covers the bar: there is no room for two bars at the bottom of a
/// phone, and a half-finished document is not somewhere to switch tabs from —
/// the way out is the header's arrow. The web mounts them in its shell along
/// with everything else, because a sidebar has room to spare.
List<RouteBase> inventoryFocusedRoutes() => [
  GoRoute(
    name: InventoryRoutes.receiptCreateName,
    path: InventoryRoutes.receiptCreatePath,
    builder: (context, state) => const GoodsReceiptFormScreen(),
  ),
  GoRoute(
    name: InventoryRoutes.stockRequestCreateName,
    path: InventoryRoutes.stockRequestCreatePath,
    builder: (context, state) => const StockRequestFormScreen(),
  ),
  GoRoute(
    name: InventoryRoutes.issueConfirmName,
    path: InventoryRoutes.issueConfirmPath,
    builder: (context, state) =>
        IssueConfirmScreen(issueId: int.parse(state.pathParameters['issueId']!)),
  ),
  GoRoute(
    name: InventoryRoutes.countDetailName,
    path: InventoryRoutes.countDetailPath,
    builder: (context, state) =>
        CountScreen(countId: int.parse(state.pathParameters['countId']!)),
  ),
  GoRoute(
    name: InventoryRoutes.wasteCreateName,
    path: InventoryRoutes.wasteCreatePath,
    builder: (context, state) => const WasteFormScreen(),
  ),
  GoRoute(
    name: InventoryRoutes.sampleCreateName,
    path: InventoryRoutes.sampleCreatePath,
    builder: (context, state) => const SampleFormScreen(),
  ),
];

/// `inv_setting` viewer, mounted in the web app's admin branch.
List<RouteBase> inventorySettingsRoutes() => [
  GoRoute(
    name: InventoryRoutes.settingsName,
    path: InventoryRoutes.settingsPath,
    builder: (context, state) => const InventorySettingsScreen(),
  ),
];

/// All inventory routes.
List<RouteBase> inventoryRoutes() => [
  ...inventoryStockRoutes(),
  ...inventoryDocumentRoutes(),
  ...inventoryFocusedRoutes(),
];
