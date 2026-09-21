import 'package:go_router/go_router.dart';

import 'navigation.dart';
import 'presentation/price_history_screen.dart';
import 'presentation/purchase_order_detail_screen.dart';
import 'presentation/purchase_order_list_screen.dart';
import 'presentation/quotation_comparison_screen.dart';
import 'presentation/requisition_form_screen.dart';
import 'presentation/requisition_list_screen.dart';
import 'presentation/rfq_list_screen.dart';

/// Routes contributed by the procurement feature.
List<RouteBase> procurementRoutes() => [
  GoRoute(
    name: ProcurementRoutes.requisitionsName,
    path: ProcurementRoutes.requisitionsPath,
    builder: (context, state) => const RequisitionListScreen(),
    routes: [
      GoRoute(
        name: ProcurementRoutes.requisitionCreateName,
        path: ProcurementRoutes.requisitionCreatePath,
        builder: (context, state) => const RequisitionFormScreen(),
      ),
    ],
  ),
  GoRoute(
    name: ProcurementRoutes.rfqsName,
    path: ProcurementRoutes.rfqsPath,
    builder: (context, state) => const RfqListScreen(),
    routes: [
      GoRoute(
        name: ProcurementRoutes.quotationComparisonName,
        path: ProcurementRoutes.quotationComparisonPath,
        builder: (context, state) => QuotationComparisonScreen(
          rfqId: int.parse(state.pathParameters['rfqId']!),
        ),
      ),
    ],
  ),
  GoRoute(
    name: ProcurementRoutes.purchaseOrdersName,
    path: ProcurementRoutes.purchaseOrdersPath,
    builder: (context, state) => const PurchaseOrderListScreen(),
    routes: [
      GoRoute(
        name: ProcurementRoutes.purchaseOrderDetailName,
        path: ProcurementRoutes.purchaseOrderDetailPath,
        builder: (context, state) => PurchaseOrderDetailScreen(
          poId: int.parse(state.pathParameters['poId']!),
        ),
      ),
    ],
  ),
  GoRoute(
    name: ProcurementRoutes.priceHistoryName,
    path: ProcurementRoutes.priceHistoryPath,
    builder: (context, state) => const PriceHistoryScreen(),
  ),
];
