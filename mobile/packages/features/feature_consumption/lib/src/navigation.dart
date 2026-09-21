/// Route names and paths of the branch consumption feature (ADR-012).
///
/// The `/consumption/*` prefix mirrors the API module. Branch screens and
/// manager screens share it: which ones are reachable is decided by the
/// app shell, and by `RequirePermission` inside each screen so a deep link
/// cannot walk around the gate.
abstract final class ConsumptionRoutes {
  // --- Branch (mobile) --------------------------------------------------
  static const String dailySalesName = 'daily-sales';
  static const String dailySalesPath = '/consumption/daily-sales';

  static const String resultName = 'consumption-result';
  static const String resultPath = '/consumption/result';

  // --- Manager (web) ----------------------------------------------------
  static const String recipeCatalogName = 'recipe-catalog';
  static const String recipeCatalogPath = '/consumption/recipes';

  static const String recipeEditorName = 'recipe-editor';

  /// Child path of [recipeCatalogPath].
  static const String recipeEditorPath = ':menuItemId';
  static String recipeEditor(int menuItemId) =>
      '$recipeCatalogPath/$menuItemId';

  static const String salesImportName = 'sales-import';
  static const String salesImportPath = '/consumption/sales-imports';

  static const String journalName = 'consumption-journal';
  static const String journalPath = '/consumption/runs';

  static const String runDetailName = 'consumption-run-detail';

  /// Child path of [journalPath].
  static const String runDetailPath = ':runId';
  static String runDetail(int id) => '$journalPath/$id';

  static const String varianceName = 'consumption-variance';
  static const String variancePath = '/consumption/variance';
}
