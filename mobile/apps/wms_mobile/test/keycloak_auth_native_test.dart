import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_mobile/auth/keycloak_auth_native.dart';

/// A Keycloak stand-in on localhost. The repository speaks plain HTTP to a
/// token endpoint, so the honest way to test it is to serve one.
class FakeKeycloak {
  FakeKeycloak(this._server) {
    _server.listen((request) async {
      final body = await utf8.decoder.bind(request).join();
      requests.add(_Request(request.uri.path, Uri.splitQueryString(body)));
      final reply = replies.isEmpty
          ? _Reply(200, jsonEncode({'access_token': _token()}))
          : replies.removeAt(0);
      request.response
        ..statusCode = reply.status
        ..headers.contentType = ContentType.json
        ..write(reply.body);
      await request.response.close();
    });
  }

  static Future<FakeKeycloak> start() async =>
      FakeKeycloak(await HttpServer.bind(InternetAddress.loopbackIPv4, 0));

  final HttpServer _server;
  final List<_Request> requests = [];
  final List<_Reply> replies = [];

  String get issuer => 'http://127.0.0.1:${_server.port}/realms/wms';

  void reply(int status, Object? body) =>
      replies.add(_Reply(status, jsonEncode(body)));

  Future<void> close() => _server.close(force: true);
}

class _Request {
  const _Request(this.path, this.form);

  final String path;
  final Map<String, String> form;
}

class _Reply {
  const _Reply(this.status, this.body);

  final int status;
  final String body;
}

/// A signed-looking JWT with the claims `Session.fromTokens` insists on.
String _token({String username = 'admin', int tenantId = 1}) {
  String segment(Map<String, Object?> value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  final header = segment({'alg': 'none', 'typ': 'JWT'});
  final payload = segment({
    'sub': 'user-1',
    'preferred_username': username,
    'tenant_id': tenantId,
    'exp': DateTime.now().add(const Duration(minutes: 5)).millisecondsSinceEpoch ~/ 1000,
  });
  return '$header.$payload.signature';
}

void main() {
  late FakeKeycloak keycloak;
  late InMemoryTokenStore store;

  setUp(() async {
    keycloak = await FakeKeycloak.start();
    store = InMemoryTokenStore();
  });

  tearDown(() => keycloak.close());

  KeycloakAuthNative repository() => KeycloakAuthNative(
    issuer: keycloak.issuer,
    clientId: 'wms-mobile',
    store: store,
  );

  test('signs in with a password grant and no browser', () async {
    keycloak.reply(200, {
      'access_token': _token(),
      'refresh_token': 'refresh-1',
      'expires_in': 300,
    });
    final auth = repository();
    addTearDown(auth.dispose);

    final result = await auth.login(username: 'admin', password: 'secret');

    expect(result.isOk, isTrue);
    expect(auth.currentSession?.username, 'admin');
    expect(auth.currentSession?.refreshToken, 'refresh-1');
    final sent = keycloak.requests.single;
    expect(sent.path, '/realms/wms/protocol/openid-connect/token');
    expect(sent.form['grant_type'], 'password');
    expect(sent.form['username'], 'admin');
    expect(sent.form['password'], 'secret');
    expect(sent.form['client_id'], 'wms-mobile');
  });

  test('a wrong password reads as a wrong password, not as a raw error', () async {
    keycloak.reply(401, {
      'error': 'invalid_grant',
      'error_description': 'Invalid user credentials',
    });
    final auth = repository();
    addTearDown(auth.dispose);

    final result = await auth.login(username: 'admin', password: 'nope');

    expect(result.isErr, isTrue);
    final failure = result.failureOrNull!;
    expect(failure, isA<UnauthorizedFailure>());
    expect(failure.message, contains('parol yanlışdır'));
  });

  test('says so when the realm has the password grant switched off', () async {
    keycloak.reply(400, {'error': 'unauthorized_client'});
    final auth = repository();
    addTearDown(auth.dispose);

    final result = await auth.login(username: 'admin', password: 'secret');

    expect(result.failureOrNull!.message, contains('Direct Access Grants'));
  });

  test('refuses an empty form without asking the server', () async {
    final auth = repository();
    addTearDown(auth.dispose);

    final result = await auth.login(username: '', password: '');

    expect(result.isErr, isTrue);
    expect(keycloak.requests, isEmpty);
  });

  test('refresh keeps the permissions the token does not carry', () async {
    keycloak.reply(200, {
      'access_token': _token(),
      'refresh_token': 'refresh-1',
      'expires_in': 300,
    });
    final auth = repository();
    addTearDown(auth.dispose);
    await auth.login(username: 'admin', password: 'secret');
    // Permissions arrive from /identity/me, not from the JWT.
    await auth.updateSession(
      auth.currentSession!.copyWith(
        permissions: {'inv.balance.view'},
        locationIds: [1, 2],
      ),
    );

    keycloak.reply(200, {
      'access_token': _token(),
      'refresh_token': 'refresh-2',
      'expires_in': 300,
    });
    final refreshed = await auth.refresh();

    expect(refreshed.isOk, isTrue);
    expect(auth.currentSession?.permissions, {'inv.balance.view'});
    expect(auth.currentSession?.locationIds, [1, 2]);
    expect(auth.currentSession?.refreshToken, 'refresh-2');
    expect(keycloak.requests.last.form['grant_type'], 'refresh_token');
  });

  test('logout ends the Keycloak session, and survives it failing', () async {
    keycloak.reply(200, {
      'access_token': _token(),
      'refresh_token': 'refresh-1',
      'expires_in': 300,
    });
    final auth = repository();
    addTearDown(auth.dispose);
    await auth.login(username: 'admin', password: 'secret');

    keycloak.reply(500, {'error': 'server_error'});
    await auth.logout();

    expect(auth.isAuthenticated, isFalse);
    expect(await store.read(), isNull);
    final logout = keycloak.requests.last;
    expect(logout.path, '/realms/wms/protocol/openid-connect/logout');
    expect(logout.form['refresh_token'], 'refresh-1');
  });
}
