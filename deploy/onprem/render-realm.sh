#!/usr/bin/env bash
# Renders a production Keycloak realm from deploy/keycloak/realm-wms.json:
#   * removes the dev users (password = username)
#   * disables direct access grants on wms-web (dev-only, used by scripts/keycloak-token.sh)
#   * sets redirect URIs / web origins / post-logout URIs of wms-web to ${WEB_PUBLIC_URL}
# Output: deploy/onprem/realm-wms.rendered.json  -> set KEYCLOAK_REALM_FILE=./onprem/realm-wms.rendered.json in .env
#
#   ./onprem/render-realm.sh                                  reads deploy/.env
#   ./onprem/render-realm.sh --env-file ./onprem/.env.smoke   reads that file instead
set -euo pipefail

DEPLOY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$DEPLOY_DIR/keycloak/realm-wms.json"
OUT="$DEPLOY_DIR/onprem/realm-wms.rendered.json"
ENV_FILE="$DEPLOY_DIR/.env"

while [ $# -gt 0 ]; do
  case "$1" in
    --env-file) ENV_FILE="$2"; case "$ENV_FILE" in /*) ;; *) ENV_FILE="$DEPLOY_DIR/${ENV_FILE#./}" ;; esac; shift 2 ;;
    -o|--out)   OUT="$2"; shift 2 ;;
    -h|--help)  sed -n '2,8p' "${BASH_SOURCE[0]}"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done

# shellcheck disable=SC1090
[ -f "$ENV_FILE" ] && { set -a; . "$ENV_FILE"; set +a; }
: "${WEB_PUBLIC_URL:?WEB_PUBLIC_URL missing (e.g. https://wms.example.com) - set it in $ENV_FILE}"
command -v jq >/dev/null || { echo "jq is required"; exit 1; }

web="${WEB_PUBLIC_URL%/}"
jq --arg web "$web" '
  del(.users)
  | .clients |= map(
      if .clientId == "wms-web" then
        .directAccessGrantsEnabled = false
        | .redirectUris = [$web + "/*"]
        | .webOrigins = [$web]
        | .attributes["post.logout.redirect.uris"] = ($web + "/*")
      else . end)
' "$SRC" > "$OUT"

echo "Rendered $OUT"
echo "  wms-web redirect: $web/*   (dev users removed, direct grants off)"
echo "Now set in deploy/.env:  KEYCLOAK_REALM_FILE=./onprem/realm-wms.rendered.json"
