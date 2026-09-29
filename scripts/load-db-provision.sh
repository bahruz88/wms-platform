#!/usr/bin/env bash
# load-db-provision.sh — builds an isolated database for the SPEC §17.3 load test.
#
#   scripts/load-db-provision.sh              # create/refresh wms_load from wms
#   scripts/load-db-provision.sh --drop       # remove it again
#   WMS_LOAD_DB=wms_perf scripts/load-db-provision.sh
#
# Why a separate database
# -----------------------
# The criterion needs 1 000 000 existing ledger rows. The ledger is append-only (ADR-003), so rows
# written into the working database could never be taken out again — every later query and every e2e
# run would carry them. This clones the structure and the reference data into `wms_load`, leaves the
# documents and the ledger empty, and grants the app the same rights it has on `wms`, including the
# one exception that makes the ledger append-only: no UPDATE or DELETE on `inv_movement`.
set -euo pipefail

CONTAINER="${WMS_MYSQL_CONTAINER:-wms-mysql-1}"
SOURCE_DB="${WMS_DB_NAME:-wms}"
LOAD_DB="${WMS_LOAD_DB:-wms_load}"
DROP=0

[ "${1:-}" = "--drop" ] && DROP=1
[ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ] && { sed -n '2,18p' "$0"; exit 0; }

command -v docker >/dev/null || { echo "error: docker is required" >&2; exit 1; }
docker ps --format '{{.Names}}' | grep -qx "$CONTAINER" || {
  echo "error: $CONTAINER is not running (scripts/dev-up.sh)" >&2; exit 1; }

# Root password stays inside the container's environment; nothing is echoed.
mysql_root() { docker exec -i -e "P=${WMS_DB_PASSWORD:-wms_root}" "$CONTAINER" \
  sh -c 'mysql -uroot -p"$P" "$@"' -- "$@" 2>&1 | grep -v 'Using a password' || true; }

if [ "$DROP" = 1 ]; then
  echo "dropping $LOAD_DB"
  echo "DROP DATABASE IF EXISTS \`$LOAD_DB\`;" | mysql_root
  echo "done"
  exit 0
fi

echo "provisioning $LOAD_DB from $SOURCE_DB"

# 1. structure only — no rows, so the ledger and every document table start empty
echo "  · structure"
echo "DROP DATABASE IF EXISTS \`$LOAD_DB\`; CREATE DATABASE \`$LOAD_DB\` CHARACTER SET utf8mb4;" | mysql_root
# `--set-gtid-purged=OFF`: the dump would otherwise carry a SET @@GLOBAL.GTID_PURGED that a live
# server refuses. `--single-transaction` keeps the structure consistent without locking the working
# database while the dev stack is using it.
STRUCTURE=$(docker exec -e "P=${WMS_DB_PASSWORD:-wms_root}" "$CONTAINER" sh -c \
  "mysqldump -uroot -p\"\$P\" --no-data --routines --skip-add-locks --skip-comments \
   --set-gtid-purged=OFF --single-transaction $SOURCE_DB" 2>/dev/null)
if [ -z "$STRUCTURE" ]; then
  echo "error: mysqldump produced nothing — cannot clone the structure" >&2
  exit 1
fi
printf '%s\n' "$STRUCTURE" | mysql_root "$LOAD_DB"

CREATED=$(docker exec -e "P=${WMS_DB_PASSWORD:-wms_root}" "$CONTAINER" sh -c "mysql -uroot -p\"\$P\" -N -B -e \
  \"SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$LOAD_DB' AND table_type='BASE TABLE';\"" \
  2>/dev/null | tr -d '[:space:]')
if [ "${CREATED:-0}" -lt 50 ]; then
  echo "error: only ${CREATED:-0} tables reached $LOAD_DB — the clone did not complete" >&2
  exit 1
fi
echo "    $CREATED tables"

# 2. the data a request cannot be served without: the tenant, its users and roles, the catalogues,
#    the settings and the sequences. Documents and the ledger stay empty on purpose.
REFERENCE_TABLES="
iam_tenant iam_permission iam_role iam_role_permission iam_user iam_user_role iam_user_location
master_uom master_product_category master_product master_product_uom master_supplier
master_supplier_certificate master_location master_reason_code master_currency_rate
master_number_sequence inv_setting notif_rule proc_approval_rule rpt_report_definition
cons_menu_item cons_recipe cons_recipe_line
__ef_migrations_common __ef_migrations_identity __ef_migrations_masterdata
__ef_migrations_inventory __ef_migrations_procurement __ef_migrations_documents
__ef_migrations_consumption __ef_migrations_notification __ef_migrations_reporting
__ef_migrations_integration
"
echo "  · reference data"
for table in $REFERENCE_TABLES; do
  echo "INSERT INTO \`$LOAD_DB\`.\`$table\` SELECT * FROM \`$SOURCE_DB\`.\`$table\`;" | mysql_root
done

# 3. the same grant model as `wms`: SELECT+INSERT everywhere, UPDATE+DELETE everywhere except the
#    two append-only tables. Generated per table because MySQL has no "all but these" grant.
echo "  · grants (inv_movement and common_audit_log stay append-only)"
{
  echo "GRANT SELECT, INSERT ON \`$LOAD_DB\`.* TO 'wms_app'@'%';"
  echo "GRANT ALL PRIVILEGES ON \`$LOAD_DB\`.* TO 'wms_migrator'@'%';"
  echo "GRANT SELECT ON \`$LOAD_DB\`.* TO 'wms_reporting'@'%';"
} | mysql_root

docker exec -e "P=${WMS_DB_PASSWORD:-wms_root}" "$CONTAINER" sh -c "mysql -uroot -p\"\$P\" -N -B -e \"
  SELECT CONCAT('GRANT UPDATE, DELETE ON \\\`$LOAD_DB\\\`.\\\`', table_name, '\\\` TO ''wms_app''@''%'';')
    FROM information_schema.tables
   WHERE table_schema = '$LOAD_DB'
     AND table_type = 'BASE TABLE'
     AND table_name NOT IN ('inv_movement', 'common_audit_log');\"" 2>/dev/null \
  | mysql_root

echo "FLUSH PRIVILEGES;" | mysql_root

echo "  · verifying the append-only exception held"
LEAK=$(docker exec -e "P=${WMS_DB_PASSWORD:-wms_root}" "$CONTAINER" sh -c "mysql -uroot -p\"\$P\" -N -B -e \"
  SELECT COUNT(*) FROM information_schema.table_privileges
   WHERE grantee = '''wms_app''@''%''' AND table_schema = '$LOAD_DB'
     AND table_name = 'inv_movement' AND privilege_type IN ('UPDATE', 'DELETE');\"" 2>/dev/null | tr -d '[:space:]')
if [ "$LEAK" != "0" ]; then
  echo "error: wms_app was granted UPDATE/DELETE on $LOAD_DB.inv_movement — the ledger would not be append-only" >&2
  exit 1
fi

docker exec -e "P=${WMS_DB_PASSWORD:-wms_root}" "$CONTAINER" sh -c "mysql -uroot -p\"\$P\" $LOAD_DB -B -e \"
  SELECT
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$LOAD_DB' AND table_type='BASE TABLE') AS tables,
    (SELECT COUNT(*) FROM master_product) AS products,
    (SELECT COUNT(*) FROM master_location) AS locations,
    (SELECT COUNT(*) FROM iam_user) AS users,
    (SELECT COUNT(*) FROM inv_movement) AS ledger_rows;\"" 2>/dev/null | grep -v 'Using a password'

cat <<NOTE

Next:
  WMS_DB_NAME=$LOAD_DB scripts/seed-ledger.py --target 1000000 --i-know-this-is-a-test-database
  scripts/load-db-switch.sh $LOAD_DB      # point the API containers at it
  scripts/load-test.sh --vus 100 --duration 3m
  scripts/load-db-switch.sh $SOURCE_DB    # put them back
NOTE
