#!/bin/bash
set -euo pipefail

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
  if [ -f package-lock.json ]; then
    npm ci || EXIT_CODE=$?
  else
    npm install || EXIT_CODE=$?
  fi
fi

if [ "$EXIT_CODE" -eq 0 ]; then
  npm run test || EXIT_CODE=$?
fi

if [ "$EXIT_CODE" -eq 0 ]; then
  npm run test:e2e || EXIT_CODE=$?
fi

if [ "$EXIT_CODE" -eq 0 ]; then
  # Run a small pytest verifier as well (keeps checks aligned with the
  # standard Harbor verifier expectations while still using Playwright).
  #
  # Do not change anything below this line except adding additional Python deps.
  curl -LsSf https://astral.sh/uv/0.9.5/install.sh | sh
  # shellcheck disable=SC1091
  source "$HOME/.local/bin/env"

  uvx \
    -p 3.13 \
    -w pytest==8.4.1 \
    -w pytest-json-ctrf==0.3.5 \
    pytest --ctrf /logs/verifier/ctrf.json /tests/test_outputs.py -rA || EXIT_CODE=$?
fi

if [ "$EXIT_CODE" -eq 0 ]; then
  echo 1 > "$REWARD_FILE"
else
  echo 0 > "$REWARD_FILE"
fi

exit "$EXIT_CODE"
