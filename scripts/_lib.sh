#!/usr/bin/env bash
# Shared helpers for scripts/*.sh (sourced, not executed).
#   compose ...   -> docker compose bound to deploy/ (reads deploy/.env; -f override via COMPOSE_FILE_NAME)
#   load_env      -> exports deploy/.env so port/credential overrides are visible to the scripts
# shellcheck shell=bash

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEPLOY_DIR="$ROOT_DIR/deploy"
COMPOSE_FILE_NAME="${COMPOSE_FILE_NAME:-docker-compose.yml}"

compose() {
  docker compose --project-directory "$DEPLOY_DIR" -f "$DEPLOY_DIR/$COMPOSE_FILE_NAME" "$@"
}

load_env() {
  if [ -f "$DEPLOY_DIR/.env" ]; then
    set -a
    # shellcheck disable=SC1091
    . "$DEPLOY_DIR/.env"
    set +a
  fi
}

# parse a leading `-f <compose-file>` (path relative to deploy/), shifts it away
# usage: parse_compose_file_arg "$@"; set -- ${REMAINING_ARGS[@]+"${REMAINING_ARGS[@]}"}
#   (the ${a[@]+"${a[@]}"} form is required: bash 3.2 on macOS aborts on an empty
#    array expansion under `set -u`)
parse_compose_file_arg() {
  REMAINING_ARGS=()
  while [ $# -gt 0 ]; do
    case "$1" in
      -f|--file) COMPOSE_FILE_NAME="$2"; shift 2 ;;
      *) REMAINING_ARGS+=("$1"); shift ;;
    esac
  done
}

require() {
  command -v "$1" >/dev/null 2>&1 || { echo "error: '$1' is required" >&2; exit 1; }
}

port_busy() {   # port_busy <port> -> 0 if something listens on it (any user, any interface)
  local p="$1"
  if command -v ss >/dev/null 2>&1; then
    ss -Hltn "( sport = :$p )" 2>/dev/null | grep -q . && return 0
  elif command -v netstat >/dev/null 2>&1; then
    # macOS `*.3306` / Linux net-tools `0.0.0.0:3306`; netstat sees root-owned listeners that lsof (non-root) hides
    netstat -an 2>/dev/null | awk -v p="$p" '$NF ~ /LISTEN/ && $4 ~ ("[.:]" p "$")' | grep -q . && return 0
  fi
  # connect probe as a last resort (catches anything the tools above missed)
  (exec 3<>"/dev/tcp/127.0.0.1/$p") 2>/dev/null && return 0
  return 1
}

port_owner() {  # best-effort description of the listener
  local p="$1" out=""
  if command -v lsof >/dev/null 2>&1; then
    out="$(lsof -nP -iTCP:"$p" -sTCP:LISTEN 2>/dev/null | awk 'NR>1 {print $1"(pid "$2")"}' | sort -u | tr '\n' ' ')"
  fi
  if [ -z "$out" ] && [ "$(uname -s)" = "Darwin" ]; then
    # macOS: `netstat -anv` shows the listener as `name:pid` in a trailing column, also for root-owned processes
    out="$(netstat -anv -p tcp 2>/dev/null \
          | awk -v p="$p" '$4 ~ ("[.:]" p "$") && $6=="LISTEN" { for (i=7; i<=NF; i++) if ($i ~ /^[A-Za-z0-9_.-]+:[0-9]+$/) print $i }' \
          | sort -u | while IFS=: read -r name pid; do
              printf '%s(pid %s, user %s) ' "$name" "$pid" "$(ps -o user= -p "$pid" 2>/dev/null | tr -d ' ')"
            done)"
  fi
  [ -n "$out" ] && printf '%s' "$out" || printf 'unknown process (try: sudo lsof -nP -iTCP:%s -sTCP:LISTEN)' "$p"
}

bold() { printf '\033[1m%s\033[0m\n' "$*"; }
ok()   { printf '  \033[32m✔\033[0m %s\n' "$*"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$*"; }
fail() { printf '  \033[31m✘\033[0m %s\n' "$*" >&2; }
