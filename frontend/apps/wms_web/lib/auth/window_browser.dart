import 'package:web/web.dart' as web;
import 'package:wms_auth/wms_auth.dart';

import 'browser.dart';

/// [Browser] on top of the real `window`. This is the only file in the app
/// that touches `package:web`, so everything else stays testable on the VM.
class WindowBrowser implements Browser {
  const WindowBrowser();

  @override
  Uri get currentUri => Uri.parse(web.window.location.href);

  @override
  void assign(String url) => web.window.location.assign(url);

  @override
  void replaceUrl(String url) => web.window.history.replaceState(null, '', url);
}

/// [PendingAuthorizationStore] backed by `sessionStorage`.
///
/// `sessionStorage` is the right scope for an in-flight authorization: it
/// survives the full page navigation to Keycloak and back, it is per tab (two
/// tabs signing in at once do not fight over the `state`), and the browser
/// drops it when the tab closes so no code verifier is left behind.
class SessionStoragePendingAuthorizationStore
    implements PendingAuthorizationStore {
  const SessionStoragePendingAuthorizationStore({this.key = defaultKey});

  static const String defaultKey = 'wms.oidc.pending';

  final String key;

  @override
  PendingAuthorization? read() =>
      PendingAuthorization.tryDecode(web.window.sessionStorage.getItem(key));

  @override
  void write(PendingAuthorization pending) =>
      web.window.sessionStorage.setItem(key, pending.encode());

  @override
  void clear() => web.window.sessionStorage.removeItem(key);
}
