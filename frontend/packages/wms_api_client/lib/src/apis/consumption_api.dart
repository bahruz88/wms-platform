import 'dart:convert';
import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:wms_core/wms_core.dart';

import '../dto/consumption/consumption_dtos.dart';
import 'module_api.dart';

/// `/api/v1/consumption/*` — recipes, sales imports, theoretical consumption
/// and variance (`contracts/openapi/consumption.v1.yaml`, ADR-012).
///
/// The flow is three steps: sales come in (`POST /sales-imports`, source
/// `POS`/`CSV`/`MANUAL`), the BOM explosion turns them into ingredient
/// demand (`POST /runs/{id}/calculate`) and the result is posted as an
/// ordinary double-entry document (`POST /runs/{id}/post`).
class ConsumptionApi extends ModuleApi {
  ConsumptionApi(Dio dio) : super(dio, '/consumption');

  /// Largest CSV the server accepts (`422 FILE_TOO_LARGE` above it).
  static const int maxCsvBytes = 5 * 1024 * 1024;

  // --- Menu items -------------------------------------------------------

  /// `GET /consumption/menu-items` — ordered by `name_sort_key`, because the
  /// Azerbaijani alphabet differs from the browser's collation.
  ///
  /// [hasActiveRecipe] `false` lists the items whose sales would deplete
  /// nothing.
  Future<Page<MenuItemDto>> listMenuItems({
    String? search,
    bool? isActive,
    bool? isSubRecipe,
    bool? hasActiveRecipe,
    PageRequest page = const PageRequest(),
    CancelToken? cancelToken,
  }) => getPage(
    'menu-items',
    fromJson: MenuItemDto.fromJson,
    page: page,
    query: {
      'search': search,
      'isActive': isActive,
      'isSubRecipe': isSubRecipe,
      'hasActiveRecipe': hasActiveRecipe,
    },
    cancelToken: cancelToken,
  );

  /// `GET /consumption/menu-items/{id}`
  Future<MenuItemDetailDto> getMenuItem(int id, {CancelToken? cancelToken}) =>
      getObject(
        'menu-items/$id',
        fromJson: MenuItemDetailDto.fromJson,
        cancelToken: cancelToken,
      );

  /// `POST /consumption/menu-items`
  Future<MenuItemDto> createMenuItem(CreateMenuItemRequest body) => postObject(
    'menu-items',
    body: body.toJson(),
    fromJson: MenuItemDto.fromJson,
  );

  /// `PUT /consumption/menu-items/{id}`
  Future<MenuItemDto> updateMenuItem(int id, UpdateMenuItemRequest body) =>
      putObject(
        'menu-items/$id',
        body: body.toJson(),
        fromJson: MenuItemDto.fromJson,
      );

  // --- Recipes ----------------------------------------------------------

  /// `GET /consumption/menu-items/{id}/recipes` — all versions, newest
  /// `validFrom` first. Past calculations stay bound to their own version.
  Future<List<RecipeSummaryDto>> listRecipeVersions(
    int menuItemId, {
    CancelToken? cancelToken,
  }) => getList(
    'menu-items/$menuItemId/recipes',
    fromJson: RecipeSummaryDto.fromJson,
    cancelToken: cancelToken,
  );

  /// `POST /consumption/menu-items/{id}/recipes` — always created `DRAFT`.
  Future<RecipeDto> createRecipeVersion(
    int menuItemId,
    CreateRecipeVersionRequest body,
  ) => postObject(
    'menu-items/$menuItemId/recipes',
    body: body.toJson(),
    fromJson: RecipeDto.fromJson,
  );

  /// `GET /consumption/recipes/{id}`
  Future<RecipeDto> getRecipe(int id, {CancelToken? cancelToken}) => getObject(
    'recipes/$id',
    fromJson: RecipeDto.fromJson,
    cancelToken: cancelToken,
  );

  /// `PUT /consumption/recipes/{id}` — `DRAFT` only, lines replace the old
  /// set. A sub-recipe cycle answers `422 RECIPE_CYCLE`.
  Future<RecipeDto> updateRecipe(int id, UpdateRecipeRequest body) => putObject(
    'recipes/$id',
    body: body.toJson(),
    fromJson: RecipeDto.fromJson,
  );

  /// `POST /consumption/recipes/{id}/activate` — `DRAFT` → `ACTIVE`; the
  /// previous version is closed with `validTo = validFrom − 1 day`.
  /// `validFrom` behind a posted consumption document → `409 PERIOD_CLOSED`.
  Future<RecipeDto> activateRecipe(int id, ActivateRecipeRequest body) =>
      postObject(
        'recipes/$id/activate',
        body: body.toJson(),
        fromJson: RecipeDto.fromJson,
      );

  /// `GET /consumption/recipes/{id}/explosion?portions=&asOfDate=` —
  /// preview of the ingredient demand; nothing leaves stock.
  Future<RecipeExplosionDto> explodeRecipe(
    int id, {
    Quantity? portions,
    DateTime? asOfDate,
    CancelToken? cancelToken,
  }) => getObject(
    'recipes/$id/explosion',
    fromJson: RecipeExplosionDto.fromJson,
    query: {'portions': portions?.toJson(), 'asOfDate': asOfDate},
    cancelToken: cancelToken,
  );

  // --- Sales imports ----------------------------------------------------

  /// `GET /consumption/sales-imports` — a branch user only ever sees their
  /// own locations (server side `iam_user_location` filter).
  Future<Page<SalesImportDto>> listSalesImports({
    int? locationId,
    DateTime? dateFrom,
    DateTime? dateTo,
    SalesImportStatus? status,
    SalesSource? source,
    PageRequest page = const PageRequest(),
    CancelToken? cancelToken,
  }) => getPage(
    'sales-imports',
    fromJson: SalesImportDto.fromJson,
    page: page,
    query: {
      'locationId': locationId,
      'dateFrom': dateFrom,
      'dateTo': dateTo,
      'status': status,
      'source': source,
    },
    cancelToken: cancelToken,
  );

  /// `GET /consumption/sales-imports/{id}`
  Future<SalesImportDetailDto> getSalesImport(
    int id, {
    CancelToken? cancelToken,
  }) => getObject(
    'sales-imports/$id',
    fromJson: SalesImportDetailDto.fromJson,
    cancelToken: cancelToken,
  );

  /// `POST /consumption/sales-imports` — one document per
  /// `(location, businessDate)`; a repeat answers
  /// `409 DUPLICATE_BUSINESS_DATE`.
  Future<SalesImportDto> createSalesImport(CreateSalesImportRequest body) =>
      postObject(
        'sales-imports',
        body: body.toJson(),
        fromJson: SalesImportDto.fromJson,
      );

  /// `PUT /consumption/sales-imports/{id}` — `DRAFT` only.
  Future<SalesImportDetailDto> updateSalesImport(
    int id,
    UpdateSalesImportRequest body,
  ) => putObject(
    'sales-imports/$id',
    body: body.toJson(),
    fromJson: SalesImportDetailDto.fromJson,
  );

  /// `POST /consumption/sales-imports/{id}/submit` — `DRAFT` → `SUBMITTED`.
  /// Unmapped lines do not block the submit; they stay visible in
  /// `unmappedCount`.
  Future<SalesImportDto> submitSalesImport(int id, {required int rowVersion}) =>
      postObject(
        'sales-imports/$id/submit',
        body: ConsumptionVersionedAction(rowVersion: rowVersion).toJson(),
        fromJson: SalesImportDto.fromJson,
      );

  /// `POST /consumption/sales-imports/upload-csv` (`multipart/form-data`).
  ///
  /// [columnMapping] names the CSV headers holding `posCode`, `qtySold` and
  /// `grossAmount`; when empty the server looks for its standard names.
  /// Unreadable rows come back in `parseErrors`, the rest are imported.
  Future<SalesImportParseResultDto> uploadSalesCsv({
    required int locationId,
    required DateTime businessDate,
    required Uint8List bytes,
    required String filename,
    SalesCsvColumnMapping? columnMapping,
    String? externalRef,
    CancelToken? cancelToken,
  }) {
    final mapping = columnMapping?.filled ?? const <String, String>{};
    return postMultipart(
      'sales-imports/upload-csv',
      fromJson: SalesImportParseResultDto.fromJson,
      fields: {
        'locationId': locationId,
        'businessDate': businessDate,
        'externalRef': externalRef,
        'columnMapping': mapping.isEmpty ? null : jsonEncode(mapping),
      },
      files: {
        'file': MultipartFile.fromBytes(
          bytes,
          filename: filename,
          contentType: DioMediaType('text', 'csv'),
        ),
      },
      cancelToken: cancelToken,
    );
  }

  // --- Consumption runs -------------------------------------------------

  /// `GET /consumption/runs` — branch × day.
  Future<Page<ConsumptionRunDto>> listConsumptionRuns({
    int? locationId,
    DateTime? dateFrom,
    DateTime? dateTo,
    ConsumptionRunStatus? status,
    bool? hasShortfall,
    PageRequest page = const PageRequest(),
    CancelToken? cancelToken,
  }) => getPage(
    'runs',
    fromJson: ConsumptionRunDto.fromJson,
    page: page,
    query: {
      'locationId': locationId,
      'dateFrom': dateFrom,
      'dateTo': dateTo,
      'status': status,
      'hasShortfall': hasShortfall,
    },
    cancelToken: cancelToken,
  );

  /// `GET /consumption/runs/{id}` — `unitCost`/`costAmount` only arrive with
  /// `master.product.view_cost`.
  Future<ConsumptionRunDetailDto> getConsumptionRun(
    int id, {
    CancelToken? cancelToken,
  }) => getObject(
    'runs/$id',
    fromJson: ConsumptionRunDetailDto.fromJson,
    cancelToken: cancelToken,
  );

  /// `POST /consumption/runs` — opens the document for a `SUBMITTED` sales
  /// import and calculates it (`DRAFT` → `CALCULATED`).
  Future<ConsumptionRunDetailDto> createConsumptionRun(
    CreateConsumptionRunRequest body,
  ) => postObject(
    'runs',
    body: body.toJson(),
    fromJson: ConsumptionRunDetailDto.fromJson,
  );

  /// `POST /consumption/runs/{id}/calculate` — recalculates a `DRAFT` or
  /// `CALCULATED` document with the recipe version of the sales date.
  Future<ConsumptionRunDetailDto> calculateConsumptionRun(
    int id, {
    required int rowVersion,
  }) => postObject(
    'runs/$id/calculate',
    body: ConsumptionVersionedAction(rowVersion: rowVersion).toJson(),
    fromJson: ConsumptionRunDetailDto.fromJson,
  );

  /// `POST /consumption/runs/{id}/post` — writes the `CONSUMPTION` movement
  /// group (`RESTAURANT −qty` / `V_CONSUMPTION +qty`) in one transaction.
  /// A shortfall does not block the post; it is a warning.
  Future<ConsumptionRunDetailDto> postConsumptionRun(
    int id, {
    required int rowVersion,
  }) => postObject(
    'runs/$id/post',
    body: ConsumptionVersionedAction(rowVersion: rowVersion).toJson(),
    fromJson: ConsumptionRunDetailDto.fromJson,
  );

  /// `POST /consumption/runs/{id}/reverse` — a posted document is never
  /// edited; the correction is a `REVERSAL` group and needs a reason code.
  Future<ConsumptionRunDetailDto> reverseConsumptionRun(
    int id,
    ReverseConsumptionRunRequest body,
  ) => postObject(
    'runs/$id/reverse',
    body: body.toJson(),
    fromJson: ConsumptionRunDetailDto.fromJson,
  );

  // --- Variance ---------------------------------------------------------

  /// `GET /consumption/variance?periodFrom=&periodTo=` — theoretical vs
  /// actual per product and location between two counts. `varianceValue`
  /// only arrives with `master.product.view_cost`.
  Future<ConsumptionVariancePageDto> getVariance({
    required DateTime periodFrom,
    required DateTime periodTo,
    int? locationId,
    int? productId,
    Decimal? minAbsVariancePct,
    PageRequest page = const PageRequest(),
    CancelToken? cancelToken,
  }) => getObject(
    'variance',
    fromJson: ConsumptionVariancePageDto.fromJson,
    query: {
      'periodFrom': periodFrom,
      'periodTo': periodTo,
      'locationId': locationId,
      'productId': productId,
      'minAbsVariancePct': minAbsVariancePct?.toJson(),
      ...page.toQuery(),
    },
    cancelToken: cancelToken,
  );

  /// `GET /consumption/portion-compliance?periodFrom=&periodTo=` —
  /// `compliancePct = recipeQty ÷ actualQty × 100`; below 100 the portion is
  /// larger than the recipe says.
  Future<Page<PortionComplianceLineDto>> getPortionCompliance({
    required DateTime periodFrom,
    required DateTime periodTo,
    int? locationId,
    int? menuItemId,
    PageRequest page = const PageRequest(),
    CancelToken? cancelToken,
  }) => getPage(
    'portion-compliance',
    fromJson: PortionComplianceLineDto.fromJson,
    page: page,
    query: {
      'periodFrom': periodFrom,
      'periodTo': periodTo,
      'locationId': locationId,
      'menuItemId': menuItemId,
    },
    cancelToken: cancelToken,
  );
}
