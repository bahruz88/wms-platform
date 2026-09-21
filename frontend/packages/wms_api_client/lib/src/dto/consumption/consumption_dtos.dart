/// DTOs of `contracts/openapi/consumption.v1.yaml` (ADR-012).
///
/// Every quantity is a [Quantity] and every amount a [Money] — both are
/// `Decimal` backed and travel as JSON strings, never as `double`.
///
/// Cost fields (`unitCost`, `costAmount`, `totalCostAmount`, `varianceValue`)
/// are **nullable on purpose**: without `master.product.view_cost` the server
/// omits the key entirely (SPEC §16), it does not mask it.
library;

import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wms_core/wms_core.dart';

import '../../json/date_only_converter.dart';

part 'consumption_dtos.freezed.dart';
part 'consumption_dtos.g.dart';

/// 100 % — the neutral yield / attach rate used when the server omits one.
final Decimal _hundred = Decimal.fromInt(100);

// ---------------------------------------------------------------------------
// Menu items
// ---------------------------------------------------------------------------

/// `cons_menu_item` — the thing that is sold. Not a product: products are the
/// ingredients it explodes into.
@freezed
abstract class MenuItemDto with _$MenuItemDto {
  const factory MenuItemDto({
    required int id,
    required String code,
    required String name,
    @Default(false) bool isSubRecipe,
    @Default(true) bool isActive,
    String? posCode,
    String? category,

    /// Recipe version valid today. `null` — no recipe, so a sale of this item
    /// produces no depletion and lands in `unmappedCount`.
    int? activeRecipeId,
    @Default(1) int rowVersion,
  }) = _MenuItemDto;

  const MenuItemDto._();

  factory MenuItemDto.fromJson(Map<String, Object?> json) =>
      _$MenuItemDtoFromJson(json);

  /// Sales of an item without an active recipe deplete nothing.
  bool get hasActiveRecipe => activeRecipeId != null;
}

/// `GET /menu-items/{id}` — the item plus its version history summary.
@freezed
abstract class MenuItemDetailDto with _$MenuItemDetailDto {
  const factory MenuItemDetailDto({
    required int id,
    required String code,
    required String name,
    @Default(false) bool isSubRecipe,
    @Default(true) bool isActive,
    String? posCode,
    String? category,
    int? activeRecipeId,
    @Default(1) int rowVersion,
    @Default(0) int recipeVersionCount,

    /// Recipes this sub-recipe is a component of.
    @Default(<RecipeSummaryDto>[]) List<RecipeSummaryDto> usedInRecipes,
  }) = _MenuItemDetailDto;

  const MenuItemDetailDto._();

  factory MenuItemDetailDto.fromJson(Map<String, Object?> json) =>
      _$MenuItemDetailDtoFromJson(json);

  bool get hasActiveRecipe => activeRecipeId != null;
}

/// `POST /menu-items` body.
@freezed
abstract class CreateMenuItemRequest with _$CreateMenuItemRequest {
  const factory CreateMenuItemRequest({
    required String code,
    required String name,
    String? posCode,
    String? category,
    @Default(false) bool isSubRecipe,
  }) = _CreateMenuItemRequest;

  factory CreateMenuItemRequest.fromJson(Map<String, Object?> json) =>
      _$CreateMenuItemRequestFromJson(json);
}

/// `PUT /menu-items/{id}` body — `409 STALE_VERSION` on a row version clash.
@freezed
abstract class UpdateMenuItemRequest with _$UpdateMenuItemRequest {
  const factory UpdateMenuItemRequest({
    required String code,
    required String name,
    required int rowVersion,
    String? posCode,
    String? category,
    @Default(false) bool isSubRecipe,
    @Default(true) bool isActive,
  }) = _UpdateMenuItemRequest;

  factory UpdateMenuItemRequest.fromJson(Map<String, Object?> json) =>
      _$UpdateMenuItemRequestFromJson(json);
}

// ---------------------------------------------------------------------------
// Recipes
// ---------------------------------------------------------------------------

/// One `cons_recipe_line` as returned by the server.
@freezed
abstract class RecipeLineDto with _$RecipeLineDto {
  const factory RecipeLineDto({
    required int lineNo,
    required ComponentType componentType,
    required Quantity qtyPerPortion,
    required int uomId,
    required Decimal yieldPct,
    int? productId,
    String? productSku,
    String? productName,
    int? subMenuItemId,
    String? subMenuItemName,
    String? uomCode,
    @Default(false) bool isOptional,
    Decimal? attachRatePct,
    String? note,
  }) = _RecipeLineDto;

  const RecipeLineDto._();

  factory RecipeLineDto.fromJson(Map<String, Object?> json) =>
      _$RecipeLineDtoFromJson(json);

  /// `attachRatePct` is ignored unless the component is optional.
  Decimal get effectiveAttachRatePct =>
      isOptional ? (attachRatePct ?? _hundred) : _hundred;

  /// Display name of whichever component this line points at.
  String get componentLabel => switch (componentType) {
    ComponentType.foodProduct => productName ?? 'Məhsul #$productId',
    ComponentType.subRecipe => subMenuItemName ?? 'Alt-resept #$subMenuItemId',
  };

  /// A line is complete when the component matching its type is set.
  bool get isComplete =>
      componentType.requiresProduct ? productId != null : subMenuItemId != null;
}

/// Line payload of `POST /menu-items/{id}/recipes` and `PUT /recipes/{id}`.
@freezed
abstract class RecipeLineInput with _$RecipeLineInput {
  const factory RecipeLineInput({
    required int lineNo,
    required ComponentType componentType,
    required Quantity qtyPerPortion,
    required int uomId,

    /// Mandatory when `componentType = FOOD_PRODUCT`.
    int? productId,

    /// Mandatory when `componentType = SUB_RECIPE`; must be a menu item with
    /// `isSubRecipe = true`.
    int? subMenuItemId,

    /// Processing loss. Lettuce trimmed by 8 % → `92`; the stock figure
    /// becomes `qtyPerPortion ÷ (yieldPct ÷ 100)`. Defaults to 100.
    Decimal? yieldPct,
    @Default(false) bool isOptional,

    /// Share of orders that actually take an optional component.
    Decimal? attachRatePct,
    String? note,
  }) = _RecipeLineInput;

  const RecipeLineInput._();

  factory RecipeLineInput.fromJson(Map<String, Object?> json) =>
      _$RecipeLineInputFromJson(json);

  factory RecipeLineInput.fromLine(RecipeLineDto line) => RecipeLineInput(
    lineNo: line.lineNo,
    componentType: line.componentType,
    qtyPerPortion: line.qtyPerPortion,
    uomId: line.uomId,
    productId: line.productId,
    subMenuItemId: line.subMenuItemId,
    yieldPct: line.yieldPct,
    isOptional: line.isOptional,
    attachRatePct: line.attachRatePct,
    note: line.note,
  );

  Decimal get effectiveYieldPct => yieldPct ?? _hundred;

  Decimal get effectiveAttachRatePct =>
      isOptional ? (attachRatePct ?? _hundred) : _hundred;

  bool get isComplete =>
      componentType.requiresProduct ? productId != null : subMenuItemId != null;
}

/// Header of a recipe version (`GET /menu-items/{id}/recipes`).
@freezed
abstract class RecipeSummaryDto with _$RecipeSummaryDto {
  const factory RecipeSummaryDto({
    required int id,
    required int menuItemId,
    required int versionNo,
    required RecipeStatus status,
    @DateOnlyConverter() required DateTime validFrom,
    String? menuItemName,
    @NullableDateOnlyConverter() DateTime? validTo,
    @Default(0) int lineCount,
  }) = _RecipeSummaryDto;

  const RecipeSummaryDto._();

  factory RecipeSummaryDto.fromJson(Map<String, Object?> json) =>
      _$RecipeSummaryDtoFromJson(json);

  /// An empty version cannot be activated → `422 RECIPE_EMPTY`.
  bool get isEmpty => lineCount == 0;
}

/// Full recipe version with its component lines.
@freezed
abstract class RecipeDto with _$RecipeDto {
  const factory RecipeDto({
    required int id,
    required int menuItemId,
    required int versionNo,
    required RecipeStatus status,
    @DateOnlyConverter() required DateTime validFrom,
    required Quantity yieldPortions,
    required int rowVersion,
    String? menuItemName,
    @NullableDateOnlyConverter() DateTime? validTo,
    @Default(0) int lineCount,
    String? note,
    @Default(<RecipeLineDto>[]) List<RecipeLineDto> lines,
  }) = _RecipeDto;

  const RecipeDto._();

  factory RecipeDto.fromJson(Map<String, Object?> json) =>
      _$RecipeDtoFromJson(json);

  /// Only a `DRAFT` version accepts `PUT`.
  bool get isEditable => status.isEditable;

  /// `422 RECIPE_EMPTY` guard, checked client side before the call.
  bool get canActivate => status.canActivate && lines.isNotEmpty;

  bool get hasSubRecipes =>
      lines.any((l) => l.componentType == ComponentType.subRecipe);
}

/// `POST /menu-items/{id}/recipes` body — the version is created `DRAFT`.
@freezed
abstract class CreateRecipeVersionRequest with _$CreateRecipeVersionRequest {
  const factory CreateRecipeVersionRequest({
    @DateOnlyConverter() required DateTime validFrom,

    /// Portions produced by one preparation; sauces and other sub-recipes
    /// yield more than one. Defaults to 1.
    Quantity? yieldPortions,

    /// Copies the component lines of an existing version.
    int? copyFromRecipeId,
    String? note,
    @Default(<RecipeLineInput>[]) List<RecipeLineInput> lines,
  }) = _CreateRecipeVersionRequest;

  factory CreateRecipeVersionRequest.fromJson(Map<String, Object?> json) =>
      _$CreateRecipeVersionRequestFromJson(json);
}

/// `PUT /recipes/{id}` body — lines are sent whole (replace semantics).
@freezed
abstract class UpdateRecipeRequest with _$UpdateRecipeRequest {
  const factory UpdateRecipeRequest({
    required int rowVersion,
    required List<RecipeLineInput> lines,
    Quantity? yieldPortions,
    String? note,
  }) = _UpdateRecipeRequest;

  factory UpdateRecipeRequest.fromJson(Map<String, Object?> json) =>
      _$UpdateRecipeRequestFromJson(json);
}

/// `POST /recipes/{id}/activate` body.
@freezed
abstract class ActivateRecipeRequest with _$ActivateRecipeRequest {
  const factory ActivateRecipeRequest({
    @DateOnlyConverter() required DateTime validFrom,
    required int rowVersion,
  }) = _ActivateRecipeRequest;

  factory ActivateRecipeRequest.fromJson(Map<String, Object?> json) =>
      _$ActivateRecipeRequestFromJson(json);
}

/// One ingredient requirement produced by the BOM explosion.
@freezed
abstract class RecipeExplosionLineDto with _$RecipeExplosionLineDto {
  const factory RecipeExplosionLineDto({
    required int productId,
    required Quantity requiredQtyBase,
    required int baseUomId,
    required String baseUomCode,
    String? productSku,
    String? productName,

    /// Set when the ingredient arrived through a sub-recipe.
    String? viaSubRecipe,
    @Default(0) int depth,
  }) = _RecipeExplosionLineDto;

  const RecipeExplosionLineDto._();

  factory RecipeExplosionLineDto.fromJson(Map<String, Object?> json) =>
      _$RecipeExplosionLineDtoFromJson(json);

  bool get isNested => depth > 0;
}

/// `GET /recipes/{id}/explosion?portions=` — preview only, nothing leaves
/// stock. Formula: `base = portions × qtyPerPortion × factor ÷ (yield ÷ 100)`.
@freezed
abstract class RecipeExplosionDto with _$RecipeExplosionDto {
  const factory RecipeExplosionDto({
    required int recipeId,
    required Quantity portions,
    @Default(<RecipeExplosionLineDto>[]) List<RecipeExplosionLineDto> lines,
    String? menuItemName,
    @Default(0) int maxDepth,
  }) = _RecipeExplosionDto;

  const RecipeExplosionDto._();

  factory RecipeExplosionDto.fromJson(Map<String, Object?> json) =>
      _$RecipeExplosionDtoFromJson(json);

  bool get isEmpty => lines.isEmpty;
}

// ---------------------------------------------------------------------------
// Sales imports
// ---------------------------------------------------------------------------

/// One `cons_sales_line`.
@freezed
abstract class SalesLineDto with _$SalesLineDto {
  const factory SalesLineDto({
    required Quantity qtySold,
    int? id,
    int? menuItemId,
    String? menuItemName,

    /// POS code kept verbatim when nothing matched it.
    String? rawPosCode,
    @Default(true) bool isMapped,

    /// `false` — the item is known but has no recipe, so it depletes nothing.
    @Default(true) bool hasRecipe,
    Money? grossAmount,
  }) = _SalesLineDto;

  const SalesLineDto._();

  factory SalesLineDto.fromJson(Map<String, Object?> json) =>
      _$SalesLineDtoFromJson(json);

  /// Counts towards `unmappedCount`: unknown POS code or no recipe.
  bool get producesNoConsumption => !isMapped || !hasRecipe;

  String get label =>
      menuItemName ?? rawPosCode ?? (menuItemId == null ? '' : '#$menuItemId');
}

/// Line payload of `POST /sales-imports` and `PUT /sales-imports/{id}`.
@freezed
abstract class SalesLineInput with _$SalesLineInput {
  const factory SalesLineInput({
    required Quantity qtySold,

    /// Required unless [posCode] is given.
    int? menuItemId,

    /// Stored as `rawPosCode` when unknown — never dropped silently.
    String? posCode,
    Money? grossAmount,
  }) = _SalesLineInput;

  factory SalesLineInput.fromJson(Map<String, Object?> json) =>
      _$SalesLineInputFromJson(json);
}

/// Header of `cons_sales_import`.
@freezed
abstract class SalesImportDto with _$SalesImportDto {
  const factory SalesImportDto({
    required int id,
    required int locationId,
    @DateOnlyConverter() required DateTime businessDate,
    required SalesSource source,
    required SalesImportStatus status,
    required int rowVersion,
    String? locationName,
    String? externalRef,
    @Default(0) int lineCount,

    /// Unknown POS codes plus known items without a recipe.
    @Default(0) int unmappedCount,
    Money? grossAmount,
    DateTime? importedAt,
    int? consumptionRunId,
  }) = _SalesImportDto;

  const SalesImportDto._();

  factory SalesImportDto.fromJson(Map<String, Object?> json) =>
      _$SalesImportDtoFromJson(json);

  bool get hasUnmapped => unmappedCount > 0;
}

/// `GET /sales-imports/{id}` — header plus every line, unmapped included.
@freezed
abstract class SalesImportDetailDto with _$SalesImportDetailDto {
  const factory SalesImportDetailDto({
    required int id,
    required int locationId,
    @DateOnlyConverter() required DateTime businessDate,
    required SalesSource source,
    required SalesImportStatus status,
    required int rowVersion,
    String? locationName,
    String? externalRef,
    @Default(0) int lineCount,
    @Default(0) int unmappedCount,
    Money? grossAmount,
    DateTime? importedAt,
    int? consumptionRunId,
    @Default(<SalesLineDto>[]) List<SalesLineDto> lines,
  }) = _SalesImportDetailDto;

  const SalesImportDetailDto._();

  factory SalesImportDetailDto.fromJson(Map<String, Object?> json) =>
      _$SalesImportDetailDtoFromJson(json);

  bool get hasUnmapped => unmappedCount > 0;

  /// Distinct POS codes that matched no menu item — the mapping worklist.
  List<String> get unmappedPosCodes => [
    for (final line in lines)
      if (!line.isMapped && line.rawPosCode != null) line.rawPosCode!,
  ];

  /// Total units sold across every line.
  Quantity get totalQtySold =>
      lines.fold(Quantity.zero, (sum, l) => sum + l.qtySold);
}

/// `POST /sales-imports` body. One document per `(location, businessDate)` —
/// a repeat call answers `409 DUPLICATE_BUSINESS_DATE`.
@freezed
abstract class CreateSalesImportRequest with _$CreateSalesImportRequest {
  const factory CreateSalesImportRequest({
    required int locationId,
    @DateOnlyConverter() required DateTime businessDate,
    required SalesSource source,
    required List<SalesLineInput> lines,

    /// POS batch or shift number.
    String? externalRef,
  }) = _CreateSalesImportRequest;

  factory CreateSalesImportRequest.fromJson(Map<String, Object?> json) =>
      _$CreateSalesImportRequestFromJson(json);
}

/// `PUT /sales-imports/{id}` body — `DRAFT` only, lines replace the old set.
@freezed
abstract class UpdateSalesImportRequest with _$UpdateSalesImportRequest {
  const factory UpdateSalesImportRequest({
    required int rowVersion,
    required List<SalesLineInput> lines,
  }) = _UpdateSalesImportRequest;

  factory UpdateSalesImportRequest.fromJson(Map<String, Object?> json) =>
      _$UpdateSalesImportRequestFromJson(json);
}

/// One unreadable CSV row; the remaining rows are still imported.
@freezed
abstract class SalesParseErrorDto with _$SalesParseErrorDto {
  const factory SalesParseErrorDto({
    required int rowNumber,
    required String message,
    String? rawLine,
  }) = _SalesParseErrorDto;

  factory SalesParseErrorDto.fromJson(Map<String, Object?> json) =>
      _$SalesParseErrorDtoFromJson(json);
}

/// `POST /sales-imports/upload-csv` response.
@freezed
abstract class SalesImportParseResultDto with _$SalesImportParseResultDto {
  const factory SalesImportParseResultDto({
    required SalesImportDetailDto salesImport,
    @Default(0) int parsedRows,
    @Default(<SalesParseErrorDto>[]) List<SalesParseErrorDto> parseErrors,
  }) = _SalesImportParseResultDto;

  const SalesImportParseResultDto._();

  factory SalesImportParseResultDto.fromJson(Map<String, Object?> json) =>
      _$SalesImportParseResultDtoFromJson(json);

  bool get hasParseErrors => parseErrors.isNotEmpty;
}

/// Column mapping of the CSV upload: which header holds which field.
@freezed
abstract class SalesCsvColumnMapping with _$SalesCsvColumnMapping {
  const factory SalesCsvColumnMapping({
    String? posCode,
    String? qtySold,
    String? grossAmount,
  }) = _SalesCsvColumnMapping;

  const SalesCsvColumnMapping._();

  factory SalesCsvColumnMapping.fromJson(Map<String, Object?> json) =>
      _$SalesCsvColumnMappingFromJson(json);

  bool get isEmpty =>
      (posCode ?? '').isEmpty &&
      (qtySold ?? '').isEmpty &&
      (grossAmount ?? '').isEmpty;

  /// Only the columns the user actually mapped; the server falls back to its
  /// standard header names for the rest.
  Map<String, String> get filled => {
    if ((posCode ?? '').isNotEmpty) 'posCode': posCode!,
    if ((qtySold ?? '').isNotEmpty) 'qtySold': qtySold!,
    if ((grossAmount ?? '').isNotEmpty) 'grossAmount': grossAmount!,
  };
}

// ---------------------------------------------------------------------------
// Consumption runs
// ---------------------------------------------------------------------------

/// `cons_run_line` — one product of one day's theoretical usage.
@freezed
abstract class ConsumptionRunLineDto with _$ConsumptionRunLineDto {
  const factory ConsumptionRunLineDto({
    required int productId,
    required Quantity theoreticalQtyBase,
    required Quantity postedQtyBase,
    required Quantity shortfallQtyBase,
    required int baseUomId,
    String? productSku,
    String? productName,
    String? baseUomCode,

    /// Absent without `master.product.view_cost` (SPEC §16).
    Money? unitCost,
    Money? costAmount,
  }) = _ConsumptionRunLineDto;

  const ConsumptionRunLineDto._();

  factory ConsumptionRunLineDto.fromJson(Map<String, Object?> json) =>
      _$ConsumptionRunLineDtoFromJson(json);

  /// Stock ran out: the missing part could not be taken off the balance.
  /// A warning, never an error — most often an unrecorded goods receipt.
  bool get hasShortfall => shortfallQtyBase.isPositive;

  bool get hasCostInfo => unitCost != null || costAmount != null;

  String get label => productName ?? 'Məhsul #$productId';
}

/// Header of `cons_run` (`CN-2026-00042`).
@freezed
abstract class ConsumptionRunDto with _$ConsumptionRunDto {
  const factory ConsumptionRunDto({
    required int id,
    required String docNo,
    required int locationId,
    @DateOnlyConverter() required DateTime businessDate,
    required ConsumptionRunStatus status,
    required int rowVersion,
    String? locationName,
    int? salesImportId,
    int? movementGroupId,
    @Default(0) int shortfallCount,
    @Default(0) int unmappedCount,
    String? failureReason,
    DateTime? calculatedAt,
    DateTime? postedAt,
  }) = _ConsumptionRunDto;

  const ConsumptionRunDto._();

  factory ConsumptionRunDto.fromJson(Map<String, Object?> json) =>
      _$ConsumptionRunDtoFromJson(json);

  bool get hasShortfall => shortfallCount > 0;

  bool get hasUnmapped => unmappedCount > 0;
}

/// `GET /runs/{id}` — header plus per product lines.
@freezed
abstract class ConsumptionRunDetailDto with _$ConsumptionRunDetailDto {
  const factory ConsumptionRunDetailDto({
    required int id,
    required String docNo,
    required int locationId,
    @DateOnlyConverter() required DateTime businessDate,
    required ConsumptionRunStatus status,
    required int rowVersion,
    String? locationName,
    int? salesImportId,
    int? movementGroupId,
    @Default(0) int shortfallCount,
    @Default(0) int unmappedCount,
    String? failureReason,
    DateTime? calculatedAt,
    DateTime? postedAt,
    @Default(<ConsumptionRunLineDto>[]) List<ConsumptionRunLineDto> lines,

    /// Bound to `master.product.view_cost`.
    Money? totalCostAmount,
  }) = _ConsumptionRunDetailDto;

  const ConsumptionRunDetailDto._();

  factory ConsumptionRunDetailDto.fromJson(Map<String, Object?> json) =>
      _$ConsumptionRunDetailDtoFromJson(json);

  bool get hasShortfall => shortfallCount > 0;

  bool get hasUnmapped => unmappedCount > 0;

  /// Lines whose theoretical usage could not be taken off the balance.
  List<ConsumptionRunLineDto> get shortfallLines =>
      lines.where((l) => l.hasShortfall).toList();

  Quantity get totalTheoreticalQtyBase =>
      lines.fold(Quantity.zero, (sum, l) => sum + l.theoreticalQtyBase);

  Quantity get totalPostedQtyBase =>
      lines.fold(Quantity.zero, (sum, l) => sum + l.postedQtyBase);

  Quantity get totalShortfallQtyBase =>
      lines.fold(Quantity.zero, (sum, l) => sum + l.shortfallQtyBase);

  bool get hasCostInfo =>
      totalCostAmount != null || lines.any((l) => l.hasCostInfo);
}

/// `POST /runs` body — opens the document and calculates it at once.
@freezed
abstract class CreateConsumptionRunRequest with _$CreateConsumptionRunRequest {
  const factory CreateConsumptionRunRequest({
    required int salesImportId,

    /// Posts straight after the calculation; needs `cons.run.post`.
    @Default(false) bool postImmediately,
  }) = _CreateConsumptionRunRequest;

  factory CreateConsumptionRunRequest.fromJson(Map<String, Object?> json) =>
      _$CreateConsumptionRunRequestFromJson(json);
}

/// `VersionedAction` body of submit / calculate / post.
@freezed
abstract class ConsumptionVersionedAction with _$ConsumptionVersionedAction {
  const factory ConsumptionVersionedAction({required int rowVersion}) =
      _ConsumptionVersionedAction;

  factory ConsumptionVersionedAction.fromJson(Map<String, Object?> json) =>
      _$ConsumptionVersionedActionFromJson(json);
}

/// `ReasonedAction` body of `POST /runs/{id}/reverse`. The reason code is
/// mandatory (SPEC §12.6) — a reversal without a reason is not a correction.
@freezed
abstract class ReverseConsumptionRunRequest
    with _$ReverseConsumptionRunRequest {
  const factory ReverseConsumptionRunRequest({
    required int reasonCodeId,
    String? note,
  }) = _ReverseConsumptionRunRequest;

  factory ReverseConsumptionRunRequest.fromJson(Map<String, Object?> json) =>
      _$ReverseConsumptionRunRequestFromJson(json);
}

// ---------------------------------------------------------------------------
// Variance / portion compliance
// ---------------------------------------------------------------------------

/// One product × location row of the theoretical vs actual report.
///
/// `expected = opening + received − theoretical − waste − sample ± transfer`
/// and `variance = counted − expected`.
@freezed
abstract class ConsumptionVarianceLineDto with _$ConsumptionVarianceLineDto {
  const factory ConsumptionVarianceLineDto({
    required int productId,
    required int locationId,
    required Quantity openingQty,
    required Quantity receivedQty,
    required Quantity theoreticalConsumedQty,
    required Quantity wasteQty,
    required Quantity expectedQty,
    required Quantity countedQty,
    required Quantity varianceQty,
    String? productSku,
    String? productName,
    String? locationName,
    String? baseUomCode,
    Quantity? sampleQty,

    /// Signed net effect of inter-branch transfers.
    Quantity? transferNetQty,
    Decimal? variancePct,

    /// Bound to `master.product.view_cost`.
    Money? varianceValue,
  }) = _ConsumptionVarianceLineDto;

  const ConsumptionVarianceLineDto._();

  factory ConsumptionVarianceLineDto.fromJson(Map<String, Object?> json) =>
      _$ConsumptionVarianceLineDtoFromJson(json);

  /// Less stock than expected: oversized portions, unrecorded waste or loss.
  bool get isShort => varianceQty.isNegative;

  bool get isZero => varianceQty.isZero;

  String get label => productName ?? 'Məhsul #$productId';
}

/// `GET /variance` response — a page that also states the period it covers.
@freezed
abstract class ConsumptionVariancePageDto with _$ConsumptionVariancePageDto {
  const factory ConsumptionVariancePageDto({
    @DateOnlyConverter() required DateTime periodFrom,
    @DateOnlyConverter() required DateTime periodTo,
    @Default(<ConsumptionVarianceLineDto>[])
    List<ConsumptionVarianceLineDto> items,
    @Default(1) int page,
    @Default(50) int size,
    @Default(0) int total,
  }) = _ConsumptionVariancePageDto;

  const ConsumptionVariancePageDto._();

  factory ConsumptionVariancePageDto.fromJson(Map<String, Object?> json) =>
      _$ConsumptionVariancePageDtoFromJson(json);

  bool get isEmpty => items.isEmpty;
}

/// Per menu item: recipe quantity against the actual usage derived from the
/// variance report. `compliancePct < 100` — portions run over the standard.
@freezed
abstract class PortionComplianceLineDto with _$PortionComplianceLineDto {
  const factory PortionComplianceLineDto({
    required int menuItemId,
    required int productId,
    required Quantity portionsSold,
    required Quantity recipeQtyPerPortion,
    required Quantity actualQtyPerPortion,
    required Decimal compliancePct,
    String? menuItemName,
    String? productName,
    String? baseUomCode,
  }) = _PortionComplianceLineDto;

  const PortionComplianceLineDto._();

  factory PortionComplianceLineDto.fromJson(Map<String, Object?> json) =>
      _$PortionComplianceLineDtoFromJson(json);

  /// Below 100 % the branch puts more into the portion than the recipe says.
  bool get isOverPortioned => compliancePct < _hundred;
}
