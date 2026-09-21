# wms_core

Layihənin **saf Dart** özəyi — Flutter asılılığı yoxdur, ona görə də `dart test` ilə
işləyir və həm tətbiqlərdən, həm də digər paketlərdən istifadə edilir.

| Bölmə | Nə var |
|---|---|
| `values/` | `Quantity`, `Money` — `Decimal` üzərində, yuvarlaqlaşdırma `AwayFromZero`. **`double` qadağandır.** |
| `result/` | `Result<T>` (`Ok`/`Err`) və `Failure` iyerarxiyası — biznes xətası üçün exception atılmır. |
| `errors/` | RFC 7807 `ProblemDetails`, `ProblemCodes`, `AppException` (transport sərhədi). |
| `paging/` | `Page<T>`, `PageRequest` — `{ items, page, size, total }`. |
| `enums/` | SPEC-dən güzgülənmiş enum-lar (sənəd statusları, partiya, lokasiya, əlavə tipləri). |
| `auth/` | `Permissions` (icazə kodları) və `Roles` (realm rolları). |
| `env/` | `AppEnv` — `--dart-define` ilə gələn konfiqurasiya. |
| `tenant/` | `TenantContext` — token-dəki `tenant_id` claim-i. |
| `observability/` | `CrashReporter` interfeysi + `LoggingCrashReporter` (defolt), `runGuardedWithReporter`. |

## İstifadə

```dart
final qty = Quantity.parse('12.5000');
final result = await repository.balances();
result.fold((page) => page.items, (failure) => throw AppException(failure));
```

Xəta bildirişini real backend-ə (Sentry/Crashlytics) yönləndirmək üçün `CrashReporter`
interfeysini tətbiq edin və tətbiqin `bootstrap()` funksiyasına verin — çağırış yerləri
dəyişmir.

## Test

```sh
cd packages/wms_core && dart test
```

`test/no_double_rule_test.dart` bütün domen paketlərini skan edir və `double` sözünə rast
gələndə uğursuz olur (decimal qaydası, `docs/CONVENTIONS.md`).
