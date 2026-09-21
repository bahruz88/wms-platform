import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

/// Unsaved state of the recipe editor: which version is open, the lines as
/// they are being typed and the portion count of the explosion preview.
///
/// [lines] is `null` until the user touches something; that is how the
/// screen knows whether to show the server's explosion or the local
/// projection, and whether «Aktivləşdir» has to wait for a save.
@immutable
class RecipeDraft {
  const RecipeDraft({this.recipeId, this.lines, this.portions, this.validFrom});

  final int? recipeId;
  final List<RecipeLineInput>? lines;
  final Quantity? portions;
  final DateTime? validFrom;

  bool get isDirty => lines != null;

  Quantity get effectivePortions => portions ?? Quantity.fromInt(1);

  /// The lines to render: the edited set when there is one, otherwise the
  /// server's, converted to the input shape.
  List<RecipeLineInput> linesOf(RecipeDto recipe) =>
      lines ?? [for (final l in recipe.lines) RecipeLineInput.fromLine(l)];

  RecipeDraft copyWith({
    int? recipeId,
    List<RecipeLineInput>? lines,
    Quantity? portions,
    DateTime? validFrom,
    bool clearLines = false,
  }) => RecipeDraft(
    recipeId: recipeId ?? this.recipeId,
    lines: clearLines ? null : (lines ?? this.lines),
    portions: portions ?? this.portions,
    validFrom: validFrom ?? this.validFrom,
  );
}

final recipeDraftProvider = NotifierProvider<RecipeDraftNotifier, RecipeDraft>(
  RecipeDraftNotifier.new,
);

class RecipeDraftNotifier extends Notifier<RecipeDraft> {
  @override
  RecipeDraft build() => const RecipeDraft();

  /// Opens a version; any pending edits of another version are dropped
  /// rather than silently carried over.
  void select(int recipeId, {DateTime? validFrom}) {
    if (state.recipeId == recipeId) return;
    state = RecipeDraft(
      recipeId: recipeId,
      portions: state.portions,
      validFrom: validFrom,
    );
  }

  /// Called once per loaded version so «Etibarlıdır» starts on the version's
  /// own `validFrom` instead of today.
  void seedValidFrom(DateTime validFrom) {
    if (state.validFrom != null) return;
    state = state.copyWith(validFrom: validFrom);
  }

  void setPortions(Quantity? portions) =>
      state = state.copyWith(portions: portions ?? Quantity.fromInt(1));

  void setValidFrom(DateTime value) => state = state.copyWith(validFrom: value);

  /// Marks the draft clean again after a successful save.
  void markSaved() => state = state.copyWith(clearLines: true);

  void replaceLines(List<RecipeLineInput> lines) =>
      state = state.copyWith(lines: _renumber(lines));

  void updateLine(
    RecipeDto recipe,
    int lineNo,
    RecipeLineInput Function(RecipeLineInput line) transform,
  ) => replaceLines([
    for (final line in state.linesOf(recipe))
      if (line.lineNo == lineNo) transform(line) else line,
  ]);

  void removeLine(RecipeDto recipe, int lineNo) => replaceLines([
    for (final line in state.linesOf(recipe))
      if (line.lineNo != lineNo) line,
  ]);

  void addLine(RecipeDto recipe, {required int uomId}) {
    final current = state.linesOf(recipe);
    replaceLines([
      ...current,
      RecipeLineInput(
        lineNo: current.length + 1,
        componentType: ComponentType.foodProduct,
        qtyPerPortion: Quantity.zero,
        uomId: uomId,
        yieldPct: Decimal.fromInt(100),
      ),
    ]);
  }

  /// Switching the component type clears the other side's reference, so a
  /// `FOOD_PRODUCT` line can never keep a stale `subMenuItemId` (the server
  /// would reject it, but the user should not have to find out that way).
  void setComponentType(RecipeDto recipe, int lineNo, ComponentType type) =>
      updateLine(
        recipe,
        lineNo,
        (line) => RecipeLineInput(
          lineNo: line.lineNo,
          componentType: type,
          qtyPerPortion: line.qtyPerPortion,
          uomId: line.uomId,
          yieldPct: line.yieldPct,
          isOptional: line.isOptional,
          attachRatePct: line.attachRatePct,
          note: line.note,
        ),
      );

  static List<RecipeLineInput> _renumber(List<RecipeLineInput> lines) => [
    for (var i = 0; i < lines.length; i++) lines[i].copyWith(lineNo: i + 1),
  ];
}
