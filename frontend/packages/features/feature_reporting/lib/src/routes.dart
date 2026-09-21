import 'package:go_router/go_router.dart';

import 'navigation.dart';
import 'presentation/dashboard_screen.dart';
import 'presentation/report_list_screen.dart';

/// Routes contributed by the reporting feature.
List<RouteBase> reportingRoutes() => [
  GoRoute(
    name: ReportingRoutes.dashboardName,
    path: ReportingRoutes.dashboardPath,
    builder: (context, state) => const DashboardScreen(),
  ),
  GoRoute(
    name: ReportingRoutes.reportsName,
    path: ReportingRoutes.reportsPath,
    builder: (context, state) => const ReportListScreen(),
  ),
];
