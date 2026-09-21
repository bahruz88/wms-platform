import 'package:meta/meta.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

/// What the branch has typed into «Günün satışı» so far.
///
/// The screen is a one-handed job on a phone, so ordering matters more than
/// it looks: an item the user has just touched jumps to the top and stays
/// there for the rest of the session. Everything else keeps the server's
/// order, which is `name_sort_key` — the Azerbaijani alphabet does not
/// survive Dart's `compareTo`.
@immutable
class DailySalesDraft {
  const DailySalesDraft({
    this.quantities = const {},
    this.recentOrder = const [],
  });

  /// Seeds the draft from an existing `DRAFT` import so a half-finished day
  /// can be picked up again.
  factory DailySalesDraft.fromImport(SalesImportDetailDto import) {
    final quantities = <int, Quantity>{};
    final order = <int>[];
    for (final line in import.lines) {
      final id = line.menuItemId;
      if (id == null || line.qtySold.isZero) continue;
      quantities[id] = line.qtySold;
      order.add(id);
    }
    return DailySalesDraft(
      quantities: Map.unmodifiable(quantities),
      recentOrder: List.unmodifiable(order),
    );
  }

  /// Menu item id → units sold. A zero or cleared entry is removed, never
  /// stored, so an untouched item is not submitted as «0 sold».
  final Map<int, Quantity> quantities;

  /// Menu item ids in most-recently-touched-first order.
  final List<int> recentOrder;

  bool get isEmpty => quantities.isEmpty;
  bool get isNotEmpty => quantities.isNotEmpty;

  /// Number of menu items with a quantity.
  int get enteredCount => quantities.length;

  /// Running total of all units entered — the figure under the list.
  Quantity get totalUnits =>
      quantities.values.fold(Quantity.zero, (sum, q) => sum + q);

  Quantity? quantityOf(int menuItemId) => quantities[menuItemId];

  /// Sets (or clears, when [qty] is `null`, zero or negative) one item and
  /// moves it to the front of [recentOrder].
  DailySalesDraft withQuantity(int menuItemId, Quantity? qty) {
    final next = Map<int, Quantity>.from(quantities);
    final order = List<int>.from(recentOrder)..remove(menuItemId);
    if (qty == null || qty.isZero || qty.isNegative) {
      next.remove(menuItemId);
    } else {
      next[menuItemId] = qty;
      order.insert(0, menuItemId);
    }
    return DailySalesDraft(
      quantities: Map.unmodifiable(next),
      recentOrder: List.unmodifiable(order),
    );
  }

  DailySalesDraft cleared() => const DailySalesDraft();

  /// [items] reordered so the ones already used come first, in
  /// most-recent-first order; the rest keep the server's order.
  List<MenuItemDto> sort(List<MenuItemDto> items) {
    if (recentOrder.isEmpty) return List<MenuItemDto>.unmodifiable(items);
    final byId = {for (final item in items) item.id: item};
    final recent = [
      for (final id in recentOrder)
        if (byId.containsKey(id)) byId[id]!,
    ];
    final recentIds = recent.map((i) => i.id).toSet();
    return List<MenuItemDto>.unmodifiable([
      ...recent,
      ...items.where((i) => !recentIds.contains(i.id)),
    ]);
  }

  /// Payload for `POST /sales-imports` / `PUT /sales-imports/{id}`.
  /// Only items with a quantity are sent; the order follows [recentOrder]
  /// so the request is stable between a create and a later replace.
  List<SalesLineInput> toLines() {
    final ids = [
      ...recentOrder.where(quantities.containsKey),
      ...quantities.keys.where((id) => !recentOrder.contains(id)),
    ];
    return [
      for (final id in ids)
        SalesLineInput(menuItemId: id, qtySold: quantities[id]!),
    ];
  }

  @override
  bool operator ==(Object other) =>
      other is DailySalesDraft &&
      _sameQuantities(other.quantities) &&
      _sameOrder(other.recentOrder);

  bool _sameQuantities(Map<int, Quantity> other) =>
      other.length == quantities.length &&
      quantities.entries.every((e) => other[e.key] == e.value);

  bool _sameOrder(List<int> other) =>
      other.length == recentOrder.length &&
      List.generate(
        recentOrder.length,
        (i) => other[i] == recentOrder[i],
      ).every((eq) => eq);

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(quantities.entries.map(_entryHash)),
    Object.hashAll(recentOrder),
  );

  static int _entryHash(MapEntry<int, Quantity> e) =>
      Object.hash(e.key, e.value);
}

/// What «Satışı təsdiqlə» must do, given the day's existing document.
///
/// `(location, businessDate)` is unique for `cons_sales_import`, so the
/// screen cannot simply `POST` twice: the second call would answer
/// `409 DUPLICATE_BUSINESS_DATE`.
sealed class DailySalesAction {
  const DailySalesAction();
}

/// No document for the day yet: `POST /sales-imports` then submit.
class CreateAndSubmit extends DailySalesAction {
  const CreateAndSubmit();
}

/// A `DRAFT` exists: `PUT /sales-imports/{id}` then submit.
class ReplaceAndSubmit extends DailySalesAction {
  const ReplaceAndSubmit({required this.importId, required this.rowVersion});

  final int importId;
  final int rowVersion;
}

/// The day is closed for entry — the reason is shown, not the action.
class DailySalesBlocked extends DailySalesAction {
  const DailySalesBlocked({required this.status, required this.importId});

  final SalesImportStatus status;
  final int importId;
}

/// Decides the submit path from the day's existing import (`null` when the
/// list came back empty).
DailySalesAction planDailySales(SalesImportDto? existing) {
  if (existing == null) return const CreateAndSubmit();
  return switch (existing.status) {
    SalesImportStatus.draft => ReplaceAndSubmit(
      importId: existing.id,
      rowVersion: existing.rowVersion,
    ),
    SalesImportStatus.submitted ||
    SalesImportStatus.consumed ||
    SalesImportStatus.cancelled => DailySalesBlocked(
      status: existing.status,
      importId: existing.id,
    ),
  };
}
