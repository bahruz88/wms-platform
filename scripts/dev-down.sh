#!/usr/bin/env bash
# dev-down.sh - stop the local stack.
#   scripts/dev-down.sh        stop & remove containers (data volumes are kept)
#   scripts/dev-down.sh -v     ... and delete the volumes (MySQL, MinIO, Keycloak H2 -> realm is re-imported next time)
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"
require docker
load_env

EXTRA=()
for a in "$@"; do
  case "$a" in
    -v|--volumes) EXTRA+=(--volumes) ;;
    -h|--help) sed -n '2,5p' "$0"; exit 0 ;;
    *) echo "unknown argument: $a" >&2; exit 2 ;;
  esac
done

compose --profile infra --profile app --profile migrate down --remove-orphans ${EXTRA[@]+"${EXTRA[@]}"}
