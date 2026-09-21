import 'package:decimal/decimal.dart';
import 'package:feature_master_data/feature_master_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import '../inventory_providers.dart';

/// Editable goods receipt line held by the form.
class ReceiptLineDraft {
  ReceiptLineDraft({
    this.productId,
    this.productName,
    this.uomId,
    this.orderedQty,
    this.receivedQty,
    this.batchNo,
    this.expiryDate,
    this.varianceNote,
  });

  int? productId;
  String? productName;
  int? uomId;
  Quantity? orderedQty;
  Quantity? receivedQty;
  String? batchNo;
  DateTime? expiryDate;
  String? varianceNote;

  /// `received − ordered`; `null` for lines that are not PO-backed.
  Quantity? get variance {
    final ordered = orderedQty;
    final received = receivedQty;
    if (ordered == null || received == null) return null;
    return received - ordered;
  }

  /// A variance note is mandatory when the quantities differ (spec §12.8).
  bool get requiresVarianceNote {
    final v = variance;
    return v != null && !v.isZero;
  }

  bool get varianceNoteMissing =>
      requiresVarianceNote &&
      (varianceNote == null || varianceNote!.trim().isEmpty);

  bool get isValid =>
      productId != null &&
      uomId != null &&
      receivedQty != null &&
      !receivedQty!.isNegative &&
      !varianceNoteMissing;
}

/// Goods receipt creation form: supplier, location, quality, temperature and
/// lines with product, received qty, UoM, batch, expiry and the mandatory
/// variance note.
class GoodsReceiptFormScreen extends ConsumerStatefulWidget {
  const GoodsReceiptFormScreen({super.key});

  @override
  ConsumerState<GoodsReceiptFormScreen> createState() =>
      _GoodsReceiptFormScreenState();
}

class _GoodsReceiptFormScreenState
    extends ConsumerState<GoodsReceiptFormScreen> {
  final List<ReceiptLineDraft> _lines = [ReceiptLineDraft()];
  int? _supplierId;
  int? _locationId;
  QualityStatus _quality = QualityStatus.accepted;
  final DateTime _docDate = DateTime.now();
  Decimal? _temperature;
  bool _submitting = false;
  Failure? _failure;
  String? _createdDocNo;

  bool get _isValid =>
      _supplierId != null &&
      _locationId != null &&
      _lines.isNotEmpty &&
      _lines.every((line) => line.isValid);

  String? get _invalidReason {
    if (_supplierId == null) return 'Təchizatçı seçilməyib';
    if (_locationId == null) return 'Lokasiya seçilməyib';
    if (_lines.any((l) => l.varianceNoteMissing)) {
      return 'Fərq olan sətirdə qeyd məcburidir';
    }
    return 'Sətir məlumatları tam deyil';
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _failure = null;
      _createdDocNo = null;
    });
    final request = CreateGoodsReceiptRequest(
      docDate: _docDate,
      supplierId: _supplierId!,
      locationId: _locationId!,
      qualityStatus: _quality,
      temperatureC: _temperature,
      lines: [
        for (final line in _lines)
          CreateGoodsReceiptLine(
            productId: line.productId!,
            receivedQty: line.receivedQty!,
            uomId: line.uomId!,
            orderedQty: line.orderedQty,
            batchNo: line.batchNo,
            expiryDate: line.expiryDate,
            varianceNote: line.varianceNote,
          ),
      ],
    );
    final result = await ref
        .read(inventoryRepositoryProvider)
        .createGoodsReceipt(request);
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
    final suppliers = ref.watch(supplierListProvider);
    final locations = ref.watch(locationListProvider);
    final uoms = ref.watch(uomListProvider);
    final products = ref.watch(productListProvider);

    return Scaffold(
      appBar: AppBar(title: Text('${l10n.docReceipt} · ${l10n.actionCreate}')),
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
                message: 'Sənəd qaralama statusundadır, post etmək lazımdır.',
              ),
              const SizedBox(height: WmsSpacing.space4),
            ],
            Wrap(
              spacing: WmsSpacing.space3,
              runSpacing: WmsSpacing.space3,
              children: [
                SizedBox(
                  width: 300,
                  child: suppliers.maybeWhen(
                    data: (page) => WmsSelect<int>(
                      label: l10n.labelSupplier,
                      required: true,
                      value: _supplierId,
                      placeholder: 'Seçin',
                      options: [
                        for (final s in page.items)
                          WmsSelectOption(
                            value: s.id,
                            label: '${s.code} · ${s.name}',
                          ),
                      ],
                      onChanged: (value) => setState(() => _supplierId = value),
                    ),
                    orElse: () => WmsSelect<int>(
                      label: l10n.labelSupplier,
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
                  width: 240,
                  child: WmsSelect<QualityStatus>(
                    label: 'Keyfiyyət',
                    required: true,
                    value: _quality,
                    options: const [
                      WmsSelectOption(
                        value: QualityStatus.accepted,
                        label: 'Qəbul edilib',
                      ),
                      WmsSelectOption(
                        value: QualityStatus.partiallyAccepted,
                        label: 'Qismən qəbul',
                      ),
                      WmsSelectOption(
                        value: QualityStatus.rejected,
                        label: 'Rədd edilib',
                      ),
                    ],
                    onChanged: (value) => setState(
                      () => _quality = value ?? QualityStatus.accepted,
                    ),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: WmsTextField(
                    label: 'Temperatur (°C)',
                    hint: 'Soyuq zəncir sənədləri üçün',
                    alignRight: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    onChanged: (value) => _temperature = Decimal.tryParse(
                      value.replaceAll(',', '.'),
                    ),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: WmsTextField(
                    label: l10n.labelDate,
                    readOnly: true,
                    controller: TextEditingController(
                      text: WmsFormat.date(_docDate),
                    ),
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
                  onPressed: () =>
                      setState(() => _lines.add(ReceiptLineDraft())),
                ),
              ],
            ),
            const SizedBox(height: WmsSpacing.space3),
            for (var i = 0; i < _lines.length; i++)
              _LineCard(
                index: i,
                line: _lines[i],
                products: products.value?.items ?? const <ProductDto>[],
                uoms: uoms.value ?? const <UomDto>[],
                onChanged: () => setState(() {}),
                onRemove: _lines.length == 1
                    ? null
                    : () => setState(() => _lines.removeAt(i)),
              ),
            const SizedBox(height: WmsSpacing.space5),
            Align(
              alignment: Alignment.centerLeft,
              child: WmsButton.primary(
                label: l10n.actionSave,
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

class _LineCard extends ConsumerStatefulWidget {
  const _LineCard({
    required this.index,
    required this.line,
    required this.products,
    required this.uoms,
    required this.onChanged,
    this.onRemove,
  });

  final int index;
  final ReceiptLineDraft line;
  final List<ProductDto> products;
  final List<UomDto> uoms;
  final VoidCallback onChanged;
  final VoidCallback? onRemove;

  @override
  ConsumerState<_LineCard> createState() => _LineCardState();
}

class _LineCardState extends ConsumerState<_LineCard> {
  String? _scanError;
  bool _scanning = false;

  /// Scan → `GET /masterdata/products?barcode=` → fill the line.
  /// An unknown barcode is not an error state of the form: the message tells
  /// the keeper to pick the product by SKU instead (ux/screen-map §7.1).
  Future<void> _scanProduct() async {
    final scanner = ref.read(barcodeScannerProvider);
    final code = await scanner.scan();
    if (code == null || !mounted) return;
    setState(() {
      _scanning = true;
      _scanError = null;
    });
    final result = await ref
        .read(masterDataRepositoryProvider)
        .productByBarcode(code);
    if (!mounted) return;
    setState(() => _scanning = false);
    result.fold(
      (product) {
        widget.line.productId = product.id;
        widget.line.productName = product.name;
        widget.line.uomId = product.baseUomId;
        widget.onChanged();
      },
      (_) {
        setState(() => _scanError = 'Bu barkod məhsula bağlı deyil: $code');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final index = widget.index;
    final line = widget.line;
    final products = widget.products;
    final uoms = widget.uoms;
    final onChanged = widget.onChanged;
    final onRemove = widget.onRemove;
    final scanner = ref.watch(barcodeScannerProvider);
    final scanError = _scanError;
    final selectedProduct = products.cast<ProductDto?>().firstWhere(
      (p) => p!.id == line.productId,
      orElse: () => null,
    );
    final productUoms = <WmsProductUom>[
      if (selectedProduct != null)
        for (final u in selectedProduct.uoms)
          WmsProductUom(
            id: u.uomId,
            code: u.uomCode ?? '#${u.uomId}',
            factorToBase: u.factorToBase,
          ),
      if (selectedProduct != null && selectedProduct.uoms.isEmpty)
        WmsProductUom(
          id: selectedProduct.baseUomId,
          code: selectedProduct.baseUomCode ?? 'BASE',
          factorToBase: Decimal.one,
        ),
      if (selectedProduct == null)
        for (final u in uoms)
          WmsProductUom(id: u.id, code: u.code, factorToBase: Decimal.one),
    ];

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
              Expanded(
                child: Text(
                  'Sətir ${index + 1}',
                  style: WmsTypography.label.copyWith(color: c.inkMuted),
                ),
              ),
              if (onRemove != null)
                WmsIconButton(
                  icon: Icons.delete_outline,
                  label: 'Sətri sil',
                  onPressed: onRemove,
                ),
            ],
          ),
          if (scanError != null) ...[
            const SizedBox(height: WmsSpacing.space2),
            WmsAlert(
              tone: WmsAlertTone.warning,
              title: scanError,
              message: 'Məhsulu SKU ilə siyahıdan seçin.',
              onClose: () => setState(() => _scanError = null),
            ),
          ],
          const SizedBox(height: WmsSpacing.space2),
          Wrap(
            spacing: WmsSpacing.space3,
            runSpacing: WmsSpacing.space3,
            children: [
              if (scanner.isAvailable)
                Padding(
                  padding: const EdgeInsets.only(top: WmsSpacing.space5),
                  child: WmsButton(
                    label: l10n.actionScan,
                    size: WmsButtonSize.sm,
                    iconLeft: Icons.qr_code_scanner_outlined,
                    loading: _scanning,
                    onPressed: _scanProduct,
                  ),
                ),
              SizedBox(
                width: 320,
                child: WmsSelect<int>(
                  label: l10n.labelProduct,
                  required: true,
                  value: line.productId,
                  placeholder: 'Məhsul seçin',
                  options: [
                    for (final p in products)
                      WmsSelectOption(
                        value: p.id,
                        label: '${p.sku} · ${p.name}',
                      ),
                  ],
                  onChanged: (value) {
                    line.productId = value;
                    final product = products.cast<ProductDto?>().firstWhere(
                      (p) => p!.id == value,
                      orElse: () => null,
                    );
                    line.productName = product?.name;
                    line.uomId = product?.baseUomId;
                    onChanged();
                  },
                ),
              ),
              SizedBox(
                width: 220,
                child: WmsQtyUomInput(
                  label: l10n.labelOrdered,
                  hint: 'PO-dan gəlir',
                  uoms: productUoms,
                  baseUomCode: selectedProduct?.baseUomCode,
                  uomId: line.uomId,
                  qty: line.orderedQty,
                  onQtyChanged: (value) {
                    line.orderedQty = value;
                    onChanged();
                  },
                  onUomChanged: (id) {
                    line.uomId = id;
                    onChanged();
                  },
                ),
              ),
              SizedBox(
                width: 220,
                child: WmsQtyUomInput(
                  label: l10n.labelReceived,
                  required: true,
                  uoms: productUoms,
                  baseUomCode: selectedProduct?.baseUomCode,
                  uomId: line.uomId,
                  qty: line.receivedQty,
                  onQtyChanged: (value) {
                    line.receivedQty = value;
                    onChanged();
                  },
                  onUomChanged: (id) {
                    line.uomId = id;
                    onChanged();
                  },
                ),
              ),
              SizedBox(
                width: 200,
                child: WmsTextField(
                  label: l10n.labelBatchNo,
                  mono: true,
                  onChanged: (value) {
                    line.batchNo = value;
                    onChanged();
                  },
                ),
              ),
              SizedBox(
                width: 200,
                child: WmsTextField(
                  label: l10n.labelExpiryDate,
                  placeholder: 'gg.aa.iiii',
                  mono: true,
                  onChanged: (value) {
                    final parts = value.split('.');
                    line.expiryDate = parts.length == 3
                        ? DateTime.tryParse(
                            '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}',
                          )
                        : null;
                    onChanged();
                  },
                ),
              ),
            ],
          ),
          if (line.requiresVarianceNote) ...[
            const SizedBox(height: WmsSpacing.space3),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: WmsSpacing.space5),
                  child: WmsBadge(
                    text:
                        'Fərq ${WmsFormat.signedQuantity(line.variance, decimals: 3)}',
                    tone: WmsTone.warning,
                    icon: Icons.warning_amber_outlined,
                  ),
                ),
                const SizedBox(width: WmsSpacing.space3),
                Expanded(
                  child: WmsTextField(
                    label: l10n.labelVarianceNote,
                    required: true,
                    error: line.varianceNoteMissing
                        ? l10n.validationVarianceNoteRequired
                        : null,
                    onChanged: (value) {
                      line.varianceNote = value;
                      onChanged();
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
