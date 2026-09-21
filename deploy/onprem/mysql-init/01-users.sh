#!/bin/bash
# On-prem variant of deploy/mysql/init/01-users.sql: identical users/grants, but the
# passwords come from the container environment (docker-compose.onprem.yml -> .env).
# Sourced by the official mysql image entrypoint on first start (empty data volume);
# `docker_process_sql` is provided by that entrypoint.
set -euo pipefail

: "${WMS_APP_PASSWORD:?WMS_APP_PASSWORD missing}"
: "${WMS_MIGRATOR_PASSWORD:?WMS_MIGRATOR_PASSWORD missing}"
: "${WMS_REPORTING_PASSWORD:?WMS_REPORTING_PASSWORD missing}"
: "${KEYCLOAK_DB_PASSWORD:?KEYCLOAK_DB_PASSWORD missing}"

docker_process_sql <<-EOSQL
	CREATE DATABASE IF NOT EXISTS \`wms\` CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

	-- wms_app: DML only; UPDATE/DELETE per table via wms_ops.apply_ledger_grants() (02-ledger-grants.sql)
	CREATE USER IF NOT EXISTS 'wms_app'@'%' IDENTIFIED BY '${WMS_APP_PASSWORD}';
	GRANT SELECT, INSERT ON \`wms\`.* TO 'wms_app'@'%';

	-- wms_migrator: schema owner (EF Core migrations, Hangfire schema) - migrator job only
	CREATE USER IF NOT EXISTS 'wms_migrator'@'%' IDENTIFIED BY '${WMS_MIGRATOR_PASSWORD}';
	GRANT ALL PRIVILEGES ON \`wms\`.* TO 'wms_migrator'@'%';

	-- wms_reporting: read-only
	CREATE USER IF NOT EXISTS 'wms_reporting'@'%' IDENTIFIED BY '${WMS_REPORTING_PASSWORD}';
	GRANT SELECT, SHOW VIEW ON \`wms\`.* TO 'wms_reporting'@'%';

	-- keycloak: its own database (Keycloak prod mode, KC_DB=mysql)
	CREATE DATABASE IF NOT EXISTS \`keycloak\` CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
	CREATE USER IF NOT EXISTS 'keycloak'@'%' IDENTIFIED BY '${KEYCLOAK_DB_PASSWORD}';
	GRANT ALL PRIVILEGES ON \`keycloak\`.* TO 'keycloak'@'%';

	FLUSH PRIVILEGES;
EOSQL
echo "[01-users.sh] wms / keycloak databases and users created"
