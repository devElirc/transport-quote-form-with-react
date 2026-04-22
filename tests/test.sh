#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

WORKSPACE_DIR="${WORKSPACE_DIR:-/workspace}"
APP_DIR="${APP_DIR:-/app}"

if [ -f package-lock.json ]; then
  npm ci
else
  npm install
fi

export DEBIAN_FRONTEND=noninteractive
npx playwright install-deps chromium
npx playwright install chromium

# Stage the app HTML where Playwright serves from.
mkdir -p "$APP_DIR"
if [ ! -f "$WORKSPACE_DIR/index.html" ]; then
  echo "Expected $WORKSPACE_DIR/index.html to exist." >&2
  exit 1
fi
cp "$WORKSPACE_DIR/index.html" "$APP_DIR/index.html"

UNIT_EXIT=0
E2E_EXIT=0
npm run test || UNIT_EXIT=$?
npm run test:e2e || E2E_EXIT=$?

mkdir -p /logs/verifier
REWARD_FILE="/logs/verifier/reward.txt"

if [ "$UNIT_EXIT" -eq 0 ] && [ "$E2E_EXIT" -eq 0 ]; then
  echo 1 > "$REWARD_FILE"
else
  echo 0 > "$REWARD_FILE"
fi

[ "$UNIT_EXIT" -eq 0 ] && [ "$E2E_EXIT" -eq 0 ]
