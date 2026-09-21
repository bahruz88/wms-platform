import 'package:flutter/material.dart';
import 'package:wms_design_system/wms_design_system.dart';

/// A read-only `dd.MM.yyyy` field with a calendar button.
///
/// Dates are shown through [WmsFormat.date] so the whole product reads one
/// format; typing is deliberately not allowed, which removes a whole class
/// of «is 03.04 March or April» mistakes on a phone.
class ConsumptionDateField extends StatelessWidget {
  const ConsumptionDateField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.firstDate,
    this.lastDate,
    this.hint,
    super.key,
  });

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final bool enabled;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? hint;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: value,
      firstDate: firstDate ?? DateTime(now.year - 3),
      lastDate: lastDate ?? DateTime(now.year + 1, 12, 31),
      helpText: label,
    );
    if (picked != null) {
      onChanged(DateTime(picked.year, picked.month, picked.day));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = WmsColors.of(context);
    return WmsField(
      label: label,
      hint: hint,
      child: Row(
        children: [
          Expanded(
            child: Text(
              WmsFormat.date(value),
              style: WmsTypography.figure.copyWith(color: c.ink),
            ),
          ),
          WmsIconButton(
            icon: Icons.event_outlined,
            label: label,
            onPressed: enabled ? () => _pick(context) : null,
          ),
        ],
      ),
    );
  }
}
