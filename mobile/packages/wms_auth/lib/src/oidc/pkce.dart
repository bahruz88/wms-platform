import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:meta/meta.dart';

/// PKCE (RFC 7636) code verifier/challenge pair used by the Authorization
/// Code flow of both apps. The realm advertises `S256` only, so the plain
/// method is deliberately not supported.
@immutable
class Pkce {
  const Pkce({required this.verifier, required this.challenge});

  /// Generates a fresh verifier and its `S256` challenge.
  ///
  /// [length] is the number of characters of the verifier; RFC 7636 §4.1
  /// allows 43..128 characters from the unreserved set.
  factory Pkce.generate({Random? random, int length = 64}) {
    if (length < minVerifierLength || length > maxVerifierLength) {
      throw ArgumentError.value(
        length,
        'length',
        'code_verifier must be $minVerifierLength..$maxVerifierLength chars',
      );
    }
    final rnd = random ?? Random.secure();
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      buffer.write(_alphabet[rnd.nextInt(_alphabet.length)]);
    }
    final verifier = buffer.toString();
    return Pkce(verifier: verifier, challenge: challengeFor(verifier));
  }

  /// RFC 7636 §4.1 unreserved characters.
  static const String _alphabet =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';

  static const int minVerifierLength = 43;
  static const int maxVerifierLength = 128;

  /// Only method the realm accepts (`pkce.code.challenge.method = S256`).
  static const String method = 'S256';

  /// `BASE64URL-ENCODE(SHA256(ASCII(verifier)))` without padding.
  static String challengeFor(String verifier) {
    final digest = sha256.convert(ascii.encode(verifier));
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  /// Opaque `state` value protecting the callback against CSRF.
  static String randomState({Random? random, int length = 32}) {
    final rnd = random ?? Random.secure();
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      buffer.write(_alphabet[rnd.nextInt(_alphabet.length)]);
    }
    return buffer.toString();
  }

  final String verifier;
  final String challenge;

  bool get isValid =>
      verifier.length >= minVerifierLength &&
      verifier.length <= maxVerifierLength &&
      challengeFor(verifier) == challenge;

  @override
  bool operator ==(Object other) =>
      other is Pkce &&
      other.verifier == verifier &&
      other.challenge == challenge;

  @override
  int get hashCode => Object.hash(verifier, challenge);

  @override
  String toString() => 'Pkce(challenge: $challenge)';
}
