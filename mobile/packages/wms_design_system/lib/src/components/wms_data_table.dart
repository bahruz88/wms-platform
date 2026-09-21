import 'package:flutter/material.dart';

import '../tokens/wms_colors.dart';
import '../tokens/wms_radius.dart';
import '../tokens/wms_shadows.dart';
import '../tokens/wms_spacing.dart';
import '../tokens/wms_typography.dart';
import 'wms_empty_state.dart';

enum WmsColumnAlign { left, center, right }

/// Column definition. Give [numeric] to quantity/amount columns (right
/// aligned, mono, tabular) and [permission] to cost columns: a column whose
/// permission the user lacks is **not rendered at all** (no blank cell, no
/// `***`).
@immutable
class WmsColumn<R> {
  const WmsColumn({
    required this.key,
    required this.header,
    this.cell,
    this.render,
    this.width,
    this.flex = 1,
    this.align,
    this.numeric = false,
    this.permission,
  }) : assert(cell != null || render != null, 'provide cell or render');

  final String key;
  final String header;

  /// Plain text cell.
  final String Function(R row)? cell;

  /// Custom widget cell.
  final Widget Function(R row, int index)? render;

  /// Fixed width in logical pixels; otherwise [flex] is used.
  final double? width;
  final int flex;
  final WmsColumnAlign? align;
  final bool numeric;
  final String? permission;

  WmsColumnAlign get effectiveAlign =>
      align ?? (numeric ? WmsColumnAlign.right : WmsColumnAlign.left);
}

/// `.wms-table` — sticky header, dense rows, permission-gated columns.
/// Paging/sorting/filtering stay outside (server returns `{items, page,
/// size, total}`).
class WmsDataTable<R> extends StatelessWidget {
  const WmsDataTable({
    required this.columns,
    required this.rows,
    this.permissions = const {},
    this.rowKey,
    this.dense = true,
    this.caption,
    this.emptyReason = 'Nəticə yoxdur.',
    this.emptyNextStep,
    this.emptyAction,
    this.footer,
    this.maxHeight,
    this.minWidth,
    this.selectedKey,
    this.onRowTap,
    super.key,
  });

  final List<WmsColumn<R>> columns;
  final List<R> rows;

  /// The user's permission codes, e.g. `{Permissions.productViewCost}`.
  final Set<String> permissions;
  final Object Function(R row, int index)? rowKey;
  final bool dense;
  final String? caption;
  final String emptyReason;
  final String? emptyNextStep;
  final Widget? emptyAction;

  /// Column key → footer text; only for summable columns.
  final Map<String, String>? footer;
  final double? maxHeight;

  /// Width below which the table scrolls horizontally
  /// (`.wms-table-wrap { overflow: auto }`). Dense document tables need it on
  /// phones; `null` means the table always fits the available width.
  final double? minWidth;
  final Object? selectedKey;
  final void Function(R row, int index)? onRowTap;

  /// Columns after permission gating.
  List<WmsColumn<R>> get visibleColumns => columns
      .where(
        (col) => col.permission == null || permissions.contains(col.permission),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    final c = WmsColors.of(context);
    final shadows = WmsShadows.of(context);
    final visible = visibleColumns;
    final widths = <int, TableColumnWidth>{
      for (var i = 0; i < visible.length; i++)
        i: visible[i].width != null
            ? FixedColumnWidth(visible[i].width!)
            : FlexColumnWidth(visible[i].flex.toDouble()),
    };
    final cellPadding = dense ? WmsSpacing.denseCell : WmsSpacing.cell;

    final header = DecoratedBox(
      decoration: BoxDecoration(
        color: c.surfaceSunken,
        border: Border(bottom: BorderSide(color: c.border)),
        boxShadow: maxHeight != null ? shadows.sm : null,
      ),
      child: Table(
        columnWidths: widths,
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(
            children: [
              for (final col in visible)
                Padding(
                  padding: WmsSpacing.denseCell,
                  child: Text(
                    col.header,
                    textAlign: _textAlign(col.effectiveAlign),
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: WmsTypography.label.copyWith(color: c.inkMuted),
                  ),
                ),
            ],
          ),
        ],
      ),
    );

    Widget body;
    if (rows.isEmpty) {
      body = WmsEmptyState(
        reason: emptyReason,
        nextStep: emptyNextStep,
        action: emptyAction,
      );
    } else {
      body = Table(
        columnWidths: widths,
        children: [
          for (var i = 0; i < rows.length; i++)
            _row(
              context,
              c,
              visible,
              rows[i],
              i,
              cellPadding,
              isLast: i == rows.length - 1,
            ),
        ],
      );
      if (maxHeight != null) {
        body = ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight!),
          child: SingleChildScrollView(child: body),
        );
      }
    }

    Widget? foot;
    if (footer != null && rows.isNotEmpty) {
      foot = DecoratedBox(
        decoration: BoxDecoration(
          color: c.surfaceSunken,
          border: Border(top: BorderSide(color: c.borderControl)),
        ),
        child: Table(
          columnWidths: widths,
          children: [
            TableRow(
              children: [
                for (final col in visible)
                  Padding(
                    padding: cellPadding,
                    child: Text(
                      footer![col.key] ?? '',
                      textAlign: _textAlign(col.effectiveAlign),
                      style:
                          (col.numeric
                                  ? WmsTypography.figure
                                  : WmsTypography.bodyStrong)
                              .copyWith(
                                fontWeight: FontWeight.w600,
                                color: c.ink,
                              ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    }

    final table = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (caption != null)
          Padding(
            padding: WmsSpacing.denseCell,
            child: Text(
              caption!,
              style: WmsTypography.title.copyWith(color: c.ink),
            ),
          ),
        header,
        body,
        ?foot,
      ],
    );

    return Semantics(
      label: caption,
      container: true,
      child: Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: WmsRadius.lgAll,
          border: Border.all(color: c.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final needed = minWidth ?? 0;
            if (needed <= constraints.maxWidth) return table;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(width: needed, child: table),
            );
          },
        ),
      ),
    );
  }

  TableRow _row(
    BuildContext context,
    WmsColors c,
    List<WmsColumn<R>> visible,
    R row,
    int index,
    EdgeInsets cellPadding, {
    required bool isLast,
  }) {
    final key = rowKey?.call(row, index) ?? index;
    final selected = selectedKey != null && selectedKey == key;
    return TableRow(
      key: ValueKey(key),
      decoration: BoxDecoration(
        color: selected ? c.accentSoft : null,
        border: isLast ? null : Border(bottom: BorderSide(color: c.border)),
      ),
      children: [
        for (final col in visible)
          _Cell(
            padding: cellPadding,
            align: col.effectiveAlign,
            onTap: onRowTap == null ? null : () => onRowTap!(row, index),
            child: col.render != null
                ? col.render!(row, index)
                : Text(
                    col.cell!(row),
                    textAlign: _textAlign(col.effectiveAlign),
                    softWrap: !col.numeric,
                    style:
                        (col.numeric
                                ? WmsTypography.figure
                                : WmsTypography.body)
                            .copyWith(color: c.ink),
                  ),
          ),
      ],
    );
  }

  static TextAlign _textAlign(WmsColumnAlign align) => switch (align) {
    WmsColumnAlign.left => TextAlign.left,
    WmsColumnAlign.center => TextAlign.center,
    WmsColumnAlign.right => TextAlign.right,
  };
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.padding,
    required this.align,
    required this.child,
    this.onTap,
  });

  final EdgeInsets padding;
  final WmsColumnAlign align;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = WmsColors.of(context);
    final aligned = Align(
      alignment: switch (align) {
        WmsColumnAlign.left => Alignment.centerLeft,
        WmsColumnAlign.center => Alignment.center,
        WmsColumnAlign.right => Alignment.centerRight,
      },
      child: child,
    );
    if (onTap == null) return Padding(padding: padding, child: aligned);
    return InkWell(
      onTap: onTap,
      hoverColor: c.rowHover,
      focusColor: c.accentSoft,
      child: Padding(padding: padding, child: aligned),
    );
  }
}
