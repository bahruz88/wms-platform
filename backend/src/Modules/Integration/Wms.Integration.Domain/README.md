# Wms.Integration.Domain

Şema prefiksi: `intg_`. Yalnız `*.Contracts` görür (SPEC §5) — 1C adapteri və outbox consumer-i.

## Sahib olduğu cədvəllər

| Entity | Cədvəl | Qeyd |
|---|---|---|
| `IntegrationEndpoint` | `intg_endpoint` | xarici sistem (1C) ünvanı və aktivlik vəziyyəti |
| `OutboundMessage` | `intg_outbound_message` | xarici sistemə göndərilən mesaj, `attempt_count`/`last_error`, `event_id` üzrə dedup (SPEC §14.1) |
| `SyncCursor` | `intg_sync_cursor` | master data sinxronizasiyasının son nöqtəsi (Faza 4) |

Consumer-lər **idempotent** olmalıdır: `uq_intg_event` unikal indeksi eyni `event_id`-nin təkrar emalını bloklayır.
Açıq qərar (SPEC §20.2): 1C-də master data sahibliyi təyin olunmayıb — sinxronizasiya istiqaməti bundan asılıdır.
