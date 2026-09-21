# wms_auth

OIDC (Keycloak) sessiya abstraksiyası: `AuthRepository`, `Session` (JWT claim-lərindən),
`TokenStore` (flutter_secure_storage), Riverpod provider-ləri və go_router üçün `AuthGuard`.
Konkret PKCE axını tətbiqdədir: `apps/wms_mobile` (flutter_appauth). Web tərəfi
artıq React-dir və `oidc-client-ts` işlədir ([ADR-013](../../../docs/adr/ADR-013-web-react-mobile-flutter.md)).
