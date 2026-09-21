import 'package:flutter_test/flutter_test.dart';
import 'package:wms_auth/wms_auth.dart';

import 'test_jwt.dart';

void main() {
  test('decodes base64url payload without padding', () {
    final claims = JwtParser.decode(fakeJwt(keeperClaims()));
    expect(claims['preferred_username'], 'keeper');
    expect(JwtParser.realmRoles(claims), contains('WAREHOUSE_KEEPER'));
    expect(
      JwtParser.expiresAt(claims),
      DateTime.fromMillisecondsSinceEpoch(4102444800 * 1000, isUtc: true),
    );
  });

  test('rejects malformed tokens', () {
    expect(() => JwtParser.decode('abc'), throwsFormatException);
    expect(JwtParser.tryDecode('abc'), isNull);
    expect(JwtParser.tryDecode(null), isNull);
  });

  test('permissions claim accepts list or comma string', () {
    expect(
      JwtParser.permissions(const {
        'permissions': ['a', 'b'],
      }),
      ['a', 'b'],
    );
    expect(JwtParser.permissions(const {'permissions': 'a, b'}), ['a', 'b']);
    expect(JwtParser.permissions(const {}), isEmpty);
  });
}
