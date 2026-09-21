# wms_auth

OIDC (Keycloak) sessiya abstraksiyası: `AuthRepository`, `Session` (JWT claim-lərindən),
`TokenStore` (flutter_secure_storage), Riverpod provider-ləri və go_router üçün `AuthGuard`.
Konkret PKCE axını tətbiqlərdədir: `apps/wms_mobile` (flutter_appauth) və `apps/wms_web` (openid_client).
