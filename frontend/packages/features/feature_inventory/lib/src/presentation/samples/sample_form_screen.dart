import 'package:decimal/decimal.dart';
import 'package:feature_master_data/feature_master_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import '../inventory_providers.dart';

class _SampleLine {
  int? productId;
  int? uomId;
  Quantity? qty;

  bool get isValid =>
      productId != null && uomId != null && qty != null && qty!.isPositive;
}

/// Sample document (`SM-YYYY-00000`): goods handed to an authority (AQTA).
/// Stock moves to the virtual `V_SAMPLE` location, so it stays inside the
/// ledger instead of vanishing from the calculation (spec §12.3).
class SampleFormScreen extends ConsumerStatefulWidget {
  const SampleFormScreen({super.key});

  @override
  ConsumerState<SampleFormScreen> createState() => _SampleFormScreenState();
}

class _SampleFormScreenState extends ConsumerState<SampleFormScreen> {
  final List<_SampleLine> _lines = [_SampleLine()];
  int? _locationId;
  String _authority = 'AQTA';
  String? _purpose;
  bool _submitting = false;
  Failure? _failure;
  String? _createdDocNo;

  bool get _isValid => _locationId != null && _lines.every((l) => l.isValid);

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _failure = null;
      _createdDocNo = null;
    });
    final result = await ref
        .read(inventoryRepositoryProvider)
        .createSample(
          CreateSampleRequest(
            docDate: DateTime.now(),
            locationId: _locationId!,
            authority: _authority,
            purpose: _purpose,
            lines: [
              for (final line in _lines)
                CreateSampleLine(
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

    return Scaffold(
      appBar: AppBar(title: Text('${l10n.docSample} · ${l10n.actionCreate}')),
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
                message: 'Nümunə V_SAMPLE virtual lokasiyasına köçürüldü.',
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
                      label: l10n.labelLocation,
                      required: true,
                      value: _locationId,
                      placeholder: 'Seçin',
                      options: [
                        for (final location in items)
                          WmsSelectOption(
                            value: location.id,
                            label: '${location.code} · ${location.name}',
                            enabled: !location.isVirtual,
                            disabledReason: location.isVirtual
                                ? 'virtual lokasiya'
                                : null,
                          ),
                      ],
                      onChanged: (value) => setState(() => _locationId = value),
                    ),
                    orElse: () => WmsSelect<int>(
                      label: l10n.labelLocation,
                      options: const [],
                      enabled: false,
                      onChanged: (_) {},
                    ),
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: WmsTextField(
                    label: 'Orqan',
                    initialValue: _authority,
                    onChanged: (value) => _authority = value,
                  ),
                ),
                SizedBox(
                  width: 360,
                  child: WmsTextField(
                    label: 'Məqsəd',
                    onChanged: (value) => _purpose = value,
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
                  onPressed: () => setState(() => _lines.add(_SampleLine())),
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
                              factorToBase: Decimal.one,
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
                disabledReason: 'Lokasiya və sətir məlumatları tam deyil',
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
