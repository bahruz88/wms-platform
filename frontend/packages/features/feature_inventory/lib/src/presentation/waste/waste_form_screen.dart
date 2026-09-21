import 'package:decimal/decimal.dart';
import 'package:feature_master_data/feature_master_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import '../attachments/attachment_upload_controller.dart';
import '../attachments/attachment_upload_field.dart';
import '../inventory_providers.dart';

class _WasteLine {
  int? productId;
  int? uomId;
  int? batchId;
  Quantity? qty;

  bool get isValid =>
      productId != null && uomId != null && qty != null && qty!.isPositive;
}

/// Waste document (`WS-YYYY-00000`): reason code is mandatory and photo
/// evidence is required when the reason code says so (`requires_photo`).
/// Photos are uploaded through the Documents presigned URL flow and their
/// ids travel with the create request (`attachmentIds`).
class WasteFormScreen extends ConsumerStatefulWidget {
  const WasteFormScreen({super.key});

  @override
  ConsumerState<WasteFormScreen> createState() => _WasteFormScreenState();
}

class _WasteFormScreenState extends ConsumerState<WasteFormScreen> {
  final List<_WasteLine> _lines = [_WasteLine()];
  int? _locationId;
  int? _reasonCodeId;
  String? _note;
  bool _submitting = false;
  Failure? _failure;
  String? _createdDocNo;

  ReasonCodeDto? _reason(List<ReasonCodeDto> reasons) => reasons
      .cast<ReasonCodeDto?>()
      .firstWhere((r) => r!.id == _reasonCodeId, orElse: () => null);

  bool _photoRequired(List<ReasonCodeDto> reasons) =>
      _reason(reasons)?.requiresPhoto ?? false;

  /// Ids of the photos already uploaded for this draft.
  List<int> get _attachmentIds => ref
      .read(attachmentUploadProvider(AttachmentEntityType.waste))
      .attachmentIds;

  bool _photoAttached(AttachmentUploadState upload) => upload.hasAttachment;

  bool _isValid(List<ReasonCodeDto> reasons, AttachmentUploadState upload) =>
      _locationId != null &&
      _reasonCodeId != null &&
      _lines.every((l) => l.isValid) &&
      (!_photoRequired(reasons) || _photoAttached(upload));

  String? _invalidReason(
    List<ReasonCodeDto> reasons,
    AttachmentUploadState upload,
  ) {
    if (_locationId == null) return 'Lokasiya seçilməyib';
    if (_reasonCodeId == null) return 'Səbəb kodu seçilməyib';
    if (_photoRequired(reasons) && !_photoAttached(upload)) {
      return 'Bu səbəb kodu foto tələb edir';
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
        .createWaste(
          CreateWasteRequest(
            docDate: DateTime.now(),
            locationId: _locationId!,
            reasonCodeId: _reasonCodeId!,
            note: _note,
            attachmentIds: _attachmentIds,
            lines: [
              for (final line in _lines)
                CreateWasteLine(
                  productId: line.productId!,
                  qty: line.qty!,
                  uomId: line.uomId!,
                  batchId: line.batchId,
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
    if (result.isOk) {
      // The photos belong to the document now; the next draft starts empty.
      ref
          .read(attachmentUploadProvider(AttachmentEntityType.waste).notifier)
          .reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final locations = ref.watch(locationListProvider);
    final products = ref.watch(productListProvider);
    final uoms = ref.watch(uomListProvider);
    final reasonsAsync = ref.watch(reasonCodeListProvider(ReasonGroup.waste));
    final reasons = reasonsAsync.value ?? const <ReasonCodeDto>[];
    final upload = ref.watch(
      attachmentUploadProvider(AttachmentEntityType.waste),
    );

    return Scaffold(
      appBar: AppBar(title: Text('${l10n.docWaste} · ${l10n.actionCreate}')),
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
                message: 'Tullantı təsdiq gözləyir (inv.waste.approve).',
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
                  width: 360,
                  child: WmsSelect<int>(
                    label: l10n.labelReasonCode,
                    required: true,
                    value: _reasonCodeId,
                    placeholder: 'Səbəb seçin',
                    hint: 'Siyahı WASTE qrupu ilə məhdudlaşır',
                    options: [
                      for (final reason in reasons)
                        WmsSelectOption(
                          value: reason.id,
                          label: '${reason.code} · ${reason.name}',
                        ),
                    ],
                    onChanged: (value) => setState(() => _reasonCodeId = value),
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
            const SizedBox(height: WmsSpacing.space4),
            AttachmentUploadField(
              entityType: AttachmentEntityType.waste,
              attachmentType: AttachmentType.wastePhoto,
              label: l10n.labelPhoto,
              required: _photoRequired(reasons),
              hint: _photoRequired(reasons)
                  ? 'Bu səbəb kodu foto tələb edir (JPEG/PNG, ən çox 25 MB).'
                  : null,
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
                  onPressed: () => setState(() => _lines.add(_WasteLine())),
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
                enabled: _isValid(reasons, upload),
                disabledReason: _invalidReason(reasons, upload),
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
