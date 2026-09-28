#!/usr/bin/env bash
# load-test.sh — SPEC §17.3 load test through k6 in Docker (no local k6 needed).
#
#   scripts/load-test.sh                          # the full criterion: 100 VUs, 3 minutes
#   scripts/load-test.sh --vus 20 --duration 1m   # a lighter smoke of the harness itself
#   scripts/load-test.sh --base http://gateway:8080 --keycloak http://keycloak:8080
#   scripts/load-test.sh --summary out.json       # machine-readable result
#
# The gateway and Keycloak are reached through host.docker.internal by default, which is how a
# container on this machine sees the dev stack's published ports.
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

VUS=100
DURATION=3m
BASE="http://host.docker.internal:5001"
KEYCLOAK="http://host.docker.internal:8180"
MOVEMENTS_PER_HOUR=2000
SUMMARY=""

while [ $# -gt 0 ]; do
  case "$1" in
    --vus)       VUS="$2"; shift 2 ;;
    --duration)  DURATION="$2"; shift 2 ;;
    --base)      BASE="$2"; shift 2 ;;
    --keycloak)  KEYCLOAK="$2"; shift 2 ;;
    --movements) MOVEMENTS_PER_HOUR="$2"; shift 2 ;;
    --summary)   SUMMARY="$2"; shift 2 ;;
    -h|--help)   sed -n '2,12p' "$0"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done

command -v docker >/dev/null || { echo "error: docker is required" >&2; exit 1; }

echo "SPEC §17.3 — ${VUS} VU, ${DURATION}, ${MOVEMENTS_PER_HOUR} movements/hour, target p95 < 2 s"
echo "  gateway:  $BASE"

ARGS=(run /load/wms-load.js)
[ -n "$SUMMARY" ] && ARGS+=(--summary-export /load/"$(basename "$SUMMARY")")

docker run --rm \
  --add-host host.docker.internal:host-gateway \
  -v "$ROOT_DIR/load":/load \
  -e "BASE_URL=$BASE" \
  -e "KEYCLOAK_URL=$KEYCLOAK" \
  -e "VUS=$VUS" \
  -e "DURATION=$DURATION" \
  -e "MOVEMENTS_PER_HOUR=$MOVEMENTS_PER_HOUR" \
  grafana/k6:latest "${ARGS[@]}"
