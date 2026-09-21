/// Procurement feature: requisitions, RFQs and quotation comparison.
///
/// Purchase-order and price-history screens were web only (screen map 4.4 /
/// 4.6) and moved to the React web app with ADR-013; the repository still
/// exposes their endpoints.
library;

export 'src/data/procurement_repository_impl.dart';
export 'src/domain/procurement_repository.dart';
export 'src/navigation.dart';
export 'src/presentation/procurement_providers.dart';
export 'src/presentation/quotation_comparison_screen.dart';
export 'src/presentation/requisition_form_screen.dart';
export 'src/presentation/requisition_list_screen.dart';
export 'src/presentation/rfq_list_screen.dart';
export 'src/routes.dart';
