#!/usr/bin/env bash
# keycloak-token.sh - fetch a dev access token for local API testing.
#
#   scripts/keycloak-token.sh <username> [password]        prints the access token (password defaults to username)
#   scripts/keycloak-token.sh keeper --decode              ... and the decoded JWT payload (tenant_id, aud, realm_access)
#   scripts/keycloak-token.sh keeper --full                whole token response (refresh token, expiry ...)
#   curl -H "Authorization: Bearer $(scripts/keycloak-token.sh keeper)" http://localhost:5000/api/v1/inventory/...
#
# Uses the OAuth2 password grant against client `wms-web`, which has
# directAccessGrantsEnabled=true in deploy/keycloak/realm-wms.json FOR DEV ONLY
# (deploy/onprem/render-realm.sh turns it off for production).
# Env: KEYCLOAK_URL (default http://localhost:${KEYCLOAK_PORT:-8080}), KEYCLOAK_CLIENT_ID (wms-web)
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"
require curl
load_env

USERNAME=""; PASSWORD=""; MODE=token
for a in "$@"; do
  case "$a" in
    --decode) MODE=decode ;;
    --full)   MODE=full ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    *) if [ -z "$USERNAME" ]; then USERNAME="$a"; elif [ -z "$PASSWORD" ]; then PASSWORD="$a"; else echo "unexpected argument: $a" >&2; exit 2; fi ;;
  esac
done
[ -n "$USERNAME" ] || { sed -n '2,12p' "$0"; exit 2; }
PASSWORD="${PASSWORD:-$USERNAME}"

KC_URL="${KEYCLOAK_URL:-http://localhost:${KEYCLOAK_PORT:-8080}}"
CLIENT_ID="${KEYCLOAK_CLIENT_ID:-wms-web}"
REALM="${KEYCLOAK_REALM:-wms}"

resp="$(curl -fsS -X POST "$KC_URL/realms/$REALM/protocol/openid-connect/token" \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode grant_type=password \
  --data-urlencode "client_id=$CLIENT_ID" \
  --data-urlencode "username=$USERNAME" \
  --data-urlencode "password=$PASSWORD" \
  --data-urlencode scope=openid)" || { echo "token request failed ($KC_URL, user $USERNAME)" >&2; exit 1; }

json_get() {  # json_get <key> - tiny extractor without a hard jq dependency
  if command -v jq >/dev/null 2>&1; then jq -r ".$1 // empty" <<<"$resp"
  else sed -n "s/.*\"$1\":\"\([^\"]*\)\".*/\1/p" <<<"$resp"; fi
}

case "$MODE" in
  full)   if command -v jq >/dev/null 2>&1; then jq . <<<"$resp"; else echo "$resp"; fi ;;
  token)  json_get access_token ;;
  decode)
    token="$(json_get access_token)"
    echo "$token"
    echo
    payload="$(cut -d. -f2 <<<"$token" | tr '_-' '/+')"
    pad=$(( (4 - ${#payload} % 4) % 4 )); [ "$pad" -gt 0 ] && payload="$payload$(printf '=%.0s' $(seq 1 $pad))"
    decoded="$(base64 -d <<<"$payload" 2>/dev/null || base64 -D <<<"$payload")"
    if command -v jq >/dev/null 2>&1; then jq '{iss, aud, sub, preferred_username, tenant_id, realm_access, exp, azp}' <<<"$decoded"; else echo "$decoded"; fi ;;
esac
