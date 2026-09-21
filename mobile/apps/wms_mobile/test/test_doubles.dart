import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_auth/wms_auth.dart';

/// API client whose adapter answers every request with an empty page, so the
/// smoke tests never touch the network.
WmsApiClient fakeApiClient() {
  final client = WmsApiClient(
    baseUrl: 'http://localhost:5001',
    tokenProvider: StaticTokenProvider('test-token'),
    enableLogging: false,
  );
  client.dio.httpClientAdapter = _EmptyAdapter();
  return client;
}

class _EmptyAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    jsonEncode(const {'items': <Object?>[], 'page': 1, 'size': 50, 'total': 0}),
    200,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
    },
  );

  @override
  void close({bool force = false}) {}
}

String fakeJwt(Map<String, Object?> payload) {
  String enc(Object? o) =>
      base64Url.encode(utf8.encode(jsonEncode(o))).replaceAll('=', '');
  return '${enc({'alg': 'none'})}.${enc(payload)}.sig';
}

Session testSession({
  Set<String> permissions = const {},
  List<String> roles = const ['WAREHOUSE_KEEPER'],
}) => Session.fromTokens(
  accessToken: fakeJwt({
    'sub': 'a1',
    'preferred_username': 'keeper',
    'name': 'Anbardar Kamil',
    'tenant_id': 1,
    'exp': 4102444800,
    'realm_access': {'roles': roles},
  }),
  refreshToken: 'refresh',
).copyWith(permissions: permissions);
