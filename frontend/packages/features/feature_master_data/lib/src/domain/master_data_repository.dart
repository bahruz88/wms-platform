import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

/// Master data reads used across the app (product pickers, location filters,
/// reason codes). Cost fields inside [ProductDto] are absent for users
/// without `master.product.view_cost` — the UI must not synthesise them.
abstract interface class MasterDataRepository {
  Future<Result<Page<ProductDto>>> products({
    String? search,
    int? categoryId,
    ProductType? productType,
    PageRequest page,
  });

  Future<Result<ProductDto>> product(int id);

  Future<Result<ProductDto>> productByBarcode(String barcode);

  Future<Result<Page<SupplierDto>>> suppliers({
    String? search,
    PageRequest page,
  });

  Future<Result<List<LocationDto>>> locations({
    LocationType? locationType,
    bool includeVirtual,
  });

  Future<Result<List<UomDto>>> uoms();

  Future<Result<List<ReasonCodeDto>>> reasonCodes({ReasonGroup? group});
}
