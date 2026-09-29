import 'package:feature_identity/feature_identity.dart';
import 'package:feature_master_data/feature_master_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_design_system/wms_design_system.dart';

import 'task.dart';
import 'tasks_providers.dart';

/// «Tapşırıqlar» — the keeper's home.
///
/// The app used to open on the balance list, which is a reference table: it
/// answers "how much of this is there", never "what should I do next". This
/// screen answers the second question, and it is the one someone opens the app
/// to ask.
class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = WmsColors.of(context);
    final tasks = ref.watch(tasksProvider);
    final session = ref.watch(sessionProvider);

    return Scaffold(
      backgroundColor: c.surfaceCanvas,
      body: Column(
        children: [
          _Header(session: session, count: tasks.value?.length ?? 0),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.refresh(tasksProvider.future),
              child: AsyncView<List<WmsTask>>(
                value: tasks,
                onRetry: () => ref.invalidate(tasksProvider),
                builder: (list) => list.isEmpty
                    ? ListView(
                        // A ListView so the pull-to-refresh still works when
                        // there is nothing to pull.
                        padding: const EdgeInsets.all(WmsSpacing.space4),
                        children: const [
                          WmsEmptyState(
                            reason: 'Sizi gözləyən tapşırıq yoxdur.',
                            nextStep:
                                'Yeni sənəd sizə təyin olunanda burada görünəcək.',
                            icon: Icons.task_alt_outlined,
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(WmsSpacing.space4),
                        itemCount: list.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: WmsSpacing.space3),
                        itemBuilder: (context, index) =>
                            _TaskCard(task: list[index]),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.session, required this.count});

  final Session? session;
  final int count;

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
                      'Tapşırıqlar',
                      style: WmsTypography.titleLg.copyWith(color: c.ink),
                    ),
                    if (session != null)
                      Text(
                        session!.fullName ?? session!.username,
                        style: WmsTypography.caption.copyWith(
                          color: c.inkMuted,
                        ),
                      ),
                  ],
                ),
              ),
              if (count > 0) ...[
                WmsBadge(
                  text: '$count',
                  tone: WmsTone.danger,
                  dot: true,
                ),
                const SizedBox(width: WmsSpacing.space2),
              ],
              // The profile lives behind the person's own name, which is where
              // the mock puts the identity too. The bottom bar is four tabs of
              // work; an account screen is not work.
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

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});

  final WmsTask task;

  @override
  Widget build(BuildContext context) {
    final c = WmsColors.of(context);
    return Material(
      color: c.surface,
      borderRadius: WmsRadius.lgAll,
      child: InkWell(
        // `push`, not `go`: the document opens over the task list so the
        // header's arrow has somewhere to go back to, and the list is still
        // there — with its scroll position — when the document closes.
        onTap: () => context.push(task.route),
        borderRadius: WmsRadius.lgAll,
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          decoration: BoxDecoration(
            borderRadius: WmsRadius.lgAll,
            border: Border.all(color: c.border),
          ),
          padding: const EdgeInsets.all(WmsSpacing.space4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      spacing: WmsSpacing.space2,
                      runSpacing: WmsSpacing.space1,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          task.docNo,
                          style: WmsTypography.docNo.copyWith(color: c.ink),
                        ),
                        WmsDocStatusBadge(status: task.status),
                      ],
                    ),
                    const SizedBox(height: WmsSpacing.space1),
                    Text(
                      task.title,
                      style: WmsTypography.bodyStrong.copyWith(color: c.ink),
                    ),
                    Text(
                      task.meta,
                      style: WmsTypography.caption.copyWith(color: c.inkMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: WmsSpacing.space3),
              Icon(Icons.chevron_right, color: c.inkMuted),
            ],
          ),
        ),
      ),
    );
  }
}
