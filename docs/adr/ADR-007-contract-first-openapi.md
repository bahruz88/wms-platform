# ADR-007: Contract-first — `contracts/openapi/` həqiqət mənbəyidir

**Status:** Qəbul edilib
**Əlaqəli:** [contracts/README.md](../../contracts/README.md), [SPEC §13](../SPEC-Satinalma-Anbar-Platformasi.md#13-api-konvensiyaları), [ADR-008](ADR-008-decimal-on-client.md)

## Kontekst

Backend (.NET) və interfeys tərəfi paralel yazılır və çox vaxt fərqli günlərdə. API-nin
harada təyin olunduğu sualının iki cavabı var:

- **Code-first:** backend kodu yazılır, `Swashbuckle`/`Microsoft.AspNetCore.OpenApi`
  `openapi/v1.json` generasiya edir, interfeys komandası onu gözləyir.
- **Contract-first:** OpenAPI faylı əvvəl yazılır, hər iki tərəf ondan törəyir.

Code-first-də interfeys backend-in yazılmasını gözləməlidir; API dəyişikliyi yalnız
generasiya olunan JSON-a baxanda görünür və "səhvən breaking" dəyişiklik heç nəyi sındırmır —
ta ki mobil tətbiq mağazada sınana qədər. Bizim halda əlavə səbəb də var: **decimal-string
qaydası** (SPEC §13, CONVENTIONS) code-first generasiyada asanlıqla itir — C# `decimal`
default olaraq JSON `number` kimi çıxır.

## Qərar

`contracts/openapi/<modul>.v1.yaml` **API-nin yeganə mənbəyidir**. Hər dəyişiklik orada başlayır:

```
kontrakt → lint → client generasiyası (Dart + TypeScript) → backend endpoint → kontrakt testi
```

- Modul başına bir fayl, ortaq komponentlər `common.v1.yaml`-da; `servers` CONVENTIONS-dakı
  route prefiksini daşıyır.
- `operationId` (camelCase) generasiya olunan Dart, TypeScript və C# metod adlarıdır — **API-nin bir hissəsidir**.
- Hər əməliyyat `x-permission` daşıyır; backend `.RequirePermission(...)` bunu təkrarlayır.
- Backend `openapi/v1.json` generasiya etməkdə davam edir, lakin o **yoxlama artefaktıdır**:
  `Wms.Api.ContractTests` onu (və işləyən host-un endpoint cədvəlini) YAML kontraktı ilə
  tutuşdurur — route, `operationId`, icazə kodu, `Idempotency-Key` tələbi, `problem+json`
  formatı və `Decimal` sahələrinin string olması.
- Mobil (`mobile/`) `scripts/gen-client.sh` ilə `dart-dio` client, web (`web/`) isə
  `npm run gen:api` (`openapi-typescript`) ilə TypeScript client generasiya edir
  ([ADR-013](ADR-013-web-react-mobile-flutter.md)); generasiya olunmuş kod **commit edilmir**
  (gitignore), hər build onu yenidən yaradır.

## Nəticələr

- İnterfeys komandaları backend-i gözləmir: kontrakt razılaşdırılan kimi hər iki client
  generasiya olunur və mock üzərində işləmək mümkündür.
- Breaking dəyişiklik **lint və kontrakt testində** görünür, istehsalatda yox.
- Sənəd həmişə güncəldir, çünki sənəd özü mənbədir.
- Decimal-string qaydası bir yerdə (`common.v1.yaml#/components/schemas/Decimal`) təyin olunur
  və hər iki tərəfə oradan yayılır.
- Qarşılığında: YAML yazmaq əlavə addımdır və developer "sadəcə endpoint əlavə etmək"
  istəyəndə maneə kimi hiss olunur. Bu, şüurlu maneədir — CI kontrakt testi ilə onu tətbiq edir.
- Modullararası `$ref` qadağandır (ADR-001-in kontrakt səviyyəsindəki əksi); başqa modulun
  obyekti lazımdırsa kiçik `*Ref` sxemi təkrarlanır.
