# Wms.Documents.Domain

Şema prefiksi: `doc_`. Başqa moduldan asılılığı yoxdur (SPEC §5).

## Sahib olduğu cədvəllər

| Entity | Cədvəl | Qeyd |
|---|---|---|
| `Attachment` | `common_attachment` (SPEC §11) — modul ona `doc_` prefiksi ilə YOX, ortaq adla sahib çıxır | metadata; fayl özü MinIO-dadır, MySQL BLOB **qadağandır** (SPEC §3) |
| `AttachmentPolicy` | `doc_attachment_policy` | maksimum 25 MB/fayl, icazəli tiplər PDF/JPEG/PNG/XLSX/DOCX (SPEC §11) |

`checksum_sha256` yükləmə zamanı hesablanır; virus skanı (ClamAV) tətbiq konfiqurasiyasındadır.
Sahibsiz obyektlərin təmizlənməsi: `AttachmentOrphanCleaner` həftəlik job (SPEC §15).
