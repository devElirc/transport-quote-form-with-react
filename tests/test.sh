#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

TEST_DIR="${TEST_DIR:-/tests}"
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

# Safety net: if anything goes wrong, still emit a reward file.
trap write_reward_if_missing EXIT

find_source_html() {
  # Common harness locations.
  local candidates=(
    "$WORKSPACE_DIR/index.html"
    "/var/www/transport-quote-form-with-react/index.html"
    "/workspace/transport-quote-form-with-react/index.html"
  )

  for p in "${candidates[@]}"; do
    if [ -f "$p" ]; then
      echo "$p"
      return 0
    fi
  done

  return 1
}

EXIT_CODE=0

SOURCE_HTML=""
if SOURCE_HTML="$(find_source_html)"; then
  :
else
  echo "Could not find index.html in known locations." >&2
  echo "Tried: $WORKSPACE_DIR/index.html, /var/www/transport-quote-form-with-react/index.html, /workspace/transport-quote-form-with-react/index.html" >&2
  EXIT_CODE=1
fi

# Stage the app HTML where Playwright serves from.
if [ "$EXIT_CODE" -eq 0 ]; then
  mkdir -p "$APP_DIR"
  cp "$SOURCE_HTML" "$APP_DIR/index.html" || EXIT_CODE=$?
fi

if [ "$EXIT_CODE" -eq 0 ]; then
  cd "$TEST_DIR"
  if [ -f package-lock.json ]; then
    npm ci --no-fund --no-audit || EXIT_CODE=$?
  else
    npm install --no-fund --no-audit || EXIT_CODE=$?
  fi
fi

if [ "$EXIT_CODE" -eq 0 ]; then
  npm run test || EXIT_CODE=$?
fi

if [ "$EXIT_CODE" -eq 0 ]; then
  npm run test:e2e || EXIT_CODE=$?
fi

if [ "$EXIT_CODE" -eq 0 ]; then
  echo 1 > "$REWARD_FILE"
else
  echo 0 > "$REWARD_FILE"
fi

exit "$EXIT_CODE"
