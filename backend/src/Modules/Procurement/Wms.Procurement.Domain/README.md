# Wms.Procurement.Domain

Şema prefiksi: `proc_`. İcazəli asılılıqlar: `Wms.MasterData.Contracts`, `Wms.Inventory.Contracts` (SPEC §5).
Kontrakt: `contracts/openapi/procurement.v1.yaml` — 36 əməliyyat, marşrut prefiksi `/api/v1/procurement`.

## Sahib olduğu cədvəllər (SPEC §10)

| Entity | Cədvəl | Status |
|---|---|---|
| `Requisition` + `RequisitionLine` | `proc_requisition`, `proc_requisition_line` | hazır (DRAFT → SUBMITTED → IN_PROCUREMENT → CONVERTED_TO_PO; `converted_qty` qismən çevrilməni izləyir, §12.8) |
| `Rfq` + `RfqLine` + `RfqSupplier` | `proc_rfq`, `proc_rfq_line`, `proc_rfq_supplier` | hazır (ən azı iki təchizatçı; DRAFT → SENT → CLOSED) |
| `Quotation` + `QuotationLine` | `proc_quotation`, `proc_quotation_line` | hazır (ən ucuz seçilmədikdə `selection_note` MƏCBURİ) |
| `PurchaseOrder` + `PurchaseOrderLine` | `proc_purchase_order`, `proc_purchase_order_line` | hazır (`total_amount_base` approval limiti ilə yoxlanılır) |
| `ApprovalRule` / `ApprovalInstance` / `ApprovalStep` | `proc_approval_rule`, `proc_approval_instance`, `proc_approval_step` | hazır: `ApprovalRuleSelector` sənəd tipi, məhsul tipi və AZN intervalına görə zənciri seçir (§17.1) |
| `PriceHistoryEntry` | `proc_price_history` | hazır (TOR §25, `PriceChanged` event) |
| `SplitCheckLog` | `proc_split_check_log` | hazır (PR bölünməsinə qarşı SoD nəzarəti) |

`proc_rfq_line` və `proc_rfq_supplier` SPEC §10 DDL-ində yoxdur: müqayisə matrisi (`getRfqComparison`)
onlarsız qurula bilmir və `procurement.v1.yaml` onları modelləşdirir.

Kontrakt tələb etdiyi üçün `proc_purchase_order`-a əlavə sütunlar gəldi: `product_type` (approval
qaydası onunla seçilir), `payment_terms`, `note`, `quotation_id`, `split_check_warning`,
`reject_comment`. `proc_requisition`-a `reject_comment`, `proc_approval_instance`-ə `doc_no`,
`amount_base`, `requested_by`, `proc_approval_step`-ə `approver_role_id` / `approver_role_code`.

## Qaydalar

- PR avtomatik PO-ya çevrilmir (TOR §9); bir PO bir neçə PR sətrindən yığıla bilər.
- `fx_rate` PO tarixindəki `master_currency_rate`-dən dondurulur; `total_amount_base` approval limiti üçün AZN-dədir.
  Məzənnə yoxdursa sənəd bloklanır — `409 FX_RATE_MISSING` (§12.5), heç vaxt köhnə məzənnəyə qayıtmır.
- Bir PO bir `productType` daşıyır; qida üçün təchizatçı `isApprovedFoodSupplier` olmalıdır.
- `lineTotal` ƏDV **daxil**dir (`qty × unitPrice × (1 + vatRate/100)`), başlıqdakı `subtotal` isə ƏDV-siz cəmdir.
- Sənədi yaradan onu təsdiqləyə bilməz (`403 SELF_APPROVAL_FORBIDDEN`, §12.6).

## Domen xidmətləri

| Xidmət | Nə edir |
|---|---|
| `ApprovalRuleSelector` | `(docType, productType, amountBase)` üzrə addım zəncirini seçir; eyni addımda konkret məhsul tipi `ANY`-ni üstələyir |
| `ApprovalAuthorization` | Addımı kim qərarlandıra bilər: rol sahibi, yaxud ondan qüvvədə olan delegasiya alan istifadəçi; `delegated_from_user_id` yazılır |
| `QuotationRanking` | Ən ucuz təklif (`total_amount_base`) və `SELECTION_NOTE_REQUIRED` qaydası |
| `SplitCheckWindow` | Pəncərədəki kumulyativ məbləğ tək sifarişdən daha uzun approval zənciri tələb edirsə siqnal verir |

## Açıq nöqtə — delegasiya mənbəyi

`IApprovalDirectory` (Application qatında) rol üzvlüyünü və qüvvədə olan `iam_delegation` sətirlərini
verən portdur. Procurement SPEC §5-ə görə `Wms.Identity.Contracts`-a istinad edə bilmir, ona görə
standart adapter (`ClaimsApprovalDirectory`) yalnız cari tokenin rollarını bilir və delegasiya
qaytarmır. Identity tərəfli adapter hazır olanda host onu `IApprovalDirectory` kimi qeyd etməlidir —
`TryAddScoped` sayəsində standart adapter avtomatik kənarlaşır. Delegasiya məntiqinin özü burada
tam işləyir və unit + integration testləri ilə örtülüb.
