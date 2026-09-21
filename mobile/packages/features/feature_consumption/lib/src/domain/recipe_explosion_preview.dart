import 'package:decimal/decimal.dart';
import 'package:meta/meta.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

/// Conversion factor of one recipe line's unit towards the product's base
/// unit (`master_product_uom.factor_to_base`), plus what to call that base
/// unit on screen.
@immutable
class PreviewUom {
  const PreviewUom({
    required this.baseUomCode,
    this.factorToBase,
    this.baseDecimals = kQuantityScale,
  });

  /// `null` means «unknown», in which case the preview treats it as 1.
  final Decimal? factorToBase;
  final String baseUomCode;
  final int baseDecimals;

  Decimal get effectiveFactor => factorToBase ?? Decimal.one;
}

/// One projected ingredient requirement.
@immutable
class ExplosionPreviewLine {
  const ExplosionPreviewLine({
    required this.lineNo,
    required this.label,
    required this.requiredQtyBase,
    required this.baseUomCode,
    required this.yieldPct,
    this.isOptional = false,
    this.attachRatePct,
    this.needsServer = false,
  });

  final int lineNo;
  final String label;
  final Quantity requiredQtyBase;
  final String baseUomCode;
  final Decimal yieldPct;
  final bool isOptional;
  final Decimal? attachRatePct;

  /// A `SUB_RECIPE` component: only the server can expand it, so the local
  /// projection shows the line but no quantity.
  final bool needsServer;

  /// `true` when the yield factor actually changes the figure.
  bool get hasProcessingLoss => yieldPct != _hundred;
}

/// Local projection of `GET /recipes/{id}/explosion` for **unsaved** editor
/// state, using the formula documented in the contract:
///
/// ```
/// required_base = portions × qtyPerPortion × conversionToBase ÷ (yieldPct ÷ 100)
/// ```
///
/// The server stays the source of truth — this only exists so the effect of
/// a yield factor is visible before the draft is saved. `SUB_RECIPE` lines
/// cannot be expanded client side and are flagged `needsServer`.
///
/// `attachRatePct` is deliberately **not** applied: the contract's formula
/// does not include it, and diverging here would make the local and server
/// figures disagree for optional components.
abstract final class RecipeExplosionPreview {
  /// Guard mirroring the server: deeper nesting is rejected with
  /// `422 RECIPE_DEPTH_EXCEEDED`.
  static const int maxDepth = 5;

  static List<ExplosionPreviewLine> project({
    required List<RecipeLineInput> lines,
    required Quantity portions,
    required PreviewUom Function(RecipeLineInput line) uomOf,
    required String Function(RecipeLineInput line) labelOf,
  }) => [
    for (final line in lines)
      _projectLine(line, portions, uomOf(line), labelOf(line)),
  ];

  static ExplosionPreviewLine _projectLine(
    RecipeLineInput line,
    Quantity portions,
    PreviewUom uom,
    String label,
  ) {
    final yieldPct = line.effectiveYieldPct;
    if (line.componentType == ComponentType.subRecipe) {
      return ExplosionPreviewLine(
        lineNo: line.lineNo,
        label: label,
        requiredQtyBase: Quantity.zero,
        baseUomCode: uom.baseUomCode,
        yieldPct: yieldPct,
        isOptional: line.isOptional,
        attachRatePct: line.attachRatePct,
        needsServer: true,
      );
    }
    return ExplosionPreviewLine(
      lineNo: line.lineNo,
      label: label,
      requiredQtyBase: requiredBase(
        portions: portions,
        qtyPerPortion: line.qtyPerPortion,
        factorToBase: uom.effectiveFactor,
        yieldPct: yieldPct,
        decimals: uom.baseDecimals,
      ),
      baseUomCode: uom.baseUomCode,
      yieldPct: yieldPct,
      isOptional: line.isOptional,
      attachRatePct: line.attachRatePct,
    );
  }

  /// `portions × qtyPerPortion × factorToBase ÷ (yieldPct ÷ 100)`.
  ///
  /// A yield of 92 % means 8 % is trimmed away, so **more** leaves stock
  /// than the recipe line states. A non-positive yield is treated as 100 %
  /// (the server rejects it; the preview must not divide by zero).
  static Quantity requiredBase({
    required Quantity portions,
    required Quantity qtyPerPortion,
    required Decimal factorToBase,
    required Decimal yieldPct,
    int decimals = kQuantityScale,
  }) {
    final gross = portions.value * qtyPerPortion.value * factorToBase;
    final effectiveYield = yieldPct > Decimal.zero ? yieldPct : _hundred;
    final ratio = effectiveYield.divide(_hundred, scale: kFactorScale);
    return Quantity(gross.divide(ratio).roundAwayFromZero(decimals));
  }

  /// Sum of one projection, for the running figure under the table.
  static Quantity totalOf(Iterable<ExplosionPreviewLine> lines) => lines
      .where((l) => !l.needsServer)
      .fold(Quantity.zero, (sum, l) => sum + l.requiredQtyBase);
}

final Decimal _hundred = Decimal.fromInt(100);
