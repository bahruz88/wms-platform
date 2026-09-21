Məxaric, transfer, tullantı və nümunə sənədlərində partiya seçimi. Sistemin FEFO/FIFO təklifini nişanlayır, expiry vəziyyətini göstərir və təklifdən kənar seçimdə səbəb tələbini üzə çıxarır.

## Nəyi siz verirsiniz

`batches` (`inv_batch` + hər partiyanın mövcud qalığı: `id`, `batchNo`, `expiryDate`, `receivedAt`, `available`, `status`), `strategy` (`master_product.issue_strategy`), `value` / `onChange`, `requiredQty`, `uom`, `decimals`. Expiry hədləri `inv_setting`-dən: `warningDays`, `criticalDays`.

## Qaydalar

- **Təklif görünür olmalıdır.** Strategiyaya görə birinci gələn partiya «FEFO təklifi» nişanı alır. Sistem seçimi arxada etsə, istifadəçi niyə o partiyanın gəldiyini bilməz.
- **Kənar seçim səssiz qalmır.** İstifadəçi təklifdən başqasını seçəndə komponent xəbərdarlıq göstərir; formada `reason_code_id` və `note` sahələrini məcburi et. Seçim audit jurnalına düşür.
- `ACTIVE` olmayan partiyalar (`BLOCKED`, `EXPIRED`, `QUARANTINE`) siyahıda qalır, amma **seçilə bilmir** və status nişanı ilə göstərilir. Gizlətmə: anbardar vaxtı keçmiş 42 ədədin harada olduğunu görməlidir.
- Expiry siqnalı iki pillədir: `criticalDays` (defolt 7) → `danger`, `warningDays` (defolt 30) → `warning`. Vaxtı keçmiş partiya üçün «N gün keçib» yazılır.
- `requiredQty` tələb olunan miqdardan az qalığı olan partiyanı gizlətmir — qismən ayırma normal haldır; bir partiya çatmırsa sənəddə ikinci sətir açılır.
- Sıralama: əvvəl `ACTIVE`, sonra `QUARANTINE`, `BLOCKED`, `EXPIRED`; hər qrup daxilində expiry tarixinə görə.
