// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'master_data_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UomDto _$UomDtoFromJson(Map<String, dynamic> json) => _UomDto(
  id: (json['id'] as num).toInt(),
  code: json['code'] as String,
  name: json['name'] as String,
  uomClass: $enumDecode(_$UomClassEnumMap, json['uomClass']),
  decimals: (json['decimals'] as num?)?.toInt() ?? 3,
);

Map<String, dynamic> _$UomDtoToJson(_UomDto instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'name': instance.name,
  'uomClass': _$UomClassEnumMap[instance.uomClass]!,
  'decimals': instance.decimals,
};

const _$UomClassEnumMap = {
  UomClass.mass: 'MASS',
  UomClass.volume: 'VOLUME',
  UomClass.count: 'COUNT',
};

_ProductCategoryDto _$ProductCategoryDtoFromJson(Map<String, dynamic> json) =>
    _ProductCategoryDto(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String,
      name: json['name'] as String,
      productType: $enumDecode(_$ProductTypeEnumMap, json['productType']),
      path: json['path'] as String,
      parentId: (json['parentId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ProductCategoryDtoToJson(_ProductCategoryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'productType': _$ProductTypeEnumMap[instance.productType]!,
      'path': instance.path,
      'parentId': instance.parentId,
    };

const _$ProductTypeEnumMap = {
  ProductType.food: 'FOOD',
  ProductType.nonFood: 'NON_FOOD',
};

_ProductUomDto _$ProductUomDtoFromJson(Map<String, dynamic> json) =>
    _ProductUomDto(
      id: (json['id'] as num).toInt(),
      uomId: (json['uomId'] as num).toInt(),
      factorToBase: Decimal.fromJson(json['factorToBase'] as String),
      validFrom: const DateOnlyConverter().fromJson(
        json['validFrom'] as String,
      ),
      uomCode: json['uomCode'] as String?,
      isPurchaseDefault: json['isPurchaseDefault'] as bool? ?? false,
      isIssueDefault: json['isIssueDefault'] as bool? ?? false,
      validTo: const NullableDateOnlyConverter().fromJson(
        json['validTo'] as String?,
      ),
    );

Map<String, dynamic> _$ProductUomDtoToJson(_ProductUomDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uomId': instance.uomId,
      'factorToBase': instance.factorToBase.toJson(),
      'validFrom': const DateOnlyConverter().toJson(instance.validFrom),
      'uomCode': instance.uomCode,
      'isPurchaseDefault': instance.isPurchaseDefault,
      'isIssueDefault': instance.isIssueDefault,
      'validTo': const NullableDateOnlyConverter().toJson(instance.validTo),
    };

_ProductDto _$ProductDtoFromJson(Map<String, dynamic> json) => _ProductDto(
  id: (json['id'] as num).toInt(),
  sku: json['sku'] as String,
  name: json['name'] as String,
  categoryId: (json['categoryId'] as num).toInt(),
  baseUomId: (json['baseUomId'] as num).toInt(),
  vatRate: Decimal.fromJson(json['vatRate'] as String),
  barcode: json['barcode'] as String?,
  categoryName: json['categoryName'] as String?,
  brand: json['brand'] as String?,
  baseUomCode: json['baseUomCode'] as String?,
  defaultSupplierId: (json['defaultSupplierId'] as num?)?.toInt(),
  minStock: json['minStock'] == null
      ? null
      : Quantity.fromJson(json['minStock'] as String),
  maxStock: json['maxStock'] == null
      ? null
      : Quantity.fromJson(json['maxStock'] as String),
  reorderPoint: json['reorderPoint'] == null
      ? null
      : Quantity.fromJson(json['reorderPoint'] as String),
  requiresBatch: json['requiresBatch'] as bool? ?? false,
  requiresExpiry: json['requiresExpiry'] as bool? ?? false,
  issueStrategy:
      $enumDecodeNullable(_$IssueStrategyEnumMap, json['issueStrategy']) ??
      IssueStrategy.fefo,
  shelfLifeDays: (json['shelfLifeDays'] as num?)?.toInt(),
  imageKey: json['imageKey'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  rowVersion: (json['rowVersion'] as num?)?.toInt() ?? 1,
  uoms:
      (json['uoms'] as List<dynamic>?)
          ?.map((e) => ProductUomDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ProductUomDto>[],
  avgUnitCost: json['avgUnitCost'] == null
      ? null
      : Money.fromJson(json['avgUnitCost'] as String),
  lastPurchasePrice: json['lastPurchasePrice'] == null
      ? null
      : Money.fromJson(json['lastPurchasePrice'] as String),
  currency: json['currency'] as String?,
);

Map<String, dynamic> _$ProductDtoToJson(_ProductDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sku': instance.sku,
      'name': instance.name,
      'categoryId': instance.categoryId,
      'baseUomId': instance.baseUomId,
      'vatRate': instance.vatRate.toJson(),
      'barcode': instance.barcode,
      'categoryName': instance.categoryName,
      'brand': instance.brand,
      'baseUomCode': instance.baseUomCode,
      'defaultSupplierId': instance.defaultSupplierId,
      'minStock': instance.minStock?.toJson(),
      'maxStock': instance.maxStock?.toJson(),
      'reorderPoint': instance.reorderPoint?.toJson(),
      'requiresBatch': instance.requiresBatch,
      'requiresExpiry': instance.requiresExpiry,
      'issueStrategy': _$IssueStrategyEnumMap[instance.issueStrategy]!,
      'shelfLifeDays': instance.shelfLifeDays,
      'imageKey': instance.imageKey,
      'isActive': instance.isActive,
      'rowVersion': instance.rowVersion,
      'uoms': instance.uoms.map((e) => e.toJson()).toList(),
      'avgUnitCost': instance.avgUnitCost?.toJson(),
      'lastPurchasePrice': instance.lastPurchasePrice?.toJson(),
      'currency': instance.currency,
    };

const _$IssueStrategyEnumMap = {
  IssueStrategy.fefo: 'FEFO',
  IssueStrategy.fifo: 'FIFO',
};

_SupplierDto _$SupplierDtoFromJson(Map<String, dynamic> json) => _SupplierDto(
  id: (json['id'] as num).toInt(),
  code: json['code'] as String,
  name: json['name'] as String,
  currency: json['currency'] as String? ?? 'AZN',
  taxId: json['taxId'] as String?,
  contactPerson: json['contactPerson'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  address: json['address'] as String?,
  paymentTerms: json['paymentTerms'] as String?,
  deliveryTerms: json['deliveryTerms'] as String?,
  incoterms: json['incoterms'] as String?,
  isApprovedFoodSupplier: json['isApprovedFoodSupplier'] as bool? ?? false,
  isActive: json['isActive'] as bool? ?? true,
  rowVersion: (json['rowVersion'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$SupplierDtoToJson(_SupplierDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'currency': instance.currency,
      'taxId': instance.taxId,
      'contactPerson': instance.contactPerson,
      'phone': instance.phone,
      'email': instance.email,
      'address': instance.address,
      'paymentTerms': instance.paymentTerms,
      'deliveryTerms': instance.deliveryTerms,
      'incoterms': instance.incoterms,
      'isApprovedFoodSupplier': instance.isApprovedFoodSupplier,
      'isActive': instance.isActive,
      'rowVersion': instance.rowVersion,
    };

_LocationDto _$LocationDtoFromJson(Map<String, dynamic> json) => _LocationDto(
  id: (json['id'] as num).toInt(),
  code: json['code'] as String,
  name: json['name'] as String,
  locationType: $enumDecode(_$LocationTypeEnumMap, json['locationType']),
  isVirtual: json['isVirtual'] as bool,
  parentId: (json['parentId'] as num?)?.toInt(),
  allowsFood: json['allowsFood'] as bool? ?? true,
  allowsNonFood: json['allowsNonFood'] as bool? ?? true,
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$LocationDtoToJson(_LocationDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'locationType': _$LocationTypeEnumMap[instance.locationType]!,
      'isVirtual': instance.isVirtual,
      'parentId': instance.parentId,
      'allowsFood': instance.allowsFood,
      'allowsNonFood': instance.allowsNonFood,
      'isActive': instance.isActive,
    };

const _$LocationTypeEnumMap = {
  LocationType.centralWarehouse: 'CENTRAL_WAREHOUSE',
  LocationType.subLocation: 'SUB_LOCATION',
  LocationType.shelf: 'SHELF',
  LocationType.restaurant: 'RESTAURANT',
  LocationType.inTransit: 'IN_TRANSIT',
  LocationType.vSupplier: 'V_SUPPLIER',
  LocationType.vWaste: 'V_WASTE',
  LocationType.vSample: 'V_SAMPLE',
  LocationType.vAdjustment: 'V_ADJUSTMENT',
  LocationType.vConsumption: 'V_CONSUMPTION',
};

_ReasonCodeDto _$ReasonCodeDtoFromJson(Map<String, dynamic> json) =>
    _ReasonCodeDto(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String,
      name: json['name'] as String,
      reasonGroup: $enumDecode(_$ReasonGroupEnumMap, json['reasonGroup']),
      requiresApproval: json['requiresApproval'] as bool? ?? true,
      requiresPhoto: json['requiresPhoto'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$ReasonCodeDtoToJson(_ReasonCodeDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'reasonGroup': _$ReasonGroupEnumMap[instance.reasonGroup]!,
      'requiresApproval': instance.requiresApproval,
      'requiresPhoto': instance.requiresPhoto,
      'isActive': instance.isActive,
    };

const _$ReasonGroupEnumMap = {
  ReasonGroup.waste: 'WASTE',
  ReasonGroup.adjustment: 'ADJUSTMENT',
  ReasonGroup.returnToVendor: 'RETURN',
  ReasonGroup.sample: 'SAMPLE',
  ReasonGroup.transfer: 'TRANSFER',
};
