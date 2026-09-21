import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wms_core/wms_core.dart';

import '../format/wms_format.dart';
import '../tokens/wms_colors.dart';
import '../tokens/wms_opacity.dart';
import '../tokens/wms_radius.dart';
import '../tokens/wms_spacing.dart';
import '../tokens/wms_typography.dart';
import 'wms_field.dart';
import 'wms_focus_ring.dart';

/// `master_product_uom` row as needed by [WmsQtyUomInput]. The base UoM must
/// be present with `factorToBase == 1`.
@immutable
class WmsProductUom {
  const WmsProductUom({
    required this.id,
    required this.code,
    required this.factorToBase,
  });

  final int id;
  final String code;
  final Decimal factorToBase;

  bool get isBase => factorToBase == Decimal.one;
}

/// `.wms-qty` — quantity + unit in one control, with the live base UoM
/// equivalent underneath. **Every quantity entry in the system goes through
/// this widget.**
///
/// * digits are right-aligned, mono, tabular;
/// * negative values are rejected (the sign comes from the document type);
/// * changing the unit never converts the number — only the base line
///   (`= 96 PCS · əmsal 12`) updates;
/// * [decimals] is `base_uom.decimals`, never a constant.
class WmsQtyUomInput extends StatefulWidget {
  const WmsQtyUomInput({
    required this.uoms,
    this.baseUomCode,
    this.decimals = 3,
    this.qty,
    this.uomId,
    this.onQtyChanged,
    this.onUomChanged,
    this.label,
    this.required = false,
    this.hint,
    this.error,
    this.placeholder = '0',
    this.enabled = true,
    this.available,
    this.autofocus = false,
    super.key,
  });

  final List<WmsProductUom> uoms;
  final String? baseUomCode;
  final int decimals;
  final Quantity? qty;
  final int? uomId;
  final ValueChanged<Quantity?>? onQtyChanged;
  final ValueChanged<int>? onUomChanged;
  final String? label;
  final bool required;
  final String? hint;
  final String? error;
  final String? placeholder;
  final bool enabled;

  /// Available stock; when the entered quantity exceeds it an error is shown
  /// together with the available figure.
  final Quantity? available;
  final bool autofocus;

  static const String negativeError = 'Miqdar mənfi ola bilməz';

  /// Allows digits and one decimal separator (`,` or `.`); denies `-`.
  static final List<TextInputFormatter> formatters = [
    FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
  ];

  @override
  State<WmsQtyUomInput> createState() => _WmsQtyUomInputState();
}

class _WmsQtyUomInputState extends State<WmsQtyUomInput> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;
  String? _localError;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.qty == null ? '' : _display(widget.qty!),
    );
    _focusNode.addListener(
      () => setState(() => _focused = _focusNode.hasFocus),
    );
  }

  @override
  void didUpdateWidget(WmsQtyUomInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.qty != oldWidget.qty && !_focusNode.hasFocus) {
      _controller.text = widget.qty == null ? '' : _display(widget.qty!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _display(Quantity q) =>
      q.value.toStringAsFixed(widget.decimals).replaceAll('.', ',');

  WmsProductUom? get _selected {
    if (widget.uoms.isEmpty) return null;
    return widget.uoms.cast<WmsProductUom?>().firstWhere(
      (u) => u!.id == widget.uomId,
      orElse: () => widget.uoms.first,
    );
  }

  void _onChanged(String raw) {
    final parsed = Quantity.tryParse(raw);
    String? error;
    if (raw.contains('-') || (parsed != null && parsed.isNegative)) {
      error = WmsQtyUomInput.negativeError;
    } else if (raw.trim().isNotEmpty && parsed == null) {
      error = 'Düzgün rəqəm daxil edin';
    }
    setState(() => _localError = error);
    widget.onQtyChanged?.call(error == null ? parsed : null);
  }

  @override
  Widget build(BuildContext context) {
    final c = WmsColors.of(context);
    final selected = _selected;
    final qty = Quantity.tryParse(_controller.text);
    final available = widget.available;
    String? availabilityError;
    if (qty != null && available != null && selected != null) {
      final base = qty.toBase(selected.factorToBase, decimals: widget.decimals);
      if (base > available) {
        availabilityError =
            'Mövcud qalıqdan çoxdur — mövcud: ${WmsFormat.quantity(available, decimals: widget.decimals)} ${widget.baseUomCode ?? ''}'
                .trim();
      }
    }
    final error = widget.error ?? _localError ?? availabilityError;
    final hasError = error != null && error.isNotEmpty;
    final borderColor = hasError
        ? c.danger
        : (_focused ? c.focusRing : c.borderControl);
    final numStyle = WmsTypography.figure.copyWith(color: c.ink);

    final input = Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: WmsRadius.mdAll,
        border: Border.all(
          color: borderColor,
          width: _focused && !hasError ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: widget.enabled,
                autofocus: widget.autofocus,
                textAlign: TextAlign.right,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: WmsQtyUomInput.formatters,
                style: numStyle,
                onChanged: _onChanged,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintText: widget.placeholder,
                  hintStyle: numStyle.copyWith(color: c.inkSubtle),
                  contentPadding: WmsSpacing.control,
                  constraints: const BoxConstraints(minHeight: 34),
                ),
              ),
            ),
            if (selected != null)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: c.surfaceSunken,
                  border: Border(left: BorderSide(color: c.border)),
                ),
                child: widget.uoms.length > 1 && widget.enabled
                    ? DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: selected.id,
                          isDense: true,
                          padding: const EdgeInsets.symmetric(
                            horizontal: WmsSpacing.space2,
                          ),
                          style: WmsTypography.bodyStrong.copyWith(
                            fontSize: 13,
                            color: c.ink,
                          ),
                          dropdownColor: c.surfaceRaised,
                          borderRadius: WmsRadius.mdAll,
                          icon: Icon(
                            Icons.expand_more,
                            size: 16,
                            color: c.inkMuted,
                          ),
                          items: [
                            for (final u in widget.uoms)
                              DropdownMenuItem<int>(
                                value: u.id,
                                child: Text(u.code),
                              ),
                          ],
                          onChanged: (id) {
                            if (id != null) widget.onUomChanged?.call(id);
                          },
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: WmsSpacing.space2,
                        ),
                        child: Center(
                          child: Text(
                            selected.code,
                            style: WmsTypography.bodyStrong.copyWith(
                              fontSize: 13,
                              color: c.ink,
                            ),
                          ),
                        ),
                      ),
              ),
          ],
        ),
      ),
    );

    String? baseLine;
    if (selected != null && !selected.isBase && qty != null) {
      final base = qty.toBase(selected.factorToBase, decimals: widget.decimals);
      baseLine =
          '= ${WmsFormat.quantity(base, decimals: widget.decimals)} ${widget.baseUomCode ?? ''}'
          ' · əmsal ${WmsFormat.number(selected.factorToBase, decimals: _factorDecimals(selected.factorToBase))}';
    }

    Widget control = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        WmsFocusRing(focused: _focused, child: input),
        if (baseLine != null)
          Padding(
            padding: const EdgeInsets.only(
              top: WmsSpacing.space1,
              right: WmsFocusRing.offset,
            ),
            child: Text(
              baseLine,
              key: const ValueKey('wms-qty-base'),
              style: WmsTypography.figureSm.copyWith(color: c.inkMuted),
              textAlign: TextAlign.right,
            ),
          ),
      ],
    );
    if (!widget.enabled) {
      control = Opacity(opacity: WmsOpacity.disabled, child: control);
    }

    return WmsField(
      label: widget.label,
      required: widget.required,
      hint: widget.hint,
      error: error,
      child: control,
    );
  }

  static int _factorDecimals(Decimal factor) {
    final text = factor.toString();
    final dot = text.indexOf('.');
    return dot == -1 ? 0 : text.length - dot - 1;
  }
}
