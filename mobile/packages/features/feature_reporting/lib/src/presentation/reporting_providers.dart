import 'package:feature_identity/feature_identity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';

import '../data/reporting_repository_impl.dart';
import '../domain/reporting_repository.dart';

final reportingRepositoryProvider = Provider<ReportingRepository>(
  (ref) => ReportingRepositoryImpl(ref.watch(apiClientProvider).reporting),
);

final dashboardProvider = FutureProvider<DashboardSummaryDto>((ref) async {
  final result = await ref.watch(reportingRepositoryProvider).dashboard();
  return result.getOrThrow();
});

final reportListProvider = FutureProvider<List<ReportDefinitionDto>>((
  ref,
) async {
  final result = await ref.watch(reportingRepositoryProvider).reports();
  return result.getOrThrow();
});

/// Export trigger; keeps the last job so the UI can show its state.
final exportControllerProvider =
    AsyncNotifierProvider<ExportController, ExportJobDto?>(
      ExportController.new,
    );

class ExportController extends AsyncNotifier<ExportJobDto?> {
  @override
  Future<ExportJobDto?> build() async => null;

  Future<void> export(String reportCode) async {
    state = const AsyncValue<ExportJobDto?>.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(reportingRepositoryProvider)
          .requestExport(reportCode);
      return result.getOrThrow();
    });
  }
}
