import 'dart:convert';

import 'package:meta/meta.dart';

import 'pkce.dart';

/// The part of an in-flight Authorization Code request that must survive the
/// full page navigation to the identity provider: `state`, the PKCE verifier,
/// the redirect URI the code was issued for and where to send the user back.
@immutable
class PendingAuthorization {
  const PendingAuthorization({
    required this.state,
    required this.codeVerifier,
    required this.redirectUri,
    required this.createdAt,
    this.returnTo,
  });

  factory PendingAuthorization.start({
    required Uri redirectUri,
    String? returnTo,
    Pkce? pkce,
    String? state,
    DateTime? now,
  }) {
    final codes = pkce ?? Pkce.generate();
    return PendingAuthorization(
      state: state ?? Pkce.randomState(),
      codeVerifier: codes.verifier,
      redirectUri: redirectUri,
      returnTo: returnTo,
      createdAt: (now ?? DateTime.now()).toUtc(),
    );
  }

  factory PendingAuthorization.fromJson(Map<String, Object?> json) =>
      PendingAuthorization(
        state: json['state']! as String,
        codeVerifier: json['codeVerifier']! as String,
        redirectUri: Uri.parse(json['redirectUri']! as String),
        returnTo: json['returnTo'] as String?,
        createdAt:
            DateTime.tryParse('${json['createdAt']}')?.toUtc() ??
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      );

  /// Decodes the serialised form; returns `null` for anything unreadable so a
  /// corrupted browser entry never breaks startup.
  static PendingAuthorization? tryDecode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return PendingAuthorization.fromJson(
        decoded.map((k, v) => MapEntry(k.toString(), v)),
      );
    } on Object {
      return null;
    }
  }

  /// An authorization request older than this is treated as abandoned.
  static const Duration maxAge = Duration(minutes: 15);

  final String state;
  final String codeVerifier;
  final Uri redirectUri;

  /// In-app location to restore after the exchange (`/inventory/balances`).
  final String? returnTo;
  final DateTime createdAt;

  String get codeChallenge => Pkce.challengeFor(codeVerifier);

  bool isExpired({DateTime? now}) =>
      (now ?? DateTime.now()).toUtc().difference(createdAt) > maxAge;

  Map<String, Object?> toJson() => {
    'state': state,
    'codeVerifier': codeVerifier,
    'redirectUri': redirectUri.toString(),
    'returnTo': returnTo,
    'createdAt': createdAt.toUtc().toIso8601String(),
  };

  String encode() => jsonEncode(toJson());

  @override
  String toString() => 'PendingAuthorization(state: $state, to: $returnTo)';
}

/// Storage for [PendingAuthorization] across the redirect. The web app backs
/// this with `sessionStorage`; tests use [InMemoryPendingAuthorizationStore].
abstract interface class PendingAuthorizationStore {
  PendingAuthorization? read();
  void write(PendingAuthorization pending);
  void clear();
}

class InMemoryPendingAuthorizationStore implements PendingAuthorizationStore {
  PendingAuthorization? _value;

  @override
  PendingAuthorization? read() => _value;

  @override
  void write(PendingAuthorization pending) => _value = pending;

  @override
  void clear() => _value = null;
}
