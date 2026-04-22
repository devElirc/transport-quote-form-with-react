#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

WORKSPACE_DIR="${WORKSPACE_DIR:-/workspace}"
APP_DIR="${APP_DIR:-/app}"

mkdir -p /logs/verifier

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

if [ -f package-lock.json ]; then
  npm ci
else
  npm install
fi

# Stage the app HTML where Playwright serves from.
mkdir -p "$APP_DIR"
SOURCE_HTML=""
if SOURCE_HTML="$(find_source_html)"; then
  :
else
  echo "Could not find index.html in known locations." >&2
  echo "Tried: $WORKSPACE_DIR/index.html, /var/www/transport-quote-form-with-react/index.html, /workspace/transport-quote-form-with-react/index.html" >&2
  false
fi
cp "$SOURCE_HTML" "$APP_DIR/index.html"

set +e
npm run test && npm run test:e2e
TEST_EXIT=$?
set -e

# Make the final $? match the test outcome (required by Harbor static checks).
if [ "$TEST_EXIT" -eq 0 ]; then
  true
else
  false
fi

if [ $? -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
