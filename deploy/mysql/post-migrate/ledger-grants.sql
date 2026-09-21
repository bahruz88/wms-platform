-- Run as root AFTER every schema migration (never from the application):
--   scripts/db-ledger-grants.sh            (docker compose dev / on-prem)
--   deploy/k8s/base/job-migrator.yaml      (Kubernetes: container "ledger-grants")
--
-- Requires the procedure defined in deploy/mysql/init/02-ledger-grants.sql
-- (db-ledger-grants.sh re-applies that file first, so this also works on an
-- externally managed MySQL that was not initialised from deploy/mysql/init).
CALL `wms_ops`.`apply_ledger_grants`();
SHOW GRANTS FOR 'wms_app'@'%';
