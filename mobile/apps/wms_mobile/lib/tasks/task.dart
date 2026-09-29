import 'package:flutter/foundation.dart';

/// One piece of work waiting for the person holding the phone.
///
/// A task is not a table row: it is a document that is *theirs to move*, from
/// whichever module it came from. The keeper's day is a queue — pick this
/// request, receive that order, confirm the delivery that arrived, finish the
/// count — and the screen that queue belongs on cannot be any one module's list.
@immutable
class WmsTask {
  const WmsTask({
    required this.docNo,
    required this.status,
    required this.title,
    required this.meta,
    required this.route,
    required this.kind,
    this.sortKey,
  });

  /// `SR-2026-01204`. What the keeper reads first.
  final String docNo;

  /// The document's own status, shown as a badge: `PICKING`, `DISPATCHED`.
  final String status;

  /// What to do with it, in words: «Elmlər filialı üçün yığım».
  final String title;

  /// The detail that decides whether to open it now: how much is left, where
  /// it came from.
  final String meta;

  /// Where tapping goes.
  final String route;

  final WmsTaskKind kind;

  /// Ordering inside a kind — oldest first, so nothing is left behind.
  final DateTime? sortKey;
}

/// The kinds are the queue's order: a delivery standing at the door is more
/// urgent than a count that runs all week.
enum WmsTaskKind {
  /// A dispatched issue waiting for this location to confirm what arrived.
  confirmReceipt,

  /// A purchase order that has been sent and is expected in.
  receivePurchase,

  /// A stock request to pick.
  pick,

  /// A count that has been frozen and is being entered.
  count,

  /// A draft write-off that is not finished.
  waste,
}
