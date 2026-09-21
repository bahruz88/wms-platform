import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/wms_colors.dart';
import '../tokens/wms_opacity.dart';
import '../tokens/wms_radius.dart';
import '../tokens/wms_spacing.dart';
import '../tokens/wms_typography.dart';
import 'wms_field.dart';

/// `.wms-input`. Use [mono] for identifiers (SKU, barcode, batch, document
/// number). Read-only values use [readOnly], not [enabled] = false, so they
/// stay selectable/copyable. Not for quantities — use `WmsQtyUomInput`.
class WmsTextField extends StatelessWidget {
  const WmsTextField({
    this.controller,
    this.initialValue,
    this.label,
    this.required = false,
    this.hint,
    this.error,
    this.placeholder,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.mono = false,
    this.alignRight = false,
    this.maxLength,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.autofocus = false,
    this.focusNode,
    this.textInputAction,
    super.key,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final String? label;
  final bool required;
  final String? hint;
  final String? error;
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool readOnly;
  final bool mono;
  final bool alignRight;
  final int? maxLength;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final c = WmsColors.of(context);
    final hasError = error != null && error!.isNotEmpty;
    final style =
        (mono
                ? WmsTypography.docNo.copyWith(fontSize: 14, height: 20 / 14)
                : WmsTypography.body)
            .copyWith(color: c.ink);
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: WmsRadius.mdAll,
          borderSide: BorderSide(color: color, width: width),
        );
    Widget field = TextField(
      controller:
          controller ??
          (initialValue == null
              ? null
              : TextEditingController(text: initialValue)),
      focusNode: focusNode,
      enabled: enabled,
      readOnly: readOnly,
      autofocus: autofocus,
      maxLength: maxLength,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: style,
      textAlign: alignRight ? TextAlign.right : TextAlign.left,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: c.surface,
        hintText: placeholder,
        hintStyle: style.copyWith(color: c.inkSubtle),
        counterText: '',
        contentPadding: WmsSpacing.control,
        constraints: const BoxConstraints(minHeight: 34),
        border: border(c.borderControl),
        enabledBorder: border(hasError ? c.danger : c.borderControl),
        disabledBorder: border(c.borderControl),
        focusedBorder: border(hasError ? c.danger : c.focusRing, 2),
      ),
    );
    if (!enabled) {
      field = Opacity(opacity: WmsOpacity.disabled, child: field);
    }
    return WmsField(
      label: label,
      required: required,
      hint: hint,
      error: error,
      child: field,
    );
  }
}
