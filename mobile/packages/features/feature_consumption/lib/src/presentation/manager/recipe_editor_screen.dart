import 'package:decimal/decimal.dart';
import 'package:feature_identity/feature_identity.dart';
import 'package:feature_master_data/feature_master_data.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import '../../domain/recipe_explosion_preview.dart';
import '../consumption_alert.dart';
import '../consumption_providers.dart';
import '../date_field.dart';
import 'recipe_draft_controller.dart';

/// «Resept redaktoru» — edit the lines of a `DRAFT` version and activate it.
///
/// The side panel is the point of the screen: it shows what the BOM
/// explosion makes of the current lines, so a yield factor stops being an
/// abstract percentage. A saved draft is exploded by the server
/// (`GET /recipes/{id}/explosion`); while edits are pending the panel falls
/// back to the same formula computed locally and says so — the two never
/// pretend to be the same number.
///
/// `RECIPE_CYCLE`, `RECIPE_DEPTH_EXCEEDED`, `RECIPE_EMPTY` and
/// `PERIOD_CLOSED` arrive as ordinary RFC 7807 problems and are shown
/// through `WmsAlert` with the code on screen.
class RecipeEditorScreen extends ConsumerStatefulWidget {
  const RecipeEditorScreen({
    required this.menuItemId,
    this.recipeId,
    super.key,
  });

  final int menuItemId;

  /// Opens a specific version; otherwise the newest one is selected.
  final int? recipeId;

  @override
  ConsumerState<RecipeEditorScreen> createState() => _RecipeEditorScreenState();
}

class _RecipeEditorScreenState extends ConsumerState<RecipeEditorScreen> {
  bool _busy = false;
  Failure? _failure;
  String? _notice;

  RecipeDraftNotifier get _draft => ref.read(recipeDraftProvider.notifier);

  Future<void> _save(RecipeDto recipe, List<RecipeLineInput> lines) async {
    setState(() {
      _busy = true;
      _failure = null;
      _notice = null;
    });
    final result = await ref
        .read(consumptionRepositoryProvider)
        .updateRecipe(
          recipe.id,
          UpdateRecipeRequest(
            rowVersion: recipe.rowVersion,
            lines: lines,
            yieldPortions: recipe.yieldPortions,
            note: recipe.note,
          ),
        );
    if (!mounted) return;
    setState(() {
      _busy = false;
      result.fold(
        (_) => _notice = 'Tərkib yadda saxlanıldı.',
        (failure) => _failure = failure,
      );
    });
    if (_failure == null) {
      _draft.markSaved();
      ref.invalidate(recipeProvider(recipe.id));
    }
  }

  Future<void> _activate(RecipeDto recipe, DateTime validFrom) async {
    setState(() {
      _busy = true;
      _failure = null;
      _notice = null;
    });
    final result = await ref
        .read(consumptionRepositoryProvider)
        .activateRecipe(
          recipe.id,
          ActivateRecipeRequest(
            validFrom: validFrom,
            rowVersion: recipe.rowVersion,
          ),
        );
    if (!mounted) return;
    setState(() {
      _busy = false;
      result.fold(
        (activated) => _notice =
            '${activated.versionNo} nömrəli versiya '
            '${WmsFormat.date(activated.validFrom)} tarixindən aktivdir.',
        (failure) => _failure = failure,
      );
    });
    if (_failure == null) {
      ref
        ..invalidate(recipeVersionsProvider(widget.menuItemId))
        ..invalidate(recipeProvider(recipe.id))
        ..invalidate(menuItemCatalogProvider);
    }
  }

  Future<void> _newVersion(RecipeSummaryDto? copyFrom) async {
    setState(() {
      _busy = true;
      _failure = null;
      _notice = null;
    });
    final result = await ref
        .read(consumptionRepositoryProvider)
        .createRecipeVersion(
          widget.menuItemId,
          CreateRecipeVersionRequest(
            validFrom: todayDate(),
            copyFromRecipeId: copyFrom?.id,
          ),
        );
    if (!mounted) return;
    setState(() {
      _busy = false;
      result.fold((created) {
        _draft.select(created.id, validFrom: created.validFrom);
        _notice =
            '${created.versionNo} nömrəli versiya qaralama kimi yaradıldı.';
      }, (failure) => _failure = failure);
    });
    if (_failure == null) {
      ref.invalidate(recipeVersionsProvider(widget.menuItemId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final versions = ref.watch(recipeVersionsProvider(widget.menuItemId));
    final draft = ref.watch(recipeDraftProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.consRecipeEditor)),
      body: RequirePermission.withNotice(
        permission: Permissions.recipeView,
        child: WmsLoadingOverlay(
          loading: _busy,
          child: AsyncView<List<RecipeSummaryDto>>(
            value: versions,
            onRetry: () =>
                ref.invalidate(recipeVersionsProvider(widget.menuItemId)),
            builder: (list) {
              final selected =
                  draft.recipeId ??
                  widget.recipeId ??
                  (list.isEmpty ? null : list.first.id);
              return ListView(
                padding: const EdgeInsets.all(WmsSpacing.space4),
                children: [
                  if (_notice != null) ...[
                    WmsAlert(tone: WmsAlertTone.success, title: _notice),
                    const SizedBox(height: WmsSpacing.space3),
                  ],
                  if (_failure != null) ...[
                    ConsumptionAlert(
                      failure: _failure!,
                      onClose: () => setState(() => _failure = null),
                    ),
                    const SizedBox(height: WmsSpacing.space3),
                  ],
                  _VersionList(
                    versions: list,
                    selectedId: selected,
                    onSelect: (id) => _draft.select(id),
                  ),
                  const SizedBox(height: WmsSpacing.space3),
                  RequirePermission(
                    permission: Permissions.recipeManage,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: WmsButton(
                        label: l10n.consActionNewVersion,
                        iconLeft: Icons.add,
                        onPressed: () =>
                            _newVersion(list.isEmpty ? null : list.first),
                      ),
                    ),
                  ),
                  const SizedBox(height: WmsSpacing.space5),
                  if (selected == null)
                    WmsEmptyState(
                      reason: l10n.consEmptyVersionsReason,
                      nextStep: l10n.consEmptyVersionsNext,
                      icon: Icons.menu_book_outlined,
                    )
                  else
                    _RecipeBody(
                      recipeId: selected,
                      onSave: _save,
                      onActivate: _activate,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

typedef _SaveCallback = void Function(
  RecipeDto recipe,
  List<RecipeLineInput> lines,
);
typedef _ActivateCallback = void Function(RecipeDto recipe, DateTime validFrom);

class _RecipeBody extends ConsumerWidget {
  const _RecipeBody({
    required this.recipeId,
    required this.onSave,
    required this.onActivate,
  });

  final int recipeId;
  final _SaveCallback onSave;
  final _ActivateCallback onActivate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipe = ref.watch(recipeProvider(recipeId));
    return AsyncView<RecipeDto>(
      value: recipe,
      onRetry: () => ref.invalidate(recipeProvider(recipeId)),
      builder: (data) => LayoutBuilder(
        builder: (context, constraints) {
          final editor = _LineEditor(
            recipe: data,
            onSave: onSave,
            onActivate: onActivate,
          );
          final preview = _ExplosionPanel(recipe: data);
          if (constraints.maxWidth < WmsBreakpoints.medium) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                editor,
                const SizedBox(height: WmsSpacing.space5),
                preview,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: editor),
              const SizedBox(width: WmsSpacing.space5),
              Expanded(flex: 2, child: preview),
            ],
          );
        },
      ),
    );
  }
}

class _VersionList extends StatelessWidget {
  const _VersionList({
    required this.versions,
    required this.selectedId,
    required this.onSelect,
  });

  final List<RecipeSummaryDto> versions;
  final int? selectedId;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return WmsDataTable<RecipeSummaryDto>(
      caption: l10n.consLabelVersion,
      rowKey: (row, _) => row.id,
      selectedKey: selectedId,
      minWidth: 620,
      emptyReason: l10n.consEmptyVersionsReason,
      emptyNextStep: l10n.consEmptyVersionsNext,
      onRowTap: (row, _) => onSelect(row.id),
      columns: [
        WmsColumn(
          key: 'versionNo',
          header: l10n.consLabelVersion,
          width: 90,
          numeric: true,
          cell: (row) => '${row.versionNo}',
        ),
        WmsColumn(
          key: 'status',
          header: l10n.labelStatus,
          width: 150,
          render: (row, _) => WmsDocStatusBadge(status: row.status.wire),
        ),
        WmsColumn(
          key: 'validFrom',
          header: l10n.consLabelValidFrom,
          width: 130,
          cell: (row) => WmsFormat.date(row.validFrom),
        ),
        WmsColumn(
          key: 'validTo',
          header: l10n.consLabelValidTo,
          width: 130,
          cell: (row) =>
              row.validTo == null ? '—' : WmsFormat.date(row.validTo),
        ),
        WmsColumn(
          key: 'lineCount',
          header: l10n.consLabelLineCount,
          width: 100,
          numeric: true,
          cell: (row) => '${row.lineCount}',
        ),
      ],
      rows: versions,
    );
  }
}

class _LineEditor extends ConsumerWidget {
  const _LineEditor({
    required this.recipe,
    required this.onSave,
    required this.onActivate,
  });

  final RecipeDto recipe;
  final _SaveCallback onSave;
  final _ActivateCallback onActivate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final draft = ref.watch(recipeDraftProvider);
    final notifier = ref.read(recipeDraftProvider.notifier);
    final canManage = ref.hasPermission(Permissions.recipeManage);
    final editable = canManage && recipe.isEditable;
    final lines = draft.linesOf(recipe);
    final products = ref.watch(productListProvider).value?.items ?? const [];
    final uoms = ref.watch(uomListProvider).value ?? const <UomDto>[];
    final subRecipes = ref.watch(subRecipeMenuItemsProvider).value ?? const [];
    final incomplete = lines.where((l) => !l.isComplete).length;
    final validFrom = draft.validFrom ?? recipe.validFrom;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${recipe.menuItemName ?? 'Menyu maddəsi #${recipe.menuItemId}'}'
                ' · ${l10n.consLabelVersion} ${recipe.versionNo}',
                style: WmsTypography.titleLg.copyWith(color: c.ink),
              ),
            ),
            WmsDocStatusBadge(status: recipe.status.wire),
          ],
        ),
        const SizedBox(height: WmsSpacing.space3),
        if (!recipe.isEditable) ...[
          const WmsAlert(
            title: 'Bu versiya redaktə olunmur',
            message:
                'Yalnız qaralama versiya dəyişdirilir. Dəyişiklik üçün yeni '
                'versiya açın — köhnə hesablamalar toxunulmaz qalır.',
            code: ProblemCodes.invalidStateTransition,
          ),
          const SizedBox(height: WmsSpacing.space3),
        ],
        for (final line in lines)
          _LineCard(
            key: ValueKey('recipe-line-${line.lineNo}'),
            line: line,
            editable: editable,
            products: products,
            uoms: uoms,
            subRecipes: subRecipes,
            onTypeChanged: (type) =>
                notifier.setComponentType(recipe, line.lineNo, type),
            onChanged: (updated) =>
                notifier.updateLine(recipe, line.lineNo, (_) => updated),
            onRemove: () => notifier.removeLine(recipe, line.lineNo),
          ),
        if (lines.isEmpty)
          WmsEmptyState(
            reason: l10n.consEmptyRecipeLinesReason,
            nextStep: l10n.consEmptyRecipeLinesNext,
            icon: Icons.playlist_add_outlined,
          ),
        if (editable) ...[
          const SizedBox(height: WmsSpacing.space3),
          Align(
            alignment: Alignment.centerLeft,
            child: WmsButton(
              label: l10n.consActionAddComponent,
              iconLeft: Icons.add,
              onPressed: () => notifier.addLine(
                recipe,
                uomId: uoms.isEmpty ? 0 : uoms.first.id,
              ),
            ),
          ),
          const SizedBox(height: WmsSpacing.space5),
          Wrap(
            spacing: WmsSpacing.space3,
            runSpacing: WmsSpacing.space3,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              WmsButton(
                label: l10n.actionSave,
                enabled: incomplete == 0,
                disabledReason: '$incomplete sətirdə tərkib seçilməyib',
                onPressed: () => onSave(recipe, lines),
              ),
              SizedBox(
                width: 210,
                child: ConsumptionDateField(
                  label: l10n.consLabelValidFrom,
                  value: validFrom,
                  onChanged: notifier.setValidFrom,
                ),
              ),
              WmsButton.primary(
                label: l10n.consActionActivate,
                enabled: lines.isNotEmpty && !draft.isDirty && incomplete == 0,
                disabledReason: lines.isEmpty
                    ? l10n.consErrRecipeEmpty
                    : (draft.isDirty
                          ? 'Əvvəlcə dəyişiklikləri yadda saxlayın'
                          : '$incomplete sətirdə tərkib seçilməyib'),
                onPressed: () => onActivate(recipe, validFrom),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _LineCard extends StatelessWidget {
  const _LineCard({
    required this.line,
    required this.editable,
    required this.products,
    required this.uoms,
    required this.subRecipes,
    required this.onTypeChanged,
    required this.onChanged,
    required this.onRemove,
    super.key,
  });

  final RecipeLineInput line;
  final bool editable;
  final List<ProductDto> products;
  final List<UomDto> uoms;
  final List<MenuItemDto> subRecipes;
  final ValueChanged<ComponentType> onTypeChanged;
  final ValueChanged<RecipeLineInput> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final isProduct = line.componentType == ComponentType.foodProduct;

    return Container(
      margin: const EdgeInsets.only(bottom: WmsSpacing.space3),
      padding: WmsSpacing.cardPadding,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: WmsRadius.lgAll,
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${line.lineNo}',
                style: WmsTypography.figure.copyWith(color: c.inkMuted),
              ),
              const Spacer(),
              if (editable)
                WmsIconButton(
                  icon: Icons.delete_outline,
                  label: 'Sətri sil',
                  onPressed: onRemove,
                ),
            ],
          ),
          Wrap(
            spacing: WmsSpacing.space4,
            runSpacing: WmsSpacing.space3,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              SizedBox(
                width: 210,
                child: WmsSelect<ComponentType>(
                  label: l10n.consLabelComponentType,
                  required: true,
                  enabled: editable,
                  value: line.componentType,
                  options: [
                    WmsSelectOption(
                      value: ComponentType.foodProduct,
                      label: l10n.consLabelFoodProduct,
                    ),
                    WmsSelectOption(
                      value: ComponentType.subRecipe,
                      label: l10n.consLabelSubRecipe,
                    ),
                  ],
                  onChanged: (value) =>
                      onTypeChanged(value ?? ComponentType.foodProduct),
                ),
              ),
              SizedBox(
                width: 300,
                child: isProduct
                    ? WmsSelect<int>(
                        label: l10n.labelProduct,
                        required: true,
                        enabled: editable,
                        value: line.productId,
                        placeholder: 'Məhsul seçin',
                        error: line.productId == null
                            ? l10n.validationRequired
                            : null,
                        options: [
                          for (final p in products)
                            WmsSelectOption(
                              value: p.id,
                              label: '${p.sku} · ${p.name}',
                            ),
                        ],
                        onChanged: (value) =>
                            onChanged(line.copyWith(productId: value)),
                      )
                    : WmsSelect<int>(
                        label: l10n.consLabelSubRecipe,
                        required: true,
                        enabled: editable,
                        value: line.subMenuItemId,
                        placeholder: 'Alt-resept seçin',
                        error: line.subMenuItemId == null
                            ? l10n.validationRequired
                            : null,
                        options: [
                          for (final m in subRecipes)
                            WmsSelectOption(
                              value: m.id,
                              label: '${m.code} · ${m.name}',
                            ),
                        ],
                        onChanged: (value) =>
                            onChanged(line.copyWith(subMenuItemId: value)),
                      ),
              ),
              SizedBox(
                width: 230,
                child: WmsQtyUomInput(
                  key: ValueKey('recipe-qty-${line.lineNo}'),
                  label: l10n.consLabelQtyPerPortion,
                  required: true,
                  enabled: editable,
                  qty: line.qtyPerPortion,
                  uomId: line.uomId,
                  uoms: [
                    for (final u in uoms)
                      WmsProductUom(
                        id: u.id,
                        code: u.code,
                        factorToBase: Decimal.one,
                      ),
                  ],
                  onQtyChanged: (value) => onChanged(
                    line.copyWith(qtyPerPortion: value ?? Quantity.zero),
                  ),
                  onUomChanged: (value) =>
                      onChanged(line.copyWith(uomId: value)),
                ),
              ),
              SizedBox(
                width: 170,
                child: WmsTextField(
                  key: ValueKey('recipe-yield-${line.lineNo}'),
                  label: l10n.consLabelYieldPct,
                  hint: l10n.consYieldHint,
                  enabled: editable,
                  alignRight: true,
                  initialValue: line.effectiveYieldPct.toString(),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
                  ],
                  onChanged: (value) => onChanged(
                    line.copyWith(
                      yieldPct: Decimal.tryParse(value.replaceAll(',', '.')),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 190,
                child: WmsSelect<bool>(
                  label: l10n.consLabelOptional,
                  enabled: editable,
                  value: line.isOptional,
                  options: const [
                    WmsSelectOption(value: false, label: 'Həmişə'),
                    WmsSelectOption(value: true, label: 'Müştəri istəyi ilə'),
                  ],
                  onChanged: (value) =>
                      onChanged(line.copyWith(isOptional: value ?? false)),
                ),
              ),
              if (line.isOptional)
                SizedBox(
                  width: 170,
                  child: WmsTextField(
                    label: l10n.consLabelAttachRatePct,
                    enabled: editable,
                    alignRight: true,
                    initialValue: line.effectiveAttachRatePct.toString(),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
                    ],
                    onChanged: (value) => onChanged(
                      line.copyWith(
                        attachRatePct: Decimal.tryParse(
                          value.replaceAll(',', '.'),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Live preview of the explosion: server figures for a saved draft, the
/// same formula computed locally while edits are pending.
class _ExplosionPanel extends ConsumerWidget {
  const _ExplosionPanel({required this.recipe});

  final RecipeDto recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final draft = ref.watch(recipeDraftProvider);
    final products = ref.watch(productListProvider).value?.items ?? const [];
    final uoms = ref.watch(uomListProvider).value ?? const <UomDto>[];
    final subRecipes = ref.watch(subRecipeMenuItemsProvider).value ?? const [];
    final lines = draft.linesOf(recipe);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.consLabelExplosion,
          style: WmsTypography.title.copyWith(color: c.ink),
        ),
        const SizedBox(height: WmsSpacing.space3),
        SizedBox(
          width: 210,
          child: WmsQtyUomInput(
            key: const ValueKey('cons-preview-portions'),
            label: l10n.consLabelPortions,
            decimals: 0,
            qty: draft.effectivePortions,
            uomId: 0,
            uoms: [
              WmsProductUom(id: 0, code: 'porsiya', factorToBase: Decimal.one),
            ],
            onQtyChanged: ref.read(recipeDraftProvider.notifier).setPortions,
          ),
        ),
        const SizedBox(height: WmsSpacing.space3),
        if (draft.isDirty) ...[
          WmsAlert(
            key: const ValueKey('cons-preview-local'),
            title: l10n.consPreviewPending,
          ),
          const SizedBox(height: WmsSpacing.space3),
          _PreviewTable(
            lines: RecipeExplosionPreview.project(
              lines: lines,
              portions: draft.effectivePortions,
              uomOf: (line) => previewUomOf(line, products, uoms),
              labelOf: (line) => previewLabelOf(line, products, subRecipes),
            ),
          ),
        ] else
          _ServerExplosion(
            recipeId: recipe.id,
            portions: draft.effectivePortions,
          ),
      ],
    );
  }
}

/// Conversion factor and base unit of a recipe line, read from the
/// product's `master_product_uom` rows.
PreviewUom previewUomOf(
  RecipeLineInput line,
  List<ProductDto> products,
  List<UomDto> uoms,
) {
  final product = products.cast<ProductDto?>().firstWhere(
    (p) => p?.id == line.productId,
    orElse: () => null,
  );
  if (product == null) {
    final uom = uoms.cast<UomDto?>().firstWhere(
      (u) => u?.id == line.uomId,
      orElse: () => null,
    );
    return PreviewUom(
      baseUomCode: uom?.code ?? '',
      baseDecimals: uom?.decimals ?? kQuantityScale,
    );
  }
  final productUom = product.uoms.cast<ProductUomDto?>().firstWhere(
    (u) => u?.uomId == line.uomId,
    orElse: () => null,
  );
  final baseUom = uoms.cast<UomDto?>().firstWhere(
    (u) => u?.id == product.baseUomId,
    orElse: () => null,
  );
  return PreviewUom(
    factorToBase: productUom?.factorToBase,
    baseUomCode: product.baseUomCode ?? baseUom?.code ?? '',
    baseDecimals: baseUom?.decimals ?? kQuantityScale,
  );
}

/// Display name of a recipe line's component.
String previewLabelOf(
  RecipeLineInput line,
  List<ProductDto> products,
  List<MenuItemDto> subRecipes,
) {
  if (line.componentType == ComponentType.subRecipe) {
    final item = subRecipes.cast<MenuItemDto?>().firstWhere(
      (m) => m?.id == line.subMenuItemId,
      orElse: () => null,
    );
    return item?.name ?? 'Alt-resept #${line.subMenuItemId ?? '—'}';
  }
  final product = products.cast<ProductDto?>().firstWhere(
    (p) => p?.id == line.productId,
    orElse: () => null,
  );
  return product?.name ?? 'Məhsul #${line.productId ?? '—'}';
}

class _ServerExplosion extends ConsumerWidget {
  const _ServerExplosion({required this.recipeId, required this.portions});

  final int recipeId;
  final Quantity portions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final request = ExplosionRequest(recipeId: recipeId, portions: portions);
    final explosion = ref.watch(recipeExplosionProvider(request));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.consPreviewServer,
          style: WmsTypography.label.copyWith(color: c.inkMuted),
        ),
        const SizedBox(height: WmsSpacing.space2),
        AsyncView<RecipeExplosionDto>(
          value: explosion,
          onRetry: () => ref.invalidate(recipeExplosionProvider(request)),
          builder: (data) => WmsDataTable<RecipeExplosionLineDto>(
            rowKey: (row, index) => '${row.productId}-$index',
            minWidth: 360,
            emptyReason: l10n.consEmptyExplosionReason,
            emptyNextStep: l10n.consEmptyExplosionNext,
            columns: [
              WmsColumn(
                key: 'product',
                header: l10n.labelProduct,
                flex: 3,
                render: (row, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(row.productName ?? 'Məhsul #${row.productId}'),
                    if (row.viaSubRecipe != null)
                      Text(
                        '${l10n.consLabelSubRecipe}: ${row.viaSubRecipe}',
                        style: WmsTypography.caption.copyWith(
                          color: c.inkMuted,
                        ),
                      ),
                  ],
                ),
              ),
              WmsColumn(
                key: 'required',
                header: 'Tələb',
                flex: 2,
                numeric: true,
                cell: (row) => WmsFormat.quantity(row.requiredQtyBase),
              ),
              WmsColumn(
                key: 'uom',
                header: 'Vahid',
                width: 70,
                cell: (row) => row.baseUomCode,
              ),
            ],
            rows: data.lines,
          ),
        ),
      ],
    );
  }
}

class _PreviewTable extends StatelessWidget {
  const _PreviewTable({required this.lines});

  final List<ExplosionPreviewLine> lines;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    return WmsDataTable<ExplosionPreviewLine>(
      rowKey: (row, _) => row.lineNo,
      minWidth: 360,
      emptyReason: l10n.consEmptyExplosionReason,
      emptyNextStep: l10n.consEmptyExplosionNext,
      columns: [
        WmsColumn(
          key: 'component',
          header: l10n.consLabelComponent,
          flex: 3,
          render: (row, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(row.label),
              if (row.needsServer)
                Text(
                  l10n.consSubRecipeNeedsSave,
                  style: WmsTypography.caption.copyWith(color: c.inkMuted),
                )
              else if (row.hasProcessingLoss)
                Text(
                  '${l10n.consLabelYieldPct} '
                  '${WmsFormat.number(row.yieldPct, decimals: 2)}',
                  style: WmsTypography.caption.copyWith(color: c.warning),
                ),
            ],
          ),
        ),
        WmsColumn(
          key: 'required',
          header: 'Tələb',
          flex: 2,
          numeric: true,
          render: (row, _) => Text(
            row.needsServer ? '—' : WmsFormat.quantity(row.requiredQtyBase),
            key: ValueKey('cons-preview-qty-${row.lineNo}'),
            textAlign: TextAlign.right,
            style: WmsTypography.figure.copyWith(color: c.ink),
          ),
        ),
        WmsColumn(
          key: 'uom',
          header: 'Vahid',
          width: 70,
          cell: (row) => row.baseUomCode,
        ),
      ],
      rows: lines,
    );
  }
}
