import 'package:feature_inventory/feature_inventory.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_core/wms_core.dart';

import 'task.dart';

/// The keeper's queue, gathered from every module that can hand them work.
///
/// Four list calls in parallel, each already filtered to the state that means
/// "someone has to act". A permission the caller lacks drops its whole source
/// rather than failing the screen: a branch user with no count permission simply
/// has no counts in the queue.
///
/// Deliberately not paged. This is a to-do list, not a register — if it ever ran
/// past a screenful the problem is the backlog, not the paging.
final tasksProvider = FutureProvider<List<WmsTask>>((ref) async {
  final inventory = ref.watch(inventoryRepositoryProvider);
  final permissions = ref.watch(sessionProvider)?.permissions ?? const <String>{};
  bool may(String permission) => permissions.contains(permission);

  // One page each. This is a to-do list, not a register: if a keeper's queue
  // ran past a page the problem would be the backlog, not the paging.
  const page = PageRequest();

  final results = await Future.wait<List<WmsTask>>([
    if (may(Permissions.issueConfirm))
      _issuesToConfirm(inventory, page)
    else
      Future.value(const <WmsTask>[]),
    if (may(Permissions.countEnter))
      _countsInProgress(inventory, page)
    else
      Future.value(const <WmsTask>[]),
    if (may(Permissions.wasteCreate))
      _draftWaste(inventory, page)
    else
      Future.value(const <WmsTask>[]),
  ]);

  final tasks = [for (final group in results) ...group]
    ..sort((a, b) {
      final byKind = a.kind.index.compareTo(b.kind.index);
      if (byKind != 0) return byKind;
      final left = a.sortKey;
      final right = b.sortKey;
      if (left == null || right == null) return 0;
      // Oldest first inside a kind: the document that has waited longest is the
      // one at risk of being forgotten.
      return left.compareTo(right);
    });
  return tasks;
});

/// Dispatched issues are the most urgent: the goods are on a van, counted in
/// neither the warehouse nor the branch until someone confirms them.
Future<List<WmsTask>> _issuesToConfirm(
  InventoryRepository inventory,
  PageRequest page,
) async {
  final result = await inventory.issues(status: IssueStatus.dispatched, page: page);
  final issues = result.valueOrNull?.items ?? const <IssueDto>[];
  return [
    for (final issue in issues)
      WmsTask(
        docNo: issue.docNo,
        status: issue.status.wire,
        title: '${issue.toLocation.name} — qəbulu təsdiqlə',
        meta: _lineCount(issue.lineCount, issue.lines.length),
        route: InventoryRoutes.issueConfirm(issue.id),
        kind: WmsTaskKind.confirmReceipt,
        sortKey: issue.dispatchedAt,
      ),
  ];
}

Future<List<WmsTask>> _countsInProgress(
  InventoryRepository inventory,
  PageRequest page,
) async {
  final result = await inventory.counts(page: page);
  final counts = result.valueOrNull?.items ?? const <CountDto>[];
  return [
    for (final count in counts)
      if (count.status == CountStatus.counting ||
          count.status == CountStatus.frozen)
        WmsTask(
          docNo: count.docNo,
          status: count.status.wire,
          title: '${count.location.name} sayımı',
          meta: count.lineCount == 0
              ? 'Sətir gözlənilir'
              : '${count.lineCount} sətirdən ${count.countedLineCount}-i sayılıb',
          route: InventoryRoutes.countDetail(count.id),
          kind: WmsTaskKind.count,
          sortKey: count.frozenAt,
        ),
  ];
}

/// A draft write-off is someone's unfinished sentence — usually waiting for the
/// photo its reason code demands.
Future<List<WmsTask>> _draftWaste(
  InventoryRepository inventory,
  PageRequest page,
) async {
  final result = await inventory.wasteDocuments(page: page);
  final wastes = result.valueOrNull?.items ?? const <WasteDto>[];
  return [
    for (final waste in wastes)
      if (waste.status == WasteStatus.draft)
        WmsTask(
          docNo: waste.docNo,
          status: waste.status.wire,
          title: 'Tullantı — tamamlanmayıb',
          meta: [
            waste.location.name,
            if (waste.reasonCodeName != null) waste.reasonCodeName!,
          ].join(' · '),
          route: InventoryRoutes.wastePath,
          kind: WmsTaskKind.waste,
          sortKey: waste.audit?.createdAt,
        ),
  ];
}

String _lineCount(int declared, int loaded) {
  final count = declared > 0 ? declared : loaded;
  return count == 1 ? '1 sətir' : '$count sətir';
}
