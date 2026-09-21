import 'package:feature_master_data/feature_master_data.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

/// In-memory [MasterDataRepository] for widget tests.
class FakeMasterDataRepository implements MasterDataRepository {
  FakeMasterDataRepository({
    this.allProducts = const [],
    this.allSuppliers = const [],
    this.allLocations = const [],
    this.allUoms = const [],
    this.allReasonCodes = const [],
    this.failure,
  });

  final List<ProductDto> allProducts;
  final List<SupplierDto> allSuppliers;
  final List<LocationDto> allLocations;
  final List<UomDto> allUoms;
  final List<ReasonCodeDto> allReasonCodes;

  /// When set, every call fails with it.
  final Failure? failure;

  Result<T> _ok<T>(T value) =>
      failure == null ? Result<T>.ok(value) : Result<T>.err(failure!);

  Page<T> _page<T>(List<T> items) =>
      Page<T>(items: items, page: 1, size: 50, total: items.length);

  @override
  Future<Result<Page<ProductDto>>> products({
    String? search,
    int? categoryId,
    ProductType? productType,
    PageRequest page = const PageRequest(),
  }) async => _ok(_page(allProducts));

  @override
  Future<Result<ProductDto>> product(int id) async =>
      _ok(allProducts.firstWhere((p) => p.id == id));

  @override
  Future<Result<ProductDto>> productByBarcode(String barcode) async =>
      _ok(allProducts.firstWhere((p) => p.barcode == barcode));

  @override
  Future<Result<Page<SupplierDto>>> suppliers({
    String? search,
    PageRequest page = const PageRequest(),
  }) async => _ok(_page(allSuppliers));

  @override
  Future<Result<List<LocationDto>>> locations({
    LocationType? locationType,
    bool includeVirtual = false,
  }) async => _ok(allLocations);

  @override
  Future<Result<List<UomDto>>> uoms() async => _ok(allUoms);

  @override
  Future<Result<List<ReasonCodeDto>>> reasonCodes({ReasonGroup? group}) async =>
      _ok(allReasonCodes);
}
