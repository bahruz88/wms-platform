/// The two browser capabilities the OIDC redirect flow needs. Keeping them
/// behind an interface means `KeycloakAuthWeb` stays a plain Dart class that
/// can be unit tested on the VM, while the real implementation
/// (`WindowBrowser`) is the only file touching `package:web`.
abstract interface class Browser {
  /// Current document URL, including query and fragment.
  Uri get currentUri;

  /// Leaves the page (full navigation to the identity provider).
  void assign(String url);

  /// Rewrites the address bar without navigating (`history.replaceState`),
  /// used to drop `?code=...` after a successful exchange.
  void replaceUrl(String url);
}

/// Browser double for tests: records navigations instead of performing them.
class RecordingBrowser implements Browser {
  RecordingBrowser({Uri? initialUri})
    : _uri = initialUri ?? Uri.parse('http://localhost:3001/');

  Uri _uri;

  /// Every URL passed to [assign], in order.
  final List<String> navigations = <String>[];

  /// Every URL passed to [replaceUrl], in order.
  final List<String> replacements = <String>[];

  @override
  Uri get currentUri => _uri;

  @override
  void assign(String url) {
    navigations.add(url);
    _uri = Uri.parse(url);
  }

  @override
  void replaceUrl(String url) {
    replacements.add(url);
    _uri = Uri.parse(url);
  }
}
