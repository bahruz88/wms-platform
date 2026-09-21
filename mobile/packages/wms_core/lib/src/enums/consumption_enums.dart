import 'package:json_annotation/json_annotation.dart';

/// `cons_recipe.status` (ADR-012, `consumption.v1.yaml#/RecipeStatus`).
///
/// Only a `DRAFT` version is editable; activation closes the previous
/// `ACTIVE` version with `valid_to = valid_from − 1 day` and archives it.
enum RecipeStatus {
  @JsonValue('DRAFT')
  draft('DRAFT'),
  @JsonValue('ACTIVE')
  active('ACTIVE'),
  @JsonValue('ARCHIVED')
  archived('ARCHIVED');

  const RecipeStatus(this.wire);

  final String wire;

  /// `PUT /recipes/{id}` is rejected with `INVALID_STATE_TRANSITION` for any
  /// other status.
  bool get isEditable => this == RecipeStatus.draft;

  bool get canActivate => this == RecipeStatus.draft;

  static RecipeStatus fromWire(String value) =>
      values.firstWhere((e) => e.wire == value);
}

/// `cons_recipe_line.component_type` — a warehouse product or a sub-recipe
/// prepared in the branch (recursively exploded, depth ≤ 5).
enum ComponentType {
  @JsonValue('FOOD_PRODUCT')
  foodProduct('FOOD_PRODUCT'),
  @JsonValue('SUB_RECIPE')
  subRecipe('SUB_RECIPE');

  const ComponentType(this.wire);

  final String wire;

  /// `productId` is mandatory for `FOOD_PRODUCT`, `subMenuItemId` for
  /// `SUB_RECIPE`.
  bool get requiresProduct => this == ComponentType.foodProduct;

  bool get requiresSubMenuItem => this == ComponentType.subRecipe;

  static ComponentType fromWire(String value) =>
      values.firstWhere((e) => e.wire == value);
}

/// `cons_sales_import.source` — where the daily sales figures came from.
/// The downstream flow is identical for all three (ADR-012).
enum SalesSource {
  @JsonValue('POS')
  pos('POS'),
  @JsonValue('CSV')
  csv('CSV'),
  @JsonValue('MANUAL')
  manual('MANUAL');

  const SalesSource(this.wire);

  final String wire;

  static SalesSource fromWire(String value) =>
      values.firstWhere((e) => e.wire == value);
}

/// `cons_sales_import.status`. `CONSUMED` — a consumption run has been
/// posted against this import.
enum SalesImportStatus {
  @JsonValue('DRAFT')
  draft('DRAFT'),
  @JsonValue('SUBMITTED')
  submitted('SUBMITTED'),
  @JsonValue('CONSUMED')
  consumed('CONSUMED'),
  @JsonValue('CANCELLED')
  cancelled('CANCELLED');

  const SalesImportStatus(this.wire);

  final String wire;

  /// Lines may only be replaced while the import is a draft.
  bool get isEditable => this == SalesImportStatus.draft;

  bool get canSubmit => this == SalesImportStatus.draft;

  /// `POST /runs` requires a `SUBMITTED` import.
  bool get canCalculate => this == SalesImportStatus.submitted;

  static SalesImportStatus fromWire(String value) =>
      values.firstWhere((e) => e.wire == value);
}

/// `cons_run.status`. `FAILED` keeps the document so the reason can be
/// investigated; `REVERSED` frees the `(location, businessDate)` slot.
enum ConsumptionRunStatus {
  @JsonValue('DRAFT')
  draft('DRAFT'),
  @JsonValue('CALCULATED')
  calculated('CALCULATED'),
  @JsonValue('POSTED')
  posted('POSTED'),
  @JsonValue('FAILED')
  failed('FAILED'),
  @JsonValue('REVERSED')
  reversed('REVERSED');

  const ConsumptionRunStatus(this.wire);

  final String wire;

  /// A posted run is never recalculated (`INVALID_STATE_TRANSITION`).
  bool get canCalculate =>
      this == ConsumptionRunStatus.draft ||
      this == ConsumptionRunStatus.calculated ||
      this == ConsumptionRunStatus.failed;

  bool get canPost => this == ConsumptionRunStatus.calculated;

  /// Posted documents are corrected through a `REVERSAL` group only.
  bool get canReverse => this == ConsumptionRunStatus.posted;

  bool get isPosted => this == ConsumptionRunStatus.posted;

  static ConsumptionRunStatus fromWire(String value) =>
      values.firstWhere((e) => e.wire == value);
}
