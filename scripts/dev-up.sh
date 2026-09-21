#!/usr/bin/env bash
# dev-up.sh - start the local infrastructure (compose profile `infra`) and wait until healthy.
#
#   scripts/dev-up.sh            mysql, redis, rabbitmq(+init), minio(+init), keycloak, seq
#   scripts/dev-up.sh --app      ... plus the backend/web images (profile `app`, built from source)
#
# Ports/credentials: docs/CONVENTIONS.md, overridable in deploy/.env (see deploy/.env.example).
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"
require docker
load_env

WITH_APP=0
for a in "$@"; do
  case "$a" in
    --app) WITH_APP=1 ;;
    -h|--help) sed -n '2,8p' "$0"; exit 0 ;;
    *) echo "unknown argument: $a" >&2; exit 2 ;;
  esac
done

PROFILES=(--profile infra)
[ "$WITH_APP" = 1 ] && PROFILES+=(--profile app)

# --- 1. host port check (only for services that are not already running) -----------
# "service:port[,port]" - keep in sync with deploy/docker-compose.yml
PORT_MAP=(
  "mysql:${MYSQL_PORT:-3306}"
  "redis:${REDIS_PORT:-6379}"
  "rabbitmq:${RABBITMQ_PORT:-5672},${RABBITMQ_MGMT_PORT:-15672}"
  "minio:${MINIO_PORT:-9000},${MINIO_CONSOLE_PORT:-9001}"
  "keycloak:${KEYCLOAK_PORT:-8080}"
  "seq:${SEQ_PORT:-5341}"
)
if [ "$WITH_APP" = 1 ]; then
  PORT_MAP+=(
    "gateway:${GATEWAY_PORT:-5000}"
    "wms-identity:${IDENTITY_PORT:-5081}"
    "wms-masterdata:${MASTERDATA_PORT:-5082}"
    "wms-inventory:${INVENTORY_PORT:-5083}"
    "wms-procurement:${PROCUREMENT_PORT:-5084}"
    "wms-reporting:${REPORTING_PORT:-5085}"
    "wms-worker:${WORKER_PORT:-5086}"
    "web:${WEB_PORT:-3000}"
  )
fi

bold "Checking host ports"
RUNNING="$(compose "${PROFILES[@]}" ps --status running --services 2>/dev/null || true)"
CONFLICT=0
for entry in "${PORT_MAP[@]}"; do
  svc="${entry%%:*}"; ports="${entry#*:}"
  if grep -qx "$svc" <<<"$RUNNING"; then
    ok "$svc already running (ports $ports)"
    continue
  fi
  for p in ${ports//,/ }; do
    if port_busy "$p"; then
      fail "port $p needed by '$svc' is in use by: $(port_owner "$p")"
      CONFLICT=1
    else
      ok "port $p free ($svc)"
    fi
  done
done
if [ "$CONFLICT" = 1 ]; then
  echo
  echo "Free the port or override it in deploy/.env (e.g. KEYCLOAK_PORT=8180, GATEWAY_PORT=5001)." >&2
  echo "macOS: 5000/7000 belong to AirPlay Receiver (System Settings > General > AirDrop & Handoff)." >&2
  exit 1
fi

# --- 2. start ------------------------------------------------------------------------
bold "Starting: docker compose ${PROFILES[*]} up -d"
if [ "$WITH_APP" = 1 ]; then
  compose "${PROFILES[@]}" up -d --build
else
  compose "${PROFILES[@]}" up -d
fi

# --- 3. wait for health ---------------------------------------------------------------
HEALTHY_SERVICES=(mysql redis rabbitmq minio keycloak seq)
ONESHOT_SERVICES=(rabbitmq-init minio-init)
if [ "$WITH_APP" = 1 ]; then
  HEALTHY_SERVICES+=(wms-identity wms-masterdata wms-inventory wms-procurement wms-reporting wms-worker gateway)
fi
TIMEOUT="${DEV_UP_TIMEOUT:-300}"
bold "Waiting for health (timeout ${TIMEOUT}s)"
start=$(date +%s)
while :; do
  status="$(compose "${PROFILES[@]}" ps -a --format '{{.Service}}|{{.State}}|{{.Health}}|{{.ExitCode}}' 2>/dev/null || true)"
  pending=()
  failed=()
  for s in "${HEALTHY_SERVICES[@]}"; do
    line="$(grep "^$s|" <<<"$status" || true)"
    h="$(cut -d'|' -f3 <<<"$line")"; st="$(cut -d'|' -f2 <<<"$line")"
    if [ "$h" != "healthy" ]; then
      [ "$st" = "exited" ] && failed+=("$s") || pending+=("$s")
    fi
  done
  for s in "${ONESHOT_SERVICES[@]}"; do
    line="$(grep "^$s|" <<<"$status" || true)"
    st="$(cut -d'|' -f2 <<<"$line")"; ec="$(cut -d'|' -f4 <<<"$line")"
    if [ "$st" = "exited" ]; then
      [ "$ec" = "0" ] || failed+=("$s")
    else
      pending+=("$s")
    fi
  done
  if [ "${#failed[@]}" -gt 0 ]; then
    fail "failed: ${failed[*]}"
    for s in "${failed[@]}"; do echo "--- logs $s ---"; compose "${PROFILES[@]}" logs --no-color --tail=40 "$s"; done
    exit 1
  fi
  if [ "${#pending[@]}" -eq 0 ]; then break; fi
  now=$(date +%s)
  if [ $((now - start)) -ge "$TIMEOUT" ]; then
    fail "timeout waiting for: ${pending[*]}"
    compose "${PROFILES[@]}" ps
    exit 1
  fi
  printf '  … waiting (%3ds): %s\n' "$((now - start))" "${pending[*]}"
  sleep 5
done

# --- 4. summary -----------------------------------------------------------------------
echo
bold "Status"
compose "${PROFILES[@]}" ps --format 'table {{.Service}}\t{{.Status}}\t{{.Ports}}'
echo
bold "Services (host)"
printf '  %-22s %-42s %s\n' "SERVICE" "URL" "CREDENTIALS"
printf '  %-22s %-42s %s\n' "MySQL 8.4"     "mysql://localhost:${MYSQL_PORT:-3306}/wms"             "root/${MYSQL_ROOT_PASSWORD:-wms_root}  wms_app/${MYSQL_APP_PASSWORD:-wms_app}  wms_migrator/${MYSQL_MIGRATOR_PASSWORD:-wms_migrator}"
printf '  %-22s %-42s %s\n' "Redis 7"       "redis://localhost:${REDIS_PORT:-6379}"                  "-"
printf '  %-22s %-42s %s\n' "RabbitMQ 4"    "amqp://localhost:${RABBITMQ_PORT:-5672}  UI http://localhost:${RABBITMQ_MGMT_PORT:-15672}" "${RABBITMQ_USER:-wms}/${RABBITMQ_PASSWORD:-wms}"
printf '  %-22s %-42s %s\n' "MinIO"         "http://localhost:${MINIO_PORT:-9000}  console http://localhost:${MINIO_CONSOLE_PORT:-9001}" "${MINIO_ROOT_USER:-minioadmin}/${MINIO_ROOT_PASSWORD:-minioadmin}  bucket ${MINIO_BUCKET:-wms-attachments}"
printf '  %-22s %-42s %s\n' "Keycloak 26"   "http://localhost:${KEYCLOAK_PORT:-8080}  (realm wms)"    "${KEYCLOAK_ADMIN:-admin}/${KEYCLOAK_ADMIN_PASSWORD:-admin}  users: admin procurement manager keeper branch1 auditor (pw = username)"
printf '  %-22s %-42s %s\n' "Seq"           "http://localhost:${SEQ_PORT:-5341}"                     "no auth (dev)"
if [ "$WITH_APP" = 1 ]; then
  printf '  %-22s %-42s %s\n' "Gateway (YARP)" "http://localhost:${GATEWAY_PORT:-5000}"             "Bearer token: scripts/keycloak-token.sh <user>"
  printf '  %-22s %-42s %s\n' "Hangfire"     "http://localhost:${WORKER_PORT:-5086}/hangfire"        "-"
  printf '  %-22s %-42s %s\n' "Web (nginx)"  "http://localhost:${WEB_PORT:-3000}"                    "-"
fi
echo
echo "Next: scripts/db-migrate.sh   (EF migrations + ledger grants)   |   scripts/keycloak-token.sh keeper"
