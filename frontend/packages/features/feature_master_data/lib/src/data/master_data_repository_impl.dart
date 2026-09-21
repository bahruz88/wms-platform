import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

import '../domain/master_data_repository.dart';

class MasterDataRepositoryImpl implements MasterDataRepository {
  MasterDataRepositoryImpl(this._api);

  final MasterDataApi _api;

  @override
  Future<Result<Page<ProductDto>>> products({
    String? search,
    int? categoryId,
    ProductType? productType,
    PageRequest page = const PageRequest(),
  }) => Result.guard(
    () => _api.listProducts(
      search: search,
      categoryId: categoryId,
      productType: productType,
      page: page,
    ),
  );

  @override
  Future<Result<ProductDto>> product(int id) =>
      Result.guard(() => _api.getProduct(id));

  @override
  Future<Result<ProductDto>> productByBarcode(String barcode) =>
      Result.guard(() => _api.getProductByBarcode(barcode));

  @override
  Future<Result<Page<SupplierDto>>> suppliers({
    String? search,
    PageRequest page = const PageRequest(),
  }) => Result.guard(() => _api.listSuppliers(search: search, page: page));

  @override
  Future<Result<List<LocationDto>>> locations({
    LocationType? locationType,
    bool includeVirtual = false,
  }) => Result.guard(
    () => _api.listLocations(
      locationType: locationType,
      includeVirtual: includeVirtual,
    ),
  );

  @override
  Future<Result<List<UomDto>>> uoms() => Result.guard(_api.listUoms);

  @override
  Future<Result<List<ReasonCodeDto>>> reasonCodes({ReasonGroup? group}) =>
      Result.guard(() => _api.listReasonCodes(group: group));
}
