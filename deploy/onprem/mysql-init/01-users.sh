#!/bin/bash
# On-prem variant of deploy/mysql/init/01-users.sql: identical users/grants, but the
# passwords come from the container environment (docker-compose.onprem.yml -> .env).
# Picked up by the official mysql image entrypoint on first start (empty data volume).
#
# WHY THE run_sql INDIRECTION
# The entrypoint handles a *.sh init file two different ways:
#     if [ -x "$f" ]; then "$f"   # separate process
#     else . "$f"                 # sourced into the entrypoint shell
# `docker_process_sql` is a FUNCTION of that entrypoint, so it only exists in the second
# case. Which branch is taken is not under our control: on a Linux host a 0644 bind mount
# is sourced, but on Docker Desktop (macOS) `[ -x ]` answers true for the very same 0644
# file and the entrypoint executes it - which used to die with
#     /docker-entrypoint-initdb.d/01-users.sh: /bin/bash: bad interpreter: Permission denied
# leaving the `wms` and `keycloak` databases and every user uncreated, and the whole
# on-prem stack unable to start. The file is therefore mode 0755 (executable in both
# worlds) and falls back to the mysql client over the init socket when it is executed.
#
# During init the temporary server listens on a unix socket only (--skip-networking),
# so the fallback must use --protocol=socket.

_wms_init_users() (
  set -euo pipefail

  : "${WMS_APP_PASSWORD:?WMS_APP_PASSWORD missing}"
  : "${WMS_MIGRATOR_PASSWORD:?WMS_MIGRATOR_PASSWORD missing}"
  : "${WMS_REPORTING_PASSWORD:?WMS_REPORTING_PASSWORD missing}"
  : "${KEYCLOAK_DB_PASSWORD:?KEYCLOAK_DB_PASSWORD missing}"

  run_sql() {
    if declare -F docker_process_sql >/dev/null 2>&1; then
      docker_process_sql                      # sourced by the entrypoint
      return
    fi
    local sock=""
    for candidate in /var/run/mysqld/mysqld.sock /var/lib/mysql/mysql.sock /tmp/mysql.sock; do
      if [ -S "$candidate" ]; then sock="$candidate"; break; fi
    done
    if [ -z "$sock" ]; then
      echo "[01-users.sh] no mysqld socket found - cannot create users" >&2
      return 1
    fi
    MYSQL_PWD="${MYSQL_ROOT_PASSWORD:-}" mysql --protocol=socket -S "$sock" -uroot
  }

  run_sql <<-EOSQL
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
)

_wms_init_users
