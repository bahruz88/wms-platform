import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wms_core/wms_core.dart';

import '../../json/date_only_converter.dart';
// `AuditFieldsDto` is defined once, with the identity DTOs.
import '../identity/identity_dtos.dart';

part 'master_data_dtos.freezed.dart';
part 'master_data_dtos.g.dart';

/// `master_uom`.
@freezed
abstract class UomDto with _$UomDto {
  const factory UomDto({
    required int id,
    required String code,
    required String name,
    required UomClass uomClass,
    @Default(3) int decimals,
  }) = _UomDto;

  factory UomDto.fromJson(Map<String, Object?> json) => _$UomDtoFromJson(json);
}

/// `master_product_category`.
@freezed
abstract class ProductCategoryDto with _$ProductCategoryDto {
  const factory ProductCategoryDto({
    required int id,
    required String code,
    required String name,
    required ProductType productType,
    required String path,
    int? parentId,
  }) = _ProductCategoryDto;

  factory ProductCategoryDto.fromJson(Map<String, Object?> json) =>
      _$ProductCategoryDtoFromJson(json);
}

/// `master_product_uom` - alternative units with a frozen factor.
@freezed
abstract class ProductUomDto with _$ProductUomDto {
  const factory ProductUomDto({
    required int id,
    required int uomId,
    required Decimal factorToBase,
    @DateOnlyConverter() required DateTime validFrom,
    String? uomCode,
    @Default(false) bool isPurchaseDefault,
    @Default(false) bool isIssueDefault,
    @NullableDateOnlyConverter() DateTime? validTo,
  }) = _ProductUomDto;

  factory ProductUomDto.fromJson(Map<String, Object?> json) =>
      _$ProductUomDtoFromJson(json);
}

/// `master_product`.
///
/// One DTO for both forms: the list answers with `ProductSummary` (no category, VAT, UoM rows or
/// audit), the detail with the whole thing, so everything only the detail carries is nullable.
///
/// It carries no cost. Master data never exposed one — average cost and last purchase price are
/// reporting figures, and the fields this DTO used to declare for them were never sent.
@freezed
abstract class ProductDto with _$ProductDto {
  const factory ProductDto({
    required int id,
    required String sku,
    required String name,
    required int baseUomId,
    required ProductType productType,
    // Only the detail carries these; the list answers with `ProductSummary`.
    int? categoryId,
    String? categoryPath,
    Decimal? vatRate,
    String? barcode,
    String? brand,
    String? baseUomCode,
    int? defaultSupplierId,
    Quantity? minStock,
    Quantity? maxStock,
    Quantity? reorderPoint,
    @Default(false) bool requiresBatch,
    @Default(false) bool requiresExpiry,
    @Default(IssueStrategy.fefo) IssueStrategy issueStrategy,
    int? shelfLifeDays,
    int? imageAttachmentId,
    @Default(true) bool isActive,
    @Default(<ProductUomDto>[]) List<ProductUomDto> uoms,
    AuditFieldsDto? audit,
  }) = _ProductDto;

  const ProductDto._();

  factory ProductDto.fromJson(Map<String, Object?> json) =>
      _$ProductDtoFromJson(json);

  /// Optimistic concurrency token. Master data carries it inside `audit`, not at the top level, and
  /// the list form omits `audit` altogether — so a list row cannot be used to submit an update.
  int? get rowVersion => audit?.rowVersion;

  /// A category name to show. The contract sends the full path (`Ət / Toyuq`), not a bare name.
  String get categoryLabel => categoryPath ?? (categoryId == null ? '—' : '#$categoryId');
}

/// `master_supplier`.
@freezed
abstract class SupplierDto with _$SupplierDto {
  const factory SupplierDto({
    required int id,
    required String code,
    required String name,
    @Default('AZN') String currency,
    String? taxId,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
    String? paymentTerms,
    String? deliveryTerms,
    String? incoterms,
    @Default(false) bool isApprovedFoodSupplier,
    @Default(true) bool isActive,
    @Default(1) int rowVersion,
  }) = _SupplierDto;

  factory SupplierDto.fromJson(Map<String, Object?> json) =>
      _$SupplierDtoFromJson(json);
}

/// `master_location` - physical and virtual.
@freezed
abstract class LocationDto with _$LocationDto {
  const factory LocationDto({
    required int id,
    required String code,
    required String name,
    required LocationType locationType,
    required bool isVirtual,
    int? parentId,
    @Default(true) bool allowsFood,
    @Default(true) bool allowsNonFood,
    @Default(true) bool isActive,
  }) = _LocationDto;

  factory LocationDto.fromJson(Map<String, Object?> json) =>
      _$LocationDtoFromJson(json);
}

/// `master_reason_code`.
@freezed
abstract class ReasonCodeDto with _$ReasonCodeDto {
  const factory ReasonCodeDto({
    required int id,
    required String code,
    required String name,
    required ReasonGroup reasonGroup,
    @Default(true) bool requiresApproval,
    @Default(false) bool requiresPhoto,
    @Default(true) bool isActive,
  }) = _ReasonCodeDto;

  factory ReasonCodeDto.fromJson(Map<String, Object?> json) =>
      _$ReasonCodeDtoFromJson(json);
}
