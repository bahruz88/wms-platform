#!/usr/bin/env bash
# db-ledger-grants.sh - (re)apply the append-only ledger protection after migrations:
#   * (re)creates wms_ops.apply_ledger_grants()   deploy/mysql/init/02-ledger-grants.sql
#   * CALLs it                                     deploy/mysql/post-migrate/ledger-grants.sql
# Result: wms_app has SELECT+INSERT on wms.*, UPDATE+DELETE on every table EXCEPT
# inv_movement and common_audit_log (SPEC §9.4, §16). Runs as MySQL root inside the container.
#
#   scripts/db-ledger-grants.sh                                dev stack
#   scripts/db-ledger-grants.sh -f docker-compose.onprem.yml   on-prem stack
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"
require docker
parse_compose_file_arg "$@"; set -- ${REMAINING_ARGS[@]+"${REMAINING_ARGS[@]}"}
load_env

SQL_INIT="$DEPLOY_DIR/mysql/init/02-ledger-grants.sql"
SQL_POST="$DEPLOY_DIR/mysql/post-migrate/ledger-grants.sql"

if ! compose ps --status running --services 2>/dev/null | grep -qx mysql; then
  fail "mysql container is not running (scripts/dev-up.sh)"; exit 1
fi

cat "$SQL_INIT" "$SQL_POST" \
  | compose exec -T mysql sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" exec mysql -uroot --table'
ok "ledger grants applied (inv_movement / common_audit_log: SELECT+INSERT only for wms_app)"
