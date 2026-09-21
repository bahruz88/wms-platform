// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consumption_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MenuItemDto _$MenuItemDtoFromJson(Map<String, dynamic> json) => _MenuItemDto(
  id: (json['id'] as num).toInt(),
  code: json['code'] as String,
  name: json['name'] as String,
  isSubRecipe: json['isSubRecipe'] as bool? ?? false,
  isActive: json['isActive'] as bool? ?? true,
  posCode: json['posCode'] as String?,
  category: json['category'] as String?,
  activeRecipeId: (json['activeRecipeId'] as num?)?.toInt(),
  rowVersion: (json['rowVersion'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$MenuItemDtoToJson(_MenuItemDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'isSubRecipe': instance.isSubRecipe,
      'isActive': instance.isActive,
      'posCode': instance.posCode,
      'category': instance.category,
      'activeRecipeId': instance.activeRecipeId,
      'rowVersion': instance.rowVersion,
    };

_MenuItemDetailDto _$MenuItemDetailDtoFromJson(Map<String, dynamic> json) =>
    _MenuItemDetailDto(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String,
      name: json['name'] as String,
      isSubRecipe: json['isSubRecipe'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      posCode: json['posCode'] as String?,
      category: json['category'] as String?,
      activeRecipeId: (json['activeRecipeId'] as num?)?.toInt(),
      rowVersion: (json['rowVersion'] as num?)?.toInt() ?? 1,
      recipeVersionCount: (json['recipeVersionCount'] as num?)?.toInt() ?? 0,
      usedInRecipes:
          (json['usedInRecipes'] as List<dynamic>?)
              ?.map((e) => RecipeSummaryDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <RecipeSummaryDto>[],
    );

Map<String, dynamic> _$MenuItemDetailDtoToJson(_MenuItemDetailDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'isSubRecipe': instance.isSubRecipe,
      'isActive': instance.isActive,
      'posCode': instance.posCode,
      'category': instance.category,
      'activeRecipeId': instance.activeRecipeId,
      'rowVersion': instance.rowVersion,
      'recipeVersionCount': instance.recipeVersionCount,
      'usedInRecipes': instance.usedInRecipes.map((e) => e.toJson()).toList(),
    };

_CreateMenuItemRequest _$CreateMenuItemRequestFromJson(
  Map<String, dynamic> json,
) => _CreateMenuItemRequest(
  code: json['code'] as String,
  name: json['name'] as String,
  posCode: json['posCode'] as String?,
  category: json['category'] as String?,
  isSubRecipe: json['isSubRecipe'] as bool? ?? false,
);

Map<String, dynamic> _$CreateMenuItemRequestToJson(
  _CreateMenuItemRequest instance,
) => <String, dynamic>{
  'code': instance.code,
  'name': instance.name,
  'posCode': instance.posCode,
  'category': instance.category,
  'isSubRecipe': instance.isSubRecipe,
};

_UpdateMenuItemRequest _$UpdateMenuItemRequestFromJson(
  Map<String, dynamic> json,
) => _UpdateMenuItemRequest(
  code: json['code'] as String,
  name: json['name'] as String,
  rowVersion: (json['rowVersion'] as num).toInt(),
  posCode: json['posCode'] as String?,
  category: json['category'] as String?,
  isSubRecipe: json['isSubRecipe'] as bool? ?? false,
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$UpdateMenuItemRequestToJson(
  _UpdateMenuItemRequest instance,
) => <String, dynamic>{
  'code': instance.code,
  'name': instance.name,
  'rowVersion': instance.rowVersion,
  'posCode': instance.posCode,
  'category': instance.category,
  'isSubRecipe': instance.isSubRecipe,
  'isActive': instance.isActive,
};

_RecipeLineDto _$RecipeLineDtoFromJson(Map<String, dynamic> json) =>
    _RecipeLineDto(
      lineNo: (json['lineNo'] as num).toInt(),
      componentType: $enumDecode(_$ComponentTypeEnumMap, json['componentType']),
      qtyPerPortion: Quantity.fromJson(json['qtyPerPortion'] as String),
      uomId: (json['uomId'] as num).toInt(),
      yieldPct: Decimal.fromJson(json['yieldPct'] as String),
      productId: (json['productId'] as num?)?.toInt(),
      productSku: json['productSku'] as String?,
      productName: json['productName'] as String?,
      subMenuItemId: (json['subMenuItemId'] as num?)?.toInt(),
      subMenuItemName: json['subMenuItemName'] as String?,
      uomCode: json['uomCode'] as String?,
      isOptional: json['isOptional'] as bool? ?? false,
      attachRatePct: json['attachRatePct'] == null
          ? null
          : Decimal.fromJson(json['attachRatePct'] as String),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$RecipeLineDtoToJson(_RecipeLineDto instance) =>
    <String, dynamic>{
      'lineNo': instance.lineNo,
      'componentType': _$ComponentTypeEnumMap[instance.componentType]!,
      'qtyPerPortion': instance.qtyPerPortion.toJson(),
      'uomId': instance.uomId,
      'yieldPct': instance.yieldPct.toJson(),
      'productId': instance.productId,
      'productSku': instance.productSku,
      'productName': instance.productName,
      'subMenuItemId': instance.subMenuItemId,
      'subMenuItemName': instance.subMenuItemName,
      'uomCode': instance.uomCode,
      'isOptional': instance.isOptional,
      'attachRatePct': instance.attachRatePct?.toJson(),
      'note': instance.note,
    };

const _$ComponentTypeEnumMap = {
  ComponentType.foodProduct: 'FOOD_PRODUCT',
  ComponentType.subRecipe: 'SUB_RECIPE',
};

_RecipeLineInput _$RecipeLineInputFromJson(Map<String, dynamic> json) =>
    _RecipeLineInput(
      lineNo: (json['lineNo'] as num).toInt(),
      componentType: $enumDecode(_$ComponentTypeEnumMap, json['componentType']),
      qtyPerPortion: Quantity.fromJson(json['qtyPerPortion'] as String),
      uomId: (json['uomId'] as num).toInt(),
      productId: (json['productId'] as num?)?.toInt(),
      subMenuItemId: (json['subMenuItemId'] as num?)?.toInt(),
      yieldPct: json['yieldPct'] == null
          ? null
          : Decimal.fromJson(json['yieldPct'] as String),
      isOptional: json['isOptional'] as bool? ?? false,
      attachRatePct: json['attachRatePct'] == null
          ? null
          : Decimal.fromJson(json['attachRatePct'] as String),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$RecipeLineInputToJson(_RecipeLineInput instance) =>
    <String, dynamic>{
      'lineNo': instance.lineNo,
      'componentType': _$ComponentTypeEnumMap[instance.componentType]!,
      'qtyPerPortion': instance.qtyPerPortion.toJson(),
      'uomId': instance.uomId,
      'productId': instance.productId,
      'subMenuItemId': instance.subMenuItemId,
      'yieldPct': instance.yieldPct?.toJson(),
      'isOptional': instance.isOptional,
      'attachRatePct': instance.attachRatePct?.toJson(),
      'note': instance.note,
    };

_RecipeSummaryDto _$RecipeSummaryDtoFromJson(Map<String, dynamic> json) =>
    _RecipeSummaryDto(
      id: (json['id'] as num).toInt(),
      menuItemId: (json['menuItemId'] as num).toInt(),
      versionNo: (json['versionNo'] as num).toInt(),
      status: $enumDecode(_$RecipeStatusEnumMap, json['status']),
      validFrom: const DateOnlyConverter().fromJson(
        json['validFrom'] as String,
      ),
      menuItemName: json['menuItemName'] as String?,
      validTo: const NullableDateOnlyConverter().fromJson(
        json['validTo'] as String?,
      ),
      lineCount: (json['lineCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$RecipeSummaryDtoToJson(_RecipeSummaryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'menuItemId': instance.menuItemId,
      'versionNo': instance.versionNo,
      'status': _$RecipeStatusEnumMap[instance.status]!,
      'validFrom': const DateOnlyConverter().toJson(instance.validFrom),
      'menuItemName': instance.menuItemName,
      'validTo': const NullableDateOnlyConverter().toJson(instance.validTo),
      'lineCount': instance.lineCount,
    };

const _$RecipeStatusEnumMap = {
  RecipeStatus.draft: 'DRAFT',
  RecipeStatus.active: 'ACTIVE',
  RecipeStatus.archived: 'ARCHIVED',
};

_RecipeDto _$RecipeDtoFromJson(Map<String, dynamic> json) => _RecipeDto(
  id: (json['id'] as num).toInt(),
  menuItemId: (json['menuItemId'] as num).toInt(),
  versionNo: (json['versionNo'] as num).toInt(),
  status: $enumDecode(_$RecipeStatusEnumMap, json['status']),
  validFrom: const DateOnlyConverter().fromJson(json['validFrom'] as String),
  yieldPortions: Quantity.fromJson(json['yieldPortions'] as String),
  rowVersion: (json['rowVersion'] as num).toInt(),
  menuItemName: json['menuItemName'] as String?,
  validTo: const NullableDateOnlyConverter().fromJson(
    json['validTo'] as String?,
  ),
  lineCount: (json['lineCount'] as num?)?.toInt() ?? 0,
  note: json['note'] as String?,
  lines:
      (json['lines'] as List<dynamic>?)
          ?.map((e) => RecipeLineDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <RecipeLineDto>[],
);

Map<String, dynamic> _$RecipeDtoToJson(_RecipeDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'menuItemId': instance.menuItemId,
      'versionNo': instance.versionNo,
      'status': _$RecipeStatusEnumMap[instance.status]!,
      'validFrom': const DateOnlyConverter().toJson(instance.validFrom),
      'yieldPortions': instance.yieldPortions.toJson(),
      'rowVersion': instance.rowVersion,
      'menuItemName': instance.menuItemName,
      'validTo': const NullableDateOnlyConverter().toJson(instance.validTo),
      'lineCount': instance.lineCount,
      'note': instance.note,
      'lines': instance.lines.map((e) => e.toJson()).toList(),
    };

_CreateRecipeVersionRequest _$CreateRecipeVersionRequestFromJson(
  Map<String, dynamic> json,
) => _CreateRecipeVersionRequest(
  validFrom: const DateOnlyConverter().fromJson(json['validFrom'] as String),
  yieldPortions: json['yieldPortions'] == null
      ? null
      : Quantity.fromJson(json['yieldPortions'] as String),
  copyFromRecipeId: (json['copyFromRecipeId'] as num?)?.toInt(),
  note: json['note'] as String?,
  lines:
      (json['lines'] as List<dynamic>?)
          ?.map((e) => RecipeLineInput.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <RecipeLineInput>[],
);

Map<String, dynamic> _$CreateRecipeVersionRequestToJson(
  _CreateRecipeVersionRequest instance,
) => <String, dynamic>{
  'validFrom': const DateOnlyConverter().toJson(instance.validFrom),
  'yieldPortions': instance.yieldPortions?.toJson(),
  'copyFromRecipeId': instance.copyFromRecipeId,
  'note': instance.note,
  'lines': instance.lines.map((e) => e.toJson()).toList(),
};

_UpdateRecipeRequest _$UpdateRecipeRequestFromJson(Map<String, dynamic> json) =>
    _UpdateRecipeRequest(
      rowVersion: (json['rowVersion'] as num).toInt(),
      lines: (json['lines'] as List<dynamic>)
          .map((e) => RecipeLineInput.fromJson(e as Map<String, dynamic>))
          .toList(),
      yieldPortions: json['yieldPortions'] == null
          ? null
          : Quantity.fromJson(json['yieldPortions'] as String),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$UpdateRecipeRequestToJson(
  _UpdateRecipeRequest instance,
) => <String, dynamic>{
  'rowVersion': instance.rowVersion,
  'lines': instance.lines.map((e) => e.toJson()).toList(),
  'yieldPortions': instance.yieldPortions?.toJson(),
  'note': instance.note,
};

_ActivateRecipeRequest _$ActivateRecipeRequestFromJson(
  Map<String, dynamic> json,
) => _ActivateRecipeRequest(
  validFrom: const DateOnlyConverter().fromJson(json['validFrom'] as String),
  rowVersion: (json['rowVersion'] as num).toInt(),
);

Map<String, dynamic> _$ActivateRecipeRequestToJson(
  _ActivateRecipeRequest instance,
) => <String, dynamic>{
  'validFrom': const DateOnlyConverter().toJson(instance.validFrom),
  'rowVersion': instance.rowVersion,
};

_RecipeExplosionLineDto _$RecipeExplosionLineDtoFromJson(
  Map<String, dynamic> json,
) => _RecipeExplosionLineDto(
  productId: (json['productId'] as num).toInt(),
  requiredQtyBase: Quantity.fromJson(json['requiredQtyBase'] as String),
  baseUomId: (json['baseUomId'] as num).toInt(),
  baseUomCode: json['baseUomCode'] as String,
  productSku: json['productSku'] as String?,
  productName: json['productName'] as String?,
  viaSubRecipe: json['viaSubRecipe'] as String?,
  depth: (json['depth'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$RecipeExplosionLineDtoToJson(
  _RecipeExplosionLineDto instance,
) => <String, dynamic>{
  'productId': instance.productId,
  'requiredQtyBase': instance.requiredQtyBase.toJson(),
  'baseUomId': instance.baseUomId,
  'baseUomCode': instance.baseUomCode,
  'productSku': instance.productSku,
  'productName': instance.productName,
  'viaSubRecipe': instance.viaSubRecipe,
  'depth': instance.depth,
};

_RecipeExplosionDto _$RecipeExplosionDtoFromJson(Map<String, dynamic> json) =>
    _RecipeExplosionDto(
      recipeId: (json['recipeId'] as num).toInt(),
      portions: Quantity.fromJson(json['portions'] as String),
      lines:
          (json['lines'] as List<dynamic>?)
              ?.map(
                (e) =>
                    RecipeExplosionLineDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <RecipeExplosionLineDto>[],
      menuItemName: json['menuItemName'] as String?,
      maxDepth: (json['maxDepth'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$RecipeExplosionDtoToJson(_RecipeExplosionDto instance) =>
    <String, dynamic>{
      'recipeId': instance.recipeId,
      'portions': instance.portions.toJson(),
      'lines': instance.lines.map((e) => e.toJson()).toList(),
      'menuItemName': instance.menuItemName,
      'maxDepth': instance.maxDepth,
    };

_SalesLineDto _$SalesLineDtoFromJson(Map<String, dynamic> json) =>
    _SalesLineDto(
      qtySold: Quantity.fromJson(json['qtySold'] as String),
      id: (json['id'] as num?)?.toInt(),
      menuItemId: (json['menuItemId'] as num?)?.toInt(),
      menuItemName: json['menuItemName'] as String?,
      rawPosCode: json['rawPosCode'] as String?,
      isMapped: json['isMapped'] as bool? ?? true,
      hasRecipe: json['hasRecipe'] as bool? ?? true,
      grossAmount: json['grossAmount'] == null
          ? null
          : Money.fromJson(json['grossAmount'] as String),
    );

Map<String, dynamic> _$SalesLineDtoToJson(_SalesLineDto instance) =>
    <String, dynamic>{
      'qtySold': instance.qtySold.toJson(),
      'id': instance.id,
      'menuItemId': instance.menuItemId,
      'menuItemName': instance.menuItemName,
      'rawPosCode': instance.rawPosCode,
      'isMapped': instance.isMapped,
      'hasRecipe': instance.hasRecipe,
      'grossAmount': instance.grossAmount?.toJson(),
    };

_SalesLineInput _$SalesLineInputFromJson(Map<String, dynamic> json) =>
    _SalesLineInput(
      qtySold: Quantity.fromJson(json['qtySold'] as String),
      menuItemId: (json['menuItemId'] as num?)?.toInt(),
      posCode: json['posCode'] as String?,
      grossAmount: json['grossAmount'] == null
          ? null
          : Money.fromJson(json['grossAmount'] as String),
    );

Map<String, dynamic> _$SalesLineInputToJson(_SalesLineInput instance) =>
    <String, dynamic>{
      'qtySold': instance.qtySold.toJson(),
      'menuItemId': instance.menuItemId,
      'posCode': instance.posCode,
      'grossAmount': instance.grossAmount?.toJson(),
    };

_SalesImportDto _$SalesImportDtoFromJson(Map<String, dynamic> json) =>
    _SalesImportDto(
      id: (json['id'] as num).toInt(),
      locationId: (json['locationId'] as num).toInt(),
      businessDate: const DateOnlyConverter().fromJson(
        json['businessDate'] as String,
      ),
      source: $enumDecode(_$SalesSourceEnumMap, json['source']),
      status: $enumDecode(_$SalesImportStatusEnumMap, json['status']),
      rowVersion: (json['rowVersion'] as num).toInt(),
      locationName: json['locationName'] as String?,
      externalRef: json['externalRef'] as String?,
      lineCount: (json['lineCount'] as num?)?.toInt() ?? 0,
      unmappedCount: (json['unmappedCount'] as num?)?.toInt() ?? 0,
      grossAmount: json['grossAmount'] == null
          ? null
          : Money.fromJson(json['grossAmount'] as String),
      importedAt: json['importedAt'] == null
          ? null
          : DateTime.parse(json['importedAt'] as String),
      consumptionRunId: (json['consumptionRunId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SalesImportDtoToJson(_SalesImportDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'locationId': instance.locationId,
      'businessDate': const DateOnlyConverter().toJson(instance.businessDate),
      'source': _$SalesSourceEnumMap[instance.source]!,
      'status': _$SalesImportStatusEnumMap[instance.status]!,
      'rowVersion': instance.rowVersion,
      'locationName': instance.locationName,
      'externalRef': instance.externalRef,
      'lineCount': instance.lineCount,
      'unmappedCount': instance.unmappedCount,
      'grossAmount': instance.grossAmount?.toJson(),
      'importedAt': instance.importedAt?.toIso8601String(),
      'consumptionRunId': instance.consumptionRunId,
    };

const _$SalesSourceEnumMap = {
  SalesSource.pos: 'POS',
  SalesSource.csv: 'CSV',
  SalesSource.manual: 'MANUAL',
};

const _$SalesImportStatusEnumMap = {
  SalesImportStatus.draft: 'DRAFT',
  SalesImportStatus.submitted: 'SUBMITTED',
  SalesImportStatus.consumed: 'CONSUMED',
  SalesImportStatus.cancelled: 'CANCELLED',
};

_SalesImportDetailDto _$SalesImportDetailDtoFromJson(
  Map<String, dynamic> json,
) => _SalesImportDetailDto(
  id: (json['id'] as num).toInt(),
  locationId: (json['locationId'] as num).toInt(),
  businessDate: const DateOnlyConverter().fromJson(
    json['businessDate'] as String,
  ),
  source: $enumDecode(_$SalesSourceEnumMap, json['source']),
  status: $enumDecode(_$SalesImportStatusEnumMap, json['status']),
  rowVersion: (json['rowVersion'] as num).toInt(),
  locationName: json['locationName'] as String?,
  externalRef: json['externalRef'] as String?,
  lineCount: (json['lineCount'] as num?)?.toInt() ?? 0,
  unmappedCount: (json['unmappedCount'] as num?)?.toInt() ?? 0,
  grossAmount: json['grossAmount'] == null
      ? null
      : Money.fromJson(json['grossAmount'] as String),
  importedAt: json['importedAt'] == null
      ? null
      : DateTime.parse(json['importedAt'] as String),
  consumptionRunId: (json['consumptionRunId'] as num?)?.toInt(),
  lines:
      (json['lines'] as List<dynamic>?)
          ?.map((e) => SalesLineDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <SalesLineDto>[],
);

Map<String, dynamic> _$SalesImportDetailDtoToJson(
  _SalesImportDetailDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'locationId': instance.locationId,
  'businessDate': const DateOnlyConverter().toJson(instance.businessDate),
  'source': _$SalesSourceEnumMap[instance.source]!,
  'status': _$SalesImportStatusEnumMap[instance.status]!,
  'rowVersion': instance.rowVersion,
  'locationName': instance.locationName,
  'externalRef': instance.externalRef,
  'lineCount': instance.lineCount,
  'unmappedCount': instance.unmappedCount,
  'grossAmount': instance.grossAmount?.toJson(),
  'importedAt': instance.importedAt?.toIso8601String(),
  'consumptionRunId': instance.consumptionRunId,
  'lines': instance.lines.map((e) => e.toJson()).toList(),
};

_CreateSalesImportRequest _$CreateSalesImportRequestFromJson(
  Map<String, dynamic> json,
) => _CreateSalesImportRequest(
  locationId: (json['locationId'] as num).toInt(),
  businessDate: const DateOnlyConverter().fromJson(
    json['businessDate'] as String,
  ),
  source: $enumDecode(_$SalesSourceEnumMap, json['source']),
  lines: (json['lines'] as List<dynamic>)
      .map((e) => SalesLineInput.fromJson(e as Map<String, dynamic>))
      .toList(),
  externalRef: json['externalRef'] as String?,
);

Map<String, dynamic> _$CreateSalesImportRequestToJson(
  _CreateSalesImportRequest instance,
) => <String, dynamic>{
  'locationId': instance.locationId,
  'businessDate': const DateOnlyConverter().toJson(instance.businessDate),
  'source': _$SalesSourceEnumMap[instance.source]!,
  'lines': instance.lines.map((e) => e.toJson()).toList(),
  'externalRef': instance.externalRef,
};

_UpdateSalesImportRequest _$UpdateSalesImportRequestFromJson(
  Map<String, dynamic> json,
) => _UpdateSalesImportRequest(
  rowVersion: (json['rowVersion'] as num).toInt(),
  lines: (json['lines'] as List<dynamic>)
      .map((e) => SalesLineInput.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$UpdateSalesImportRequestToJson(
  _UpdateSalesImportRequest instance,
) => <String, dynamic>{
  'rowVersion': instance.rowVersion,
  'lines': instance.lines.map((e) => e.toJson()).toList(),
};

_SalesParseErrorDto _$SalesParseErrorDtoFromJson(Map<String, dynamic> json) =>
    _SalesParseErrorDto(
      rowNumber: (json['rowNumber'] as num).toInt(),
      message: json['message'] as String,
      rawLine: json['rawLine'] as String?,
    );

Map<String, dynamic> _$SalesParseErrorDtoToJson(_SalesParseErrorDto instance) =>
    <String, dynamic>{
      'rowNumber': instance.rowNumber,
      'message': instance.message,
      'rawLine': instance.rawLine,
    };

_SalesImportParseResultDto _$SalesImportParseResultDtoFromJson(
  Map<String, dynamic> json,
) => _SalesImportParseResultDto(
  salesImport: SalesImportDetailDto.fromJson(
    json['salesImport'] as Map<String, dynamic>,
  ),
  parsedRows: (json['parsedRows'] as num?)?.toInt() ?? 0,
  parseErrors:
      (json['parseErrors'] as List<dynamic>?)
          ?.map((e) => SalesParseErrorDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <SalesParseErrorDto>[],
);

Map<String, dynamic> _$SalesImportParseResultDtoToJson(
  _SalesImportParseResultDto instance,
) => <String, dynamic>{
  'salesImport': instance.salesImport.toJson(),
  'parsedRows': instance.parsedRows,
  'parseErrors': instance.parseErrors.map((e) => e.toJson()).toList(),
};

_SalesCsvColumnMapping _$SalesCsvColumnMappingFromJson(
  Map<String, dynamic> json,
) => _SalesCsvColumnMapping(
  posCode: json['posCode'] as String?,
  qtySold: json['qtySold'] as String?,
  grossAmount: json['grossAmount'] as String?,
);

Map<String, dynamic> _$SalesCsvColumnMappingToJson(
  _SalesCsvColumnMapping instance,
) => <String, dynamic>{
  'posCode': instance.posCode,
  'qtySold': instance.qtySold,
  'grossAmount': instance.grossAmount,
};

_ConsumptionRunLineDto _$ConsumptionRunLineDtoFromJson(
  Map<String, dynamic> json,
) => _ConsumptionRunLineDto(
  productId: (json['productId'] as num).toInt(),
  theoreticalQtyBase: Quantity.fromJson(json['theoreticalQtyBase'] as String),
  postedQtyBase: Quantity.fromJson(json['postedQtyBase'] as String),
  shortfallQtyBase: Quantity.fromJson(json['shortfallQtyBase'] as String),
  baseUomId: (json['baseUomId'] as num).toInt(),
  productSku: json['productSku'] as String?,
  productName: json['productName'] as String?,
  baseUomCode: json['baseUomCode'] as String?,
  unitCost: json['unitCost'] == null
      ? null
      : Money.fromJson(json['unitCost'] as String),
  costAmount: json['costAmount'] == null
      ? null
      : Money.fromJson(json['costAmount'] as String),
);

Map<String, dynamic> _$ConsumptionRunLineDtoToJson(
  _ConsumptionRunLineDto instance,
) => <String, dynamic>{
  'productId': instance.productId,
  'theoreticalQtyBase': instance.theoreticalQtyBase.toJson(),
  'postedQtyBase': instance.postedQtyBase.toJson(),
  'shortfallQtyBase': instance.shortfallQtyBase.toJson(),
  'baseUomId': instance.baseUomId,
  'productSku': instance.productSku,
  'productName': instance.productName,
  'baseUomCode': instance.baseUomCode,
  'unitCost': instance.unitCost?.toJson(),
  'costAmount': instance.costAmount?.toJson(),
};

_ConsumptionRunDto _$ConsumptionRunDtoFromJson(Map<String, dynamic> json) =>
    _ConsumptionRunDto(
      id: (json['id'] as num).toInt(),
      docNo: json['docNo'] as String,
      locationId: (json['locationId'] as num).toInt(),
      businessDate: const DateOnlyConverter().fromJson(
        json['businessDate'] as String,
      ),
      status: $enumDecode(_$ConsumptionRunStatusEnumMap, json['status']),
      rowVersion: (json['rowVersion'] as num).toInt(),
      locationName: json['locationName'] as String?,
      salesImportId: (json['salesImportId'] as num?)?.toInt(),
      movementGroupId: (json['movementGroupId'] as num?)?.toInt(),
      shortfallCount: (json['shortfallCount'] as num?)?.toInt() ?? 0,
      unmappedCount: (json['unmappedCount'] as num?)?.toInt() ?? 0,
      failureReason: json['failureReason'] as String?,
      calculatedAt: json['calculatedAt'] == null
          ? null
          : DateTime.parse(json['calculatedAt'] as String),
      postedAt: json['postedAt'] == null
          ? null
          : DateTime.parse(json['postedAt'] as String),
    );

Map<String, dynamic> _$ConsumptionRunDtoToJson(_ConsumptionRunDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'docNo': instance.docNo,
      'locationId': instance.locationId,
      'businessDate': const DateOnlyConverter().toJson(instance.businessDate),
      'status': _$ConsumptionRunStatusEnumMap[instance.status]!,
      'rowVersion': instance.rowVersion,
      'locationName': instance.locationName,
      'salesImportId': instance.salesImportId,
      'movementGroupId': instance.movementGroupId,
      'shortfallCount': instance.shortfallCount,
      'unmappedCount': instance.unmappedCount,
      'failureReason': instance.failureReason,
      'calculatedAt': instance.calculatedAt?.toIso8601String(),
      'postedAt': instance.postedAt?.toIso8601String(),
    };

const _$ConsumptionRunStatusEnumMap = {
  ConsumptionRunStatus.draft: 'DRAFT',
  ConsumptionRunStatus.calculated: 'CALCULATED',
  ConsumptionRunStatus.posted: 'POSTED',
  ConsumptionRunStatus.failed: 'FAILED',
  ConsumptionRunStatus.reversed: 'REVERSED',
};

_ConsumptionRunDetailDto _$ConsumptionRunDetailDtoFromJson(
  Map<String, dynamic> json,
) => _ConsumptionRunDetailDto(
  id: (json['id'] as num).toInt(),
  docNo: json['docNo'] as String,
  locationId: (json['locationId'] as num).toInt(),
  businessDate: const DateOnlyConverter().fromJson(
    json['businessDate'] as String,
  ),
  status: $enumDecode(_$ConsumptionRunStatusEnumMap, json['status']),
  rowVersion: (json['rowVersion'] as num).toInt(),
  locationName: json['locationName'] as String?,
  salesImportId: (json['salesImportId'] as num?)?.toInt(),
  movementGroupId: (json['movementGroupId'] as num?)?.toInt(),
  shortfallCount: (json['shortfallCount'] as num?)?.toInt() ?? 0,
  unmappedCount: (json['unmappedCount'] as num?)?.toInt() ?? 0,
  failureReason: json['failureReason'] as String?,
  calculatedAt: json['calculatedAt'] == null
      ? null
      : DateTime.parse(json['calculatedAt'] as String),
  postedAt: json['postedAt'] == null
      ? null
      : DateTime.parse(json['postedAt'] as String),
  lines:
      (json['lines'] as List<dynamic>?)
          ?.map(
            (e) => ConsumptionRunLineDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <ConsumptionRunLineDto>[],
  totalCostAmount: json['totalCostAmount'] == null
      ? null
      : Money.fromJson(json['totalCostAmount'] as String),
);

Map<String, dynamic> _$ConsumptionRunDetailDtoToJson(
  _ConsumptionRunDetailDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'docNo': instance.docNo,
  'locationId': instance.locationId,
  'businessDate': const DateOnlyConverter().toJson(instance.businessDate),
  'status': _$ConsumptionRunStatusEnumMap[instance.status]!,
  'rowVersion': instance.rowVersion,
  'locationName': instance.locationName,
  'salesImportId': instance.salesImportId,
  'movementGroupId': instance.movementGroupId,
  'shortfallCount': instance.shortfallCount,
  'unmappedCount': instance.unmappedCount,
  'failureReason': instance.failureReason,
  'calculatedAt': instance.calculatedAt?.toIso8601String(),
  'postedAt': instance.postedAt?.toIso8601String(),
  'lines': instance.lines.map((e) => e.toJson()).toList(),
  'totalCostAmount': instance.totalCostAmount?.toJson(),
};

_CreateConsumptionRunRequest _$CreateConsumptionRunRequestFromJson(
  Map<String, dynamic> json,
) => _CreateConsumptionRunRequest(
  salesImportId: (json['salesImportId'] as num).toInt(),
  postImmediately: json['postImmediately'] as bool? ?? false,
);

Map<String, dynamic> _$CreateConsumptionRunRequestToJson(
  _CreateConsumptionRunRequest instance,
) => <String, dynamic>{
  'salesImportId': instance.salesImportId,
  'postImmediately': instance.postImmediately,
};

_ConsumptionVersionedAction _$ConsumptionVersionedActionFromJson(
  Map<String, dynamic> json,
) => _ConsumptionVersionedAction(
  rowVersion: (json['rowVersion'] as num).toInt(),
);

Map<String, dynamic> _$ConsumptionVersionedActionToJson(
  _ConsumptionVersionedAction instance,
) => <String, dynamic>{'rowVersion': instance.rowVersion};

_ReverseConsumptionRunRequest _$ReverseConsumptionRunRequestFromJson(
  Map<String, dynamic> json,
) => _ReverseConsumptionRunRequest(
  reasonCodeId: (json['reasonCodeId'] as num).toInt(),
  note: json['note'] as String?,
);

Map<String, dynamic> _$ReverseConsumptionRunRequestToJson(
  _ReverseConsumptionRunRequest instance,
) => <String, dynamic>{
  'reasonCodeId': instance.reasonCodeId,
  'note': instance.note,
};

_ConsumptionVarianceLineDto _$ConsumptionVarianceLineDtoFromJson(
  Map<String, dynamic> json,
) => _ConsumptionVarianceLineDto(
  productId: (json['productId'] as num).toInt(),
  locationId: (json['locationId'] as num).toInt(),
  openingQty: Quantity.fromJson(json['openingQty'] as String),
  receivedQty: Quantity.fromJson(json['receivedQty'] as String),
  theoreticalConsumedQty: Quantity.fromJson(
    json['theoreticalConsumedQty'] as String,
  ),
  wasteQty: Quantity.fromJson(json['wasteQty'] as String),
  expectedQty: Quantity.fromJson(json['expectedQty'] as String),
  countedQty: Quantity.fromJson(json['countedQty'] as String),
  varianceQty: Quantity.fromJson(json['varianceQty'] as String),
  productSku: json['productSku'] as String?,
  productName: json['productName'] as String?,
  locationName: json['locationName'] as String?,
  baseUomCode: json['baseUomCode'] as String?,
  sampleQty: json['sampleQty'] == null
      ? null
      : Quantity.fromJson(json['sampleQty'] as String),
  transferNetQty: json['transferNetQty'] == null
      ? null
      : Quantity.fromJson(json['transferNetQty'] as String),
  variancePct: json['variancePct'] == null
      ? null
      : Decimal.fromJson(json['variancePct'] as String),
  varianceValue: json['varianceValue'] == null
      ? null
      : Money.fromJson(json['varianceValue'] as String),
);

Map<String, dynamic> _$ConsumptionVarianceLineDtoToJson(
  _ConsumptionVarianceLineDto instance,
) => <String, dynamic>{
  'productId': instance.productId,
  'locationId': instance.locationId,
  'openingQty': instance.openingQty.toJson(),
  'receivedQty': instance.receivedQty.toJson(),
  'theoreticalConsumedQty': instance.theoreticalConsumedQty.toJson(),
  'wasteQty': instance.wasteQty.toJson(),
  'expectedQty': instance.expectedQty.toJson(),
  'countedQty': instance.countedQty.toJson(),
  'varianceQty': instance.varianceQty.toJson(),
  'productSku': instance.productSku,
  'productName': instance.productName,
  'locationName': instance.locationName,
  'baseUomCode': instance.baseUomCode,
  'sampleQty': instance.sampleQty?.toJson(),
  'transferNetQty': instance.transferNetQty?.toJson(),
  'variancePct': instance.variancePct?.toJson(),
  'varianceValue': instance.varianceValue?.toJson(),
};

_ConsumptionVariancePageDto _$ConsumptionVariancePageDtoFromJson(
  Map<String, dynamic> json,
) => _ConsumptionVariancePageDto(
  periodFrom: const DateOnlyConverter().fromJson(json['periodFrom'] as String),
  periodTo: const DateOnlyConverter().fromJson(json['periodTo'] as String),
  items:
      (json['items'] as List<dynamic>?)
          ?.map(
            (e) =>
                ConsumptionVarianceLineDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <ConsumptionVarianceLineDto>[],
  page: (json['page'] as num?)?.toInt() ?? 1,
  size: (json['size'] as num?)?.toInt() ?? 50,
  total: (json['total'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ConsumptionVariancePageDtoToJson(
  _ConsumptionVariancePageDto instance,
) => <String, dynamic>{
  'periodFrom': const DateOnlyConverter().toJson(instance.periodFrom),
  'periodTo': const DateOnlyConverter().toJson(instance.periodTo),
  'items': instance.items.map((e) => e.toJson()).toList(),
  'page': instance.page,
  'size': instance.size,
  'total': instance.total,
};

_PortionComplianceLineDto _$PortionComplianceLineDtoFromJson(
  Map<String, dynamic> json,
) => _PortionComplianceLineDto(
  menuItemId: (json['menuItemId'] as num).toInt(),
  productId: (json['productId'] as num).toInt(),
  portionsSold: Quantity.fromJson(json['portionsSold'] as String),
  recipeQtyPerPortion: Quantity.fromJson(json['recipeQtyPerPortion'] as String),
  actualQtyPerPortion: Quantity.fromJson(json['actualQtyPerPortion'] as String),
  compliancePct: Decimal.fromJson(json['compliancePct'] as String),
  menuItemName: json['menuItemName'] as String?,
  productName: json['productName'] as String?,
  baseUomCode: json['baseUomCode'] as String?,
);

Map<String, dynamic> _$PortionComplianceLineDtoToJson(
  _PortionComplianceLineDto instance,
) => <String, dynamic>{
  'menuItemId': instance.menuItemId,
  'productId': instance.productId,
  'portionsSold': instance.portionsSold.toJson(),
  'recipeQtyPerPortion': instance.recipeQtyPerPortion.toJson(),
  'actualQtyPerPortion': instance.actualQtyPerPortion.toJson(),
  'compliancePct': instance.compliancePct.toJson(),
  'menuItemName': instance.menuItemName,
  'productName': instance.productName,
  'baseUomCode': instance.baseUomCode,
};
