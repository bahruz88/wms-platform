import 'package:flutter/material.dart';

import '../tokens/wms_colors.dart';
import '../tokens/wms_opacity.dart';
import '../tokens/wms_radius.dart';
import '../tokens/wms_spacing.dart';
import '../tokens/wms_typography.dart';
import 'wms_field.dart';

/// One option of [WmsSelect]. A non-selectable option is kept in the list,
/// disabled, with [disabledReason] appended to its label:
/// «Non-Food WH (qida qəbul etmir)».
@immutable
class WmsSelectOption<T> {
  const WmsSelectOption({
    required this.value,
    required this.label,
    this.enabled = true,
    this.disabledReason,
  });

  final T value;
  final String label;
  final bool enabled;
  final String? disabledReason;

  String get displayLabel =>
      !enabled && disabledReason != null && disabledReason!.isNotEmpty
      ? '$label ($disabledReason)'
      : label;
}

/// `.wms-select`. Keep the list ordered by the server's `name_sort_key`;
/// do not sort client-side (Dart's `compareTo` misplaces `ə`).
class WmsSelect<T> extends StatelessWidget {
  const WmsSelect({
    required this.options,
    required this.onChanged,
    this.value,
    this.label,
    this.required = false,
    this.hint,
    this.error,
    this.placeholder,
    this.enabled = true,
    super.key,
  });

  final List<WmsSelectOption<T>> options;
  final ValueChanged<T?>? onChanged;
  final T? value;
  final String? label;
  final bool required;
  final String? hint;
  final String? error;
  final String? placeholder;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final c = WmsColors.of(context);
    final hasError = error != null && error!.isNotEmpty;
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: WmsRadius.mdAll,
          borderSide: BorderSide(color: color, width: width),
        );
    final textStyle = WmsTypography.body.copyWith(color: c.ink);
    Widget select = DropdownButtonFormField<T>(
      initialValue: options.any((o) => o.value == value) ? value : null,
      isExpanded: true,
      icon: Icon(Icons.expand_more, size: 16, color: c.inkMuted),
      style: textStyle,
      dropdownColor: c.surfaceRaised,
      borderRadius: WmsRadius.mdAll,
      hint: placeholder == null
          ? null
          : Text(placeholder!, style: textStyle.copyWith(color: c.inkSubtle)),
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: c.surface,
        contentPadding: WmsSpacing.control,
        constraints: const BoxConstraints(minHeight: 34),
        border: border(c.borderControl),
        enabledBorder: border(hasError ? c.danger : c.borderControl),
        disabledBorder: border(c.borderControl),
        focusedBorder: border(hasError ? c.danger : c.focusRing, 2),
      ),
      items: [
        for (final option in options)
          DropdownMenuItem<T>(
            value: option.value,
            enabled: option.enabled,
            child: Opacity(
              opacity: option.enabled ? 1 : WmsOpacity.disabled,
              child: Text(
                option.displayLabel,
                style: textStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
      ],
    );
    if (!enabled) select = Opacity(opacity: WmsOpacity.disabled, child: select);
    return WmsField(
      label: label,
      required: required,
      hint: hint,
      error: error,
      child: select,
    );
  }
}
