# Ekran xəritəsi (UX starting point)

> **Status:** başlanğıc nöqtəsi. Bu sənəd spesifikasiyadan **törədilib** — hansı ekranların
> mövcud olmalı olduğunu, hansı sahələri daşıdığını və hansı validasiyaların domen
> invariantlarından gəldiyini qeyd edir. Müştərinin UI/UX sənədi gəldikdə bu fayl onunla
> **əvəz olunur**; domen qaydaları (§6) isə əvəz olunmur — onlar SPEC-dən gəlir.
>
> **Vizual dil burada təyin edilmir.** Rəng, tipoqrafiya, məsafə, ikonoqrafiya, boş/xəta
> vəziyyətləri və əlçatanlıq [`docs/design-system/`](../design-system/README.md)-dədir
> (WMS Enterprise, [ADR-011](../adr/ADR-011-design-system.md)). Aşağıdakı hər ekranda
> istifadə olunan komponentlər adı ilə göstərilib.

**Mənbələr:** [SPEC](../SPEC-Satinalma-Anbar-Platformasi.md) · [contracts/openapi](../../contracts/openapi) ·
[design-system](../design-system/README.md) · [FLUTTER-MAPPING](../design-system/FLUTTER-MAPPING.md)

---

## 1. Rol × platforma matrisi

Bölgü **optimallaşdırmadır, məhdudiyyət deyil**: rol icazəsi çatırsa, ekran hər iki qabıqda
açıla bilər. Yeganə həqiqi yoxlama serverdədir (`x-permission`).

> **«Platforma» sətri iki ayrı stack deməkdir** ([ADR-013](../adr/ADR-013-web-react-mobile-flutter.md)):
> **veb** = React 18 + TypeScript (`web/`), **mobil** = Flutter (`mobile/apps/wms_mobile`).
> Kod paylaşılmır; ortaq nöqtə yalnız `contracts/openapi/`-dir. Ona görə «mobil + veb»
> işarəsi ekranın **iki dəfə** — hər stack-də bir dəfə — qurulduğunu bildirir, eyni
> widget-in təkrar istifadəsini yox.

| Rol | Mobil (Flutter, `mobile/`) | Veb (React, `web/`) | Əsas iş |
|---|---|---|---|
| **WAREHOUSE_KEEPER** (anbardar) | ●●● əsas | ○ nadir | Qəbul (skan), məxaric/picking, sayım, tullantı, nümunə, partiya bloku. **Qiymət görmür** (`master.product.view_cost` YOX) |
| **BRANCH_USER** (filial) | ●●● əsas | ○ nadir | Tələb göndərmək, gələn malı təsdiqləmək (fərqlə), filial tullantısı, filial qalığı |
| **PROCUREMENT_OFFICER** | ● təsdiq/baxış | ●●● əsas | PR → RFQ → təklif → müqayisə → PO; təchizatçı və qiymət tarixçəsi |
| **PROCUREMENT_MANAGER** | ●● təsdiqlər | ●●● əsas | PO/tullantı/sayım təsdiqi, dashboard, hesabatlar, delegasiya |
| **ADMIN** | ○ | ●●● əsas | Master data, istifadəçi/rol/icazə, approval qaydaları, bildiriş qaydaları, `inv_setting` |
| **AUDITOR** | ○ | ●●● əsas | Ledger, audit log, hesabatlar, export — **yalnız oxuma**, heç bir mutasiya endpoint-i yoxdur |

●●● əsas platforma · ●● mühüm · ● köməkçi · ○ nəzərdə tutulmayıb (bloklanmır)

**Platforma seçiminin səbəbi:** anbardar və filial işçisi ayaq üstə, bir əllə, skan edərək
işləyir — mobil. Satınalma və menecer çoxsütunlu müqayisə cədvəlləri və Excel export ilə
işləyir — veb ([ADR-013](../adr/ADR-013-web-react-mobile-flutter.md), ADR-006-nı əvəz edir).
Masaüstü admin paneli üçün DOM əsaslı React seçilib: mətn seçimi, `Ctrl+F`, çap və
brauzerin öz açıqlıq alətləri olduğu kimi işləyir.

---

## 2. Naviqasiya

### Mobil (Flutter — `mobile/apps/wms_mobile`)

Bottom navigation, 4 bölmə + kontekstual axınlar:

```
[Əsas]          gün üçün tapşırıqlar: gözləyən tələblər, gələn mal, açıq sayım
[Əməliyyatlar]  Qəbul · Məxaric · Sayım · Tullantı · Nümunə · Qaytarma
[Qalıq]         lokasiya üzrə balans + partiya axtarışı (skan ilə)
[Bildirişlər]   inbox + badge (unread-count)
```

Menecer mobildə əlavə: **Təsdiqlər** bölməsi (`listPendingApprovals`).

### Veb (React — `web/`)

Sol sidebar, rol üzrə filtrlənmiş:

```
Dashboard
Satınalma      PR · RFQ · Təkliflər · PO · Təsdiqlər · Qiymət tarixçəsi
Anbar          Qalıq · Partiyalar · Qəbullar · Məxariclər · Sayımlar · Tullantı · Nümunə · Qaytarma · Ledger
Hesabatlar     Kataloq · Exportlar
Master data    Məhsullar · Kateqoriyalar · Vahidlər · Təchizatçılar · Lokasiyalar · Məzənnələr · Səbəb kodları
İdarəetmə      İstifadəçilər · Rollar · Delegasiyalar · Approval qaydaları · Bildiriş qaydaları · Parametrlər
Audit          Audit log · Ledger yoxlaması
```

Menyu elementi `GET /identity/me` → `permissions[]` ilə filtrlənir. İcazəsi olmayan
element **göstərilmir** (deaktiv edilmir).

---

## 3. Ekranlar — Anbar (Inventory)

### 3.1. Qəbul siyahısı — `listGoodsReceipts`

| | |
|---|---|
| **Platforma** | mobil + veb |
| **İcazə** | `inv.receipt.view` |
| **Məqsəd** | Açıq və post edilmiş qəbulları görmək, yenisini başlamaq |
| **Əsas sahələr** | `docNo` · `docDate` · təchizatçı · lokasiya · `status` · `hasVariance` · sətir sayı |
| **Komponentlər** | `WmsDataTable` (mobil: kart siyahısı) · `WmsDocStatusBadge` · `WmsEmptyState` |
| **Qeyd** | Filial istifadəçisi yalnız öz lokasiyalarını görür (server filtri) |

### 3.2. Qəbul yaratma / redaktə — `createGoodsReceipt`, `postGoodsReceipt`

| | |
|---|---|
| **Platforma** | **mobil (əsas)** + veb |
| **İcazə** | `inv.receipt.create`, post üçün `inv.receipt.post` |
| **Məqsəd** | PO-dan və ya PO-suz malı qəbul etmək, partiya və son istifadə tarixini qeyd etmək |
| **Başlıq sahələri** | PO seçimi (`listOpenPurchaseOrdersForReceipt`) · təchizatçı · lokasiya · `temperatureC` · `qualityStatus` · `packagingNote` |
| **Sətir sahələri** | məhsul (skan/axtarış) · `orderedQty` (PO-dan, oxunur) · `receivedQty` · `rejectedQty` · vahid · `batchNo` · `productionDate` · `expiryDate` · `varianceNote` |
| **Komponentlər** | `WmsQtyUomInput` (hər miqdar) · `WmsTextField` (mono: `batchNo`, barkod) · `WmsSelect` · `WmsVarianceIndicator` (sətir fərqi) · `WmsAlert` (409) · `WmsDialog` (post təsdiqi) · `WmsButton` |

**Validasiyalar (SPEC-dən):**

| Şərt | Nəticə | Mənbə |
|---|---|---|
| `product.requiresBatch` → `batchNo` boş | sahə xətası, post bloklanır | SPEC §9.2 |
| `product.requiresExpiry` → `expiryDate` boş və ya keçmiş | sahə xətası | SPEC §9.2 |
| `receivedQty < ordered × (1 − under_tol)` → **`varianceNote` məcburi** | `422 VARIANCE_NOTE_REQUIRED` | SPEC §12.8 |
| `receivedQty > ordered × (1 + over_tol)` | post-da `409 APPROVAL_REQUIRED` | SPEC §12.8 |
| Qida məhsulu, təchizatçı `isApprovedFoodSupplier=false` | `422` | TOR §7 |
| Lokasiyada `FROZEN` sayım | post-da `409 LOCATION_FROZEN` → `WmsAlert` + düymələr deaktiv | SPEC §12.7 |
| Xarici valyuta, məzənnə yoxdur | post-da `409 FX_RATE_MISSING` | SPEC §12.5 |
| **Anbardara `unitPrice` sütunu göstərilmir** | sahə render edilmir | SPEC §16 |

### 3.3. Qalıq (balans) — `listBalances`, `getBalanceSummary`

| | |
|---|---|
| **Platforma** | mobil + veb |
| **İcazə** | `inv.balance.view`; maya dəyəri üçün əlavə `master.product.view_cost` |
| **Əsas sahələr** | məhsul (SKU + ad) · lokasiya · partiya · `qtyOnHand` · `qtyReserved` · `qtyAvailable` · `daysToExpiry` · `isBelowMin` |
| **Şərti sahələr** | `avgUnitCost`, `totalValue` — **yalnız icazə ilə**; icazəsiz sütun **render edilmir** |
| **Filtrlər** | lokasiya · məhsul · kateqoriya · partiya · `belowMin` · `expiringWithinDays` · `includeZero` |
| **Komponentlər** | `WmsDataTable` (`numeric` sütunlar, `permission: "master.product.view_cost"`) · `WmsBadge` (virtual lokasiya tonu) · `WmsEmptyState` |
| **Qadağa** | **Qalıq input deyil.** Heç bir düzəliş düyməsi yoxdur — dəyişiklik yalnız sənədlə ([ADR-004](../adr/ADR-004-balance-as-projection.md)) |

### 3.4. Partiyalar — `listBatches`, `changeBatchStatus`

| | |
|---|---|
| **Platforma** | mobil (skan) + veb |
| **İcazə** | `inv.batch.view`, status dəyişmək üçün `inv.batch.manage` |
| **Əsas sahələr** | `batchNo` · məhsul · `expiryDate` · `daysToExpiry` · `status` · `qtyOnHand` · təchizatçı |
| **Komponentlər** | `WmsDataTable` · `WmsBadge` (status tonu) · `WmsDialog` (status dəyişmə, səbəb kodu məcburi) |
| **Validasiya** | `EXPIRED` statusu **əl ilə geri qaytarılmır** (yalnız `ExpiryScanner` verir) → `409` |

### 3.5. Filial tələbi — `createStockRequest`, `submitStockRequest`

| | |
|---|---|
| **Platforma** | **mobil (filial)** + veb |
| **İcazə** | `inv.request.create`, `inv.request.submit` |
| **Sahələr** | `fromLocation` (mərkəzi anbar) · `toLocation` (öz filialı) · `requiredDate` · sətirlər (məhsul, miqdar, vahid, qeyd) |
| **Komponentlər** | `WmsQtyUomInput` · `WmsSelect` · `WmsDataTable` (sətirlər) · `WmsDocStatusBadge` |
| **Validasiya** | `toLocationId` istifadəçinin `locationIds` siyahısında olmalıdır → əks halda `403` |

### 3.6. Məxaric / picking — `createIssue`, `dispatchIssue`

| | |
|---|---|
| **Platforma** | **mobil (anbardar)** |
| **İcazə** | `inv.issue.create`, `inv.issue.dispatch` |
| **Sahələr** | tələb seçimi · `issueType` · mənbə/hədəf lokasiya · sətirlər: məhsul, miqdar, **partiya** |
| **Komponentlər** | **`WmsBatchPicker`** (FEFO/FIFO təklifi) · `WmsQtyUomInput` · `WmsAlert` (409) · `WmsDocStatusBadge` |

**Partiya qaydası (SPEC §12.4):** server FEFO/FIFO ilə partiya **təklif edir** və `WmsBatchPicker`
onu nişanlayır. İstifadəçi başqasını seçərsə **səbəb kodu + qeyd məcburi** olur
(`422 REASON_CODE_REQUIRED`) və audit-ə düşür. `ACTIVE` olmayan partiyalar siyahıda **görünür,
lakin seçilmir** (səbəbi yazılır). Çatmayan qalıq → `409 INSUFFICIENT_STOCK`.

### 3.7. Filial qəbulu (in-transit təsdiqi) — `confirmIssueReceipt`

| | |
|---|---|
| **Platforma** | **mobil (filial)** |
| **İcazə** | `inv.issue.confirm` |
| **Sahələr** | sətir üzrə `dispatchedQty` (oxunur) vs `receivedQty` · fərq səbəbi · fərq fotosu |
| **Komponentlər** | `WmsQtyUomInput` · **`WmsVarianceIndicator`** · `WmsDialog` (təsdiq) · foto əlavəsi |
| **Validasiya** | `receivedQty ≠ dispatchedQty` → **`reasonCodeId` + `note` məcburi**; `receivedQty > dispatchedQty` qadağandır (`422`). Fərq varsa sənəd `DISCREPANCY` statusuna keçir və çatmayan hissə `IN_TRANSIT`-də qalır |

### 3.8. Sayım — `createCount`, `freezeCount`, `submitCountLines`, `approveCount`, `postCount`

| | |
|---|---|
| **Platforma** | **mobil (sayım)** + veb (nəzarət/təsdiq) |
| **İcazə** | `inv.count.create` · `inv.count.freeze` · `inv.count.enter` · `inv.adjustment.approve` · `inv.count.post` |
| **Ekranlar** | (1) Sayım yaratma (lokasiya, tip, əhatə) · (2) **Dondurma təsdiqi** (nəticəsi izah olunur) · (3) Sayım girişi (rəf-rəf, hissə-hissə göndərilir) · (4) Fərq icmalı · (5) Təsdiq (veb) · (6) Post |
| **Sahələr** | `bookQty` (oxunur) · `countedQty` · `varianceQty` · `variancePct` · səbəb kodu · qeyd |
| **Şərti sahə** | `varianceValue` (manatla) — yalnız `master.product.view_cost` |
| **Komponentlər** | `WmsQtyUomInput` · **`WmsVarianceIndicator`** (hədd aşıldıqda «Təsdiq tələb edir», səbəb yoxdursa «Səbəb kodu yoxdur») · `WmsDataTable` · `WmsAlert` (dondurma xəbərdarlığı) · `WmsApprovalChain` (təsdiq addımları) · `WmsDialog` |

**Kritik davranış:** `freezeCount` **lokasiyanı bloklayır** — həmin lokasiyada qəbul, məxaric,
transfer, tullantı və nümunə düymələri deaktiv olur və səbəb `WmsAlert` ilə yazılır
(`409 LOCATION_FROZEN`). Sayımı aparan özü təsdiqləyə bilməz (SoD → `403`).

### 3.9. Tullantı — `createWaste`, `submitWaste`, `approveWaste`, `postWaste`

| | |
|---|---|
| **Platforma** | **mobil (fotolu)** + veb (təsdiq) |
| **İcazə** | `inv.waste.create` · `inv.waste.approve` · `inv.waste.post` |
| **Sahələr** | lokasiya · **səbəb kodu (məcburi)** · sətirlər (məhsul, partiya, miqdar) · **foto** |
| **Komponentlər** | `WmsSelect` (səbəb kodu, qrup `WASTE`) · `WmsQtyUomInput` · `WmsBatchPicker` · `WmsApprovalChain` · `WmsDialog` (destruktiv təsdiq) · foto əlavəsi |
| **Validasiya** | Səbəb kodunda `requiresPhoto=true` → ən azı bir foto **məcburi** (`422`). `requiresApproval=true` → sənəd `PENDING_APPROVAL`-a gedir; yaradan özü təsdiqləyə bilməz (`403`) |
| **Şərti sahə** | `totalValue` — yalnız `master.product.view_cost` (anbardar tullantının manat dəyərini görmür) |

### 3.10. AQTA nümunəsi — `createSample`, `postSample`

Tullantı ilə eyni struktur; `authority` (default `AQTA`), `purpose` sahələri əlavə;
approval yoxdur, birbaşa post edilir. Komponentlər eynidir.

### 3.11. Təchizatçıya qaytarma — `createReturnToVendor`, `sendReturnToVendor`, `closeReturnToVendor`

| | |
|---|---|
| **Platforma** | veb (əsas) + mobil |
| **İcazə** | `inv.rtv.create`, `inv.rtv.post` |
| **Sahələr** | təchizatçı · mənbə qəbul (`receiptId`) · səbəb kodu · sətirlər · `claimAmount` (icazəyə bağlı) · nəticə (`ACCEPTED`/`REJECTED`) |
| **Komponentlər** | `WmsDataTable` · `WmsBatchPicker` · `WmsDocStatusBadge` · `WmsDialog` |

### 3.12. Ledger (hərəkət jurnalı) — `listMovements`, `getMovementGroup`, `reverseMovementGroup`

| | |
|---|---|
| **Platforma** | **veb** (auditor, menecer, admin) |
| **İcazə** | `inv.movement.view`; storno üçün `inv.movement.reverse` |
| **Sahələr** | `postedAt` · `docType` · `docNo` · məhsul · partiya · lokasiya · **işarəli `qtyBase`** · `enteredQty`/`enteredUomId` · `conversionRate` |
| **Şərti sahələr** | `unitCost`, `currency`, `fxRate` — yalnız `master.product.view_cost` |
| **Komponentlər** | **`WmsLedgerTable`** — işarə (`+`/`−`) həmişə görünür, rəng ikinci dərəcəlidir; virtual lokasiyalar `virtual` tonlu nişanla; **cəm sıfır yoxlaması sətri həmişə göstərilir** |
| **Qadağa** | Redaktə düyməsi **yoxdur**. Yeganə düzəliş — «Storno et» (`WmsDialog`, səbəb kodu məcburi), o da **yeni sənəd yaradır** (SPEC §9.4, §12.6) |

---

## 4. Ekranlar — Satınalma (Procurement)

### 4.1. PR (tələb) — `createRequisition`, `submitRequisition`, `rejectRequisition`

| | |
|---|---|
| **Platforma** | veb (əsas), mobil (filial tələbi) |
| **İcazə** | `proc.pr.create` · `proc.pr.submit` · `proc.pr.reject` |
| **Sahələr** | tələbçi lokasiyası · `productType` · `priority` · `requiredDate` · sətirlər (məhsul, miqdar, vahid, qeyd) |
| **Kontekst sahəsi** | `currentStockQty` — tələbçi lokasiyasındakı cari qalıq (satınalmaçı üçün) |
| **Komponentlər** | `WmsDataTable` · `WmsQtyUomInput` · `WmsSelect` · `WmsDocStatusBadge` · `WmsDialog` (rədd, `comment` məcburi) |
| **Validasiya** | Bir PR bir `productType` daşıyır — qarışıq sətir `422`. Rəddə `comment` məcburi |

### 4.2. RFQ — `createRfq`, `sendRfq`, `closeRfq`

| | |
|---|---|
| **Platforma** | **veb** |
| **İcazə** | `proc.rfq.create` |
| **Sahələr** | `dueDate` · **ən azı 2 təchizatçı** · sətirlər (PR sətirlərindən seçilir) |
| **Komponentlər** | `WmsDataTable` (PR sətirlərinin seçimi) · `WmsSelect` (çoxlu təchizatçı) · `WmsDocStatusBadge` |
| **Validasiya** | `supplierIds.length < 2` → `422` (müqayisə tələbi) |

### 4.3. Təkliflərin müqayisəsi — `getRfqComparison`, `selectQuotation`

| | |
|---|---|
| **Platforma** | **veb — bu ekran mobil üçün nəzərdə tutulmayıb** (çoxsütunlu matris) |
| **İcazə** | `proc.quotation.view`, seçim üçün `proc.quotation.select` |
| **Struktur** | Sətirlər = RFQ sətirləri, sütunlar = təkliflər. Hər hüceyrədə: `unitPrice` + valyuta, **AZN-ə çevrilmiş** `unitPriceBase`, `lineTotalBase`, əvvəlki qiymətlə fərq (`diffFromPrevPct`) |
| **Nişanlar** | `isLowest` (sətir üzrə ən aşağı), `cheapestQuotationId` (ümumi ən ucuz), `selectedQuotationId` |
| **Komponentlər** | `WmsDataTable` (matris, `numeric` sütunlar) · `WmsVarianceIndicator` (qiymət fərqi) · `WmsBadge` («ən ucuz») · `WmsDialog` (seçim təsdiqi) |
| **Kritik validasiya** | **Ən ucuz təklif seçilmirsə `selectionNote` məcburidir** → `422 SELECTION_NOTE_REQUIRED`. Dialoq bu halda mətn sahəsi açır və o dolana qədər təsdiq düyməsi deaktivdir (SPEC §10) |

### 4.4. PO — `createPurchaseOrder`, `submitPurchaseOrder`, `sendPurchaseOrder`, `closePurchaseOrder`

| | |
|---|---|
| **Platforma** | **veb** |
| **İcazə** | `proc.po.create` · `proc.po.submit` · `proc.po.send` · `proc.po.close` |
| **Başlıq** | təchizatçı · valyuta · **`fxRate` (dondurulmuş, oxunur)** · çatdırılma lokasiyası · `expectedDate` · incoterms · ödəniş şərtləri |
| **Cəmlər** | `subtotal` · `vatAmount` · `totalAmount` · **`totalAmountBase` (AZN — approval limiti bununla)** |
| **Sətirlər** | məhsul · miqdar · vahid · `unitPrice` · `vatRate` · `lineTotal` · `receivedQty`/`remainingQty` |
| **Komponentlər** | `WmsDataTable` · `WmsQtyUomInput` · **`WmsApprovalChain`** (təsdiq vəziyyəti) · `WmsDocStatusBadge` · `WmsAlert` (`splitCheckWarning`) · `WmsDialog` |
| **Validasiyalar** | Məzənnə yoxdur → `409 FX_RATE_MISSING`. Uyğun approval qaydası yoxdur → `422`. Təsdiqlənməmiş PO göndərilmir → `409 APPROVAL_REQUIRED`. PR bölünməsi şübhəsi → `splitCheckWarning` bannerı |

### 4.5. Təsdiqlər (inbox) — `listPendingApprovals`, `decideApproval`

| | |
|---|---|
| **Platforma** | **veb + mobil** (menecer mobildə təsdiq verir) |
| **İcazə** | `proc.approval.view`, `proc.approval.decide` |
| **Sahələr** | sənəd tipi (PO / WASTE / COUNT_ADJUST) · `docNo` · `amountBase` · xülasə · tələbçi · **`viaDelegationFrom`** · gözləmə müddəti |
| **Komponentlər** | **`WmsApprovalChain`** (bütün addımlar, cari addım vurğulu, delegasiya açıq yazılır) · `WmsKpiCard` (gözləyən say) · `WmsDialog` (qərar; `REJECTED` üçün `comment` məcburi) · `WmsButton` (primary «Təsdiqlə», danger «Rədd et») |
| **Qeyd** | Təsdiq/rədd düymələri `WmsApprovalChain`-in **daxilində deyil** — ekran onları özü yerləşdirir |

### 4.6. Qiymət tarixçəsi — `listPriceHistory`

| | |
|---|---|
| **Platforma** | veb |
| **İcazə** | **`master.product.view_cost`** — anbardar bu ekranı ümumiyyətlə görmür |
| **Sahələr** | məhsul · təchizatçı · `priceDate` · `unitPrice` + valyuta · `unitPriceBase` · `prevPriceBase` · `diffAmount` · `diffPct` |
| **Komponentlər** | `WmsDataTable` · `WmsVarianceIndicator` (qiymət dəyişməsi) |

---

## 5. Ekranlar — Dashboard, hesabat, master data, idarəetmə

### 5.1. Dashboard — `getDashboardSummary`

| | |
|---|---|
| **Platforma** | veb (tam), mobil (qısaldılmış «Əsas» ekranı) |
| **İcazə** | `rpt.dashboard.view` |
| **KPI-lar** | gözləyən təsdiqlər · 7 gündə bitən partiyalar · min-dən aşağı məhsullar · açıq tələblər · aylıq tullantı · **anbar dəyəri (AZN)** — sonuncu yalnız `view_cost` ilə |
| **Alertlər** | `BATCH_EXPIRING` · `STOCK_BELOW_MIN` · `CERTIFICATE_EXPIRING` · `PENDING_APPROVAL` · `RECONCILIATION_FAILED` (ADMIN/AUDITOR) |
| **Komponentlər** | **`WmsKpiCard`** (pul göstəricisi icazə yoxdursa **kart render edilmir**) · `WmsAlert` · `WmsDataTable` (son hərəkətlər) |

### 5.2. Hesabatlar — `listReports`, `getReportDefinition`, `runReport`, `createExport`

| | |
|---|---|
| **Platforma** | **veb** |
| **İcazə** | `rpt.report.view`, `rpt.export.create` |
| **Axın** | Kataloq (kateqoriya üzrə) → parametr forması (`ReportDefinition.parameters`-dən **dinamik** qurulur) → nəticə cədvəli (maks. 200 sətir/səhifə) → «Excel-ə çıxar» (asinxron) |
| **Export** | `POST /exports` → `QUEUED` → poll və ya `ExportReady` bildirişi → `downloadUrl` (5 dəq) |
| **Komponentlər** | `WmsDataTable` (nəticə; `isCost` sütunları icazəyə bağlı) · `WmsSelect`/`WmsTextField` (parametrlər) · `WmsKpiCard` (cəmlər) · `WmsAlert` (uzun sorğu xəbərdarlığı) |

### 5.3. Master data ekranları

Hamısı eyni şablonda: siyahı (`WmsDataTable` + axtarış + filtr) → detal/redaktə (`WmsDialog`
və ya ayrıca səhifə) → `rowVersion` ilə saxlama.

| Ekran | İcazə | Xüsusi qaydalar |
|---|---|---|
| **Məhsullar** | `master.product.view` / `.manage` | `sku` məcburi + unikal; `baseUomId` və `sku` **sonradan dəyişmir**; ad `TRIM` edilir; sıralama `nameSortKey` (AZ əlifbası) |
| **Məhsul vahidləri** | `master.product.manage` | `factorToBase` **UPDATE edilmir** — köhnə sətir `validTo` ilə bağlanır, yenisi açılır. UI bunu «Yeni əmsal (tarixdən)» kimi göstərir, «Redaktə» kimi yox |
| **Kateqoriyalar** | `master.category.manage` | Ağac; `productType` dəyişmir |
| **Ölçü vahidləri** | `master.uom.manage` | `decimals` — göstərilən onluq sayı |
| **Təchizatçılar** | `master.supplier.view` / `.manage` | `isApprovedFoodSupplier` bayrağı; sertifikatlar + bitmə tarixi (`WmsBadge` warning/danger) |
| **Lokasiyalar** | `master.location.view` / `.manage` | Virtual lokasiyalar `virtual-location` tonu ilə; `locationType` və `isVirtual` dəyişmir |
| **Məzənnələr** | `master.currency.view` / `.manage` | **Köhnə məzənnə avtomatik götürülmür** — yoxdursa PO/qəbul bloklanır |
| **Səbəb kodları** | `master.reason.manage` | `reasonGroup` dəyişmir; `requiresPhoto`/`requiresApproval` UI davranışını dəyişir |
| **Nömrə seriyaları** | `master.sequence.view` | Yalnız oxunur; boşluqlar normaldır (izah mətni ilə) |

### 5.4. İdarəetmə

| Ekran | İcazə | Qeyd |
|---|---|---|
| **İstifadəçilər** | `iam.user.view` / `.manage` | Keycloak subject (`externalId`) bağlanması; rollar; **lokasiya girişi** (boş = hamısı) |
| **Rollar və icazələr** | `iam.role.view` / `.manage` | İcazə kataloqu modul üzrə; **`WAREHOUSE_KEEPER`-ə `master.product.view_cost` verilə bilməz** → `422` (SoD, SPEC §7.1). Kritik icazələr xəbərdarlıqla göstərilir |
| **Delegasiyalar** | `iam.delegation.view` / `.create` | Tarix aralığı, üst-üstə düşmə yoxlanılır |
| **Approval qaydaları** | `proc.approval_rule.view` / `.manage` | Sənəd tipi × məhsul tipi × AZN interval × addım × rol; intervallar üst-üstə düşməməlidir |
| **Bildiriş qaydaları** | `notif.rule.view` / `.manage` | Event → hədəf (rol/istifadəçi/lokasiya) → kanal (in-app, e-mail, push); sistem qaydaları silinmir |
| **Parametrlər** | `inv.settings.view` / `.manage` | `inv_setting` açarları (expiry günləri, tolerans faizləri, costing metodu, sayım həddi) — **hard-code yoxdur** (TOR §36) |

### 5.5. Audit (yalnız AUDITOR/ADMIN)

| Ekran | İcazə | Sahələr |
|---|---|---|
| **Audit log** | `audit.log.view` | `entityType` · `entityId` · `action` · `changes` (field/old/new) · istifadəçi · IP · vaxt |
| **Ledger yoxlaması** | `inv.movement.view` | `DoubleEntryCheck` və `BalanceReconciliation` job-larının son nəticəsi (`DashboardSummary.systemHealth`) |

---

## 6. Domen validasiyaları — bütün ekranlara aid

Bunlar **UI seçimi deyil**, spesifikasiya invariantlarıdır. UI/UX sənədi dəyişsə də qalır.

| # | Qayda | Harada görünür | Mənbə |
|---|---|---|---|
| 1 | **Qalıq heç bir ekranda input deyil** | bütün balans göstəriciləri | ADR-004 |
| 2 | **Fərq varsa izah məcburi** (`varianceNote`) | qəbul sətri | SPEC §12.8 |
| 3 | **Düzəlişin səbəbi məcburi** (`reasonCodeId`) | sayım fərqi, storno, tullantı, partiya bloku, transfer fərqi | SPEC §12.6 |
| 4 | **Ən ucuz seçilmirsə izah məcburi** (`selectionNote`) | təkliflərin müqayisəsi | SPEC §10 |
| 5 | **Təklifdən fərqli partiya → səbəb məcburi** | `WmsBatchPicker` | SPEC §12.4 |
| 6 | **Qiymət sahələri icazəyə bağlı** — sütun **render edilmir**, maskalanmır | balans, ledger, qəbul, tullantı, sayım, hesabat, KPI | SPEC §16 |
| 7 | **Dondurulmuş lokasiyada əməliyyat yoxdur** — düymə deaktiv + səbəb `WmsAlert` ilə | qəbul, məxaric, tullantı, nümunə | SPEC §12.7 |
| 8 | **Post edilmiş sənəddə «Redaktə» yoxdur** — yalnız «Storno et» (yeni sənəd) | bütün post edilən sənədlər | SPEC §9.4 |
| 9 | **Öz sənədini təsdiqləmək olmaz** (SoD) | tullantı, sayım, PO | SPEC §7.1 |
| 10 | **Mənfi qalıq qadağandır** → `409 INSUFFICIENT_STOCK` | məxaric, tullantı, nümunə, qaytarma, storno | SPEC §12.1 |
| 11 | **Bloklanmış/expired partiya ayrılmır** → `409 BATCH_BLOCKED` | məxaric, tullantı | SPEC §12.4 |
| 12 | **Məzənnə yoxdursa əməliyyat bloklanır** → `409 FX_RATE_MISSING` | PO, xarici valyutada qəbul | SPEC §12.5 |
| 13 | **`Idempotency-Key` hər POST-da** — təkrar göndərmə yeni sənəd yaratmır | bütün mutasiyalar | SPEC §13.2 |
| 14 | **`rowVersion` uyğunsuzluğu** → `409 STALE_VERSION` → «Sənəd dəyişilib, yenidən yükləyin» | bütün redaktə formaları | SPEC §13.5 |
| 15 | **Server xətasında `code` görünməlidir** (`INSUFFICIENT_STOCK` və s.) — dəstək bu kodla işləyir | `WmsAlert` | design-system README |

---

## 7. Əsas axınlar

### 7.1. Mobil — qəbul (skan ilə)

```
Əsas → «Qəbul» → PO seç (və ya «PO-suz»)
  → lokasiya (default: istifadəçinin anbarı)
  → [sətir] barkod SKAN → məhsul tapıldı
      → receivedQty (WmsQtyUomInput, base ekvivalenti altda)
      → rejectedQty (varsa)
      → batchNo + expiryDate (məhsul tələb edirsə — məcburi)
      → orderedQty ilə fərq varsa → varianceNote sahəsi AÇILIR (məcburi)
  → [təkrar] növbəti sətir
  → temperatur + qablaşdırma qeydi + foto (qaimə)
  → «Yadda saxla» (DRAFT)  |  «Post et» → WmsDialog təsdiqi
      → 409 LOCATION_FROZEN / FX_RATE_MISSING / APPROVAL_REQUIRED → WmsAlert, sənəd DRAFT qalır
      → 200 → «Qəbul edildi GR-2026-00311», balans yeniləndi
```

Skan: kamera ilə barkod → `listProducts?barcode=`. Tapılmazsa «Bu barkod məhsula bağlı deyil»
+ əl ilə axtarış. **Skan ekranı tək əllə işləməlidir** (böyük hədəf sahələri — bax §8).

### 7.2. Mobil — filial təsdiqi

```
Bildiriş «Sizə mal göndərildi IS-2026-00998» → aç
  → sətirlər: göndərilən miqdar (oxunur) | qəbul edilən (WmsQtyUomInput)
  → fərq varsa → WmsVarianceIndicator qırmızı + səbəb kodu + qeyd (MƏCBURİ) + foto
  → «Təsdiqlə» → WmsDialog
      → fərqsiz: status RECEIVED
      → fərqli:  status DISCREPANCY + anbardara bildiriş
```

### 7.3. Mobil — sayım

```
«Sayım» → aktiv sayım seç (və ya yeni yarat)
  → «Dondur» → WmsDialog: «Bu lokasiyada bütün əməliyyatlar dayandırılacaq» → təsdiq
  → sətirlər rəf-rəf: countedQuantity daxil et → hər 10-15 sətirdə avtomatik göndər
      → fərq ≠ 0 → səbəb kodu sahəsi AÇILIR (məcburi)
  → «Yoxlamaya göndər» → REVIEW
  → (menecer veb və ya mobil «Təsdiqlər»-dən təsdiqləyir)
  → «Post et» → COUNT_ADJUST yazılır, lokasiya AÇILIR
```

### 7.4. Mobil — tullantı (fotolu)

```
«Tullantı» → lokasiya → səbəb kodu (WmsSelect)
  → səbəb requiresPhoto isə: «Foto əlavə edin» bloku MƏCBURİ olur
  → sətirlər: məhsul → partiya (WmsBatchPicker, FEFO təklifi) → miqdar
  → «Təsdiqə göndər» → PENDING_APPROVAL (və ya requiresApproval=false → APPROVED)
  → təsdiqdən sonra «Post et» → V_WASTE-ə yazılır
```

### 7.5. Veb — PR → RFQ → müqayisə → PO → təsdiq

```
PR siyahısı → «Yeni PR» → sətirlər (cari qalıq kontekst kimi görünür) → «Göndər»
  → satınalmaçı: PR-ları seç → «RFQ yarat» → ≥2 təchizatçı → «Göndər»
  → təkliflər daxil edilir (PDF əlavəsi ilə)
  → «Müqayisə» ekranı: matris, ən ucuz nişanlanıb
      → başqasını seç → selectionNote MƏCBURİ → «Seç»
  → «PO yarat» (seçilmiş təklifdən) → fxRate dondurulur → «Təsdiqə göndər»
  → menecer «Təsdiqlər» → WmsApprovalChain → «Təsdiqlə»
      → çox addımlı qayda varsa növbəti addıma keçir
      → delegasiya varsa əvəzedici də görür
  → «Təchizatçıya göndər» → SENT_TO_SUPPLIER
  → anbardar mobildə həmin PO-nu qəbul ekranında görür (qiymətsiz)
```

### 7.6. Veb — dashboard və hesabat

```
Dashboard → KPI kartı «7 gündə bitən partiyalar: 34» → klik
  → Partiyalar ekranı, expiringWithinDays=7 filtri ilə açılır
Hesabatlar → kataloq → «Tullantı icmalı» → parametrlər (dövr, lokasiya)
  → nəticə cədvəli → «Excel-ə çıxar» → bildiriş «Hazırdır» → yüklə
```

---

## 8. Mobil üçün açıq məsələlər (offline, skan, toxunma)

Bunlar dizayn sistemində **həll olunmayıb** və qərar tələb edir.

### Offline — açıq sual

Anbar və soyuducu otaqlarda şəbəkə zəif ola bilər. Üç variant:

| Variant | Əhatə | Mürəkkəblik | Risk |
|---|---|---|---|
| **(a) Offline yoxdur** | Şəbəkə yoxdursa əməliyyat mümkün deyil, aydın mesaj | minimal | Anbardar işləyə bilmir |
| **(b) Yalnız oxuma keşi** | Məhsul, lokasiya, qalıq snapshot-u keşlənir; yazma onlayn tələb edir | orta | Köhnə qalıq göstərilə bilər — **vaxt damğası göstərilməlidir** |
| **(c) Tam offline növbə** | Sənədlər lokal saxlanılır, şəbəkə qayıdanda `Idempotency-Key` ilə göndərilir | yüksək | **Balans invariantları ilə ziddiyyət**: `INSUFFICIENT_STOCK`, `LOCATION_FROZEN`, FEFO təklifi yalnız serverdə yoxlanır — offline yaradılmış sənəd sonradan rədd edilə bilər |

**Tövsiyə:** (b) ilə başlamaq. (c) seçilərsə, konflikt həlli ekranı («Bu sənədlər göndərilə
bilmədi, səbəb: …») ayrıca layihələndirilməlidir. `Idempotency-Key` artıq hər POST-da
məcburi olduğu üçün təkrar göndərmə təhlükəsizdir — bu, (c) üçün texniki əsas var deməkdir,
lakin domen tərəfi həll olunmayıb.

### Barkod skanı

- Hansı kitabxana (`mobile_scanner` vs platform channel), hansı formatlar (EAN-13, Code-128, QR).
- Ardıcıl skan rejimi: hər skandan sonra forma sıfırlanırmı, yoxsa sətir siyahısına əlavə olunur?
- Skan səsi/vibrasiya — anbarda səs eşidilmir, **haptic** daha uyğundur.
- Barkodu olmayan məhsul üçün ehtiyat axın (SKU ilə axtarış) hər skan ekranında olmalıdır.

### Toxunma hədəfləri və layout

Dizayn sistemi veb ölçüləri verir (`WmsButton` md = 34px hündürlük). **Mobil üçün minimum
44×44 pt toxunma hədəfi** lazımdır — bu, `wms_design_system`-də mobil variant kimi əlavə
edilməlidir (komponentin özündə `size: "touch"`), ekran-ekran padding ilə deyil.
Həmçinin: bir əllə çatan zona (ekranın alt 2/3-ü), əsas əməliyyat düyməsinin alt sticky
panel-də olması, əlcəkli barmaq üçün sahələr arası məsafə.

### Digər açıq mövzular

- **Çap/PDF şablonları:** PO-nun təchizatçıya göndərilən PDF-i, qəbul aktı, sayım cədvəli,
  tullantı aktı — layout, loqo, imza sahələri (`docs/design-system/` bunları əhatə etmir).
- **Onboarding:** ilk giriş, lokasiya seçimi, icazə izahı; anbardar üçün sadə təlim axını.
- **Boş məlumat halı:** sistem yeni qurulduqda (məhsul yoxdur, qalıq yoxdur) hansı ardıcıllıqla
  doldurulmalıdır — Faza 0 data migrasiyası ilə əlaqəli ([SPEC §19](../SPEC-Satinalma-Anbar-Platformasi.md#faza-0--data-migration-hazırlığı-24-həftə)).
- **Bildiriş dərinliyi:** push açılanda hansı ekran açılır (`Notification.link`), tətbiq bağlıdırsa
  deep link davranışı.
- **Filial istehlakı ekranı:** [SPEC §20.1](../SPEC-Satinalma-Anbar-Platformasi.md#201--filial-istehlakı-modeli--bloklayıcı)
  bloklayıcı açıq qərardır — variant (b) seçilərsə «Günlük istehlak» forması əlavə olunacaq.

---

## 9. Dizayn sistemi nə verir, nə vermir

**Verir** (əl ilə həll etməyə ehtiyac yoxdur) — [`docs/design-system/`](../design-system/README.md):

- 28 rəng tokeni (işıqlı + tünd), 11 mətn stili, məsafə/radius/kölgə/şəffaflıq şkalası;
- Azərbaycan dili qaydaları (böyük hərf qadağası, vergül onluq ayırıcısı, `1 284,5000` formatı,
  U+2212 mənfi işarəsi, `dd.MM.yyyy`, `name_sort_key` sıralaması);
- 16 komponent və onların davranış qaydaları (`WmsDataTable`, `WmsQtyUomInput`, `WmsBatchPicker`,
  `WmsDocStatusBadge`, `WmsLedgerTable`, `WmsVarianceIndicator`, `WmsApprovalChain`, `WmsKpiCard`,
  `WmsAlert`, `WmsDialog`, `WmsButton`, `WmsBadge`, `WmsField`, `WmsTextField`, `WmsSelect`,
  `WmsEmptyState`);
- ikonoqrafiya qaydası (konturlu, 1.5px, 16px şəbəkə, `currentColor`, `aria-label`);
- boş və xəta vəziyyətləri (səbəb + növbəti addım; `code` mütləq görünür);
- əlçatanlıq (kontrast 4.5:1 / 3:1, fokus halqası, `prefers-reduced-motion`, real `table` markup);
- React tətbiqi komponentləri **doğma formatında** işlədir (`bundle.css` + tipli ESM modulları);
- Flutter-ə (mobil) köçürmə təlimatı ([FLUTTER-MAPPING.md](../design-system/FLUTTER-MAPPING.md)).

**Vermir** (bu sənədin §8-i və gələcək UI/UX sənədi həll etməlidir):

- ekran-spesifik mobil layout və toxunma hədəfləri (44×44 pt);
- offline davranış və konflikt həlli;
- barkod skan axını və cihaz inteqrasiyası;
- çap/PDF/Excel şablonlarının vizual dizaynı;
- onboarding və boş sistem ssenarisi;
- illüstrasiya/marketinq qrafikası (sistem yalnız interfeys üçündür).
