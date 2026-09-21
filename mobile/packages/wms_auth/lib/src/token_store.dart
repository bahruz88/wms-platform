import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'session.dart';

/// Persists the [Session] between app launches.
abstract interface class TokenStore {
  Future<Session?> read();
  Future<void> write(Session session);
  Future<void> clear();
}

/// [TokenStore] on top of `flutter_secure_storage` (Keychain / Keystore /
/// browser storage). The whole session is stored as one JSON entry.
class SecureTokenStore implements TokenStore {
  SecureTokenStore({FlutterSecureStorage? storage, this.key = defaultKey})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String defaultKey = 'wms.session';

  final FlutterSecureStorage _storage;
  final String key;

  @override
  Future<Session?> read() async {
    final raw = await _storage.read(key: key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw);
      if (json is! Map) return null;
      return Session.fromJson(json.map((k, v) => MapEntry(k.toString(), v)));
    } on FormatException {
      await clear();
      return null;
    }
  }

  @override
  Future<void> write(Session session) =>
      _storage.write(key: key, value: jsonEncode(session.toJson()));

  @override
  Future<void> clear() => _storage.delete(key: key);
}

/// Volatile store for tests and for the web when persistence is undesired.
class InMemoryTokenStore implements TokenStore {
  Session? _session;

  @override
  Future<Session?> read() async => _session;

  @override
  Future<void> write(Session session) async => _session = session;

  @override
  Future<void> clear() async => _session = null;
}
