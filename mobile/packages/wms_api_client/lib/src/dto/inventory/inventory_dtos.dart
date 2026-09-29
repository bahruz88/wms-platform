import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wms_core/wms_core.dart';

import '../../json/date_only_converter.dart';
import '../common/ref_dtos.dart';
// `AuditFieldsDto` is defined once, with the identity DTOs.
import '../identity/identity_dtos.dart';

part 'inventory_dtos.freezed.dart';
part 'inventory_dtos.g.dart';

// ---------------------------------------------------------------------------
// Balances / batches
// ---------------------------------------------------------------------------

/// `Balance` — one `inv_balance` row as the API sends it.
///
/// Product, location and batch arrive as nested objects, not as bare ids. The previous DTO expected
/// `productId`/`locationId` and so could not parse a single balance row, while its unit test passed
/// because the fixture had been written to the same wrong shape.
///
/// Cost and value are absent without `master.product.view_cost`: the server leaves the fields out
/// rather than sending null, so a screen cannot print a blank where a number was withheld (spec §16).
@freezed
abstract class BalanceDto with _$BalanceDto {
  const factory BalanceDto({
    required ProductRefDto product,
    required LocationRefDto location,
    required Quantity qtyOnHand,
    required Quantity qtyReserved,
    BatchRefDto? batch,
    int? baseUomId,
    String? baseUomCode,
    Money? avgUnitCost,
    Money? totalValue,
    Quantity? minStock,
    @Default(false) bool isBelowMin,
    int? daysToExpiry,
    int? lastMovementId,
    DateTime? updatedAt,
  }) = _BalanceDto;

  const BalanceDto._();

  factory BalanceDto.fromJson(Map<String, Object?> json) =>
      _$BalanceDtoFromJson(json);

  /// `qty_available = qty_on_hand − qty_reserved` (spec §9.5).
  ///
  /// Recomputed rather than read from the response, so a screen can never show a total that
  /// disagrees with the two numbers printed next to it.
  Quantity get qtyAvailable => qtyOnHand - qtyReserved;

  bool get hasCostInfo => avgUnitCost != null || totalValue != null;
}

/// `Batch` — `inv_batch` with the product embedded and the stock it still holds.
///
/// One DTO serves both the list and the detail, so everything only the detail carries is nullable.
/// The quantity has two names on the wire: the list sends `totalQtyOnHand` with a `byLocation`
/// breakdown, the contract calls them `qtyOnHand` and `balances`. Both spellings are read and
/// `onHand` hides the difference from the screens.
@freezed
abstract class BatchDto with _$BatchDto {
  const factory BatchDto({
    required int id,
    required ProductRefDto product,
    required String batchNo,
    required DateTime receivedAt,
    required BatchStatus status,
    Quantity? qtyOnHand,
    Quantity? totalQtyOnHand,
    @Default(1) int rowVersion,
    @NullableDateOnlyConverter() DateTime? productionDate,
    @NullableDateOnlyConverter() DateTime? expiryDate,
    int? supplierId,
    String? supplierName,
    int? daysToExpiry,
    @Default(<Object?>[]) List<Object?> byLocation,
  }) = _BatchDto;

  factory BatchDto.fromJson(Map<String, Object?> json) =>
      _$BatchDtoFromJson(json);
}

// ---------------------------------------------------------------------------
// Goods receipt
// ---------------------------------------------------------------------------

/// `inv_goods_receipt_line`.
@freezed
abstract class GoodsReceiptLineDto with _$GoodsReceiptLineDto {
  const factory GoodsReceiptLineDto({
    required int lineNo,
    required ProductRefDto product,
    required Quantity receivedQty,
    required int uomId,
    required Quantity rejectedQty,
    int? id,
    int? poLineId,
    Quantity? orderedQty,
    String? uomCode,
    String? batchNo,
    @NullableDateOnlyConverter() DateTime? productionDate,
    @NullableDateOnlyConverter() DateTime? expiryDate,
    Money? unitPrice,
    String? currency,
    String? varianceNote,
  }) = _GoodsReceiptLineDto;

  const GoodsReceiptLineDto._();

  factory GoodsReceiptLineDto.fromJson(Map<String, Object?> json) =>
      _$GoodsReceiptLineDtoFromJson(json);

  /// `received − ordered`; `null` when the line is not PO-backed.
  Quantity? get variance =>
      orderedQty == null ? null : receivedQty - orderedQty!;

  /// A note is mandatory whenever the received quantity differs from the
  /// ordered one (spec §9.6 / §12.8).
  bool get requiresVarianceNote {
    final v = variance;
    return v != null && !v.isZero;
  }
}

/// `inv_goods_receipt`.
@freezed
abstract class GoodsReceiptDto with _$GoodsReceiptDto {
  const factory GoodsReceiptDto({
    required int id,
    required String docNo,
    @DateOnlyConverter() required DateTime docDate,
    // Flat, unlike its siblings: `GoodsReceiptSummary` declares `supplierId`/`supplierName` and
    // `locationId`/`locationName`, where `IssueSummary`, `WasteSummary`, `CountSummary` and
    // `StockRequestSummary` all declare nested refs. The contract is inconsistent here and the
    // server follows the contract, so the DTO does too — changing it to a ref broke parsing.
    required int supplierId,
    required int locationId,
    required QualityStatus qualityStatus,
    required ReceiptStatus status,
    int? poId,
    String? poDocNo,
    String? supplierName,
    String? locationName,
    Decimal? temperatureC,
    String? packagingNote,
    int? movementGroupId,
    DateTime? postedAt,
    AuditFieldsDto? audit,
    @Default(1) int rowVersion,
    @Default(<GoodsReceiptLineDto>[]) List<GoodsReceiptLineDto> lines,
  }) = _GoodsReceiptDto;

  factory GoodsReceiptDto.fromJson(Map<String, Object?> json) =>
      _$GoodsReceiptDtoFromJson(json);
}

@freezed
abstract class CreateGoodsReceiptLine with _$CreateGoodsReceiptLine {
  const factory CreateGoodsReceiptLine({
    required int productId,
    required Quantity receivedQty,
    required int uomId,
    int? poLineId,
    Quantity? orderedQty,
    Quantity? rejectedQty,
    String? batchNo,
    @NullableDateOnlyConverter() DateTime? productionDate,
    @NullableDateOnlyConverter() DateTime? expiryDate,
    Money? unitPrice,
    String? currency,
    String? varianceNote,
  }) = _CreateGoodsReceiptLine;

  factory CreateGoodsReceiptLine.fromJson(Map<String, Object?> json) =>
      _$CreateGoodsReceiptLineFromJson(json);
}

/// `POST /inventory/goods-receipts` body.
@freezed
abstract class CreateGoodsReceiptRequest with _$CreateGoodsReceiptRequest {
  const factory CreateGoodsReceiptRequest({
    @DateOnlyConverter() required DateTime docDate,
    required int supplierId,
    required int locationId,
    required QualityStatus qualityStatus,
    required List<CreateGoodsReceiptLine> lines,
    int? poId,
    Decimal? temperatureC,
    String? packagingNote,
  }) = _CreateGoodsReceiptRequest;

  factory CreateGoodsReceiptRequest.fromJson(Map<String, Object?> json) =>
      _$CreateGoodsReceiptRequestFromJson(json);
}

// ---------------------------------------------------------------------------
// Stock request (branch demand)
// ---------------------------------------------------------------------------

@freezed
abstract class StockRequestLineDto with _$StockRequestLineDto {
  const factory StockRequestLineDto({
    required int lineNo,
    required ProductRefDto product,
    required Quantity qty,
    required int uomId,
    required Quantity issuedQty,
    int? id,
    String? uomCode,
    String? note,
  }) = _StockRequestLineDto;

  factory StockRequestLineDto.fromJson(Map<String, Object?> json) =>
      _$StockRequestLineDtoFromJson(json);
}

/// `inv_stock_request`.
@freezed
abstract class StockRequestDto with _$StockRequestDto {
  const factory StockRequestDto({
    required int id,
    required String docNo,
    @DateOnlyConverter() required DateTime docDate,
    required LocationRefDto fromLocation,
    required LocationRefDto toLocation,
    required StockRequestStatus status,
    @NullableDateOnlyConverter() DateTime? requiredDate,
    String? note,
    AuditFieldsDto? audit,
    @Default(1) int rowVersion,
    @Default(<StockRequestLineDto>[]) List<StockRequestLineDto> lines,
  }) = _StockRequestDto;

  factory StockRequestDto.fromJson(Map<String, Object?> json) =>
      _$StockRequestDtoFromJson(json);
}

@freezed
abstract class CreateStockRequestLine with _$CreateStockRequestLine {
  const factory CreateStockRequestLine({
    required int productId,
    required Quantity qty,
    required int uomId,
    String? note,
  }) = _CreateStockRequestLine;

  factory CreateStockRequestLine.fromJson(Map<String, Object?> json) =>
      _$CreateStockRequestLineFromJson(json);
}

/// `POST /inventory/stock-requests` body.
@freezed
abstract class CreateStockRequestRequest with _$CreateStockRequestRequest {
  const factory CreateStockRequestRequest({
    @DateOnlyConverter() required DateTime docDate,
    required int fromLocationId,
    required int toLocationId,
    required List<CreateStockRequestLine> lines,
    @NullableDateOnlyConverter() DateTime? requiredDate,
    String? note,
  }) = _CreateStockRequestRequest;

  factory CreateStockRequestRequest.fromJson(Map<String, Object?> json) =>
      _$CreateStockRequestRequestFromJson(json);
}

// ---------------------------------------------------------------------------
// Issue / transfer (IN_TRANSIT mechanism)
// ---------------------------------------------------------------------------

@freezed
abstract class IssueLineDto with _$IssueLineDto {
  const factory IssueLineDto({
    // Needed to confirm a receipt: `IssueConfirmLine.lineId` is this, not `lineNo`.
    required int id,
    required int lineNo,
    required ProductRefDto product,
    required Quantity qty,
    required int uomId,
    BatchRefDto? batch,
    BatchRefDto? suggestedBatch,
    String? uomCode,
    Quantity? receivedQty,
    Quantity? discrepancyQty,
    int? batchOverrideReasonCodeId,
    int? discrepancyReasonCodeId,
    String? discrepancyNote,
  }) = _IssueLineDto;

  const IssueLineDto._();

  factory IssueLineDto.fromJson(Map<String, Object?> json) =>
      _$IssueLineDtoFromJson(json);

  /// `received − dispatched` after branch confirmation.
  Quantity? get discrepancy => receivedQty == null ? null : receivedQty! - qty;
}

/// `inv_issue`.
@freezed
abstract class IssueDto with _$IssueDto {
  const factory IssueDto({
    required int id,
    required String docNo,
    @DateOnlyConverter() required DateTime docDate,
    required IssueType issueType,
    required LocationRefDto fromLocation,
    required LocationRefDto toLocation,
    required IssueStatus status,
    int? requestId,
    int? dispatchGroupId,
    int? receiptGroupId,
    DateTime? dispatchedAt,
    DateTime? receivedAt,
    int? receivedBy,
    @Default(1) int rowVersion,
    @Default(<IssueLineDto>[]) List<IssueLineDto> lines,
  }) = _IssueDto;

  factory IssueDto.fromJson(Map<String, Object?> json) =>
      _$IssueDtoFromJson(json);
}

/// `Quantity` of common.v1.yaml — a value plus the unit the user typed it in.
///
/// Some request bodies nest the quantity (`{"quantity": {"value": "1.0000", "uomId": 3}}`) and
/// others keep it flat beside a `uomId`. The server binds each one only in its own shape, so the
/// difference is not cosmetic: the waste and count bodies used to send the flat form and every
/// submission was rejected with 400 before it reached a validator.
@freezed
abstract class QuantityInput with _$QuantityInput {
  const factory QuantityInput({
    required Quantity value,
    required int uomId,
  }) = _QuantityInput;

  factory QuantityInput.fromJson(Map<String, Object?> json) =>
      _$QuantityInputFromJson(json);
}

@freezed
abstract class CreateIssueLine with _$CreateIssueLine {
  const factory CreateIssueLine({
    required int productId,
    required Quantity qty,
    required int uomId,
    // Ties the line back to the stock request it fulfils.
    int? requestLineId,
    int? batchId,
    // Overriding the suggested batch needs a reason and a note, and the server binds them under
    // these names — a plain `reasonCodeId`/`note` pair was silently dropped.
    int? batchOverrideReasonCodeId,
    String? batchOverrideNote,
  }) = _CreateIssueLine;

  factory CreateIssueLine.fromJson(Map<String, Object?> json) =>
      _$CreateIssueLineFromJson(json);
}

/// `POST /inventory/issues` body.
@freezed
abstract class CreateIssueRequest with _$CreateIssueRequest {
  const factory CreateIssueRequest({
    @DateOnlyConverter() required DateTime docDate,
    required IssueType issueType,
    required int fromLocationId,
    required int toLocationId,
    required List<CreateIssueLine> lines,
    int? requestId,
  }) = _CreateIssueRequest;

  factory CreateIssueRequest.fromJson(Map<String, Object?> json) =>
      _$CreateIssueRequestFromJson(json);
}

@freezed
abstract class ConfirmIssueLine with _$ConfirmIssueLine {
  const factory ConfirmIssueLine({
    // The line's id, not its `lineNo`. They differ, and the server looks up by id.
    required int lineId,
    required Quantity receivedQty,
    // Mandatory when `receivedQty` differs from the dispatched quantity.
    int? reasonCodeId,
    String? note,
  }) = _ConfirmIssueLine;

  factory ConfirmIssueLine.fromJson(Map<String, Object?> json) =>
      _$ConfirmIssueLineFromJson(json);
}

/// `POST /inventory/issues/{id}/confirm` body (branch receipt).
@freezed
abstract class ConfirmIssueRequest with _$ConfirmIssueRequest {
  const factory ConfirmIssueRequest({
    required List<ConfirmIssueLine> lines,
    required int rowVersion,
    String? note,
  }) = _ConfirmIssueRequest;

  factory ConfirmIssueRequest.fromJson(Map<String, Object?> json) =>
      _$ConfirmIssueRequestFromJson(json);
}

// ---------------------------------------------------------------------------
// Inventory count
// ---------------------------------------------------------------------------

@freezed
abstract class CountLineDto with _$CountLineDto {
  const factory CountLineDto({
    required int id,
    required ProductRefDto product,
    required Quantity bookQty,
    String? baseUomCode,
    BatchRefDto? batch,
    Quantity? countedQty,
    Quantity? varianceQty,
    Decimal? variancePct,
    int? reasonCodeId,
    String? note,
  }) = _CountLineDto;

  const CountLineDto._();

  factory CountLineDto.fromJson(Map<String, Object?> json) =>
      _$CountLineDtoFromJson(json);

  bool get isCounted => countedQty != null;

  /// A reason code is mandatory when variance ≠ 0 (spec §9.6).
  bool get requiresReasonCode {
    final counted = countedQty;
    return counted != null && !(counted - bookQty).isZero;
  }
}

/// `inv_count`.
@freezed
abstract class CountDto with _$CountDto {
  const factory CountDto({
    required int id,
    required String docNo,
    required LocationRefDto location,
    required CountType countType,
    required CountStatus status,
    DateTime? frozenAt,
    int? approvedBy,
    DateTime? approvedAt,
    int? adjustGroupId,
    @Default(1) int rowVersion,
    @Default(<CountLineDto>[]) List<CountLineDto> lines,
  }) = _CountDto;

  factory CountDto.fromJson(Map<String, Object?> json) =>
      _$CountDtoFromJson(json);
}

/// `POST /inventory/counts` body.
@freezed
abstract class CreateCountRequest with _$CreateCountRequest {
  const factory CreateCountRequest({
    required int locationId,
    required CountType countType,
  }) = _CreateCountRequest;

  factory CreateCountRequest.fromJson(Map<String, Object?> json) =>
      _$CreateCountRequestFromJson(json);
}

@freezed
abstract class EnterCountLine with _$EnterCountLine {
  const factory EnterCountLine({
    // The count sheet is addressed by product, not by line id: a line the sheet did not pre-create
    // can still be counted.
    required int productId,
    required QuantityInput countedQuantity,
    int? batchId,
    int? reasonCodeId,
    String? note,
  }) = _EnterCountLine;

  factory EnterCountLine.fromJson(Map<String, Object?> json) =>
      _$EnterCountLineFromJson(json);
}

/// `POST /inventory/counts/{id}/lines` body.
@freezed
abstract class EnterCountRequest with _$EnterCountRequest {
  const factory EnterCountRequest({
    required List<EnterCountLine> lines,
    required int rowVersion,
  }) = _EnterCountRequest;

  factory EnterCountRequest.fromJson(Map<String, Object?> json) =>
      _$EnterCountRequestFromJson(json);
}

// ---------------------------------------------------------------------------
// Waste / sample
// ---------------------------------------------------------------------------

@freezed
abstract class WasteLineDto with _$WasteLineDto {
  const factory WasteLineDto({
    required int lineNo,
    required ProductRefDto product,
    required Quantity qty,
    required int uomId,
    BatchRefDto? batch,
    String? uomCode,
    int? id,
    Quantity? qtyBase,
    String? note,
    Money? unitCost,
    Money? lineValue,
  }) = _WasteLineDto;

  factory WasteLineDto.fromJson(Map<String, Object?> json) =>
      _$WasteLineDtoFromJson(json);
}

/// `inv_waste`.
@freezed
abstract class WasteDto with _$WasteDto {
  const factory WasteDto({
    required int id,
    required String docNo,
    @DateOnlyConverter() required DateTime docDate,
    required LocationRefDto location,
    required int reasonCodeId,
    required WasteStatus status,
    String? reasonCodeName,
    String? note,
    int? approvedBy,
    DateTime? approvedAt,
    int? movementGroupId,
    @Default(<int>[]) List<int> attachmentIds,
    @Default(1) int rowVersion,
    @Default(<WasteLineDto>[]) List<WasteLineDto> lines,
  }) = _WasteDto;

  factory WasteDto.fromJson(Map<String, Object?> json) =>
      _$WasteDtoFromJson(json);
}

@freezed
abstract class CreateWasteLine with _$CreateWasteLine {
  const factory CreateWasteLine({
    required int productId,
    required QuantityInput quantity,
    int? batchId,
    String? note,
  }) = _CreateWasteLine;

  factory CreateWasteLine.fromJson(Map<String, Object?> json) =>
      _$CreateWasteLineFromJson(json);
}

/// `POST /inventory/waste` body. [attachmentIds] reference documents
/// uploaded via the Documents module (photo evidence when the reason code
/// has `requires_photo`).
@freezed
abstract class CreateWasteRequest with _$CreateWasteRequest {
  const factory CreateWasteRequest({
    @DateOnlyConverter() required DateTime docDate,
    required int locationId,
    required int reasonCodeId,
    required List<CreateWasteLine> lines,
    String? note,
    @Default(<int>[]) List<int> attachmentIds,
  }) = _CreateWasteRequest;

  factory CreateWasteRequest.fromJson(Map<String, Object?> json) =>
      _$CreateWasteRequestFromJson(json);
}

/// A sample's lines are `WasteLine` in the contract: the same shape, because a sample and a waste
/// document both take stock off the shelf against a reason code.
@freezed
abstract class SampleLineDto with _$SampleLineDto {
  const factory SampleLineDto({
    required int lineNo,
    required ProductRefDto product,
    required Quantity qty,
    required int uomId,
    BatchRefDto? batch,
    String? uomCode,
    int? id,
    Quantity? qtyBase,
    String? note,
  }) = _SampleLineDto;

  factory SampleLineDto.fromJson(Map<String, Object?> json) =>
      _$SampleLineDtoFromJson(json);
}

/// `inv_sample` (AQTA samples).
@freezed
abstract class SampleDto with _$SampleDto {
  const factory SampleDto({
    required int id,
    required String docNo,
    @DateOnlyConverter() required DateTime docDate,
    required LocationRefDto location,
    @Default('AQTA') String authority,
    String? purpose,
    int? movementGroupId,
    @Default(<SampleLineDto>[]) List<SampleLineDto> lines,
  }) = _SampleDto;

  factory SampleDto.fromJson(Map<String, Object?> json) =>
      _$SampleDtoFromJson(json);
}

@freezed
abstract class CreateSampleLine with _$CreateSampleLine {
  const factory CreateSampleLine({
    required int productId,
    required QuantityInput quantity,
    int? batchId,
    String? note,
  }) = _CreateSampleLine;

  factory CreateSampleLine.fromJson(Map<String, Object?> json) =>
      _$CreateSampleLineFromJson(json);
}

/// `POST /inventory/samples` body.
@freezed
abstract class CreateSampleRequest with _$CreateSampleRequest {
  const factory CreateSampleRequest({
    @DateOnlyConverter() required DateTime docDate,
    required int locationId,
    required List<CreateSampleLine> lines,
    @Default('AQTA') String authority,
    String? purpose,
  }) = _CreateSampleRequest;

  factory CreateSampleRequest.fromJson(Map<String, Object?> json) =>
      _$CreateSampleRequestFromJson(json);
}

/// Body for state transitions that need optimistic locking
/// (`POST .../{id}/post`, `/dispatch`, `/approve`...).
@freezed
abstract class VersionedActionRequest with _$VersionedActionRequest {
  const factory VersionedActionRequest({
    required int rowVersion,
    String? comment,
  }) = _VersionedActionRequest;

  factory VersionedActionRequest.fromJson(Map<String, Object?> json) =>
      _$VersionedActionRequestFromJson(json);
}

/// `inv_setting.value_type` - how the string value must be interpreted.
enum SettingValueType {
  @JsonValue('INT')
  intValue('INT'),
  @JsonValue('DECIMAL')
  decimalValue('DECIMAL'),
  @JsonValue('BOOL')
  boolValue('BOOL'),
  @JsonValue('ENUM')
  enumValue('ENUM');

  const SettingValueType(this.wire);

  final String wire;
}

/// `inv_setting` key/value row (SPEC §9.1). The value always travels as a
/// string; [valueType] says how to read it, so nothing is hard-coded in the
/// client (TOR §36).
@freezed
abstract class InventorySettingDto with _$InventorySettingDto {
  const factory InventorySettingDto({
    required String key,
    required String value,
    required SettingValueType valueType,
    @Default(<String>[]) List<String> allowedValues,
    String? description,
  }) = _InventorySettingDto;

  const InventorySettingDto._();

  factory InventorySettingDto.fromJson(Map<String, Object?> json) =>
      _$InventorySettingDtoFromJson(json);

  /// `true` for a `BOOL` key whose value reads as true.
  bool get asFlag =>
      valueType == SettingValueType.boolValue && value.toLowerCase() == 'true';
}

/// `PUT /inventory/settings/{key}` body.
@freezed
abstract class UpdateInventorySettingRequest
    with _$UpdateInventorySettingRequest {
  const factory UpdateInventorySettingRequest({required String value}) =
      _UpdateInventorySettingRequest;

  factory UpdateInventorySettingRequest.fromJson(Map<String, Object?> json) =>
      _$UpdateInventorySettingRequestFromJson(json);
}
