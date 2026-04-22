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

INSTALL_EXIT=0
if [ -f package-lock.json ]; then
  npm ci || INSTALL_EXIT=$?
else
  npm install || INSTALL_EXIT=$?
fi

export DEBIAN_FRONTEND=noninteractive
PW_DEPS_EXIT=0
PW_BROWSER_EXIT=0
npx playwright install-deps chromium || PW_DEPS_EXIT=$?
npx playwright install chromium || PW_BROWSER_EXIT=$?

# Stage the app HTML where Playwright serves from.
mkdir -p "$APP_DIR"
if [ ! -f "$WORKSPACE_DIR/index.html" ]; then
  echo "Expected $WORKSPACE_DIR/index.html to exist." >&2
  echo 0 > "$REWARD_FILE"
  exit 0
fi
cp "$WORKSPACE_DIR/index.html" "$APP_DIR/index.html"

UNIT_EXIT=0
E2E_EXIT=0
npm run test || UNIT_EXIT=$?
npm run test:e2e || E2E_EXIT=$?

if [ "$INSTALL_EXIT" -eq 0 ] && [ "$PW_DEPS_EXIT" -eq 0 ] && [ "$PW_BROWSER_EXIT" -eq 0 ] && [ "$UNIT_EXIT" -eq 0 ] && [ "$E2E_EXIT" -eq 0 ]; then
  echo 1 > "$REWARD_FILE"
else
  echo 0 > "$REWARD_FILE"
fi

[ "$INSTALL_EXIT" -eq 0 ] && [ "$PW_DEPS_EXIT" -eq 0 ] && [ "$PW_BROWSER_EXIT" -eq 0 ] && [ "$UNIT_EXIT" -eq 0 ] && [ "$E2E_EXIT" -eq 0 ]
