import 'package:wms_api_client/wms_api_client.dart';

import 'auth_repository.dart';

/// Adapts an [AuthRepository] to the API client's [TokenProvider]:
/// proactively refreshes when the access token is about to expire and signs
/// out when a 401 cannot be recovered.
class SessionTokenProvider implements TokenProvider {
  SessionTokenProvider(this._repository);

  final AuthRepository _repository;

  @override
  Future<String?> getAccessToken() async {
    final session = _repository.currentSession;
    if (session == null) return null;
    if (session.isExpired() && session.refreshToken != null) {
      final refreshed = await _repository.refresh();
      return refreshed.valueOrNull?.accessToken ?? session.accessToken;
    }
    return session.accessToken;
  }

  @override
  Future<bool> refresh() async {
    final result = await _repository.refresh();
    return result.isOk;
  }

  @override
  Future<void> onUnauthorized() => _repository.logout();
}
