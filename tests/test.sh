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

if [ -f package-lock.json ]; then
  npm ci || EXIT_CODE=$?
else
  npm install || EXIT_CODE=$?
fi

# Stage the app HTML where Playwright serves from.
mkdir -p "$APP_DIR"
SOURCE_HTML=""
if SOURCE_HTML="$(find_source_html)"; then
  :
else
  echo "Could not find index.html in known locations." >&2
  echo "Tried: $WORKSPACE_DIR/index.html, /var/www/transport-quote-form-with-react/index.html, /workspace/transport-quote-form-with-react/index.html" >&2
  EXIT_CODE=1
fi
if [ "$EXIT_CODE" -eq 0 ]; then
  cp "$SOURCE_HTML" "$APP_DIR/index.html" || EXIT_CODE=$?
fi

set +e
npm run test || EXIT_CODE=$?
if [ "$EXIT_CODE" -eq 0 ]; then
  npm run test:e2e || EXIT_CODE=$?
fi
set -e

# Make the final $? match the test outcome (required by Harbor static checks).
if [ "$EXIT_CODE" -eq 0 ]; then
  true
else
  false
fi

if [ $? -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
