/// Route names and paths of the master data feature.
abstract final class MasterDataRoutes {
  static const String productsName = 'products';
  static const String productsPath = '/master-data/products';

  static const String productDetailName = 'product-detail';

  /// Child path of [productsPath].
  static const String productDetailPath = ':productId';
  static String productDetail(int id) => '$productsPath/$id';

  static const String suppliersName = 'suppliers';
  static const String suppliersPath = '/master-data/suppliers';

  static const String locationsName = 'locations';
  static const String locationsPath = '/master-data/locations';

  static const String uomsName = 'uoms';
  static const String uomsPath = '/master-data/uoms';
}
