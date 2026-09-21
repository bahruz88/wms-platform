import 'package:feature_inventory/feature_inventory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import 'fake_inventory_repository.dart';

const _settings = [
  InventorySettingDto(
    key: 'expiry_warning_days',
    value: '14',
    valueType: SettingValueType.intValue,
    description: 'Bitməyə qalan gün sayı',
  ),
  InventorySettingDto(
    key: 'costing_method',
    value: 'MOVING_AVERAGE',
    valueType: SettingValueType.enumValue,
    allowedValues: ['MOVING_AVERAGE', 'FIFO'],
  ),
  InventorySettingDto(
    key: 'allow_negative_stock',
    value: 'false',
    valueType: SettingValueType.boolValue,
  ),
  InventorySettingDto(
    key: 'future_key_we_do_not_know',
    value: '1',
    valueType: SettingValueType.intValue,
  ),
];

Widget host({Set<String> permissions = const {Permissions.userManage}}) =>
    ProviderScope(
      overrides: [
        inventoryRepositoryProvider.overrideWithValue(
          FakeInventoryRepository(settingList: _settings),
        ),
        sessionProvider.overrideWithValue(
          Session(
            accessToken: 'token',
            userId: 'u1',
            username: 'admin',
            tenantId: 1,
            permissions: permissions,
          ),
        ),
      ],
      child: MaterialApp(
        theme: WmsTheme.light(),
        locale: WmsL10n.defaultLocale,
        supportedLocales: WmsL10n.supportedLocales,
        localizationsDelegates: WmsL10n.delegates,
        home: const InventorySettingsScreen(),
      ),
    );

void main() {
  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first
          ..physicalSize = const Size(1400, 900)
          ..devicePixelRatio = 1;
    addTearDown(view.reset);
  });

  testWidgets('renders inv_setting rows with Azerbaijani labels', (
    tester,
  ) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    expect(find.text('Bitmə xəbərdarlığı (gün)'), findsOneWidget);
    expect(find.text('expiry_warning_days'), findsOneWidget);
    expect(find.text('14'), findsOneWidget);
    expect(find.text('Maya dəyəri metodu'), findsOneWidget);
    expect(find.text('MOVING_AVERAGE, FIFO'), findsOneWidget);
  });

  testWidgets('BOOL values read as words, unknown keys keep their key', (
    tester,
  ) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    expect(find.text('xeyr'), findsOneWidget);
    // An unknown key must still be listed, with the raw key as its label.
    expect(find.text('future_key_we_do_not_know'), findsNWidgets(2));
  });

  testWidgets('the screen is gated on iam.user.manage', (tester) async {
    await tester.pumpWidget(host(permissions: const {}));
    await tester.pumpAndSettle();

    expect(find.text('Bu bölmə üçün icazəniz yoxdur'), findsOneWidget);
    expect(find.text('expiry_warning_days'), findsNothing);
  });

  group('value rendering', () {
    test('labels cover every documented InventorySettingKey', () {
      // Keys of contracts/openapi/inventory.v1.yaml -> InventorySettingKey.
      const documented = [
        'expiry_warning_days',
        'expiry_critical_days',
        'receipt_over_tolerance_pct',
        'receipt_under_tolerance_pct',
        'costing_method',
        'count_variance_approval_threshold_pct',
        'block_transactions_during_count',
        'require_branch_receipt_confirmation',
        'allow_negative_stock',
      ];
      for (final key in documented) {
        expect(
          InventorySettingsScreen.keyLabels.containsKey(key),
          isTrue,
          reason: key,
        );
      }
      expect(InventorySettingsScreen.labelFor('unknown'), 'unknown');
    });

    test('BOOL parsing goes through the DTO', () {
      const yes = InventorySettingDto(
        key: 'allow_negative_stock',
        value: 'true',
        valueType: SettingValueType.boolValue,
      );
      expect(yes.asFlag, isTrue);
      expect(InventorySettingsScreen.displayValue(yes), 'bəli');
      expect(
        InventorySettingsScreen.displayValue(_settings[1]),
        'MOVING_AVERAGE',
      );
    });

    test('value types are named in Azerbaijani', () {
      expect(
        InventorySettingsScreen.valueTypeLabel(SettingValueType.intValue),
        'tam ədəd',
      );
      expect(
        InventorySettingsScreen.valueTypeLabel(SettingValueType.decimalValue),
        'onluq',
      );
      expect(
        InventorySettingsScreen.valueTypeLabel(SettingValueType.boolValue),
        'bəli/xeyr',
      );
      expect(
        InventorySettingsScreen.valueTypeLabel(SettingValueType.enumValue),
        'siyahı',
      );
    });
  });
}
