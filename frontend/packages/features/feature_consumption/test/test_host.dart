import 'package:feature_consumption/feature_consumption.dart';
import 'package:feature_master_data/feature_master_data.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import 'fake_consumption_repository.dart';

/// Session with the given permissions and one branch location, which is
/// what the mobile screens read to know where the user works.
Session consumptionSession({
  Set<String> permissions = const {},
  List<int> locationIds = const [1],
}) => Session(
  accessToken: 'token',
  userId: 'u1',
  username: 'branch1',
  tenantId: 1,
  permissions: permissions,
  locationIds: locationIds,
);

/// Wraps [child] in the providers every consumption screen reads.
Widget consumptionHost({
  required Widget child,
  required FakeConsumptionRepository repository,
  Set<String> permissions = const {},
  List<int> locationIds = const [1],
  List<ProductDto> products = const [],
  List<UomDto> uoms = const [],
  List<LocationDto> locations = const [],
  List<ReasonCodeDto> reasonCodes = const [],
  CsvFilePicker picker = const UnsupportedCsvFilePicker(),
}) => ProviderScope(
  overrides: [
    consumptionRepositoryProvider.overrideWithValue(repository),
    csvFilePickerProvider.overrideWithValue(picker),
    sessionProvider.overrideWithValue(
      consumptionSession(permissions: permissions, locationIds: locationIds),
    ),
    locationListProvider.overrideWith((ref) async => locations),
    uomListProvider.overrideWith((ref) async => uoms),
    productListProvider.overrideWith(() => _StaticProductList(products)),
    reasonCodeListProvider.overrideWith((ref, group) async => reasonCodes),
  ],
  child: MaterialApp(
    theme: WmsTheme.light(),
    locale: WmsL10n.defaultLocale,
    supportedLocales: WmsL10n.supportedLocales,
    localizationsDelegates: WmsL10n.delegates,
    home: child,
  ),
);

class _StaticProductList extends ProductListNotifier {
  _StaticProductList(this.products);

  final List<ProductDto> products;

  @override
  Future<Page<ProductDto>> build() async => Page<ProductDto>(
    items: products,
    page: 1,
    size: 50,
    total: products.length,
  );
}
