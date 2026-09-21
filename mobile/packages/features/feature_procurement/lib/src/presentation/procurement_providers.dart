import 'package:feature_identity/feature_identity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

import '../data/procurement_repository_impl.dart';
import '../domain/procurement_repository.dart';

final procurementRepositoryProvider = Provider<ProcurementRepository>(
  (ref) => ProcurementRepositoryImpl(ref.watch(apiClientProvider).procurement),
);

final requisitionListProvider = FutureProvider<Page<RequisitionDto>>((
  ref,
) async {
  final result = await ref.watch(procurementRepositoryProvider).requisitions();
  return result.getOrThrow();
});

final rfqListProvider = FutureProvider<Page<RfqDto>>((ref) async {
  final result = await ref.watch(procurementRepositoryProvider).rfqs();
  return result.getOrThrow();
});

final quotationListProvider = FutureProvider.family<List<QuotationDto>, int>((
  ref,
  rfqId,
) async {
  final result = await ref
      .watch(procurementRepositoryProvider)
      .quotations(rfqId);
  return result.getOrThrow();
});
