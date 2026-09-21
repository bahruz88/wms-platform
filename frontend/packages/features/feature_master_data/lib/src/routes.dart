import 'package:go_router/go_router.dart';

import 'navigation.dart';
import 'presentation/location_list_screen.dart';
import 'presentation/product_detail_screen.dart';
import 'presentation/product_list_screen.dart';
import 'presentation/supplier_list_screen.dart';
import 'presentation/uom_list_screen.dart';

/// Routes contributed by the master data feature.
List<RouteBase> masterDataRoutes() => [
  GoRoute(
    name: MasterDataRoutes.productsName,
    path: MasterDataRoutes.productsPath,
    builder: (context, state) => const ProductListScreen(),
    routes: [
      GoRoute(
        name: MasterDataRoutes.productDetailName,
        path: MasterDataRoutes.productDetailPath,
        builder: (context, state) => ProductDetailScreen(
          productId: int.parse(state.pathParameters['productId']!),
        ),
      ),
    ],
  ),
  GoRoute(
    name: MasterDataRoutes.suppliersName,
    path: MasterDataRoutes.suppliersPath,
    builder: (context, state) => const SupplierListScreen(),
  ),
  GoRoute(
    name: MasterDataRoutes.locationsName,
    path: MasterDataRoutes.locationsPath,
    builder: (context, state) => const LocationListScreen(),
  ),
  GoRoute(
    name: MasterDataRoutes.uomsName,
    path: MasterDataRoutes.uomsPath,
    builder: (context, state) => const UomListScreen(),
  ),
];
