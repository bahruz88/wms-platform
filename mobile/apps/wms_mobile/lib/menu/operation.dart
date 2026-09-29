import 'package:flutter/material.dart';

/// One tile on the home menu: a thing this person can go and do.
///
/// The menu is built from these rather than from the person's role, and each
/// carries the permission that puts it there. Two people with the same job title
/// can hold different permissions, and a role list would have to be kept in step
/// with the permission catalogue by hand; this way the menu is right by
/// construction — a keeper sees the keeper's work because a keeper holds the
/// keeper's permissions.
@immutable
class WmsOperation {
  const WmsOperation({
    required this.label,
    required this.icon,
    required this.route,
    required this.permission,
    required this.group,
    this.hint,
  });

  /// What the tile says. A verb where there is one: «Qəbul et», not «Qəbullar».
  final String label;

  final IconData icon;

  /// Where it goes.
  final String route;

  /// The permission that shows it. No permission, no tile — the screen behind it
  /// gates again, so a deep link cannot walk around this.
  final String permission;

  /// Which part of the day it belongs to; the menu keeps groups together.
  final WmsOperationGroup group;

  /// A second line, when the label alone is not enough.
  final String? hint;
}

/// The menu's sections, in the order they are shown.
enum WmsOperationGroup {
  /// Goods arriving: purchase receipts, confirming a transfer.
  inbound('Mal qəbulu'),

  /// Goods leaving: picking, dispatching, requesting.
  outbound('Göndəriş'),

  /// Counting, writing off, sampling — what keeps the ledger honest.
  control('Nəzarət'),

  /// The branch's own day (ADR-012).
  branch('Filialın günü'),

  /// Buying: requisitions, RFQs, orders.
  procurement('Satınalma'),

  /// Looking things up.
  lookup('Axtarış');

  const WmsOperationGroup(this.label);

  final String label;
}
