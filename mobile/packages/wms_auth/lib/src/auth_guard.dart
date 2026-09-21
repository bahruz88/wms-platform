import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'auth_repository.dart';

/// go_router redirect + refresh listenable for authentication.
///
/// ```dart
/// final guard = AuthGuard(repository: repo, loginPath: '/login');
/// GoRouter(
///   redirect: guard.redirect,
///   refreshListenable: guard,
///   ...
/// );
/// ```
class AuthGuard extends ChangeNotifier {
  AuthGuard({
    required AuthRepository repository,
    this.loginPath = '/login',
    this.homePath = '/',
    this.publicPaths = const {},
    this.redirectParam = 'from',
  }) : _repository = repository {
    _subscription = repository.sessionChanges.listen((_) => notifyListeners());
  }

  final AuthRepository _repository;
  final String loginPath;
  final String homePath;

  /// Paths reachable without a session (besides [loginPath]).
  final Set<String> publicPaths;

  /// Query parameter carrying the original location through the login page.
  final String redirectParam;

  StreamSubscription<Object?>? _subscription;

  /// go_router `redirect` callback.
  String? redirect(BuildContext context, GoRouterState state) => resolve(
    authenticated: _repository.isAuthenticated,
    location: state.uri.toString(),
    matchedLocation: state.matchedLocation,
    queryParameters: state.uri.queryParameters,
  );

  /// Pure redirect logic (unit-testable without a router).
  String? resolve({
    required bool authenticated,
    required String location,
    required String matchedLocation,
    Map<String, String> queryParameters = const {},
  }) {
    final isPublic =
        matchedLocation == loginPath || publicPaths.contains(matchedLocation);
    if (!authenticated) {
      if (isPublic) return null;
      final from = Uri.encodeComponent(location);
      return '$loginPath?$redirectParam=$from';
    }
    if (matchedLocation == loginPath) {
      final from = queryParameters[redirectParam];
      if (from != null && from.isNotEmpty && from != loginPath) {
        final decoded = Uri.decodeComponent(from);
        if (decoded.startsWith('/') && !decoded.startsWith(loginPath)) {
          return decoded;
        }
      }
      return homePath;
    }
    return null;
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    _subscription = null;
    super.dispose();
  }
}
