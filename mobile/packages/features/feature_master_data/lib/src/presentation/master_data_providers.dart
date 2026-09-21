import 'package:feature_identity/feature_identity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

import '../data/master_data_repository_impl.dart';
import '../domain/master_data_repository.dart';

final masterDataRepositoryProvider = Provider<MasterDataRepository>(
  (ref) => MasterDataRepositoryImpl(ref.watch(apiClientProvider).masterData),
);

/// Free-text filter of the product list.
final productSearchProvider = NotifierProvider<ProductSearchNotifier, String>(
  ProductSearchNotifier.new,
);

class ProductSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  // ignore: use_setters_to_change_properties
  void setSearch(String value) => state = value;
}

/// Paged product list; re-runs whenever the search text changes.
final productListProvider =
    AsyncNotifierProvider<ProductListNotifier, Page<ProductDto>>(
      ProductListNotifier.new,
    );

class ProductListNotifier extends AsyncNotifier<Page<ProductDto>> {
  @override
  Future<Page<ProductDto>> build() async {
    final search = ref.watch(productSearchProvider);
    final result = await ref
        .watch(masterDataRepositoryProvider)
        .products(search: search.isEmpty ? null : search);
    return result.getOrThrow();
  }

  Future<void> loadPage(int page) async {
    state = const AsyncValue<Page<ProductDto>>.loading();
    state = await AsyncValue.guard(() async {
      final search = ref.read(productSearchProvider);
      final result = await ref
          .read(masterDataRepositoryProvider)
          .products(
            search: search.isEmpty ? null : search,
            page: PageRequest(page: page),
          );
      return result.getOrThrow();
    });
  }

  Future<void> refresh() => loadPage(state.value?.page ?? 1);
}

final productDetailProvider = FutureProvider.family<ProductDto, int>((
  ref,
  id,
) async {
  final result = await ref.watch(masterDataRepositoryProvider).product(id);
  return result.getOrThrow();
});

final supplierListProvider = FutureProvider<Page<SupplierDto>>((ref) async {
  final result = await ref.watch(masterDataRepositoryProvider).suppliers();
  return result.getOrThrow();
});

/// Physical locations the user may see (`iam_user_location` filtered).
final locationListProvider = FutureProvider<List<LocationDto>>((ref) async {
  final result = await ref.watch(masterDataRepositoryProvider).locations();
  return result.getOrThrow();
});

final uomListProvider = FutureProvider<List<UomDto>>((ref) async {
  final result = await ref.watch(masterDataRepositoryProvider).uoms();
  return result.getOrThrow();
});

/// Reason codes of one group (`WASTE`, `ADJUSTMENT`, ...).
final reasonCodeListProvider =
    FutureProvider.family<List<ReasonCodeDto>, ReasonGroup>((ref, group) async {
      final result = await ref
          .watch(masterDataRepositoryProvider)
          .reasonCodes(group: group);
      return result.getOrThrow();
    });
