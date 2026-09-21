import 'package:go_router/go_router.dart';

import 'navigation.dart';
import 'presentation/branch/consumption_result_screen.dart';
import 'presentation/branch/daily_sales_screen.dart';
import 'presentation/manager/consumption_journal_screen.dart';
import 'presentation/manager/consumption_run_detail_screen.dart';
import 'presentation/manager/recipe_catalog_screen.dart';
import 'presentation/manager/recipe_editor_screen.dart';
import 'presentation/manager/sales_import_screen.dart';
import 'presentation/manager/variance_report_screen.dart';

/// Branch routes, mounted in the mobile shell's «Filial» branch.
///
/// The screens gate themselves with `RequirePermission.withNotice`, so a
/// deep link straight to `/consumption/daily-sales` shows the notice rather
/// than the form.
List<RouteBase> consumptionBranchRoutes() => [
  GoRoute(
    name: ConsumptionRoutes.dailySalesName,
    path: ConsumptionRoutes.dailySalesPath,
    builder: (context, state) => const DailySalesScreen(),
  ),
  GoRoute(
    name: ConsumptionRoutes.resultName,
    path: ConsumptionRoutes.resultPath,
    builder: (context, state) => const ConsumptionResultScreen(),
  ),
];

/// Manager routes, mounted in the web NavigationRail's «İstehlak» branch.
List<RouteBase> consumptionManagerRoutes() => [
  GoRoute(
    name: ConsumptionRoutes.recipeCatalogName,
    path: ConsumptionRoutes.recipeCatalogPath,
    builder: (context, state) => const RecipeCatalogScreen(),
    routes: [
      GoRoute(
        name: ConsumptionRoutes.recipeEditorName,
        path: ConsumptionRoutes.recipeEditorPath,
        builder: (context, state) => RecipeEditorScreen(
          menuItemId: int.parse(state.pathParameters['menuItemId']!),
          recipeId: int.tryParse(state.uri.queryParameters['recipeId'] ?? ''),
        ),
      ),
    ],
  ),
  GoRoute(
    name: ConsumptionRoutes.salesImportName,
    path: ConsumptionRoutes.salesImportPath,
    builder: (context, state) => const SalesImportScreen(),
  ),
  GoRoute(
    name: ConsumptionRoutes.journalName,
    path: ConsumptionRoutes.journalPath,
    builder: (context, state) => const ConsumptionJournalScreen(),
    routes: [
      GoRoute(
        name: ConsumptionRoutes.runDetailName,
        path: ConsumptionRoutes.runDetailPath,
        builder: (context, state) => ConsumptionRunDetailScreen(
          runId: int.parse(state.pathParameters['runId']!),
        ),
      ),
    ],
  ),
  GoRoute(
    name: ConsumptionRoutes.varianceName,
    path: ConsumptionRoutes.variancePath,
    builder: (context, state) => const VarianceReportScreen(),
  ),
];

/// Every consumption route (branch + manager).
List<RouteBase> consumptionRoutes() => [
  ...consumptionBranchRoutes(),
  ...consumptionManagerRoutes(),
];
