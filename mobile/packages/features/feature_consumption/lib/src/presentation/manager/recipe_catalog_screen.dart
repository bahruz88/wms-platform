import 'package:feature_identity/feature_identity.dart';
import 'package:feature_master_data/feature_master_data.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import '../../navigation.dart';
import '../consumption_providers.dart';

/// «Resept kataloqu» — every menu item with the state of its recipe.
///
/// The point of the screen is the flag: an item **without** an active
/// recipe produces no depletion when it is sold, so its sales quietly
/// disappear from the stock picture. Those rows are called out at the top
/// and can be filtered on their own.
class RecipeCatalogScreen extends ConsumerWidget {
  const RecipeCatalogScreen({this.onOpenMenuItem, super.key});

  /// Overridden in tests; by default the row opens the recipe editor.
  final void Function(BuildContext context, int menuItemId)? onOpenMenuItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.consRecipeCatalog)),
      body: RequirePermission.withNotice(
        permission: Permissions.recipeView,
        child: _Body(onOpenMenuItem: onOpenMenuItem),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({this.onOpenMenuItem});

  final void Function(BuildContext context, int menuItemId)? onOpenMenuItem;

  void _open(BuildContext context, int menuItemId) {
    final handler = onOpenMenuItem;
    if (handler != null) {
      handler(context, menuItemId);
      return;
    }
    context.go(ConsumptionRoutes.recipeEditor(menuItemId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final filter = ref.watch(menuItemCatalogFilterProvider);
    final items = ref.watch(menuItemCatalogProvider);

    return ListView(
      padding: const EdgeInsets.all(WmsSpacing.space4),
      children: [
        Wrap(
          spacing: WmsSpacing.space4,
          runSpacing: WmsSpacing.space3,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            SizedBox(
              width: 320,
              child: WmsTextField(
                label: l10n.actionSearch,
                placeholder: 'Menyu maddəsinin adı, kodu və ya POS kodu',
                onSubmitted: (value) => ref
                    .read(menuItemCatalogFilterProvider.notifier)
                    .setSearch(value.trim()),
              ),
            ),
            SizedBox(
              width: 260,
              child: WmsSelect<RecipeFilter>(
                label: 'Resept',
                value: filter.recipe,
                options: [
                  WmsSelectOption(
                    value: RecipeFilter.all,
                    label: l10n.labelAll,
                  ),
                  const WmsSelectOption(
                    value: RecipeFilter.withRecipe,
                    label: 'Aktiv resepti olanlar',
                  ),
                  WmsSelectOption(
                    value: RecipeFilter.withoutRecipe,
                    label: l10n.consLabelRecipeMissing,
                  ),
                ],
                onChanged: (value) => ref
                    .read(menuItemCatalogFilterProvider.notifier)
                    .setRecipeFilter(value ?? RecipeFilter.all),
              ),
            ),
            SizedBox(
              width: 240,
              child: WmsSelect<bool>(
                label: l10n.consLabelComponentType,
                value: filter.subRecipesOnly,
                options: [
                  WmsSelectOption(value: false, label: l10n.labelAll),
                  const WmsSelectOption(
                    value: true,
                    label: 'Yalnız alt-reseptlər',
                  ),
                ],
                onChanged: (value) => ref
                    .read(menuItemCatalogFilterProvider.notifier)
                    .setSubRecipesOnly(value: value ?? false),
              ),
            ),
          ],
        ),
        const SizedBox(height: WmsSpacing.space4),
        AsyncView<Page<MenuItemDto>>(
          value: items,
          onRetry: () => ref.invalidate(menuItemCatalogProvider),
          builder: (page) {
            final missing = page.items
                .where((i) => !i.isSubRecipe && !i.hasActiveRecipe)
                .toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (missing.isNotEmpty) ...[
                  WmsAlert(
                    key: const ValueKey('cons-missing-recipe-alert'),
                    tone: WmsAlertTone.warning,
                    title: '${missing.length} maddənin aktiv resepti yoxdur',
                    message: l10n.consNoRecipeWarning,
                  ),
                  const SizedBox(height: WmsSpacing.space3),
                ],
                WmsDataTable<MenuItemDto>(
                  rowKey: (row, _) => row.id,
                  minWidth: 720,
                  emptyReason: l10n.consEmptyMenuItemsReason,
                  emptyNextStep: l10n.consEmptyMenuItemsNext,
                  onRowTap: (row, _) => _open(context, row.id),
                  columns: [
                    WmsColumn(
                      key: 'code',
                      header: 'Kod',
                      width: 130,
                      render: (row, _) => Text(
                        row.code,
                        style: WmsTypography.docNo.copyWith(color: c.ink),
                      ),
                    ),
                    WmsColumn(
                      key: 'name',
                      header: l10n.consLabelMenuItem,
                      flex: 3,
                      cell: (row) => row.name,
                    ),
                    WmsColumn(
                      key: 'category',
                      header: 'Kateqoriya',
                      flex: 2,
                      cell: (row) => row.category ?? '—',
                    ),
                    WmsColumn(
                      key: 'posCode',
                      header: l10n.consLabelPosCode,
                      width: 130,
                      render: (row, _) => Text(
                        row.posCode ?? '—',
                        style: WmsTypography.docNo.copyWith(color: c.inkMuted),
                      ),
                    ),
                    WmsColumn(
                      key: 'kind',
                      header: l10n.consLabelComponentType,
                      width: 140,
                      render: (row, _) => row.isSubRecipe
                          ? WmsBadge(
                              text: l10n.consLabelSubRecipe,
                              tone: WmsTone.accent,
                              tooltip: 'is_sub_recipe = true',
                            )
                          : const WmsBadge(text: 'Satılan maddə'),
                    ),
                    WmsColumn(
                      key: 'recipe',
                      header: 'Aktiv resept',
                      width: 170,
                      render: (row, _) => row.hasActiveRecipe
                          ? WmsBadge(
                              text: 'Resept #${row.activeRecipeId}',
                              tone: WmsTone.success,
                              tooltip: 'cons_recipe.id = ${row.activeRecipeId}',
                            )
                          : WmsBadge(
                              text: l10n.consLabelRecipeMissing,
                              tone: WmsTone.warning,
                              tooltip: l10n.consNoRecipeWarning,
                            ),
                    ),
                    WmsColumn(
                      key: 'isActive',
                      header: l10n.labelStatus,
                      width: 110,
                      render: (row, _) => row.isActive
                          ? const WmsBadge(text: 'Aktiv', tone: WmsTone.success)
                          : const WmsBadge(text: 'Deaktiv'),
                    ),
                  ],
                  rows: page.items,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
