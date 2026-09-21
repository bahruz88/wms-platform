import 'package:dio/dio.dart' show Options;
import 'package:test/test.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

import 'fake_adapter.dart';

class _RefreshingTokenProvider implements TokenProvider {
  _RefreshingTokenProvider({required this.refreshSucceeds});

  final bool refreshSucceeds;
  String token = 'old-token';
  int refreshCalls = 0;
  int unauthorizedCalls = 0;

  @override
  Future<String?> getAccessToken() async => token;

  @override
  Future<bool> refresh() async {
    refreshCalls++;
    if (refreshSucceeds) token = 'new-token';
    return refreshSucceeds;
  }

  @override
  Future<void> onUnauthorized() async => unauthorizedCalls++;
}

(WmsApiClient, FakeAdapter) _client(TokenProvider tokens) {
  final adapter = FakeAdapter();
  final client = WmsApiClient(
    baseUrl: 'http://localhost:5000/',
    tokenProvider: tokens,
    enableLogging: false,
  );
  client.dio.httpClientAdapter = adapter;
  return (client, adapter);
}

void main() {
  test('base URL gets /api/v1 exactly once', () {
    final a = WmsApiClient(
      baseUrl: 'http://localhost:5000/',
      tokenProvider: StaticTokenProvider(),
      enableLogging: false,
    );
    final b = WmsApiClient(
      baseUrl: 'http://localhost:5000/api/v1',
      tokenProvider: StaticTokenProvider(),
      enableLogging: false,
    );
    expect(a.dio.options.baseUrl, 'http://localhost:5000/api/v1');
    expect(b.dio.options.baseUrl, 'http://localhost:5000/api/v1');
  });

  group('IdempotencyInterceptor', () {
    test('adds a UUID v4 Idempotency-Key to POST only', () async {
      final (client, adapter) = _client(StaticTokenProvider('t'));
      adapter
        ..enqueueJson({'count': 1})
        ..enqueueJson(null);
      await client.notifications.unreadCount();
      await client.notifications.markAllRead();

      final get = adapter.requests[0];
      final post = adapter.requests[1];
      expect(get.method, 'GET');
      expect(get.headers.containsKey('Idempotency-Key'), isFalse);
      expect(post.method, 'POST');
      expect(
        post.headers['Idempotency-Key'],
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );
    });

    test('keeps a caller supplied key', () async {
      final adapter = FakeAdapter();
      final client = WmsApiClient(
        baseUrl: 'http://x',
        tokenProvider: StaticTokenProvider(),
        enableLogging: false,
        idempotencyKeyGenerator: () => 'generated',
      );
      client.dio.httpClientAdapter = adapter;
      await client.dio.post<Object?>(
        '/inventory/waste',
        options: Options(headers: {'Idempotency-Key': 'mine'}),
      );
      expect(adapter.requests.single.headers['Idempotency-Key'], 'mine');
    });
  });

  group('AuthInterceptor', () {
    test('attaches bearer token', () async {
      final (client, adapter) = _client(StaticTokenProvider('abc'));
      adapter.enqueueJson({'count': 0});
      await client.notifications.unreadCount();
      expect(adapter.requests.single.headers['Authorization'], 'Bearer abc');
    });

    test('refreshes once on 401 and retries with the new token', () async {
      final tokens = _RefreshingTokenProvider(refreshSucceeds: true);
      final (client, adapter) = _client(tokens);
      adapter
        ..enqueueJson(
          {'status': 401, 'title': 'Unauthorized'},
          status: 401,
          contentType: 'application/problem+json',
        )
        ..enqueueJson({'count': 7});
      final result = await client.notifications.unreadCount();
      expect(result.count, 7);
      expect(tokens.refreshCalls, 1);
      expect(adapter.requests, hasLength(2));
      expect(adapter.headerSnapshots[0]['Authorization'], 'Bearer old-token');
      expect(adapter.headerSnapshots[1]['Authorization'], 'Bearer new-token');
    });

    test('surfaces UnauthorizedFailure when refresh fails', () async {
      final tokens = _RefreshingTokenProvider(refreshSucceeds: false);
      final (client, adapter) = _client(tokens);
      adapter.enqueueJson(
        {'status': 401, 'title': 'Unauthorized', 'code': 'UNAUTHORIZED'},
        status: 401,
        contentType: 'application/problem+json',
      );
      final result = await Result.guard(client.notifications.unreadCount);
      expect(result.failureOrNull, isA<UnauthorizedFailure>());
      expect(tokens.unauthorizedCalls, 1);
      expect(adapter.requests, hasLength(1));
    });
  });

  group('ProblemDetailsInterceptor', () {
    test('maps problem+json 409 to ConflictFailure with code', () async {
      final (client, adapter) = _client(StaticTokenProvider('t'));
      adapter.enqueueJson(
        {
          'type': 'https://wms/errors/insufficient-stock',
          'title': 'Kifayət qədər stok yoxdur',
          'status': 409,
          'code': 'INSUFFICIENT_STOCK',
          'detail': 'Chicken Strips: mövcud 45.0000 KG',
          'traceId': '00-abc',
          'errors': {
            'lines[2].qty': ['Mövcud qalıqdan çoxdur'],
          },
        },
        status: 409,
        contentType: 'application/problem+json',
      );
      final result = await Result.guard(
        () => client.inventory.postGoodsReceipt(5, rowVersion: 1),
      );
      final failure = result.failureOrNull;
      expect(failure, isA<ConflictFailure>());
      final conflict = failure! as ConflictFailure;
      expect(conflict.isInsufficientStock, isTrue);
      expect(conflict.problem.traceId, '00-abc');
      expect(conflict.problem.fieldErrors('lines[2].qty'), isNotEmpty);
    });

    test('maps 422 with field errors to ValidationFailure', () async {
      final (client, adapter) = _client(StaticTokenProvider('t'));
      adapter.enqueueJson(
        {
          'status': 422,
          'title': 'Validation failed',
          'code': 'VALIDATION_ERROR',
          'errors': {
            'lines[0].varianceNote': ['Fərq olduqda məcburidir'],
          },
        },
        status: 422,
        contentType: 'application/problem+json',
      );
      final result = await Result.guard(
        () => client.inventory.getGoodsReceipt(1),
      );
      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(
        (result.failureOrNull! as ValidationFailure)
            .fieldErrors['lines[0].varianceNote'],
        ['Fərq olduqda məcburidir'],
      );
    });

    test('non-problem 500 body becomes a synthetic ServerFailure', () async {
      final (client, adapter) = _client(StaticTokenProvider('t'));
      adapter.enqueueJson('boom', status: 500, contentType: 'text/plain');
      final result = await Result.guard(() => client.identity.me());
      final failure = result.failureOrNull;
      expect(failure, isA<ServerFailure>());
      expect((failure! as ServerFailure).status, 500);
      expect((failure as ServerFailure).code, 'HTTP_500');
    });

    test('timeouts become NetworkFailure(isTimeout)', () async {
      final (client, adapter) = _client(StaticTokenProvider('t'));
      adapter.enqueueTimeout();
      final result = await Result.guard(() => client.identity.me());
      expect(result.failureOrNull, isA<NetworkFailure>());
      expect((result.failureOrNull! as NetworkFailure).isTimeout, isTrue);
    });
  });
}
