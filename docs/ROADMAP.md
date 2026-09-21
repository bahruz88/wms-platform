# Vəziyyət və yol xəritəsi

**Tarix:** 21.09.2026 · **Mənbə:** repo boyunca yeddi paralel audit (kontraktlar, domen, web,
mobil, infrastruktur, çarpaz məsələlər, meta-audit). Ümumilikdə **164 boşluq** aşkarlandı.

Bu sənəd nəyin hazır olduğunu, nəyin qaldığını və hansı ardıcıllıqla görüləcəyini deyir.
Hər bənd audit tərəfindən sübutla təsdiqlənib — fayl yolu, marşrut, test adı və ya əmr nəticəsi ilə.

---

## 1. Bir baxışda

### Kontrakt əhatəsi

Doqquz OpenAPI spesifikasiyası **184 əməliyyat** elan edir. Gateway-dən **81-i** işləyir (44 %).

| Modul | Elan olunub | İşləyir | Qalıq |
|---|---:|---:|---:|
| Consumption | 24 | 24 | **0** |
| Inventory | 53 | 48 | 5 |
| Reporting | 8 | 1 | 7 |
| Documents | 6 | 1 | 5 |
| Notifications | 11 | 0 | 11 |
| Identity | 17 | 2 | 15 |
| MasterData | 29 | 2 | 27 |
| Procurement | 36 | 1 | 35 |

Anbar və istehlak tərəfi işləyir. Qalan hər şey kontraktda var, kodda yoxdur.

### Keyfiyyət göstəriciləri

| Göstərici | Hazırkı |
|---|---|
| Backend test | 530 keçir |
| Web test | 245 keçir |
| Mobil test | 266 keçir |
| Backend build | 0 xəbərdarlıq |
| Ledger balanssız qrup | 0 |
| Mənfi fiziki qalıq | 0 |
| **Backend CI** | **heç vaxt keçməyib** |
| **Web konteyner obrazı** | **heç vaxt qurulmayıb** |
| **On-prem profili** | **heç vaxt qaldırılmayıb** |
| **Kubernetes** | **heç vaxt tətbiq edilməyib** |

---

## 2. Dərhal bağlanmalı təhlükəsizlik boşluqları

Bunlar faza gözləmir. Hər ikisi canlı stack-də özüm yoxladım.

**Filial istifadəçisi bütün şirkətin stokunu görür.** `branch1` tokeni ilə `/inventory/balances`
sorğusu hər iki mərkəzi anbarı (WH-01, WH-02) və başqa filialı (BR-NIZ) qaytarır.
`iam_user_location` cədvəli boşdur və lokasiya filtri fail-open qurulub, yəni məhdudiyyət
tətbiq olunmur. Spesifikasiya §16 bunu birbaşa tələb edir.

**Modullararası `/internal/*` marşrutları gateway-dən açıqdır.** 24 marşrutun hamısı adi
autentifikasiya olunmuş istifadəçi tərəfindən çağırıla bilir, heç birində icazə yoxlaması yoxdur.
İçlərində yazma əməliyyatları da var, o cümlədən ledger və nömrə seriyası. `branch1` tokeni ilə
`/api/v1/masterdata/internal/products` sorğusu 200 qaytarır.

Bunlara əlavə: gateway CORS başlığı göndərmir, heç yerdə Content-Security-Policy yoxdur,
OIDC tokenləri `localStorage`-də saxlanılır, Keycloak production realm-ində parol siyasəti,
MFA və audit jurnalı yoxdur.

---

## 3. Fazalar

### Faza 1 — Sistemi işlək hala gətirmək (bloklayıcı)

Bunlarsız məhsul real tenant üçün qurula bilmir.

1. **MasterData yazma endpoint-ləri** — 27 əməliyyat. Məhsul, lokasiya, təchizatçı, vahid,
   səbəb kodu, məzənnə yalnız seeder ilə yaranır. Səbəb kodu siyahısı isə hər ləğv, tullantı və
   düzəliş sorğusunda tələb olunur, amma `GET /masterdata/reason-codes` 404 qaytarır.
2. **Identity yazma endpoint-ləri və `iam` sxeminin doldurulması** — 15 əməliyyat. Bütün `iam_*`
   cədvəlləri boşdur; icazə yoxlaması sabit kodlaşdırılmış xəritədən işləyir, verilənlər bazasından yox.
3. **JWT-də daxili istifadəçi identifikatoru.** Token `iam_user.id` daşımadığı üçün bütün
   `created_by`, `posted_by`, `approved_by` sahələri sıfırdır. Nəticədə audit jurnalı kimə aid
   olduğunu göstərmir və §12.6-dakı öz-özünü təsdiq qadağası səssizcə söndürülüb.
4. **Lokasiya filtri və `/internal/*` qorunması** — §2-dəki iki boşluq.
5. **Fayl əlavələri** — MinIO client, presign, complete, download, virus skanı, 25 MB limiti.
   Hazırda backend-də heç biri yoxdur, yalnız heç kimin yazmadığı cədvəlin oxu siyahısı var.
6. **`inv_setting` endpoint-ləri.** Spesifikasiyanın sabit kodlaşdırılmamasını tələb etdiyi
   parametrlər məhsul vasitəsilə nə görünür, nə dəyişir.
7. **`GET /identity/me` kontraktı pozur** — hər iki client məhz bu endpoint-dən başlayır.
8. **Backend CI heç vaxt keçməyib** — EF-in generasiya etdiyi miqrasiyada IDE0161 xətası build-i
   dayandırır. Mobil CI də qırıqdır.

### Faza 2 — Satınalma

Məhsulun yarısı. Domen entity-ləri var, amma onları hərəkətə gətirən heç nə yoxdur:
Application qatında bir dənə sorğu faylı var, komanda yoxdur.

- Tələbnamə, RFQ, təklif, müqayisə, sifariş, təsdiq zənciri — 35 əməliyyat.
- Dörd cədvəl ümumiyyətlə yoxdur: `proc_rfq`, `proc_quotation`, `proc_price_history`,
  `proc_split_check_log`.
- Web-də altı satınalma ekranı hazırdır və hamısı 404 alır.

### Faza 3 — Sistemin reaksiya verməsi

Hadisələr yaranır, amma heç nə onları oxumur.

- **RabbitMQ-da abunəçi yoxdur.** Notification, Reporting və Integration heç nəyə reaksiya vermir.
- Spesifikasiyanın 11 hadisəsindən 4-ü heç vaxt dərc olunmur.
- Doqquz arxa fon job-undan 5-i yoxdur.
- **24 hesabatdan 0-ı mövcuddur**, üstəlik həmin 24-ün siyahısı repoda yoxdur.
- Bildirişlər növbəyə düşür və orada qalır, heç yerə çatdırılmır.
- Gecə özünüyoxlama job-ları yalnız log yazır; aşkarlanan ledger uyğunsuzluğu heç kimə çatmır.

### Faza 4 — Mobil tətbiqi işlək hala gətirmək

Tətbiq kompilyasiya olunur və 266 testi keçir, lakin canlı backend-ə qarşı işləmir.

- **DTO forması uyğun gəlmir.** Əl ilə yazılmış DTO-lar düz `productId` gözləyir, backend isə
  kontrakta uyğun olaraq iç-içə `product: {...}` qaytarır. Kök səbəb: generasiya olunmuş client
  heç vaxt qoşulmayıb.
- Filial təsdiqi mövcud olmayan marşruta göndərilir.
- Sayım dövrəsi yarımçıqdır: yalnız sətir girişi var, yaratma, dondurma, təsdiqə göndərmə və post yoxdur.
- Məxaric yaratma ekranı yoxdur, `WmsBatchPicker` heç yerdə işlənmir.
- Ekranların çoxuna naviqasiya yoxdur.
- Toxunma hədəfləri web ölçüsündədir (34px), mobil üçün 44pt variant yoxdur.
- Təxminən 300 sətir mətn kodda sabitdir, halbuki az/en/ru tərcümələri hazırdır.
- Release build debug açarı ilə imzalanır; cihaza çatdırma yolu yoxdur.

### Faza 5 — İstismara hazırlıq

Heç bir deployment artefaktı real işlədilməyib.

- Web obrazı heç vaxt qurulmayıb; `:3000` host üzərində Vite preview-dur, konteyner deyil.
- On-prem profili heç vaxt qaldırılmayıb. Kubernetes manifestləri heç vaxt tətbiq edilməyib.
- `overlays/prod` hər deploy-da real sirləri placeholder ilə əvəz edərdi.
- Yedəkləmə skripti heç vaxt işlədilməyib və MinIO addımında ad səhvi var. Bərpa aləti yoxdur,
  halbuki spesifikasiya §18.4 rüblük bərpa təlimi tələb edir.
- Sirr idarəetməsi dev defoltlarından o yana getmir. Versiyalaşdırma və buraxılış prosesi yoxdur.
- Monitorinq Seq və health check ilə bitir; alert kanalı yoxdur.
- **Yük testi ümumiyyətlə yoxdur**, halbuki §17.3 yeganə rəqəmli qəbul meyarıdır: 100 eyni vaxtlı
  istifadəçi, 1 000 000 hərəkət sətri, p95 < 2 saniyə.

### Faza 0 — Data köçürməsi (paralel, erkən başlamalıdır)

Spesifikasiya §19 bunu ayrıca mərhələ kimi göstərir və **heç bir aləti yoxdur**. Seeder dev
datasıdır, köçürmə yolu deyil. Lazımdır: SKU təyini, base UoM və çevirmə əmsalları, partiya
səviyyəsində açılış qalıqları, təchizatçı bazası, açılış qiymətləri.

Bu, müştərinin əməliyyat komandasından vaxt tələb edir və layihə planında ayrıca sətir olmalıdır.

---

## 4. Miqyas tavanları

Meta-audit bir asılılıq tapdı ki, ayrı-ayrı auditlər onu görə bilməzdi: **hazır sayılan iki modul,
çatışmayan modullar doldurulduqda ilk sınacaq yerlərdir.**

- Modullararası arayış sorğusu identifikatorları GET query string-də ötürür və təxminən
  1 300 identifikatorda HTTP 414 verir. Canlı stack-də sübut olunub.
- `GET /inventory/balances` 20 000 sətirdə səssizcə kəsilir və kateqoriya, axtarış və ya minimum
  filtri işlədildikdə filtrləmə ilə səhifələməni yaddaşda aparır.
- Sayım siyahısı üç ədədi hesablamaq üçün səhifədəki hər sayımın hər sətrini yükləyir; detal
  endpoint-ində sətir səhifələməsi ümumiyyətlə yoxdur.
- Gecə job-ları bütün ledger tarixçəsini tarix məhdudiyyəti olmadan skan edir.
- `inv_movement` partisiyaları 2027-nin sonunda bitir, baxım job-u və siqnal yoxdur.
- Rate limit prosesdaxilidir, gateway səviyyəsində deyil, ona görə production profilində elan
  olunandan təxminən 12 dəfə zəifdir.

---

## 5. Sənədləşdirilməmiş sahələr

- **Son istifadəçi sənədi, operator runbook-u və təlim materialı yoxdur.** `docs/` tamamilə
  qurucular üçündür.
- **Qəbul meyarları və UAT protokolu yoxdur.** Dörd fazadan üçünün çıxış meyarı yoxdur.
- **Lisenziya uyğunluğu** spesifikasiya §3-də layihədən əvvəl tələb olunurdu: LICENSE, NOTICE,
  SBOM və ya skan yoxdur. Hangfire MySQL storage-ın LGPL məsələsi hələ açıqdır.
- **Data saxlama və Azərbaycanın fərdi məlumatlar qanunu** (§16): siyasət, kod, cədvəl və məsul şəxs yoxdur.
- **Əlçatanlıq** diqqətlə yazılıb və heç nə ilə yoxlanmır: lint qaydası, axe, kontrast testi yoxdur.
- Server xəta mesajları yalnız ingiliscədir, halbuki interfeys dili azərbaycancadır.

---

## 6. Spesifikasiyanın açıq qərarları

| Bənd | Vəziyyət |
|---|---|
| §20.1 Filial istehlakı modeli | **Həll olundu** — [ADR-012](adr/ADR-012-branch-consumption-model.md) |
| §20.2 1C-də master data sahibliyi | Açıq, ADR yoxdur, məsul şəxs yoxdur |
| §20.3 Həcm göstəriciləri | Açıq — sizing və qiymətləndirmə üçün lazımdır |
| §20.4 Costing metodunun 1C ilə uzlaşması | Açıq, maliyyə təsdiqi gözləyir |

---

## 7. Təklif olunan ardıcıllıq

1. **Təhlükəsizlik** (§2) — günlərlə ölçülür, gözləməməlidir.
2. **Faza 1** — sistemin qurula bilməsi. Bunsuz demo real tenant üçün qurula bilmir.
3. **Faza 0** paralel başlasın — müştəri tərəfindən data toplanması uzun sürür.
4. **Faza 2** satınalma — məhsulun ikinci yarısı.
5. **Faza 4** mobil — anbardar və filial işçisinin əsl iş yeri.
6. **Faza 3** reaksiya və hesabatlar.
7. **Faza 5** istismara hazırlıq — lakin CI-ın düzəldilməsi və web obrazının bir dəfə qurulması
   Faza 1-ə çəkilməlidir, çünki onlar hər şeyi bloklayır.
