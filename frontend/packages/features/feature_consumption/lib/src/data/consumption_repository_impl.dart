import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

import '../domain/consumption_repository.dart';

/// [ConsumptionRepository] over [ConsumptionApi]. Every call is wrapped in
/// `Result.guard`, so transport and RFC 7807 problems arrive as `Err`.
class ConsumptionRepositoryImpl implements ConsumptionRepository {
  ConsumptionRepositoryImpl(this._api);

  final ConsumptionApi _api;

  @override
  Future<Result<Page<MenuItemDto>>> menuItems({
    String? search,
    bool? isActive,
    bool? isSubRecipe,
    bool? hasActiveRecipe,
    PageRequest page = const PageRequest(),
  }) => Result.guard(
    () => _api.listMenuItems(
      search: search,
      isActive: isActive,
      isSubRecipe: isSubRecipe,
      hasActiveRecipe: hasActiveRecipe,
      page: page,
    ),
  );

  @override
  Future<Result<MenuItemDetailDto>> menuItem(int id) =>
      Result.guard(() => _api.getMenuItem(id));

  @override
  Future<Result<MenuItemDto>> createMenuItem(CreateMenuItemRequest request) =>
      Result.guard(() => _api.createMenuItem(request));

  @override
  Future<Result<MenuItemDto>> updateMenuItem(
    int id,
    UpdateMenuItemRequest request,
  ) => Result.guard(() => _api.updateMenuItem(id, request));

  @override
  Future<Result<List<RecipeSummaryDto>>> recipeVersions(int menuItemId) =>
      Result.guard(() => _api.listRecipeVersions(menuItemId));

  @override
  Future<Result<RecipeDto>> recipe(int id) =>
      Result.guard(() => _api.getRecipe(id));

  @override
  Future<Result<RecipeDto>> createRecipeVersion(
    int menuItemId,
    CreateRecipeVersionRequest request,
  ) => Result.guard(() => _api.createRecipeVersion(menuItemId, request));

  @override
  Future<Result<RecipeDto>> updateRecipe(int id, UpdateRecipeRequest request) =>
      Result.guard(() => _api.updateRecipe(id, request));

  @override
  Future<Result<RecipeDto>> activateRecipe(
    int id,
    ActivateRecipeRequest request,
  ) => Result.guard(() => _api.activateRecipe(id, request));

  @override
  Future<Result<RecipeExplosionDto>> explodeRecipe(
    int id, {
    Quantity? portions,
    DateTime? asOfDate,
  }) => Result.guard(
    () => _api.explodeRecipe(id, portions: portions, asOfDate: asOfDate),
  );

  @override
  Future<Result<Page<SalesImportDto>>> salesImports({
    int? locationId,
    DateTime? dateFrom,
    DateTime? dateTo,
    SalesImportStatus? status,
    SalesSource? source,
    PageRequest page = const PageRequest(),
  }) => Result.guard(
    () => _api.listSalesImports(
      locationId: locationId,
      dateFrom: dateFrom,
      dateTo: dateTo,
      status: status,
      source: source,
      page: page,
    ),
  );

  @override
  Future<Result<SalesImportDetailDto>> salesImport(int id) =>
      Result.guard(() => _api.getSalesImport(id));

  @override
  Future<Result<SalesImportDto>> createSalesImport(
    CreateSalesImportRequest request,
  ) => Result.guard(() => _api.createSalesImport(request));

  @override
  Future<Result<SalesImportDetailDto>> updateSalesImport(
    int id,
    UpdateSalesImportRequest request,
  ) => Result.guard(() => _api.updateSalesImport(id, request));

  @override
  Future<Result<SalesImportDto>> submitSalesImport(
    int id, {
    required int rowVersion,
  }) => Result.guard(() => _api.submitSalesImport(id, rowVersion: rowVersion));

  @override
  Future<Result<SalesImportParseResultDto>> uploadSalesCsv({
    required int locationId,
    required DateTime businessDate,
    required Uint8List bytes,
    required String filename,
    SalesCsvColumnMapping? columnMapping,
    String? externalRef,
  }) => Result.guard(
    () => _api.uploadSalesCsv(
      locationId: locationId,
      businessDate: businessDate,
      bytes: bytes,
      filename: filename,
      columnMapping: columnMapping,
      externalRef: externalRef,
    ),
  );

  @override
  Future<Result<Page<ConsumptionRunDto>>> runs({
    int? locationId,
    DateTime? dateFrom,
    DateTime? dateTo,
    ConsumptionRunStatus? status,
    bool? hasShortfall,
    PageRequest page = const PageRequest(),
  }) => Result.guard(
    () => _api.listConsumptionRuns(
      locationId: locationId,
      dateFrom: dateFrom,
      dateTo: dateTo,
      status: status,
      hasShortfall: hasShortfall,
      page: page,
    ),
  );

  @override
  Future<Result<ConsumptionRunDetailDto>> run(int id) =>
      Result.guard(() => _api.getConsumptionRun(id));

  @override
  Future<Result<ConsumptionRunDetailDto>> createRun(
    CreateConsumptionRunRequest request,
  ) => Result.guard(() => _api.createConsumptionRun(request));

  @override
  Future<Result<ConsumptionRunDetailDto>> calculateRun(
    int id, {
    required int rowVersion,
  }) => Result.guard(
    () => _api.calculateConsumptionRun(id, rowVersion: rowVersion),
  );

  @override
  Future<Result<ConsumptionRunDetailDto>> postRun(
    int id, {
    required int rowVersion,
  }) => Result.guard(() => _api.postConsumptionRun(id, rowVersion: rowVersion));

  @override
  Future<Result<ConsumptionRunDetailDto>> reverseRun(
    int id,
    ReverseConsumptionRunRequest request,
  ) => Result.guard(() => _api.reverseConsumptionRun(id, request));

  @override
  Future<Result<ConsumptionVariancePageDto>> variance({
    required DateTime periodFrom,
    required DateTime periodTo,
    int? locationId,
    int? productId,
    Decimal? minAbsVariancePct,
    PageRequest page = const PageRequest(),
  }) => Result.guard(
    () => _api.getVariance(
      periodFrom: periodFrom,
      periodTo: periodTo,
      locationId: locationId,
      productId: productId,
      minAbsVariancePct: minAbsVariancePct,
      page: page,
    ),
  );

  @override
  Future<Result<Page<PortionComplianceLineDto>>> portionCompliance({
    required DateTime periodFrom,
    required DateTime periodTo,
    int? locationId,
    int? menuItemId,
    PageRequest page = const PageRequest(),
  }) => Result.guard(
    () => _api.getPortionCompliance(
      periodFrom: periodFrom,
      periodTo: periodTo,
      locationId: locationId,
      menuItemId: menuItemId,
      page: page,
    ),
  );
}
