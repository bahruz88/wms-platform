import 'package:feature_identity/feature_identity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import '../inventory_providers.dart';

/// Admin → Parametrlər: `GET /inventory/settings` (`inv_setting`, SPEC §9.1).
///
/// Read only. Every value the rest of the app needs (expiry thresholds,
/// receipt tolerances, costing method) comes from here instead of being
/// hard-coded (TOR §36). Editing needs `inv.settings.manage` and per-type
/// validation, which is a separate screen.
class InventorySettingsScreen extends ConsumerWidget {
  const InventorySettingsScreen({super.key});

  /// Azerbaijani label per documented `InventorySettingKey`. Unknown keys
  /// are shown with their raw key, never hidden.
  static const Map<String, String> keyLabels = {
    'expiry_warning_days': 'Bitmə xəbərdarlığı (gün)',
    'expiry_critical_days': 'Kritik bitmə həddi (gün)',
    'receipt_over_tolerance_pct': 'Qəbulda artıq tolerans (%)',
    'receipt_under_tolerance_pct': 'Qəbulda əskik tolerans (%)',
    'costing_method': 'Maya dəyəri metodu',
    'count_variance_approval_threshold_pct': 'Sayım fərqi təsdiq həddi (%)',
    'block_transactions_during_count': 'Sayım zamanı əməliyyatları blokla',
    'require_branch_receipt_confirmation': 'Filial qəbulu təsdiqi məcburidir',
    'allow_negative_stock': 'Mənfi qalığa icazə',
  };

  static String labelFor(String key) => keyLabels[key] ?? key;

  static String valueTypeLabel(SettingValueType type) => switch (type) {
    SettingValueType.intValue => 'tam ədəd',
    SettingValueType.decimalValue => 'onluq',
    SettingValueType.boolValue => 'bəli/xeyr',
    SettingValueType.enumValue => 'siyahı',
  };

  /// `BOOL` values read better as words than as `true`/`false`.
  static String displayValue(InventorySettingDto setting) =>
      switch (setting.valueType) {
        SettingValueType.boolValue => setting.asFlag ? 'bəli' : 'xeyr',
        _ => setting.value,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final settings = ref.watch(inventorySettingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.labelSettings)),
      body: RequirePermission.withNotice(
        permission: Permissions.userManage,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(WmsSpacing.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Bu dəyərlər interfeysdə və serverdə eyni mənbədən '
                '(`inv_setting`) oxunur.',
                style: WmsTypography.caption.copyWith(color: c.inkMuted),
              ),
              const SizedBox(height: WmsSpacing.space3),
              AdminAsyncView<List<InventorySettingDto>>(
                value: settings,
                onRetry: () => ref.invalidate(inventorySettingsProvider),
                builder: (items) => WmsDataTable<InventorySettingDto>(
                  rowKey: (row, _) => row.key,
                  emptyReason: 'Parametr siyahısı boşdur.',
                  emptyNextStep:
                      'Inventory modulu `inv_setting` cədvəlini seed edir.',
                  columns: [
                    WmsColumn(
                      key: 'label',
                      header: 'Parametr',
                      flex: 3,
                      cell: (row) => labelFor(row.key),
                    ),
                    WmsColumn(
                      key: 'key',
                      header: 'Açar',
                      flex: 3,
                      render: (row, _) => Text(
                        row.key,
                        style: WmsTypography.docNo.copyWith(color: c.inkMuted),
                      ),
                    ),
                    const WmsColumn(
                      key: 'value',
                      header: 'Dəyər',
                      width: 160,
                      numeric: true,
                      cell: displayValue,
                    ),
                    WmsColumn(
                      key: 'type',
                      header: 'Tip',
                      width: 120,
                      cell: (row) => valueTypeLabel(row.valueType),
                    ),
                    WmsColumn(
                      key: 'allowed',
                      header: 'İcazəli dəyərlər',
                      flex: 2,
                      cell: (row) => row.allowedValues.isEmpty
                          ? '—'
                          : row.allowedValues.join(', '),
                    ),
                  ],
                  rows: items,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
