import 'package:feature_identity/feature_identity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_design_system/wms_design_system.dart';

import '../tasks/tasks_providers.dart';
import '../tasks/tasks_routes.dart';
import 'operation.dart';
import 'operations.dart';

/// The home menu: everything this person can go and do, as tiles.
///
/// A keeper standing in a cold room with one hand free does not want to read a
/// navigation tree. They want the thing they came to do, named, big enough to
/// hit with a glove on. The tiles are permission-gated, so the same screen is
/// the keeper's menu, the branch's menu and the buyer's menu without any of the
/// three being written out separately — and the heading names which one it is,
/// because an account that holds several people's permissions otherwise reads
/// as nobody's screen in particular.
class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = WmsColors.of(context);
    final session = ref.watch(sessionProvider);
    final permissions = session?.permissions ?? const <String>{};
    final workplace = WmsWorkplace.fromRoles(session?.roles ?? const []);
    final waiting = ref.watch(tasksProvider).value?.length ?? 0;

    final available = kOperations
        .where((operation) => permissions.contains(operation.permission))
        .toList();
    final groups = <WmsOperationGroup, List<WmsOperation>>{};
    for (final operation in available) {
      groups.putIfAbsent(operation.group, () => []).add(operation);
    }

    return Scaffold(
      backgroundColor: c.surfaceCanvas,
      body: Column(
        children: [
          _Header(session: session, workplace: workplace),
          Expanded(
            child: available.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(WmsSpacing.space4),
                    child: WmsEmptyState(
                      reason: 'Hesabınıza heç bir əməliyyat icazəsi verilməyib.',
                      nextStep: 'Administratordan rol təyin etməsini istəyin.',
                      icon: Icons.lock_outline,
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(WmsSpacing.space4),
                    children: [
                      if (waiting > 0) ...[
                        _WaitingBanner(count: waiting),
                        const SizedBox(height: WmsSpacing.space4),
                      ],
                      for (final group in WmsOperationGroup.values)
                        if (groups[group] case final list?) ...[
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: WmsSpacing.space2,
                            ),
                            child: Text(
                              group.label,
                              style: WmsTypography.label.copyWith(
                                color: c.inkMuted,
                              ),
                            ),
                          ),
                          _Tiles(operations: list),
                          const SizedBox(height: WmsSpacing.space5),
                        ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.session, required this.workplace});

  final Session? session;
  final WmsWorkplace workplace;

  @override
  Widget build(BuildContext context) {
    final c = WmsColors.of(context);
    return Material(
      color: c.surface,
      child: SafeArea(
        bottom: false,
        child: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: c.border)),
          ),
          padding: const EdgeInsets.all(WmsSpacing.space4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      session?.fullName ?? session?.username ?? '',
                      style: WmsTypography.titleLg.copyWith(color: c.ink),
                    ),
                    if (workplace != WmsWorkplace.unknown)
                      Text(
                        // Whose screen this is, in one word. An account holding
                        // several people's permissions otherwise reads as
                        // nobody's in particular.
                        workplace.label,
                        style: WmsTypography.caption.copyWith(
                          color: c.inkMuted,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => context.go(IdentityRoutes.profilePath),
                icon: const Icon(Icons.account_circle_outlined),
                color: c.inkMuted,
                tooltip: 'Profil',
                constraints: const BoxConstraints(
                  minWidth: WmsTouch.target,
                  minHeight: WmsTouch.target,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// «3 sənəd sizi gözləyir» over the tiles, linking to the queue.
class _WaitingBanner extends StatelessWidget {
  const _WaitingBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final c = WmsColors.of(context);
    return Material(
      color: c.accentSoft,
      borderRadius: WmsRadius.lgAll,
      child: InkWell(
        onTap: () => context.go(TasksRoutes.tasksPath),
        borderRadius: WmsRadius.lgAll,
        child: Container(
          constraints: const BoxConstraints(minHeight: WmsTouch.target),
          padding: const EdgeInsets.symmetric(
            horizontal: WmsSpacing.space4,
            vertical: WmsSpacing.space3,
          ),
          child: Row(
            children: [
              Icon(Icons.pending_actions_outlined, color: c.accent, size: 20),
              const SizedBox(width: WmsSpacing.space3),
              Expanded(
                child: Text(
                  '$count sənəd sizi gözləyir',
                  style: WmsTypography.bodyStrong.copyWith(color: c.accent),
                ),
              ),
              Icon(Icons.chevron_right, color: c.accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tiles extends StatelessWidget {
  const _Tiles({required this.operations});

  final List<WmsOperation> operations;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      // Two columns on a phone, more as the window grows; the tile keeps a
      // comfortable size rather than stretching to fill a tablet.
      final columns = (constraints.maxWidth / 190).floor().clamp(2, 4);
      return GridView.builder(
        // Explicit zero: a grid nested in a scroll view inherits the
        // MediaQuery padding, which on a phone is the status bar — it showed up
        // as a gap between each heading and its tiles.
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: operations.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: WmsSpacing.space3,
          crossAxisSpacing: WmsSpacing.space3,
          // A height, not a ratio: a ratio ties the tile's height to the column
          // width, so a narrower phone made the same two lines of text overflow
          // the box they had fitted in a moment earlier. This is what the
          // content needs — icon, a label that may wrap once, and one line of
          // hint — and it does not change with the window.
          mainAxisExtent: 134,
        ),
        itemBuilder: (context, index) => _Tile(operation: operations[index]),
      );
    },
  );
}

class _Tile extends StatelessWidget {
  const _Tile({required this.operation});

  final WmsOperation operation;

  @override
  Widget build(BuildContext context) {
    final c = WmsColors.of(context);
    return Material(
      color: c.surface,
      borderRadius: WmsRadius.lgAll,
      child: InkWell(
        onTap: () => context.go(operation.route),
        borderRadius: WmsRadius.lgAll,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: WmsRadius.lgAll,
            border: Border.all(color: c.border),
          ),
          padding: const EdgeInsets.all(WmsSpacing.space4),
          // Icon and label sit together rather than at opposite ends: spread
          // apart they read as two things, and the tile has to be taller than
          // it needs to be to hold the gap.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(operation.icon, size: 30, color: c.accent),
              const SizedBox(height: WmsSpacing.space3),
              Text(
                operation.label,
                style: WmsTypography.bodyStrong.copyWith(color: c.ink),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (operation.hint != null)
                Text(
                  operation.hint!,
                  style: WmsTypography.caption.copyWith(color: c.inkMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
