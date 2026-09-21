import 'dart:convert';

/// Builds an unsigned JWT with the given payload for tests.
String fakeJwt(Map<String, Object?> payload) {
  String enc(Object? o) =>
      base64Url.encode(utf8.encode(jsonEncode(o))).replaceAll('=', '');
  return '${enc({'alg': 'none', 'typ': 'JWT'})}.${enc(payload)}.sig';
}

Map<String, Object?> keeperClaims({int exp = 4102444800}) => {
  'sub': 'a1b2',
  'preferred_username': 'keeper',
  'name': 'Anbardar Kamil',
  'tenant_id': '1',
  'exp': exp,
  'realm_access': {
    'roles': ['WAREHOUSE_KEEPER', 'offline_access'],
  },
};
