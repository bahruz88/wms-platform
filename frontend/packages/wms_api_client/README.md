# wms_api_client

Dio əsaslı tipli HTTP müştəri. `WmsApiClient` bütün interceptor-ları (auth, idempotency,
problem+json, logging) qurur və modul üzrə API siniflərini (`inventory`, `procurement`,
`masterData`, `identity`, `reporting`, `notifications`) təqdim edir.

- Bütün miqdar/məbləğ sahələri `Quantity`/`Money` (decimal) tipindədir — JSON-da string.
- `lib/src/generated/` openapi-generator çıxışı üçün ayrılıb (bax README orada).
- Kod generasiyası: `dart run build_runner build --delete-conflicting-outputs`.
