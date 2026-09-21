import 'package:dio/dio.dart';
import 'package:wms_core/wms_core.dart';

import '../dto/master_data/master_data_dtos.dart';
import 'module_api.dart';

/// `/api/v1/masterdata/*`.
class MasterDataApi extends ModuleApi {
  MasterDataApi(Dio dio) : super(dio, '/masterdata');

  Future<Page<ProductDto>> listProducts({
    String? search,
    int? categoryId,
    ProductType? productType,
    bool? isActive,
    PageRequest page = const PageRequest(),
    CancelToken? cancelToken,
  }) => getPage(
    'products',
    fromJson: ProductDto.fromJson,
    page: page,
    query: {
      'search': search,
      'categoryId': categoryId,
      'productType': productType,
      'isActive': isActive,
    },
    cancelToken: cancelToken,
  );

  Future<ProductDto> getProduct(int id) =>
      getObject('products/$id', fromJson: ProductDto.fromJson);

  /// Barcode lookup used by the scanner entry point.
  Future<ProductDto> getProductByBarcode(String barcode) => getObject(
    'products/by-barcode/${Uri.encodeComponent(barcode)}',
    fromJson: ProductDto.fromJson,
  );

  Future<List<ProductCategoryDto>> listCategories({ProductType? productType}) =>
      getList(
        'categories',
        fromJson: ProductCategoryDto.fromJson,
        query: {'productType': productType},
      );

  Future<List<UomDto>> listUoms() => getList('uoms', fromJson: UomDto.fromJson);

  Future<Page<SupplierDto>> listSuppliers({
    String? search,
    bool? isActive,
    bool? approvedFoodOnly,
    PageRequest page = const PageRequest(),
  }) => getPage(
    'suppliers',
    fromJson: SupplierDto.fromJson,
    page: page,
    query: {
      'search': search,
      'isActive': isActive,
      'approvedFoodOnly': approvedFoodOnly,
    },
  );

  Future<SupplierDto> getSupplier(int id) =>
      getObject('suppliers/$id', fromJson: SupplierDto.fromJson);

  /// All locations visible to the caller (filtered by `iam_user_location`).
  Future<List<LocationDto>> listLocations({
    LocationType? locationType,
    bool? includeVirtual,
  }) => getList(
    'locations',
    fromJson: LocationDto.fromJson,
    query: {'locationType': locationType, 'includeVirtual': includeVirtual},
  );

  Future<List<ReasonCodeDto>> listReasonCodes({ReasonGroup? group}) => getList(
    'reason-codes',
    fromJson: ReasonCodeDto.fromJson,
    query: {'group': group},
  );
}
