import 'package:flutter/material.dart';

import 'wms_badge.dart';

/// The only way to show a document/batch status. Maps the server ENUM to an
/// Azerbaijani label and a tone; unknown values are shown verbatim in the
/// neutral tone (never blank). The raw ENUM stays in the tooltip.
class WmsDocStatusBadge extends StatelessWidget {
  const WmsDocStatusBadge({
    required this.status,
    this.label,
    this.dot = true,
    super.key,
  });

  /// Server ENUM value, e.g. `PENDING_APPROVAL`.
  final String status;

  /// Overrides the default label — only when really necessary.
  final String? label;
  final bool dot;

  /// ENUM → (label, tone). Extend here when a status is added to the spec.
  static const Map<String, (String, WmsTone)> statuses = {
    // Generic document lifecycle
    'DRAFT': ('Qaralama', WmsTone.neutral),
    'SUBMITTED': ('Təqdim edilib', WmsTone.accent),
    'PENDING_APPROVAL': ('Təsdiq gözləyir', WmsTone.warning),
    'APPROVED': ('Təsdiqlənib', WmsTone.success),
    'REJECTED': ('Rədd edilib', WmsTone.danger),
    'POSTED': ('Post edilib', WmsTone.success),
    'CANCELLED': ('Ləğv edilib', WmsTone.danger),
    'CLOSED': ('Bağlanıb', WmsTone.neutral),
    // Procurement
    'IN_PROCUREMENT': ('Satınalmada', WmsTone.accent),
    'CONVERTED_TO_PO': ('PO-ya çevrilib', WmsTone.success),
    'SENT': ('Göndərilib', WmsTone.accent),
    'SENT_TO_SUPPLIER': ('Təchizatçıya göndərilib', WmsTone.accent),
    'PARTIALLY_RECEIVED': ('Qismən qəbul edilib', WmsTone.warning),
    'FULLY_RECEIVED': ('Tam qəbul edilib', WmsTone.success),
    'PENDING': ('Gözləyir', WmsTone.warning),
    // Stock request / issue
    'PICKING': ('Yığılır', WmsTone.accent),
    'PARTIALLY_ISSUED': ('Qismən buraxılıb', WmsTone.warning),
    'ISSUED': ('Buraxılıb', WmsTone.success),
    'DISPATCHED': ('Yolda', WmsTone.accent),
    'RECEIVED': ('Qəbul edilib', WmsTone.success),
    'DISCREPANCY': ('Uyğunsuzluq', WmsTone.danger),
    // Count
    'FROZEN': ('Dondurulub', WmsTone.warning),
    'COUNTING': ('Sayılır', WmsTone.accent),
    'REVIEW': ('Baxılır', WmsTone.warning),
    // Batch
    'ACTIVE': ('Aktiv', WmsTone.success),
    'BLOCKED': ('Bloklanıb', WmsTone.danger),
    'EXPIRED': ('Vaxtı keçib', WmsTone.danger),
    'QUARANTINE': ('Karantin', WmsTone.warning),
    // Receipt quality
    'ACCEPTED': ('Qəbul edilib', WmsTone.success),
    'PARTIALLY_ACCEPTED': ('Qismən qəbul', WmsTone.warning),
    // Location
    'IN_TRANSIT': ('Yolda', WmsTone.virtual),
    // Consumption (ADR-012): recipe versions, sales imports, runs
    'ARCHIVED': ('Arxivlənib', WmsTone.neutral),
    'CONSUMED': ('İstehlaka düşüb', WmsTone.success),
    'CALCULATED': ('Hesablanıb', WmsTone.accent),
    'REVERSED': ('Storno edilib', WmsTone.danger),
    // Jobs / exports
    'QUEUED': ('Növbədə', WmsTone.accent),
    'RUNNING': ('İcra olunur', WmsTone.accent),
    'COMPLETED': ('Tamamlanıb', WmsTone.success),
    'FAILED': ('Uğursuz', WmsTone.danger),
  };

  static (String, WmsTone) resolve(String status) =>
      statuses[status] ?? (status, WmsTone.neutral);

  @override
  Widget build(BuildContext context) {
    final (defaultLabel, tone) = resolve(status);
    return WmsBadge(
      text: label ?? defaultLabel,
      tone: tone,
      dot: dot,
      tooltip: status,
    );
  }
}
