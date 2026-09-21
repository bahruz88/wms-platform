#!/usr/bin/env bash
# =============================================================================
# WMS on-prem backup (SPEC §18.4): RPO <= 15 min, RTO <= 4 h.
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
# cron (as a user allowed to run docker):
#   */15 * * * *  /opt/wms/deploy/onprem/backup.sh binlog   >> /var/log/wms-backup.log 2>&1
#   30 1  * * *   /opt/wms/deploy/onprem/backup.sh full     >> /var/log/wms-backup.log 2>&1
#
# Then ship $BACKUP_DIR off-host (rsync/rclone to a second machine or object
# storage). Restore procedure and the quarterly restore drill: deploy/README.md.
# =============================================================================
set -euo pipefail

MODE="${1:-full}"                               # full | binlog | minio | all
DEPLOY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE=(docker compose -f "$DEPLOY_DIR/docker-compose.onprem.yml")
BACKUP_DIR="${WMS_BACKUP_DIR:-/var/backups/wms}"
RETENTION_DAYS="${WMS_BACKUP_RETENTION_DAYS:-14}"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"

# shellcheck disable=SC1091
[ -f "$DEPLOY_DIR/.env" ] && { set -a; . "$DEPLOY_DIR/.env"; set +a; }
: "${MYSQL_ROOT_PASSWORD:?MYSQL_ROOT_PASSWORD missing (deploy/.env)}"

mkdir -p "$BACKUP_DIR/mysql/full" "$BACKUP_DIR/mysql/binlog" "$BACKUP_DIR/minio"
log() { printf '%s [backup] %s\n' "$(date -u +%FT%TZ)" "$*"; }

mysql_exec() {   # run mysql client inside the container with root creds
  "${COMPOSE[@]}" exec -T -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql "$@"
}

backup_full() {
  local out="$BACKUP_DIR/mysql/full/wms-full-$STAMP.sql.gz"
  log "MySQL full dump -> $out"
  # --source-data=2 records the binlog file/position as a comment (start point for PITR)
  mysql_exec mysqldump -uroot --single-transaction --quick --routines --events --triggers \
      --set-gtid-purged=ON --source-data=2 --all-databases \
    | gzip -6 > "$out.tmp"
  mv "$out.tmp" "$out"
  log "MySQL full dump done ($(du -h "$out" | cut -f1))"
  find "$BACKUP_DIR/mysql/full" -name 'wms-full-*.sql.gz' -mtime +"$RETENTION_DAYS" -delete
}

backup_binlog() {
  # Rotate so the current binlog is closed and copy every file we do not have yet.
  mysql_exec mysql -uroot -e 'FLUSH BINARY LOGS;'
  local files
  files="$(mysql_exec mysql -uroot -N -e 'SHOW BINARY LOGS;' | awk '{print $1}')"
  local copied=0
  for f in $files; do
    if [ ! -s "$BACKUP_DIR/mysql/binlog/$f" ]; then
      "${COMPOSE[@]}" exec -T mysql cat "/var/lib/mysql/$f" > "$BACKUP_DIR/mysql/binlog/$f.tmp"
      mv "$BACKUP_DIR/mysql/binlog/$f.tmp" "$BACKUP_DIR/mysql/binlog/$f"
      copied=$((copied + 1))
    fi
  done
  log "binlog: $copied new file(s) archived"
  find "$BACKUP_DIR/mysql/binlog" -name 'binlog.*' -mtime +"$RETENTION_DAYS" -delete
}

backup_minio() {
  log "MinIO mirror -> $BACKUP_DIR/minio"
  docker run --rm --network "$(basename "$DEPLOY_DIR")_default" \
    -e MC_HOST_src="http://${MINIO_ROOT_USER}:${MINIO_ROOT_PASSWORD}@minio:9000" \
    -v "$BACKUP_DIR/minio:/backup" \
    quay.io/minio/mc:RELEASE.2025-08-13T08-35-41Z \
    mirror --overwrite --preserve "src/${MINIO_BUCKET:-wms-attachments}" "/backup/${MINIO_BUCKET:-wms-attachments}"
  log "MinIO mirror done"
}

case "$MODE" in
  full)   backup_full; backup_binlog; backup_minio ;;
  binlog) backup_binlog ;;
  minio)  backup_minio ;;
  all)    backup_full; backup_binlog; backup_minio ;;
  *) echo "usage: $0 [full|binlog|minio|all]"; exit 2 ;;
esac
log "OK ($MODE)"
