# ADR-001: Modulyar kod bazası, modul üzrə deployment

**Status:** Qəbul edilib
**Mənbə:** [SPEC §2 → ADR-001](../SPEC-Satinalma-Anbar-Platformasi.md#adr-001-modulyar-kod-bazası-modul-üzrə-deployment)

## Kontekst

Tender mikroservis arxitekturası tələb edir (modullar müstəqil deploy və scale olunmalıdır),
lakin komanda 1–3 developerdir və ayrıca DevOps yoxdur. Üstəlik deployment hibriddir:
cloud müştərilər üçün çox konteyner, on-prem müştəri üçün tək konteyner. Həqiqi
mikroservis bölgüsü (repo başına servis, pipeline başına servis, DB başına servis) bu
komanda ölçüsündə daşınmaz operativ yükdür.

## Qərar

Bir solution, bounded context başına bir .NET layihə dəsti
(`Domain/Application/Infrastructure/Endpoints/Contracts`), hər modul öz cədvəl prefiksi ilə.
Deployment profili **konfiqurasiya ilə** seçilir: `--Modules=inventory`,
`--Modules=masterdata,identity`, on-prem üçün `--Modules=*`. Eyni Docker image bütün
profillərə xidmət edir; `ModuleLoader` hansı modulların qalxacağını `Modules` açarından oxuyur.
Modullararası çağırış yalnız `*.Contracts` interfeysləri üzərindən gedir və nəqliyyat
(`ModuleTransport: InProcess | Http`) konfiqurasiya ilə dəyişir.

## Nəticələr

- Bir repo, bir build, bir miqrasiya seti — 3 nəfərlik komanda üçün idarə olunandır.
- Modul başqa modulun daxili tiplərinə və `DbContext`-inə müraciət edə **bilməz**; bu qayda
  `Wms.ArchitectureTests` ilə qorunur (SPEC §17.4) — pozuntu build-i sındırır.
- Kod dəyişmədən həqiqi mikroservisə keçid mümkündür: `ModuleTransport=Http` + ayrı konteyner.
- Qarşılığında: modullar eyni prosesdə işlədikdə təsadüfən bağlılıq yaratmaq asandır —
  arxitektura testi bunun yeganə qoruyucusudur, onu söndürmək qadağandır.
- Bu, tender müzakirəsində izah tələb edən mövqedir: "modulyar monolit + modul üzrə
  deployment profili" mikroservis tələbinin praktik icrasıdır.
