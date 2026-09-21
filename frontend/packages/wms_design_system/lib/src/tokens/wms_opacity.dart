/// Opacity tokens (`tokens.json` → `opacity`).
abstract final class WmsOpacity {
  /// Disabled button, input, row.
  static const double disabled = 0.45;

  /// Approval step not yet decided.
  static const double pending = 0.7;

  static const Map<String, double> tokenMap = {
    'opacity-disabled': disabled,
    'opacity-pending': pending,
  };
}
