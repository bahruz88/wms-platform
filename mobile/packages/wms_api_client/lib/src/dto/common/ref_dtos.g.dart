// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ref_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductRefDto _$ProductRefDtoFromJson(Map<String, dynamic> json) =>
    _ProductRefDto(
      id: (json['id'] as num).toInt(),
      sku: json['sku'] as String,
      name: json['name'] as String,
      baseUomId: (json['baseUomId'] as num).toInt(),
      baseUomCode: json['baseUomCode'] as String,
      requiresBatch: json['requiresBatch'] as bool?,
      requiresExpiry: json['requiresExpiry'] as bool?,
    );

Map<String, dynamic> _$ProductRefDtoToJson(_ProductRefDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sku': instance.sku,
      'name': instance.name,
      'baseUomId': instance.baseUomId,
      'baseUomCode': instance.baseUomCode,
      'requiresBatch': instance.requiresBatch,
      'requiresExpiry': instance.requiresExpiry,
    };

_LocationRefDto _$LocationRefDtoFromJson(Map<String, dynamic> json) =>
    _LocationRefDto(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String,
      name: json['name'] as String,
      isVirtual: json['isVirtual'] as bool? ?? false,
    );

Map<String, dynamic> _$LocationRefDtoToJson(_LocationRefDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'isVirtual': instance.isVirtual,
    };

_BatchRefDto _$BatchRefDtoFromJson(Map<String, dynamic> json) => _BatchRefDto(
  id: (json['id'] as num).toInt(),
  batchNo: json['batchNo'] as String,
  expiryDate: const NullableDateOnlyConverter().fromJson(
    json['expiryDate'] as String?,
  ),
  status: json['status'] as String?,
);

Map<String, dynamic> _$BatchRefDtoToJson(
  _BatchRefDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'batchNo': instance.batchNo,
  'expiryDate': const NullableDateOnlyConverter().toJson(instance.expiryDate),
  'status': instance.status,
};

_UserRefDto _$UserRefDtoFromJson(Map<String, dynamic> json) => _UserRefDto(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String?,
  fullName: json['fullName'] as String?,
);

Map<String, dynamic> _$UserRefDtoToJson(_UserRefDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'fullName': instance.fullName,
    };

_SupplierRefDto _$SupplierRefDtoFromJson(Map<String, dynamic> json) =>
    _SupplierRefDto(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$SupplierRefDtoToJson(_SupplierRefDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
    };
