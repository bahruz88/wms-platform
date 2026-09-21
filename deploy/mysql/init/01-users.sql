-- Executed once by the official mysql image on first start (empty data volume).
-- Dev credentials are fixed by docs/CONVENTIONS.md. On-prem creates the same users
-- from environment variables: deploy/onprem/mysql-init/01-users.sh.

CREATE DATABASE IF NOT EXISTS `wms`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

-- ---------------------------------------------------------------------------
-- wms_app: the running API / worker. Database-level SELECT + INSERT only.
-- UPDATE / DELETE are granted table-by-table by wms_ops.apply_ledger_grants()
-- (02-ledger-grants.sql) so that the append-only ledger tables
-- inv_movement and common_audit_log NEVER receive them (SPEC §9.4, §16).
-- ---------------------------------------------------------------------------
CREATE USER IF NOT EXISTS 'wms_app'@'%' IDENTIFIED BY 'wms_app';
GRANT SELECT, INSERT ON `wms`.* TO 'wms_app'@'%';

-- ---------------------------------------------------------------------------
-- wms_migrator: owns the schema (EF Core migrations per module, Hangfire schema).
-- Used ONLY by the Wms.Host.Migrator job (SPEC §18.3), never by a running host.
-- ---------------------------------------------------------------------------
CREATE USER IF NOT EXISTS 'wms_migrator'@'%' IDENTIFIED BY 'wms_migrator';
GRANT ALL PRIVILEGES ON `wms`.* TO 'wms_migrator'@'%';

-- ---------------------------------------------------------------------------
-- wms_reporting: read-only (Dapper report queries, BI tools, auditors).
-- ---------------------------------------------------------------------------
CREATE USER IF NOT EXISTS 'wms_reporting'@'%' IDENTIFIED BY 'wms_reporting';
GRANT SELECT, SHOW VIEW ON `wms`.* TO 'wms_reporting'@'%';

FLUSH PRIVILEGES;
