#!/bin/bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

WORKSPACE_DIR="${WORKSPACE_DIR:-/workspace}"
APP_DIR="${APP_DIR:-/app}"

mkdir -p /logs/verifier
REWARD_FILE="/logs/verifier/reward.txt"

write_reward_if_missing() {
  if [ -f "$REWARD_FILE" ]; then
    return 0
  fi
  echo 0 > "$REWARD_FILE"
}

trap write_reward_if_missing EXIT

log() {
  echo "verifier: $*"
}

find_source_html() {
  # Common harness locations.
  local candidates=(
    "$WORKSPACE_DIR/index.html"
    "/var/www/transport-quote-form-with-react/index.html"
    "/workspace/transport-quote-form-with-react/index.html"
    "/app/index.html"
  )

  for p in "${candidates[@]}"; do
    if [ -f "$p" ]; then
      echo "$p"
      return 0
    fi
  done

  return 1
}

INSTALL_EXIT=0
if [ -f package-lock.json ]; then
  log "npm ci (from $PWD)"
  npm ci || INSTALL_EXIT=$?
else
  log "npm install (from $PWD)"
  npm install || INSTALL_EXIT=$?
fi

export DEBIAN_FRONTEND=noninteractive
PW_DEPS_EXIT=0
PW_BROWSER_EXIT=0
log "playwright browsers are preinstalled in the image"

# Stage the app HTML where Playwright serves from.
mkdir -p "$APP_DIR"
SOURCE_HTML=""
if SOURCE_HTML="$(find_source_html)"; then
  log "staging $SOURCE_HTML -> $APP_DIR/index.html"
else
  echo "Could not find index.html in known locations." >&2
  echo "Tried: $WORKSPACE_DIR/index.html, /var/www/transport-quote-form-with-react/index.html, /workspace/transport-quote-form-with-react/index.html, /app/index.html" >&2
  echo 0 > "$REWARD_FILE"
  exit 0
fi
cp "$SOURCE_HTML" "$APP_DIR/index.html"

UNIT_EXIT=0
E2E_EXIT=0
log "running unit tests (vitest)"
npm run test || UNIT_EXIT=$?
log "running e2e tests (playwright)"
npm run test:e2e || E2E_EXIT=$?

log "exit codes: npm_install=$INSTALL_EXIT pw_deps=$PW_DEPS_EXIT pw_browser=$PW_BROWSER_EXIT unit=$UNIT_EXIT e2e=$E2E_EXIT"

if [ "$INSTALL_EXIT" -eq 0 ] && [ "$PW_DEPS_EXIT" -eq 0 ] && [ "$PW_BROWSER_EXIT" -eq 0 ] && [ "$UNIT_EXIT" -eq 0 ] && [ "$E2E_EXIT" -eq 0 ]; then
  echo 1 > "$REWARD_FILE"
else
  echo 0 > "$REWARD_FILE"
fi

[ "$INSTALL_EXIT" -eq 0 ] && [ "$PW_DEPS_EXIT" -eq 0 ] && [ "$PW_BROWSER_EXIT" -eq 0 ] && [ "$UNIT_EXIT" -eq 0 ] && [ "$E2E_EXIT" -eq 0 ]
