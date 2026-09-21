/// Branch consumption feature (ADR-012): daily sales entry and the
/// consumption result on mobile; recipe catalogue, recipe editor, CSV sales
/// import, consumption journal and variance report on the web.
library;

export 'src/data/consumption_repository_impl.dart';
export 'src/domain/consumption_problem_hints.dart';
export 'src/domain/consumption_repository.dart';
export 'src/domain/csv_file_picker.dart';
export 'src/domain/daily_sales_draft.dart';
export 'src/domain/daily_sales_submitter.dart';
export 'src/domain/recipe_explosion_preview.dart';
export 'src/navigation.dart';
export 'src/presentation/branch/consumption_result_screen.dart';
export 'src/presentation/branch/daily_sales_screen.dart';
export 'src/presentation/consumption_alert.dart';
export 'src/presentation/consumption_providers.dart';
export 'src/presentation/date_field.dart';
export 'src/presentation/manager/consumption_journal_screen.dart';
export 'src/presentation/manager/consumption_run_detail_screen.dart';
export 'src/presentation/manager/recipe_catalog_screen.dart';
export 'src/presentation/manager/recipe_draft_controller.dart';
export 'src/presentation/manager/recipe_editor_screen.dart';
export 'src/presentation/manager/sales_import_screen.dart';
export 'src/presentation/manager/variance_report_screen.dart';
export 'src/presentation/run_detail_view.dart';
export 'src/routes.dart';
