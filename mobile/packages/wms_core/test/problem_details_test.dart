import 'package:test/test.dart';
import 'package:wms_core/wms_core.dart';

void main() {
  test('ProblemDetails parses the spec example', () {
    final pd = ProblemDetails.fromJson(const {
      'type': 'https://wms/errors/insufficient-stock',
      'title': 'Kifayət qədər stok yoxdur',
      'status': 409,
      'code': 'INSUFFICIENT_STOCK',
      'detail': 'Chicken Strips: mövcud 45.0000 KG, tələb olunan 60.0000 KG',
      'traceId': '00-abc',
      'errors': {
        'lines[2].qty': ['Mövcud qalıqdan çoxdur'],
      },
    });
    expect(pd.status, 409);
    expect(pd.code, ProblemCodes.insufficientStock);
    expect(pd.traceId, '00-abc');
    expect(pd.fieldErrors('lines[2].qty'), ['Mövcud qalıqdan çoxdur']);
    expect(pd.fieldErrors('missing'), isEmpty);
    expect(pd.hasFieldErrors, isTrue);
    expect(pd.toJson()['errors'], isA<Map<String, List<String>>>());
  });

  test('tolerates malformed bodies', () {
    final pd = ProblemDetails.fromJson(const {'status': '500', 'errors': 'x'});
    expect(pd.status, 500);
    expect(pd.errors, isEmpty);
    expect(pd.message, 'Unknown error');
  });

  test('TenantContext.fromClaims requires tenant_id', () {
    expect(TenantContext.fromClaims(const {}), isNull);
    final t = TenantContext.fromClaims(const {'tenant_id': '1'});
    expect(t?.tenantId, 1);
    expect(t?.currency, 'AZN');
  });

  test('AppEnv.validate reports missing defines', () {
    const env = AppEnv(
      apiBaseUrl: '',
      keycloakIssuer: 'x',
      keycloakClientId: '',
      flavor: 'dev',
    );
    expect(
      env.validate,
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('API_BASE_URL, KEYCLOAK_CLIENT_ID'),
        ),
      ),
    );
    const ok = AppEnv(
      apiBaseUrl: 'http://localhost:5001/',
      keycloakIssuer: 'http://localhost:8180/realms/wms',
      keycloakClientId: 'wms-web',
      flavor: 'prod',
    );
    expect(ok.isProd, isTrue);
    expect(ok.apiV1, 'http://localhost:5001/api/v1');
    // Dev defaults follow deploy/.env (5001 / 8180) but stay overridable.
    expect(AppEnv.fromEnvironment.apiBaseUrl, 'http://localhost:5001');
    expect(
      AppEnv.fromEnvironment.keycloakIssuer,
      'http://localhost:8180/realms/wms',
    );
  });
}
