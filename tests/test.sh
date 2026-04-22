#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

if [ -f package-lock.json ]; then
  npm ci
else
  npm install
fi

export DEBIAN_FRONTEND=noninteractive
npx playwright install-deps chromium
npx playwright install chromium

# Agents usually edit the task workspace. Mirror that file into /app so the
# unit-test fallback path and the Playwright web server both validate the same page.
if [ -f /workspace/index.html ]; then
  mkdir -p /app
  cp /workspace/index.html /app/index.html
elif [ -f /app/index.html ]; then
  cp /app/index.html /workspace/index.html
fi

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
