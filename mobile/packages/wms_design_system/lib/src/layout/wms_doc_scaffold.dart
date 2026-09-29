import 'package:flutter/material.dart';

import '../components/wms_doc_status_badge.dart';
import '../tokens/wms_colors.dart';
import '../tokens/wms_spacing.dart';
import '../tokens/wms_touch.dart';
import '../tokens/wms_typography.dart';

/// The frame every document screen on a phone shares.
///
/// Three parts, and each earns its place:
///
///  * a header that says what the screen is *and which document it is about* —
///    `Qəbul` over `PO-2026-00087 · Azərsun MMC` — with the status on the right.
///    A keeper works several documents in a row and the document number is how
///    they tell one from another; a plain title bar makes them open the document
///    to find out;
///  * the scrolling body;
///  * an action bar pinned to the bottom. A posting screen's form is longer than
///    the screen, and a button that scrolls away is a button nobody finds. Pinned
///    also puts it under the thumb.
///
/// The bar sits above the system gesture inset, and the body is inset by the
/// keyboard, so a field near the bottom stays visible while it is being typed
/// into.
class WmsDocScaffold extends StatelessWidget {
  const WmsDocScaffold({
    required this.title,
    required this.body,
    this.subtitle,
    this.status,
    this.trailing,
    this.actions,
    this.onBack,
    this.banner,
    super.key,
  }) : assert(
         status == null || trailing == null,
         'a header carries either a status badge or its own trailing widget',
       );

  /// What the screen is: `Qəbul`, `Sayım`, `Yığım`.
  final String title;

  /// Which document it is about, e.g. `IC-2026-00012 · Food WH`. Rendered in the
  /// mono face, because it is a document number.
  final String? subtitle;

  /// The document's status, shown as a badge on the right of the header.
  final String? status;

  /// Anything else for the right of the header, when [status] does not fit.
  final Widget? trailing;

  /// Buttons for the pinned bar. Each is given an equal share of the width
  /// unless it is wrapped in an [Expanded] with its own flex.
  final List<Widget>? actions;

  /// Pinned under the header, above the scrolling body: an alert that must not
  /// scroll away, such as a frozen location.
  final Widget? banner;

  final Widget body;

  /// Defaults to popping the route; `null` with nothing to pop hides the arrow.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final c = WmsColors.of(context);
    final canPop = Navigator.of(context).canPop();
    final back = onBack ?? (canPop ? () => Navigator.of(context).pop() : null);

    return Scaffold(
      backgroundColor: c.surfaceCanvas,
      // The bar is placed by hand rather than as `bottomNavigationBar`, so the
      // keyboard inset lifts it instead of covering it.
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          _Header(
            title: title,
            subtitle: subtitle,
            status: status,
            trailing: trailing,
            onBack: back,
          ),
          if (banner != null)
            Container(
              width: double.infinity,
              color: c.surface,
              padding: const EdgeInsets.fromLTRB(
                WmsSpacing.space4,
                WmsSpacing.space3,
                WmsSpacing.space4,
                0,
              ),
              child: banner,
            ),
          Expanded(child: body),
          if (actions != null && actions!.isNotEmpty)
            _ActionBar(actions: actions!),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.trailing,
    required this.onBack,
  });

  final String title;
  final String? subtitle;
  final String? status;
  final Widget? trailing;
  final VoidCallback? onBack;

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
          padding: const EdgeInsets.symmetric(
            horizontal: WmsSpacing.space2,
            vertical: WmsSpacing.space2,
          ),
          child: Row(
            children: [
              if (onBack != null)
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back),
                  color: c.inkMuted,
                  tooltip: 'Geri',
                  constraints: const BoxConstraints(
                    minWidth: WmsTouch.target,
                    minHeight: WmsTouch.target,
                  ),
                )
              else
                const SizedBox(width: WmsSpacing.space2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: WmsTypography.title.copyWith(
                        color: c.ink,
                        fontSize: 17,
                        height: 24 / 17,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: WmsTypography.figureSm.copyWith(
                          color: c.inkMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (status != null) ...[
                const SizedBox(width: WmsSpacing.space2),
                WmsDocStatusBadge(status: status!),
              ] else if (trailing != null) ...[
                const SizedBox(width: WmsSpacing.space2),
                trailing!,
              ],
              const SizedBox(width: WmsSpacing.space2),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.actions});

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final c = WmsColors.of(context);
    return Material(
      color: c.surface,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: c.border)),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: WmsSpacing.space4,
            vertical: WmsSpacing.space3,
          ),
          child: Row(
            children: [
              for (var i = 0; i < actions.length; i++) ...[
                if (i > 0) const SizedBox(width: WmsSpacing.space3),
                // An action already wrapped in Expanded keeps its own flex.
                if (actions[i] is Expanded)
                  actions[i]
                else
                  Expanded(child: actions[i]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
