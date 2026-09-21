import 'dart:convert';

import 'package:wms_auth/wms_auth.dart';

/// Builds an unsigned JWT for tests.
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
).copyWith(permissions: permissions);
