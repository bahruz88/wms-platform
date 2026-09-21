#!/usr/bin/env bash
# dev-logs.sh - follow logs of the local stack.
#   scripts/dev-logs.sh                 all services
#   scripts/dev-logs.sh keycloak mysql  selected services
#   TAIL=50 scripts/dev-logs.sh         lines of history per service (default 200)
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"
require docker
load_env

compose --profile infra --profile app --profile migrate logs -f --tail="${TAIL:-200}" "$@"
