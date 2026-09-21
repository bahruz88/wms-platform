import 'package:feature_master_data/feature_master_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import '../inventory_providers.dart';

/// Branch stock request (`SR-YYYY-00000`): what the restaurant needs from
/// the central warehouse.
class StockRequestFormScreen extends ConsumerStatefulWidget {
  const StockRequestFormScreen({super.key});

  @override
  ConsumerState<StockRequestFormScreen> createState() =>
      _StockRequestFormScreenState();
}

class _RequestLine {
  int? productId;
  int? uomId;
  Quantity? qty;

  bool get isValid =>
      productId != null && uomId != null && qty != null && qty!.isPositive;
}

class _StockRequestFormScreenState
    extends ConsumerState<StockRequestFormScreen> {
  final List<_RequestLine> _lines = [_RequestLine()];
  int? _fromLocationId;
  int? _toLocationId;
  DateTime? _requiredDate;
  String? _note;
  bool _submitting = false;
  Failure? _failure;
  String? _createdDocNo;

  bool get _isValid =>
      _fromLocationId != null &&
      _toLocationId != null &&
      _fromLocationId != _toLocationId &&
      _lines.every((l) => l.isValid);

  String? get _invalidReason {
    if (_fromLocationId == null) return 'Mənbə anbarı seçilməyib';
    if (_toLocationId == null) return 'Filial seçilməyib';
    if (_fromLocationId == _toLocationId) {
      return 'Mənbə və hədəf eyni ola bilməz';
    }
    return 'Sətir məlumatları tam deyil';
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _failure = null;
      _createdDocNo = null;
    });
    final result = await ref
        .read(inventoryRepositoryProvider)
        .createStockRequest(
          CreateStockRequestRequest(
            docDate: DateTime.now(),
            fromLocationId: _fromLocationId!,
            toLocationId: _toLocationId!,
            requiredDate: _requiredDate,
            note: _note,
            lines: [
              for (final line in _lines)
                CreateStockRequestLine(
                  productId: line.productId!,
                  qty: line.qty!,
                  uomId: line.uomId!,
                ),
            ],
          ),
        );
    if (!mounted) return;
    setState(() {
      _submitting = false;
      result.fold(
        (dto) => _createdDocNo = dto.docNo,
        (failure) => _failure = failure,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final locations = ref.watch(locationListProvider);
    final products = ref.watch(productListProvider);
    final uoms = ref.watch(uomListProvider);

    List<WmsSelectOption<int>> locationOptions(List<LocationDto> items) => [
      for (final location in items)
        WmsSelectOption(
          value: location.id,
          label: '${location.code} · ${location.name}',
          enabled: !location.isVirtual,
          disabledReason: location.isVirtual ? 'virtual lokasiya' : null,
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.docStockRequest} · ${l10n.actionCreate}'),
      ),
      body: WmsLoadingOverlay(
        loading: _submitting,
        child: ListView(
          padding: const EdgeInsets.all(WmsSpacing.space4),
          children: [
            if (_failure != null) ...[
              WmsAlert.fromFailure(_failure!),
              const SizedBox(height: WmsSpacing.space4),
            ],
            if (_createdDocNo != null) ...[
              WmsAlert(
                tone: WmsAlertTone.success,
                title: '$_createdDocNo yaradıldı',
                message: 'Tələb mərkəzi anbara göndərildi.',
              ),
              const SizedBox(height: WmsSpacing.space4),
            ],
            Wrap(
              spacing: WmsSpacing.space3,
              runSpacing: WmsSpacing.space3,
              children: [
                SizedBox(
                  width: 300,
                  child: locations.maybeWhen(
                    data: (items) => WmsSelect<int>(
                      label: 'Mənbə anbar',
                      required: true,
                      value: _fromLocationId,
                      placeholder: 'Seçin',
                      options: locationOptions(items),
                      onChanged: (value) =>
                          setState(() => _fromLocationId = value),
                    ),
                    orElse: () => WmsSelect<int>(
                      label: 'Mənbə anbar',
                      options: const [],
                      enabled: false,
                      onChanged: (_) {},
                    ),
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: locations.maybeWhen(
                    data: (items) => WmsSelect<int>(
                      label: 'Filial',
                      required: true,
                      value: _toLocationId,
                      placeholder: 'Seçin',
                      hint:
                          'Siyahı sizə təyin edilmiş lokasiyalarla məhdudlaşır',
                      options: locationOptions(items),
                      onChanged: (value) =>
                          setState(() => _toLocationId = value),
                    ),
                    orElse: () => WmsSelect<int>(
                      label: 'Filial',
                      options: const [],
                      enabled: false,
                      onChanged: (_) {},
                    ),
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: WmsTextField(
                    label: l10n.labelNote,
                    onChanged: (value) => _note = value,
                  ),
                ),
              ],
            ),
            const SizedBox(height: WmsSpacing.space5),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Sətirlər',
                    style: WmsTypography.title.copyWith(color: c.ink),
                  ),
                ),
                WmsButton.ghost(
                  label: l10n.actionAddLine,
                  size: WmsButtonSize.sm,
                  iconLeft: Icons.add,
                  onPressed: () => setState(() => _lines.add(_RequestLine())),
                ),
              ],
            ),
            const SizedBox(height: WmsSpacing.space3),
            for (var i = 0; i < _lines.length; i++)
              Container(
                margin: const EdgeInsets.only(bottom: WmsSpacing.space3),
                padding: WmsSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: WmsRadius.lgAll,
                  border: Border.all(color: c.border),
                ),
                child: Wrap(
                  spacing: WmsSpacing.space3,
                  runSpacing: WmsSpacing.space3,
                  children: [
                    SizedBox(
                      width: 320,
                      child: WmsSelect<int>(
                        label: l10n.labelProduct,
                        required: true,
                        value: _lines[i].productId,
                        placeholder: 'Məhsul seçin',
                        options: [
                          for (final p
                              in products.value?.items ?? const <ProductDto>[])
                            WmsSelectOption(
                              value: p.id,
                              label: '${p.sku} · ${p.name}',
                            ),
                        ],
                        onChanged: (value) => setState(() {
                          _lines[i].productId = value;
                          final product =
                              (products.value?.items ?? const <ProductDto>[])
                                  .cast<ProductDto?>()
                                  .firstWhere(
                                    (p) => p!.id == value,
                                    orElse: () => null,
                                  );
                          _lines[i].uomId = product?.baseUomId;
                        }),
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child: WmsQtyUomInput(
                        label: l10n.labelQuantity,
                        required: true,
                        qty: _lines[i].qty,
                        uomId: _lines[i].uomId,
                        uoms: [
                          for (final u in uoms.value ?? const <UomDto>[])
                            WmsProductUom(
                              id: u.id,
                              code: u.code,
                              factorToBase: Quantity.fromInt(1).value,
                            ),
                        ],
                        onQtyChanged: (value) =>
                            setState(() => _lines[i].qty = value),
                        onUomChanged: (id) =>
                            setState(() => _lines[i].uomId = id),
                      ),
                    ),
                    if (_lines.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: WmsSpacing.space5),
                        child: WmsIconButton(
                          icon: Icons.delete_outline,
                          label: 'Sətri sil',
                          onPressed: () => setState(() => _lines.removeAt(i)),
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: WmsSpacing.space5),
            Align(
              alignment: Alignment.centerLeft,
              child: WmsButton.primary(
                label: l10n.actionCreate,
                enabled: _isValid,
                disabledReason: _invalidReason,
                loading: _submitting,
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
