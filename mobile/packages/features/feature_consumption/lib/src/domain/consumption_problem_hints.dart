import 'package:wms_core/wms_core.dart';
import 'package:wms_l10n/wms_l10n.dart';

/// Plain-language explanation for the consumption module's RFC 7807 codes.
///
/// The server message is always shown verbatim; this only adds the «what do
/// I do now» line underneath it. The `code` itself stays on screen — support
/// works with the code, so it is never swallowed.
String? consumptionProblemHint(String? code, AppLocalizations l10n) =>
    switch (code) {
      ProblemCodes.recipeCycle => l10n.consErrRecipeCycle,
      ProblemCodes.recipeDepthExceeded => l10n.consErrRecipeDepth,
      ProblemCodes.recipeEmpty => l10n.consErrRecipeEmpty,
      ProblemCodes.periodClosed => l10n.consErrPeriodClosed,
      ProblemCodes.duplicateBusinessDate => l10n.consErrDuplicateBusinessDate,
      ProblemCodes.uomFactorMissing => l10n.consErrUomFactorMissing,
      ProblemCodes.fileTooLarge => l10n.consErrFileTooLarge,
      _ => null,
    };

/// Codes this feature explains; a test keeps the list and the mapping in
/// sync so a new code cannot be added without a hint.
const Set<String> consumptionExplainedCodes = {
  ProblemCodes.recipeCycle,
  ProblemCodes.recipeDepthExceeded,
  ProblemCodes.recipeEmpty,
  ProblemCodes.periodClosed,
  ProblemCodes.duplicateBusinessDate,
  ProblemCodes.uomFactorMissing,
  ProblemCodes.fileTooLarge,
};

/// The RFC 7807 problem behind a [Failure], when there is one.
ProblemDetails? problemOf(Failure failure) =>
    failure is ServerFailure ? failure.problem : null;
