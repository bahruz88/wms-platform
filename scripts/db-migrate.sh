#!/usr/bin/env bash
# db-migrate.sh - run EF Core migrations through the run-once `migrator` container (SPEC §18.3:
# never at API startup), then re-apply the ledger grants (SPEC §9.4/§16).
#
#   scripts/db-migrate.sh                              dev stack (deploy/docker-compose.yml)
#   scripts/db-migrate.sh -f docker-compose.onprem.yml on-prem stack
#   scripts/db-migrate.sh --no-build                   reuse the existing migrator image
#   scripts/db-migrate.sh -- <args>                    extra args for Wms.Host.Migrator (e.g. --Modules=inventory)
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"
require docker
parse_compose_file_arg "$@"; set -- ${REMAINING_ARGS[@]+"${REMAINING_ARGS[@]}"}
load_env

BUILD=(--build)
MIGRATOR_ARGS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --no-build) BUILD=(); shift ;;
    --) shift; MIGRATOR_ARGS=("$@"); break ;;
    -h|--help) sed -n '2,9p' "$0"; exit 0 ;;
    *) MIGRATOR_ARGS+=("$1"); shift ;;
  esac
done

bold "Running migrator ($COMPOSE_FILE_NAME)"
# `infra` must be activated together with `migrate`: the migrator depends_on mysql, which lives in the
# infra profile, and Compose rejects the project with "depends on undefined service" otherwise.
compose --profile infra --profile migrate run --rm ${BUILD[@]+"${BUILD[@]}"} migrator ${MIGRATOR_ARGS[@]+"${MIGRATOR_ARGS[@]}"}

bold "Applying ledger grants"
COMPOSE_FILE_NAME="$COMPOSE_FILE_NAME" "$(dirname "${BASH_SOURCE[0]}")/db-ledger-grants.sh"
