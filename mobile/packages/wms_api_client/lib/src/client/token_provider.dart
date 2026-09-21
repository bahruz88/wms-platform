/// Bridge between the auth layer and the HTTP client. Implemented in
/// `wms_auth`/apps so that this package stays independent of the OIDC stack.
abstract interface class TokenProvider {
  /// Current access token or `null` when signed out.
  Future<String?> getAccessToken();

  /// Attempts a refresh; returns `true` when a new access token is available.
  Future<bool> refresh();

  /// Called after a 401 that could not be recovered by [refresh].
  Future<void> onUnauthorized();
}

/// Token provider for tests and anonymous calls.
class StaticTokenProvider implements TokenProvider {
  StaticTokenProvider([this.token]);

  String? token;

  @override
  Future<String?> getAccessToken() async => token;

  @override
  Future<bool> refresh() async => false;

  @override
  Future<void> onUnauthorized() async {}
}
