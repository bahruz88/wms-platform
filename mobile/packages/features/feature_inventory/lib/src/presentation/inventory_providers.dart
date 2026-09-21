import 'package:feature_identity/feature_identity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

import '../data/inventory_repository_impl.dart';
import '../domain/barcode_scanner.dart';
import '../domain/inventory_repository.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>(
  (ref) => InventoryRepositoryImpl(ref.watch(apiClientProvider).inventory),
);

/// Overridden by the mobile app with a camera-backed implementation.
final barcodeScannerProvider = Provider<BarcodeScanner>(
  (ref) => const UnsupportedBarcodeScanner(),
);

/// Balance filters (location / product / free text).
@immutable
class BalanceFilter {
  const BalanceFilter({this.locationId, this.productId, this.search});

  final int? locationId;
  final int? productId;
  final String? search;

  BalanceFilter copyWith({
    int? locationId,
    int? productId,
    String? search,
    bool clearLocation = false,
  }) => BalanceFilter(
    locationId: clearLocation ? null : (locationId ?? this.locationId),
    productId: productId ?? this.productId,
    search: search ?? this.search,
  );

  @override
  bool operator ==(Object other) =>
      other is BalanceFilter &&
      other.locationId == locationId &&
      other.productId == productId &&
      other.search == search;

  @override
  int get hashCode => Object.hash(locationId, productId, search);
}

final balanceFilterProvider =
    NotifierProvider<BalanceFilterNotifier, BalanceFilter>(
      BalanceFilterNotifier.new,
    );

class BalanceFilterNotifier extends Notifier<BalanceFilter> {
  @override
  BalanceFilter build() => const BalanceFilter();

  // ignore: use_setters_to_change_properties
  void setFilter(BalanceFilter filter) => state = filter;

  void setLocation(int? locationId) => state = state.copyWith(
    locationId: locationId,
    clearLocation: locationId == null,
  );

  void setSearch(String? search) => state = state.copyWith(search: search);

  void setProduct(int? productId) =>
      state = BalanceFilter(productId: productId);
}

final balancesProvider =
    AsyncNotifierProvider<BalancesNotifier, Page<BalanceDto>>(
      BalancesNotifier.new,
    );

class BalancesNotifier extends AsyncNotifier<Page<BalanceDto>> {
  @override
  Future<Page<BalanceDto>> build() => _load(1);

  Future<Page<BalanceDto>> _load(int page) async {
    final filter = ref.watch(balanceFilterProvider);
    final result = await ref
        .watch(inventoryRepositoryProvider)
        .balances(
          locationId: filter.locationId,
          productId: filter.productId,
          search: filter.search,
          page: PageRequest(page: page),
        );
    return result.getOrThrow();
  }

  Future<void> loadPage(int page) async {
    state = const AsyncValue<Page<BalanceDto>>.loading();
    state = await AsyncValue.guard(() => _load(page));
  }

  Future<void> refresh() => loadPage(state.value?.page ?? 1);
}

final goodsReceiptListProvider = FutureProvider<Page<GoodsReceiptDto>>((
  ref,
) async {
  final result = await ref.watch(inventoryRepositoryProvider).goodsReceipts();
  return result.getOrThrow();
});

/// Issues heading to the user's locations that still wait for confirmation.
final issueListProvider = FutureProvider.family<Page<IssueDto>, IssueStatus?>((
  ref,
  status,
) async {
  final result = await ref
      .watch(inventoryRepositoryProvider)
      .issues(status: status);
  return result.getOrThrow();
});

final issueDetailProvider = FutureProvider.family<IssueDto, int>((
  ref,
  id,
) async {
  final result = await ref.watch(inventoryRepositoryProvider).issue(id);
  return result.getOrThrow();
});

final countListProvider = FutureProvider<Page<CountDto>>((ref) async {
  final result = await ref.watch(inventoryRepositoryProvider).counts();
  return result.getOrThrow();
});

final countDetailProvider = FutureProvider.family<CountDto, int>((
  ref,
  id,
) async {
  final result = await ref.watch(inventoryRepositoryProvider).count(id);
  return result.getOrThrow();
});

final wasteListProvider = FutureProvider<Page<WasteDto>>((ref) async {
  final result = await ref.watch(inventoryRepositoryProvider).wasteDocuments();
  return result.getOrThrow();
});

/// `inv_setting` list for the admin section.
final inventorySettingsProvider = FutureProvider<List<InventorySettingDto>>((
  ref,
) async {
  final result = await ref.watch(inventoryRepositoryProvider).settings();
  return result.getOrThrow();
});
