import 'package:dio/dio.dart';

import '../apis/consumption_api.dart';
import '../apis/documents_api.dart';
import '../apis/identity_api.dart';
import '../apis/inventory_api.dart';
import '../apis/master_data_api.dart';
import '../apis/notifications_api.dart';
import '../apis/procurement_api.dart';
import '../apis/reporting_api.dart';
import '../interceptors/auth_interceptor.dart';
import '../interceptors/idempotency_interceptor.dart';
import '../interceptors/logging_interceptor.dart';
import '../interceptors/problem_details_interceptor.dart';
import 'token_provider.dart';

/// `true` in AOT/release builds. Named `_kReleaseMode` so importing this
/// library never clashes with Flutter's `kReleaseMode`.
const bool _kReleaseMode = bool.fromEnvironment('dart.vm.product');

/// Entry point of the API client. One instance per app, created in
/// `bootstrap()` and exposed through a Riverpod provider.
///
/// ```dart
/// final client = WmsApiClient(
///   baseUrl: AppEnv.fromEnvironment.apiBaseUrl,
///   tokenProvider: SessionTokenProvider(authRepository),
/// );
/// final page = await client.inventory.listBalances(locationId: 3);
/// ```
class WmsApiClient {
  WmsApiClient({
    required String baseUrl,
    required TokenProvider tokenProvider,
    Dio? dio,
    bool enableLogging = !_kReleaseMode,
    String Function()? idempotencyKeyGenerator,
    Duration connectTimeout = const Duration(seconds: 15),
    Duration receiveTimeout = const Duration(seconds: 30),
    Dio? storageClient,
  }) : dio = dio ?? Dio(),
       storageClient = storageClient ?? Dio() {
    this.dio.options
      ..baseUrl = _normalise(baseUrl)
      ..connectTimeout = connectTimeout
      ..receiveTimeout = receiveTimeout
      ..responseType = ResponseType.json
      ..headers = {'Accept': 'application/json, application/problem+json'};
    this.dio.interceptors.addAll([
      IdempotencyInterceptor(keyGenerator: idempotencyKeyGenerator),
      AuthInterceptor(tokenProvider: tokenProvider, dio: this.dio),
      ProblemDetailsInterceptor(),
      if (enableLogging) LoggingInterceptor(),
    ]);
  }

  /// Underlying Dio instance (exposed for tests and for file downloads).
  final Dio dio;

  /// Interceptor-free Dio used for presigned storage (MinIO) transfers; the
  /// bearer token and `Idempotency-Key` must never reach the object store.
  final Dio storageClient;

  late final InventoryApi inventory = InventoryApi(dio);
  late final ProcurementApi procurement = ProcurementApi(dio);
  late final MasterDataApi masterData = MasterDataApi(dio);
  late final IdentityApi identity = IdentityApi(dio);
  late final ReportingApi reporting = ReportingApi(dio);
  late final NotificationsApi notifications = NotificationsApi(dio);
  late final ConsumptionApi consumption = ConsumptionApi(dio);
  late final DocumentsApi documents = DocumentsApi(
    dio,
    storageClient: storageClient,
  );

  /// `/api/v1` is appended once; callers pass the gateway origin only.
  static String _normalise(String baseUrl) {
    var url = baseUrl.trim();
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url.endsWith('/api/v1') ? url : '$url/api/v1';
  }

  void close({bool force = false}) {
    dio.close(force: force);
    storageClient.close(force: force);
  }
}
