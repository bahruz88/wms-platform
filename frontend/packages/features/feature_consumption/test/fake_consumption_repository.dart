import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:feature_consumption/feature_consumption.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

/// In-memory [ConsumptionRepository] for widget and use-case tests.
///
/// Calls are recorded so a test can assert *what* was sent, not only what
/// was rendered — the difference between «DRAFT → SUBMITTED» working and
/// merely looking like it worked.
class FakeConsumptionRepository implements ConsumptionRepository {
  FakeConsumptionRepository({
    this.menuItemRows = const [],
    this.recipeVersionRows = const [],
    this.recipeRows = const [],
    this.explosion,
    this.salesImportRows = const [],
    this.salesImportDetails = const [],
    this.runRows = const [],
    this.runDetails = const [],
    this.variancePage,
    this.complianceRows = const [],
    this.parseResult,
    this.failure,
    this.submitFailure,
  });

  final List<MenuItemDto> menuItemRows;
  final List<RecipeSummaryDto> recipeVersionRows;
  final List<RecipeDto> recipeRows;
  final RecipeExplosionDto? explosion;
  final List<SalesImportDto> salesImportRows;
  final List<SalesImportDetailDto> salesImportDetails;
  final List<ConsumptionRunDto> runRows;
  final List<ConsumptionRunDetailDto> runDetails;
  final ConsumptionVariancePageDto? variancePage;
  final List<PortionComplianceLineDto> complianceRows;
  final SalesImportParseResultDto? parseResult;

  /// Applied to every call.
  final Failure? failure;

  /// Applied to [submitSalesImport] only.
  final Failure? submitFailure;

  final List<CreateSalesImportRequest> createdImports = [];
  final List<UpdateSalesImportRequest> updatedImports = [];
  final List<int> submitted = [];
  final List<UpdateRecipeRequest> savedRecipes = [];
  final List<ActivateRecipeRequest> activations = [];
  final List<ReverseConsumptionRunRequest> reversals = [];
  final List<int> posted = [];
  final List<int> calculated = [];
  final List<UpdateMenuItemRequest> menuItemUpdates = [];

  Result<T> _ok<T>(T value) =>
      failure == null ? Result<T>.ok(value) : Result<T>.err(failure!);

  Page<T> _page<T>(List<T> items) =>
      Page<T>(items: items, page: 1, size: 50, total: items.length);

  ConsumptionRunDetailDto _runDetail(int id) => runDetails.firstWhere(
    (r) => r.id == id,
    orElse: () => runDetails.isEmpty
        ? ConsumptionRunDetailDto(
            id: id,
            docNo: 'CN-2026-00000',
            locationId: 1,
            businessDate: DateTime(2026, 9, 20),
            status: ConsumptionRunStatus.calculated,
            rowVersion: 1,
          )
        : runDetails.first,
  );

  @override
  Future<Result<Page<MenuItemDto>>> menuItems({
    String? search,
    bool? isActive,
    bool? isSubRecipe,
    bool? hasActiveRecipe,
    PageRequest page = const PageRequest(),
  }) async => _ok(
    _page([
      for (final item in menuItemRows)
        if (isSubRecipe == null || item.isSubRecipe == isSubRecipe)
          if (hasActiveRecipe == null ||
              item.hasActiveRecipe == hasActiveRecipe)
            item,
    ]),
  );

  @override
  Future<Result<MenuItemDetailDto>> menuItem(int id) async {
    final item = menuItemRows.firstWhere((m) => m.id == id);
    return _ok(
      MenuItemDetailDto(
        id: item.id,
        code: item.code,
        name: item.name,
        isSubRecipe: item.isSubRecipe,
        isActive: item.isActive,
        posCode: item.posCode,
        category: item.category,
        activeRecipeId: item.activeRecipeId,
        rowVersion: item.rowVersion,
      ),
    );
  }

  @override
  Future<Result<MenuItemDto>> createMenuItem(
    CreateMenuItemRequest request,
  ) async => _ok(MenuItemDto(id: 999, code: request.code, name: request.name));

  @override
  Future<Result<MenuItemDto>> updateMenuItem(
    int id,
    UpdateMenuItemRequest request,
  ) async {
    menuItemUpdates.add(request);
    return _ok(
      MenuItemDto(
        id: id,
        code: request.code,
        name: request.name,
        posCode: request.posCode,
        rowVersion: request.rowVersion + 1,
      ),
    );
  }

  @override
  Future<Result<List<RecipeSummaryDto>>> recipeVersions(int menuItemId) async =>
      _ok(recipeVersionRows);

  @override
  Future<Result<RecipeDto>> recipe(int id) async =>
      _ok(recipeRows.firstWhere((r) => r.id == id));

  @override
  Future<Result<RecipeDto>> createRecipeVersion(
    int menuItemId,
    CreateRecipeVersionRequest request,
  ) async => _ok(
    RecipeDto(
      id: 900,
      menuItemId: menuItemId,
      versionNo: 2,
      status: RecipeStatus.draft,
      validFrom: request.validFrom,
      yieldPortions: Quantity.fromInt(1),
      rowVersion: 1,
    ),
  );

  @override
  Future<Result<RecipeDto>> updateRecipe(
    int id,
    UpdateRecipeRequest request,
  ) async {
    savedRecipes.add(request);
    final current = recipeRows.firstWhere((r) => r.id == id);
    return _ok(current.copyWith(rowVersion: current.rowVersion + 1));
  }

  @override
  Future<Result<RecipeDto>> activateRecipe(
    int id,
    ActivateRecipeRequest request,
  ) async {
    activations.add(request);
    final current = recipeRows.firstWhere((r) => r.id == id);
    return _ok(
      current.copyWith(
        status: RecipeStatus.active,
        validFrom: request.validFrom,
        rowVersion: current.rowVersion + 1,
      ),
    );
  }

  @override
  Future<Result<RecipeExplosionDto>> explodeRecipe(
    int id, {
    Quantity? portions,
    DateTime? asOfDate,
  }) async => _ok(
    explosion ??
        RecipeExplosionDto(
          recipeId: id,
          portions: portions ?? Quantity.fromInt(1),
        ),
  );

  @override
  Future<Result<Page<SalesImportDto>>> salesImports({
    int? locationId,
    DateTime? dateFrom,
    DateTime? dateTo,
    SalesImportStatus? status,
    SalesSource? source,
    PageRequest page = const PageRequest(),
  }) async => _ok(_page(salesImportRows));

  @override
  Future<Result<SalesImportDetailDto>> salesImport(int id) async =>
      _ok(salesImportDetails.firstWhere((s) => s.id == id));

  @override
  Future<Result<SalesImportDto>> createSalesImport(
    CreateSalesImportRequest request,
  ) async {
    createdImports.add(request);
    return _ok(
      SalesImportDto(
        id: 501,
        locationId: request.locationId,
        businessDate: request.businessDate,
        source: request.source,
        status: SalesImportStatus.draft,
        rowVersion: 1,
        lineCount: request.lines.length,
      ),
    );
  }

  @override
  Future<Result<SalesImportDetailDto>> updateSalesImport(
    int id,
    UpdateSalesImportRequest request,
  ) async {
    updatedImports.add(request);
    return _ok(
      SalesImportDetailDto(
        id: id,
        locationId: 1,
        businessDate: DateTime(2026, 9, 21),
        source: SalesSource.manual,
        status: SalesImportStatus.draft,
        rowVersion: request.rowVersion + 1,
        lineCount: request.lines.length,
      ),
    );
  }

  @override
  Future<Result<SalesImportDto>> submitSalesImport(
    int id, {
    required int rowVersion,
  }) async {
    submitted.add(id);
    if (submitFailure != null) {
      return Result<SalesImportDto>.err(submitFailure!);
    }
    return _ok(
      SalesImportDto(
        id: id,
        locationId: 1,
        businessDate: DateTime(2026, 9, 21),
        source: SalesSource.manual,
        status: SalesImportStatus.submitted,
        rowVersion: rowVersion + 1,
      ),
    );
  }

  @override
  Future<Result<SalesImportParseResultDto>> uploadSalesCsv({
    required int locationId,
    required DateTime businessDate,
    required Uint8List bytes,
    required String filename,
    SalesCsvColumnMapping? columnMapping,
    String? externalRef,
  }) async => _ok(
    parseResult ??
        SalesImportParseResultDto(
          salesImport: SalesImportDetailDto(
            id: 1,
            locationId: locationId,
            businessDate: businessDate,
            source: SalesSource.csv,
            status: SalesImportStatus.draft,
            rowVersion: 1,
          ),
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
  }) async => _ok(_page(runRows));

  @override
  Future<Result<ConsumptionRunDetailDto>> run(int id) async =>
      _ok(_runDetail(id));

  @override
  Future<Result<ConsumptionRunDetailDto>> createRun(
    CreateConsumptionRunRequest request,
  ) async => _ok(_runDetail(1));

  @override
  Future<Result<ConsumptionRunDetailDto>> calculateRun(
    int id, {
    required int rowVersion,
  }) async {
    calculated.add(id);
    return _ok(_runDetail(id));
  }

  @override
  Future<Result<ConsumptionRunDetailDto>> postRun(
    int id, {
    required int rowVersion,
  }) async {
    posted.add(id);
    return _ok(_runDetail(id).copyWith(status: ConsumptionRunStatus.posted));
  }

  @override
  Future<Result<ConsumptionRunDetailDto>> reverseRun(
    int id,
    ReverseConsumptionRunRequest request,
  ) async {
    reversals.add(request);
    return _ok(_runDetail(id).copyWith(status: ConsumptionRunStatus.reversed));
  }

  @override
  Future<Result<ConsumptionVariancePageDto>> variance({
    required DateTime periodFrom,
    required DateTime periodTo,
    int? locationId,
    int? productId,
    Decimal? minAbsVariancePct,
    PageRequest page = const PageRequest(),
  }) async => _ok(
    variancePage ??
        ConsumptionVariancePageDto(periodFrom: periodFrom, periodTo: periodTo),
  );

  @override
  Future<Result<Page<PortionComplianceLineDto>>> portionCompliance({
    required DateTime periodFrom,
    required DateTime periodTo,
    int? locationId,
    int? menuItemId,
    PageRequest page = const PageRequest(),
  }) async => _ok(_page(complianceRows));
}
