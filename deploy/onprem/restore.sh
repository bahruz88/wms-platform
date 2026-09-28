#!/usr/bin/env bash
# =============================================================================
# WMS restore / restore drill (SPEC §18.4 - RPO <= 15 min, RTO <= 4 h).
#
# Counterpart of deploy/onprem/backup.sh. Three things it does:
#
#   verify   checksum + gzip integrity of a dump, and list what is inside it.
#            Cheap; run it from cron right after every backup.
#
#   drill    THE QUARTERLY RESTORE DRILL SPEC §18.4 ASKS FOR. Starts a throwaway
#            MySQL container on an empty volume, loads the newest full dump into it,
#            optionally replays the archived binlogs (point-in-time recovery), runs
#            verification queries, prints how long it took against the 4-hour RTO,
#            writes a drill report and removes the container again. It touches
#            NOTHING that is running - no production database is opened at all.
#
#   mysql    the real disaster restore: load a dump into the mysql service of a
#            running compose stack. Destructive, therefore needs --yes.
#
#   minio    mirror the backup copy of the attachment bucket back into a running
#            MinIO (object versions are preserved; missing objects come back).
#
# Usage:
#   restore.sh verify [--dump FILE] [--backup-dir DIR]
#   restore.sh drill  [--dump FILE] [--backup-dir DIR] [--stop-datetime "YYYY-MM-DD HH:MM:SS"]
#                     [--no-binlog] [--keep]
#   restore.sh mysql  --yes [--dump FILE] [-f <compose-file>] [--env-file <env-file>]
#   restore.sh minio  --yes [-f <compose-file>] [--env-file <env-file>] [--backup-dir DIR]
#
#   --dump defaults to the newest wms-full-*.sql.gz in <backup-dir>/mysql/full.
#   --backup-dir defaults to $WMS_BACKUP_DIR, else /var/backups/wms (paths relative
#   to deploy/ are resolved against it, like backup.sh).
#
# PITR NOTE. The dump carries `SET @@GLOBAL.GTID_PURGED` (backup.sh uses
# --set-gtid-purged=ON), so replaying the whole binlog archive on top of it is safe and
# idempotent: the restored server already knows those GTIDs and skips them, and only the
# transactions committed AFTER the dump are applied. That is what makes the 15-minute RPO
# real - the gap is only the interval between binlog archives.
# =============================================================================
set -euo pipefail

DEPLOY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE=""
COMPOSE_FILE="docker-compose.onprem.yml"
ENV_FILE=".env"
DUMP=""
STOP_DATETIME=""
REPLAY_BINLOG=1
KEEP=0
CONFIRM=0
DRILL_CONTAINER="wms-restore-drill"
DRILL_IMAGE="${WMS_RESTORE_IMAGE:-mysql:8.4}"
# The official mysql:8.4 image is built from mysql-community-server-MINIMAL and ships NO
# mysqlbinlog - `ls /usr/bin/mysql*` gives mysql, mysqladmin, mysqldump, mysqlsh and nothing
# else. Point-in-time recovery is therefore impossible inside the very image the stack runs,
# which is why this script brings its own: Percona's build of the same 8.4 server, whose
# mysqlbinlog reads 8.4 binlogs byte for byte (Ver 8.4.11). Override if you mirror images.
BINLOG_IMAGE="${WMS_BINLOG_IMAGE:-percona/percona-server:8.4}"
DRILL_ROOT_PW="restore_drill_$$"

abspath() { case "$1" in /*) printf '%s' "$1" ;; *) printf '%s' "$DEPLOY_DIR/${1#./}" ;; esac; }

BACKUP_DIR_ARG=""
while [ $# -gt 0 ]; do
  case "$1" in
    verify|drill|mysql|minio) MODE="$1"; shift ;;
    --dump)           DUMP="$2"; shift 2 ;;
    --backup-dir)     BACKUP_DIR_ARG="$2"; shift 2 ;;
    --stop-datetime)  STOP_DATETIME="$2"; shift 2 ;;
    --no-binlog)      REPLAY_BINLOG=0; shift ;;
    --keep)           KEEP=1; shift ;;
    --yes)            CONFIRM=1; shift ;;
    -f|--file)        COMPOSE_FILE="$2"; shift 2 ;;
    --env-file)       ENV_FILE="$2"; shift 2 ;;
    -h|--help)        sed -n '2,40p' "${BASH_SOURCE[0]}"; exit 0 ;;
    *) echo "unknown argument: $1 (try --help)" >&2; exit 2 ;;
  esac
done
[ -n "$MODE" ] || { echo "usage: $0 {verify|drill|mysql|minio} [...]  (try --help)" >&2; exit 2; }

COMPOSE_FILE="$(abspath "$COMPOSE_FILE")"
ENV_FILE="$(abspath "$ENV_FILE")"
# shellcheck disable=SC1090
[ -f "$ENV_FILE" ] && { set -a; . "$ENV_FILE"; set +a; }

BACKUP_DIR="$(abspath "${BACKUP_DIR_ARG:-${WMS_BACKUP_DIR:-/var/backups/wms}}")"
FULL_DIR="$BACKUP_DIR/mysql/full"
BINLOG_DIR="$BACKUP_DIR/mysql/binlog"

COMPOSE=(docker compose --project-directory "$DEPLOY_DIR" -f "$COMPOSE_FILE")
[ -f "$ENV_FILE" ] && COMPOSE+=(--env-file "$ENV_FILE")

log()  { printf '%s [restore] %s\n' "$(date -u +%FT%TZ)" "$*"; }
die()  { printf '%s [restore] ERROR: %s\n' "$(date -u +%FT%TZ)" "$*" >&2; exit 1; }

pick_dump() {
  if [ -n "$DUMP" ]; then
    case "$DUMP" in /*) ;; *) DUMP="$(abspath "$DUMP")" ;; esac
  else
    DUMP="$(ls -1t "$FULL_DIR"/wms-full-*.sql.gz 2>/dev/null | head -1 || true)"
  fi
  [ -n "$DUMP" ] && [ -f "$DUMP" ] || die "no dump found (looked in $FULL_DIR)"
}

verify_dump() {
  log "dump:   $DUMP  ($(du -h "$DUMP" | cut -f1))"
  if [ -f "$DUMP.sha256" ]; then
    ( cd "$(dirname "$DUMP")" && shasum -a 256 -c "$(basename "$DUMP").sha256" ) >/dev/null \
      || die "sha256 mismatch - the dump is corrupt"
    log "sha256: OK"
  else
    log "sha256: no .sha256 next to the dump (older backup) - skipped"
  fi
  gzip -t "$DUMP" || die "gzip integrity check failed"
  log "gzip:   OK"
  [ -f "$DUMP.position" ] && log "binlog position at dump time: $(cat "$DUMP.position")"
  log "databases in the dump: $(gunzip -c "$DUMP" | grep -c '^CREATE DATABASE' || true)"
  gunzip -c "$DUMP" | sed -n 's/^CREATE DATABASE.*`\([^`]*\)`.*/  - \1/p' | sort -u
}

drill_cleanup() {
  [ "$KEEP" = "1" ] && { log "--keep: container $DRILL_CONTAINER left running"; return; }
  docker rm -f "$DRILL_CONTAINER" >/dev/null 2>&1 || true
}

drill_mysql() {   # run a client inside the drill container
  docker exec -i -e MYSQL_PWD="$DRILL_ROOT_PW" "$DRILL_CONTAINER" "$@"
}

# ---------------------------------------------------------------------------------------
# Point-in-time recovery: replay the archived binlogs on top of a just-restored server.
#   replay_binlogs <target-container> <root-password>
# The target is reached at 127.0.0.1:3306 from a one-off container that SHARES its network
# namespace, so this works for the throwaway drill server and for a live compose stack alike.
# ---------------------------------------------------------------------------------------
replay_binlogs() {
  local target="$1" root_pw="$2"
  ls "$BINLOG_DIR"/binlog.* >/dev/null 2>&1 || { log "no archived binlogs in $BINLOG_DIR - nothing to replay"; return 0; }

  # START WHERE THE DUMP ENDED. backup.sh writes the coordinate mysqldump --source-data=2
  # recorded into <dump>.position; replaying from there is the difference between a PITR that
  # takes seconds and one that takes hours. Feeding mysqlbinlog the whole archive "works"
  # (GTIDs already in gtid_executed are skipped) but the server still walks every skipped
  # transaction one at a time - on a busy database that is millions of them.
  local start_file="" start_pos="" files names stop_arg=""
  if [ -f "$DUMP.position" ]; then
    start_file="$(sed -n "s/.*_LOG_FILE='\\([^']*\\)'.*/\\1/p" "$DUMP.position")"
    start_pos="$(sed -n 's/.*_LOG_POS=\([0-9]*\).*/\1/p' "$DUMP.position")"
  fi
  if [ -n "$start_file" ]; then
    files="$(ls -1 "$BINLOG_DIR"/binlog.* | sort | awk -v s="$BINLOG_DIR/$start_file" '$0 >= s')"
    log "PITR from $start_file:${start_pos:-4}${STOP_DATETIME:+ up to $STOP_DATETIME}"
  else
    files="$(ls -1 "$BINLOG_DIR"/binlog.* | sort)"
    log "no recorded dump position - replaying the whole archive (slow)${STOP_DATETIME:+, up to $STOP_DATETIME}"
  fi
  [ -n "$files" ] || die "no binlog file at or after ${start_file:-the dump position} in $BINLOG_DIR"

  names=""
  for f in $files; do names="$names /binlogs/$(basename "$f")"; done
  [ -n "$STOP_DATETIME" ] && stop_arg="--stop-datetime=$STOP_DATETIME"

  # ONE mysqlbinlog invocation over the files in order: a transaction that spans a rotation is
  # only applied correctly when every file belongs to the same run. --start-position applies
  # to the first file, which is exactly the dump coordinate.
  # pipefail is essential - without it a missing mysqlbinlog makes the pipeline "succeed"
  # because `mysql` happily consumes empty input, and the restore silently loses every
  # transaction after the dump.
  docker run --rm --network "container:$target" \
    -v "$BINLOG_DIR:/binlogs:ro" \
    -e MYSQL_PWD="$root_pw" -e STOP_ARG="$stop_arg" -e NAMES="$names" \
    -e START_POS="${start_pos:-4}" \
    --entrypoint bash "$BINLOG_IMAGE" -c '
      set -euo pipefail
      command -v mysqlbinlog >/dev/null || { echo "ERROR: no mysqlbinlog in this image" >&2; exit 1; }
      # shellcheck disable=SC2086
      mysqlbinlog --start-position="$START_POS" ${STOP_ARG:+"$STOP_ARG"} $NAMES \
        | mysql -h 127.0.0.1 -P 3306 -uroot --binary-mode
    ' || die "binlog replay failed"
  log "binlog replay done ($(printf '%s\n' "$files" | wc -l | tr -d ' ') file(s))"
}

do_drill() {
  local started ended elapsed report
  started="$(date -u +%s)"
  report="$BACKUP_DIR/drills/drill-$(date -u +%Y%m%dT%H%M%SZ).log"
  mkdir -p "$BACKUP_DIR/drills"

  verify_dump

  docker rm -f "$DRILL_CONTAINER" >/dev/null 2>&1 || true
  # `docker rm -f` can leave a container in state Dead (a busy volume on Docker Desktop);
  # `docker run` then fails with a name conflict, so say so plainly instead.
  if docker ps -a --format '{{.Names}}' | grep -qx "$DRILL_CONTAINER"; then
    die "a previous drill container is stuck: docker rm -f $DRILL_CONTAINER (retry, it can take a minute)"
  fi
  trap drill_cleanup EXIT

  log "starting throwaway $DRILL_IMAGE as $DRILL_CONTAINER (empty volume, production my.cnf)"
  docker run -d --name "$DRILL_CONTAINER" \
    -e MYSQL_ROOT_PASSWORD="$DRILL_ROOT_PW" -e TZ=UTC \
    -v "$DEPLOY_DIR/mysql/conf.d:/etc/mysql/conf.d:ro" \
    "$DRILL_IMAGE" >/dev/null

  log "waiting for the restore target to accept connections"
  local i
  for i in $(seq 1 90); do
    if drill_mysql mysqladmin ping -h 127.0.0.1 -uroot --silent >/dev/null 2>&1; then break; fi
    sleep 2
  done
  drill_mysql mysqladmin ping -h 127.0.0.1 -uroot --silent >/dev/null 2>&1 \
    || die "restore target did not come up; see: docker logs $DRILL_CONTAINER"

  log "loading the full dump"
  gunzip -c "$DUMP" | drill_mysql mysql -uroot
  log "full dump loaded"

  local before_pitr
  before_pitr="$(drill_mysql mysql -uroot -N -e 'SELECT @@GLOBAL.gtid_executed;' | tr -d '\n')"
  log "gtid_executed after the dump: ${before_pitr:0:120}"

  if [ "$REPLAY_BINLOG" = "1" ]; then
    replay_binlogs "$DRILL_CONTAINER" "$DRILL_ROOT_PW"
  else
    log "binlog replay skipped (--no-binlog)"
  fi

  log "verification queries"
  {
    echo "== WMS restore drill =="
    echo "when          : $(date -u +%FT%TZ)"
    echo "dump          : $DUMP"
    echo "binlogs       : $(ls -1 "$BINLOG_DIR"/binlog.* 2>/dev/null | wc -l | tr -d ' ') file(s)${STOP_DATETIME:+, stopped at $STOP_DATETIME}"
    echo "target        : throwaway container $DRILL_CONTAINER ($DRILL_IMAGE)"
    echo
    echo "-- schemas --"
    drill_mysql mysql -uroot -N -e "SELECT schema_name FROM information_schema.schemata WHERE schema_name NOT IN ('mysql','information_schema','performance_schema','sys');"
    echo
    echo "-- wms: table count and the rows that matter --"
    drill_mysql mysql -uroot --table -e "
      SELECT COUNT(*) AS tables_in_wms FROM information_schema.tables WHERE table_schema='wms';" 2>/dev/null || true
    drill_mysql mysql -uroot --table -e "
      SELECT 'inv_movement' t, COUNT(*) rows_ FROM wms.inv_movement
      UNION ALL SELECT 'inv_balance', COUNT(*) FROM wms.inv_balance
      UNION ALL SELECT 'master_product', COUNT(*) FROM wms.master_product
      UNION ALL SELECT 'common_audit_log', COUNT(*) FROM wms.common_audit_log;" 2>/dev/null || echo "(wms tables not present in this dump)"
    echo
    echo "-- ledger invariant (SPEC §9.4): every movement group must net to zero --"
    drill_mysql mysql -uroot --table -e "
      SELECT COUNT(*) AS unbalanced_groups FROM (
        SELECT group_id FROM wms.inv_movement GROUP BY group_id HAVING SUM(qty_base) <> 0
      ) x;" 2>/dev/null || echo "(skipped: inv_movement not in this dump)"
    echo
    echo "-- ledger grants inside the restored mysql schema (SPEC §9.4, §16) --"
    # Read the grant TABLES, not SHOW GRANTS: the in-memory ACLs are still the drill
    # container's until FLUSH PRIVILEGES, and flushing swaps root's password for the source
    # server's (see the note under 'restoring for real' in deploy/README.md §5).
    # ledger_tables_with_update MUST be 0 - inv_movement and common_audit_log are append-only.
    drill_mysql mysql -uroot --table -e "
      SELECT
        (SELECT COUNT(*) FROM mysql.tables_priv
          WHERE Db='wms' AND User='wms_app' AND FIND_IN_SET('Update', Table_priv)) AS tables_with_update,
        (SELECT COUNT(*) FROM mysql.tables_priv
          WHERE Db='wms' AND User='wms_app' AND Table_name IN ('inv_movement','common_audit_log')
            AND FIND_IN_SET('Update', Table_priv))                                  AS ledger_tables_with_update,
        (SELECT COUNT(*) FROM mysql.user WHERE user IN ('wms_app','wms_migrator','wms_reporting')) AS wms_users;" 2>/dev/null \
      || echo "(mysql schema not in this dump)"
    echo
    echo "-- gtid_executed after replay --"
    drill_mysql mysql -uroot -N -e 'SELECT @@GLOBAL.gtid_executed;'
  } | tee "$report"

  ended="$(date -u +%s)"; elapsed=$((ended - started))
  {
    echo
    printf 'elapsed       : %s s (%02d:%02d:%02d)\n' "$elapsed" $((elapsed/3600)) $(((elapsed%3600)/60)) $((elapsed%60))
    printf 'RTO budget    : 14400 s (4 h) -> %s\n' "$([ "$elapsed" -le 14400 ] && echo 'WITHIN BUDGET' || echo 'OVER BUDGET')"
  } | tee -a "$report"
  log "drill report: $report"
  log "reminder: a REAL restore of an --all-databases dump needs FLUSH PRIVILEGES (or a restart)"
  log "          afterwards, and root's password then becomes the SOURCE server's, not the new one"
}

do_mysql_restore() {
  [ "$CONFIRM" = "1" ] || die "restoring over a live database needs --yes"
  pick_dump; verify_dump
  local cid
  cid="$("${COMPOSE[@]}" ps -q mysql | head -1)"
  [ -n "$cid" ] || die "mysql service of ${COMPOSE_FILE##*/} is not running"
  log "restoring $DUMP into the RUNNING mysql of ${COMPOSE_FILE##*/} - existing data is overwritten"
  gunzip -c "$DUMP" | "${COMPOSE[@]}" exec -T mysql sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" exec mysql -uroot'
  log "dump loaded; now re-apply the ledger grants:  scripts/db-ledger-grants.sh -f ${COMPOSE_FILE##*/}"
}

do_minio_restore() {
  [ "$CONFIRM" = "1" ] || die "mirroring back into a live MinIO needs --yes"
  local cid net user pass bucket
  cid="$("${COMPOSE[@]}" ps -q minio | head -1)"
  [ -n "$cid" ] || die "minio service of ${COMPOSE_FILE##*/} is not running"
  net="$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$k}}{{"\n"}}{{end}}' "$cid" | head -1)"
  user="${MINIO_ROOT_USER:-$(docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' "$cid" | sed -n 's/^MINIO_ROOT_USER=//p' | head -1)}"
  pass="${MINIO_ROOT_PASSWORD:-$(docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' "$cid" | sed -n 's/^MINIO_ROOT_PASSWORD=//p' | head -1)}"
  bucket="${MINIO_BUCKET:-wms-attachments}"
  [ -d "$BACKUP_DIR/minio/$bucket" ] || die "no MinIO backup at $BACKUP_DIR/minio/$bucket"
  log "mirroring $BACKUP_DIR/minio/$bucket back into minio/$bucket (network $net)"
  docker run --rm --network "$net" \
    -e MC_HOST_dst="http://${user}:${pass}@minio:9000" \
    -v "$BACKUP_DIR/minio:/backup:ro" \
    --entrypoint mc quay.io/minio/mc:RELEASE.2025-08-13T08-35-41Z \
    mirror --overwrite --preserve "/backup/$bucket" "dst/$bucket"
  log "MinIO restore done"
}

case "$MODE" in
  verify) pick_dump; verify_dump ;;
  drill)  pick_dump; do_drill ;;
  mysql)  do_mysql_restore ;;
  minio)  do_minio_restore ;;
esac
log "OK ($MODE)"
