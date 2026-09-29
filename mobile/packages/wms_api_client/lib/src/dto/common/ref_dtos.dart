import 'package:freezed_annotation/freezed_annotation.dart';

import '../../json/date_only_converter.dart';

part 'ref_dtos.freezed.dart';
part 'ref_dtos.g.dart';

/// The small denormalised objects the API embeds instead of bare foreign keys.
///
/// The contracts send `product: {id, sku, name, …}`, not `productId` — a list row can then show a
/// name without a second request, and the id it points at cannot be shown as a number by accident.
/// The DTOs here exist because the hand-written ones expected the bare ids: every list screen
/// failed to parse, and the unit tests agreed with the DTOs rather than with the wire.

/// `ProductRef` — enough of a product to render a line without fetching the card.
@freezed
abstract class ProductRefDto with _$ProductRefDto {
  const factory ProductRefDto({
    required int id,
    required String sku,
    required String name,
    // Required by the contract and sent by every endpoint: a line entered in the base unit — a
    // count sheet, for one — needs the id to name the unit it was typed in.
    required int baseUomId,
    required String baseUomCode,
    bool? requiresBatch,
    bool? requiresExpiry,
  }) = _ProductRefDto;

  const ProductRefDto._();

  factory ProductRefDto.fromJson(Map<String, Object?> json) => _$ProductRefDtoFromJson(json);
}

/// `LocationRef`. `isVirtual` marks the ledger's counter-accounts (`V_*`, `IN_TRANSIT`).
@freezed
abstract class LocationRefDto with _$LocationRefDto {
  const factory LocationRefDto({
    required int id,
    required String code,
    required String name,
    @Default(false) bool isVirtual,
  }) = _LocationRefDto;

  const LocationRefDto._();

  factory LocationRefDto.fromJson(Map<String, Object?> json) => _$LocationRefDtoFromJson(json);
}

/// `BatchRef`.
@freezed
abstract class BatchRefDto with _$BatchRefDto {
  const factory BatchRefDto({
    required int id,
    required String batchNo,
    @NullableDateOnlyConverter() DateTime? expiryDate,
    String? status,
  }) = _BatchRefDto;

  const BatchRefDto._();

  factory BatchRefDto.fromJson(Map<String, Object?> json) => _$BatchRefDtoFromJson(json);
}

/// `UserRef`.
@freezed
abstract class UserRefDto with _$UserRefDto {
  const factory UserRefDto({
    required int id,
    String? username,
    String? fullName,
  }) = _UserRefDto;

  const UserRefDto._();

  factory UserRefDto.fromJson(Map<String, Object?> json) => _$UserRefDtoFromJson(json);
}

/// `AuditFields` already lives in `identity_dtos.dart`; it is not repeated here.

/// `SupplierRef`.
@freezed
abstract class SupplierRefDto with _$SupplierRefDto {
  const factory SupplierRefDto({
    required int id,
    required String code,
    required String name,
  }) = _SupplierRefDto;

  const SupplierRefDto._();

  factory SupplierRefDto.fromJson(Map<String, Object?> json) => _$SupplierRefDtoFromJson(json);
}
