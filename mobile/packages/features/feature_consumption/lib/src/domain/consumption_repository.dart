import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

/// Branch consumption reads and document operations
/// (`contracts/openapi/consumption.v1.yaml`, ADR-012).
///
/// Every method returns a [Result]: a business failure is a value, never an
/// exception, so a screen can put the RFC 7807 `code` on screen unchanged.
abstract interface class ConsumptionRepository {
  // --- Menu items -------------------------------------------------------
  Future<Result<Page<MenuItemDto>>> menuItems({
    String? search,
    bool? isActive,
    bool? isSubRecipe,
    bool? hasActiveRecipe,
    PageRequest page,
  });

  Future<Result<MenuItemDetailDto>> menuItem(int id);

  Future<Result<MenuItemDto>> createMenuItem(CreateMenuItemRequest request);

  /// Also the only way to bind an unmapped POS code to a menu item.
  Future<Result<MenuItemDto>> updateMenuItem(
    int id,
    UpdateMenuItemRequest request,
  );

  // --- Recipes ----------------------------------------------------------
  Future<Result<List<RecipeSummaryDto>>> recipeVersions(int menuItemId);

  Future<Result<RecipeDto>> recipe(int id);

  /// Creates a `DRAFT` version; activation is a separate operation.
  Future<Result<RecipeDto>> createRecipeVersion(
    int menuItemId,
    CreateRecipeVersionRequest request,
  );

  /// `DRAFT` only; lines replace the previous set. `422 RECIPE_CYCLE` when a
  /// sub-recipe points back at its own menu item.
  Future<Result<RecipeDto>> updateRecipe(int id, UpdateRecipeRequest request);

  /// `DRAFT` → `ACTIVE`. `409 PERIOD_CLOSED` when `validFrom` would move
  /// behind an already posted consumption document.
  Future<Result<RecipeDto>> activateRecipe(
    int id,
    ActivateRecipeRequest request,
  );

  /// Ingredient demand preview; takes nothing off stock.
  Future<Result<RecipeExplosionDto>> explodeRecipe(
    int id, {
    Quantity? portions,
    DateTime? asOfDate,
  });

  // --- Sales imports ----------------------------------------------------
  Future<Result<Page<SalesImportDto>>> salesImports({
    int? locationId,
    DateTime? dateFrom,
    DateTime? dateTo,
    SalesImportStatus? status,
    SalesSource? source,
    PageRequest page,
  });

  Future<Result<SalesImportDetailDto>> salesImport(int id);

  Future<Result<SalesImportDto>> createSalesImport(
    CreateSalesImportRequest request,
  );

  Future<Result<SalesImportDetailDto>> updateSalesImport(
    int id,
    UpdateSalesImportRequest request,
  );

  /// `DRAFT` → `SUBMITTED`; unmapped lines do not block it.
  Future<Result<SalesImportDto>> submitSalesImport(
    int id, {
    required int rowVersion,
  });

  Future<Result<SalesImportParseResultDto>> uploadSalesCsv({
    required int locationId,
    required DateTime businessDate,
    required Uint8List bytes,
    required String filename,
    SalesCsvColumnMapping? columnMapping,
    String? externalRef,
  });

  // --- Consumption runs -------------------------------------------------
  Future<Result<Page<ConsumptionRunDto>>> runs({
    int? locationId,
    DateTime? dateFrom,
    DateTime? dateTo,
    ConsumptionRunStatus? status,
    bool? hasShortfall,
    PageRequest page,
  });

  Future<Result<ConsumptionRunDetailDto>> run(int id);

  Future<Result<ConsumptionRunDetailDto>> createRun(
    CreateConsumptionRunRequest request,
  );

  Future<Result<ConsumptionRunDetailDto>> calculateRun(
    int id, {
    required int rowVersion,
  });

  /// Writes the `CONSUMPTION` movement group. A shortfall is a warning, not
  /// a blocker.
  Future<Result<ConsumptionRunDetailDto>> postRun(
    int id, {
    required int rowVersion,
  });

  /// Needs `inv.movement.reverse` and a mandatory reason code (SPEC §12.6).
  Future<Result<ConsumptionRunDetailDto>> reverseRun(
    int id,
    ReverseConsumptionRunRequest request,
  );

  // --- Variance ---------------------------------------------------------
  Future<Result<ConsumptionVariancePageDto>> variance({
    required DateTime periodFrom,
    required DateTime periodTo,
    int? locationId,
    int? productId,
    Decimal? minAbsVariancePct,
    PageRequest page,
  });

  Future<Result<Page<PortionComplianceLineDto>>> portionCompliance({
    required DateTime periodFrom,
    required DateTime periodTo,
    int? locationId,
    int? menuItemId,
    PageRequest page,
  });
}
