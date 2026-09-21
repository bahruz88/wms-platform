# Wms.Documents.Domain

Şema prefiksi: `doc_`. Başqa moduldan asılılığı yoxdur (SPEC §5).

## Sahib olduğu cədvəllər

| Entity | Cədvəl | Qeyd |
|---|---|---|
| `Attachment` | `common_attachment` (SPEC §11) — modul ona `doc_` prefiksi ilə YOX, ortaq adla sahib çıxır | metadata; fayl özü MinIO-dadır, MySQL BLOB **qadağandır** (SPEC §3) |
| `AttachmentPolicy` | — (kod, cədvəl deyil) | maksimum 25 MB/fayl, icazəli tiplər PDF/JPEG/PNG/XLSX/DOCX (SPEC §11) |

## Yükləmə axını (presign → PUT → complete)

Fayl heç vaxt API-dən keçmir. `POST /attachments/presign` sətri **PENDING** statusunda yaradır və MinIO üçün
presigned `PUT` URL verir; client faylı birbaşa MinIO-ya yükləyir; `POST /attachments/{id}/complete` isə
obyektin **həqiqi** ölçüsünü, content type-ını, SHA-256-sını və ClamAV skanını yoxlayıb sətri **READY** edir.
Yalnız READY sətir `listAttachments` / `getAttachment` cavabında görünür.

`checksum_sha256` complete anında MinIO-dakı baytlardan hesablanır (MinIO `ETag` tək hissəli yükləmədə
yalnız MD5-dir, ona görə kifayət etmir) və client-in göndərdiyi dəyərlə tutuşdurulur.

### SPEC §11 DDL-indən kənarlaşmalar

| Sütun | Səbəb |
|---|---|
| `status ENUM('PENDING','SCANNING','READY','REJECTED') NOT NULL` | DDL-də yoxdur; baytlar API-dən kənarda gəldiyi üçün sətir yoxlanılmadan görünə bilməz |
| `scan_result VARCHAR(200) NULL` | ClamAV nəticəsi: `CLEAN`, `SKIPPED`, `INFECTED:<signature>` |
| `entity_id = 0` | Kontrakt `entityId: null` (sənəd hələ yaradılmayıb) deyir, DDL isə sütunu NOT NULL saxlayır — sıfır sentinel-dir (`Attachment.UnassignedEntityId`) |
| `checksum_sha256 = ''` | PENDING sətirdə hələ checksum yoxdur; sütun SPEC-dəki kimi `CHAR(64) NOT NULL` qalır |

Miqrasiya: `20260922_Documents_AttachmentUpload`.

## Obyekt açarı

`{tenantId}/{entityType}/{entityId|unassigned}/{guid}/{təmizlənmiş fayl adı}` — həmişə serverdə qurulur,
**heç vaxt** client-dən qəbul edilmir (`AttachmentStorageKey`). Fayl adı `[A-Za-z0-9._-]`-ə endirilir,
ona görə `../` və qovluq ayırıcıları prefiksdən çıxa bilmir.

Virus skanı (ClamAV INSTREAM) tətbiq konfiqurasiyasındadır: `Antivirus__Enabled` (dev-də `false`),
`Antivirus__Host`, `Antivirus__Port`, `Antivirus__TimeoutSeconds`. Skaner əlçatmazdırsa axın **fail closed**
işləyir: `503 VIRUS_SCAN_UNAVAILABLE`, sətir PENDING qalır.

Sahibsiz obyektlərin təmizlənməsi: `AttachmentOrphanCleaner` həftəlik job (SPEC §15) — hələ yazılmayıb.
