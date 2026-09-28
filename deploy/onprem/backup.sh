#!/usr/bin/env bash
# =============================================================================
# WMS backup (SPEC §18.4): RPO <= 15 min, RTO <= 4 h.
#
#   1. MySQL: daily full logical dump (mysqldump --single-transaction, all
#      databases incl. `keycloak`, routines/events/triggers) + GTID position.
#   2. MySQL binlog: the server keeps ROW-format binlogs (deploy/mysql/conf.d/wms.cnf,
#      7 days). Every run copies the binlog files that are not yet archived,
#      so with a 15-minute cron the RPO target is met (point-in-time recovery =
#      last full dump + binlogs up to the incident).
#   3. MinIO: `mc mirror` of the versioned bucket to the backup directory
#      (object versions are kept by MinIO; the mirror is the off-box copy).
#
# Usage:
#   backup.sh [full|binlog|minio|all] [-f <compose-file>] [--env-file <env-file>]
#
#   backup.sh full                                        on-prem stack (default)
#   backup.sh full -f docker-compose.yml                  the dev stack instead
#   backup.sh binlog --env-file ./onprem/.env.smoke       alternative env file
#
#   -f / --env-file take paths relative to deploy/ (or absolute). They exist because
#   the credentials, the compose project and therefore the docker NETWORK differ per
#   stack; see get_network() below.
#
# cron (as a user allowed to run docker):
#   */15 * * * *  /opt/wms/deploy/onprem/backup.sh binlog   >> /var/log/wms-backup.log 2>&1
#   30 1  * * *   /opt/wms/deploy/onprem/backup.sh full     >> /var/log/wms-backup.log 2>&1
#
# Then ship $WMS_BACKUP_DIR off-host (rsync/rclone to a second machine or object
# storage). Restore and the quarterly restore drill: deploy/onprem/restore.sh.
# =============================================================================
set -euo pipefail

DEPLOY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE=""
COMPOSE_FILE="docker-compose.onprem.yml"
ENV_FILE=".env"

abspath() {   # resolve a path given relative to deploy/
  case "$1" in /*) printf '%s' "$1" ;; *) printf '%s' "$DEPLOY_DIR/${1#./}" ;; esac
}

while [ $# -gt 0 ]; do
  case "$1" in
    full|binlog|minio|all) MODE="$1"; shift ;;
    -f|--file)     COMPOSE_FILE="$2"; shift 2 ;;
    --env-file)    ENV_FILE="$2"; shift 2 ;;
    -h|--help)     sed -n '2,32p' "${BASH_SOURCE[0]}"; exit 0 ;;
    *) echo "usage: $0 [full|binlog|minio|all] [-f <compose-file>] [--env-file <env-file>]" >&2; exit 2 ;;
  esac
done
MODE="${MODE:-full}"

COMPOSE_FILE="$(abspath "$COMPOSE_FILE")"
ENV_FILE="$(abspath "$ENV_FILE")"
[ -f "$COMPOSE_FILE" ] || { echo "error: compose file not found: $COMPOSE_FILE" >&2; exit 1; }

# shellcheck disable=SC1090
[ -f "$ENV_FILE" ] && { set -a; . "$ENV_FILE"; set +a; }

COMPOSE=(docker compose --project-directory "$DEPLOY_DIR" -f "$COMPOSE_FILE")
[ -f "$ENV_FILE" ] && COMPOSE+=(--env-file "$ENV_FILE")

BACKUP_DIR="$(abspath "${WMS_BACKUP_DIR:-/var/backups/wms}")"
RETENTION_DAYS="${WMS_BACKUP_RETENTION_DAYS:-14}"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"

mkdir -p "$BACKUP_DIR/mysql/full" "$BACKUP_DIR/mysql/binlog" "$BACKUP_DIR/minio"
log() { printf '%s [backup] %s\n' "$(date -u +%FT%TZ)" "$*"; }

# Run a mysql client inside the mysql container, authenticating from the CONTAINER's own
# MYSQL_ROOT_PASSWORD. Reading it from the host env used to be a hard requirement, which made
# `backup.sh -f docker-compose.yml` impossible: the dev stack never sets MYSQL_ROOT_PASSWORD in
# deploy/.env, it relies on the `${MYSQL_ROOT_PASSWORD:-wms_root}` default inside the compose file.
mysql_exec() {
  "${COMPOSE[@]}" exec -T mysql sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" exec "$@"' _ "$@"
}

# Same idea for MinIO: the effective credentials are whatever the running container got.
container_env() {   # container_env <service> <VAR>
  local cid
  cid="$("${COMPOSE[@]}" ps -q "$1" 2>/dev/null | head -1)"
  [ -n "$cid" ] || return 1
  docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' "$cid" | sed -n "s/^$2=//p" | head -1
}

# The docker network to attach the one-off `mc` container to. It CANNOT be derived from
# the directory name: docker-compose.onprem.yml declares `name: wms-onprem` and
# docker-compose.yml declares `name: wms`, so the networks are `wms-onprem_default` and
# `wms_default` - never `deploy_default`, which is what `basename $DEPLOY_DIR`_default
# used to produce. Every `backup.sh minio` run therefore failed with
#   docker: Error response from daemon: network deploy_default not found
# Asking the running container is exact for any project name or custom network.
get_network() {
  local cid
  cid="$("${COMPOSE[@]}" ps -q minio 2>/dev/null | head -1)"
  [ -n "$cid" ] || { echo "error: minio container is not running (${COMPOSE_FILE##*/})" >&2; return 1; }
  docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$k}}{{"\n"}}{{end}}' "$cid" | head -1
}

backup_full() {
  local out="$BACKUP_DIR/mysql/full/wms-full-$STAMP.sql.gz"
  log "MySQL full dump -> $out"
  # --source-data=2 records the binlog file/position as a comment (start point for PITR)
  mysql_exec mysqldump -uroot --single-transaction --quick --routines --events --triggers \
      --set-gtid-purged=ON --source-data=2 --all-databases \
    | gzip -6 > "$out.tmp"
  mv "$out.tmp" "$out"
  # Checksum + the GTID/binlog coordinate, so a restore can prove it read an intact file
  # and knows where to start replaying binlogs from.
  ( cd "$BACKUP_DIR/mysql/full" && shasum -a 256 "$(basename "$out")" > "$(basename "$out").sha256" )
  gunzip -c "$out" | grep -m1 -E '^-- CHANGE (MASTER|REPLICATION SOURCE)' > "$out.position" 2>/dev/null || true
  log "MySQL full dump done ($(du -h "$out" | cut -f1)), sha256 written"
  find "$BACKUP_DIR/mysql/full" -name 'wms-full-*.sql.gz*' -mtime +"$RETENTION_DAYS" -delete
}

backup_binlog() {
  # Rotate so the current binlog is closed and copy every file we do not have yet.
  mysql_exec mysql -uroot -e 'FLUSH BINARY LOGS;'
  local files current copied=0
  files="$(mysql_exec mysql -uroot -N -e 'SHOW BINARY LOGS;' | awk '{print $1}')"
  # The last one is the file the server is writing to now; archive the closed ones only,
  # otherwise the copy is a torn file that mysqlbinlog may refuse.
  current="$(printf '%s\n' "$files" | tail -1)"
  for f in $files; do
    [ "$f" = "$current" ] && continue
    if [ ! -s "$BACKUP_DIR/mysql/binlog/$f" ]; then
      "${COMPOSE[@]}" exec -T mysql cat "/var/lib/mysql/$f" > "$BACKUP_DIR/mysql/binlog/$f.tmp"
      mv "$BACKUP_DIR/mysql/binlog/$f.tmp" "$BACKUP_DIR/mysql/binlog/$f"
      copied=$((copied + 1))
    fi
  done
  log "binlog: $copied new file(s) archived (open file $current left alone)"
  find "$BACKUP_DIR/mysql/binlog" -name 'binlog.*' -mtime +"$RETENTION_DAYS" -delete
}

backup_minio() {
  local net bucket user pass
  net="$(get_network)"
  user="${MINIO_ROOT_USER:-$(container_env minio MINIO_ROOT_USER || true)}"
  pass="${MINIO_ROOT_PASSWORD:-$(container_env minio MINIO_ROOT_PASSWORD || true)}"
  bucket="${MINIO_BUCKET:-$(container_env minio-init MINIO_BUCKET 2>/dev/null || echo wms-attachments)}"
  bucket="${bucket:-wms-attachments}"
  [ -n "$user" ] && [ -n "$pass" ] || { echo "error: MinIO credentials not found (env file or container)" >&2; return 1; }
  log "MinIO mirror (network $net) -> $BACKUP_DIR/minio/$bucket"
  docker run --rm --network "$net" \
    -e MC_HOST_src="http://${user}:${pass}@minio:9000" \
    -v "$BACKUP_DIR/minio:/backup" \
    --entrypoint mc \
    quay.io/minio/mc:RELEASE.2025-08-13T08-35-41Z \
    mirror --overwrite --preserve "src/$bucket" "/backup/$bucket"
  log "MinIO mirror done ($(find "$BACKUP_DIR/minio/$bucket" -type f 2>/dev/null | wc -l | tr -d ' ') object(s))"
}

case "$MODE" in
  full)   backup_full; backup_binlog; backup_minio ;;
  binlog) backup_binlog ;;
  minio)  backup_minio ;;
  all)    backup_full; backup_binlog; backup_minio ;;
esac
log "OK ($MODE, stack ${COMPOSE_FILE##*/}, dir $BACKUP_DIR)"
