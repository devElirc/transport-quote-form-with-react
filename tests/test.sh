#!/bin/bash
set -uo pipefail

SCRIPT_PATH="${BASH_SOURCE[0]:-$0}"
TEST_DIR="${TEST_DIR:-$(cd "$(dirname "$SCRIPT_PATH")" && pwd)}"

mkdir -p /logs/verifier

# Verifier entrypoint (Harbor runs this script).
#
# Behavioral verification is implemented as:
# - Vitest unit tests: /tests/unit/transport-quote-form.spec.ts
# - Playwright E2E tests: /tests/e2e/transport-quote-form.spec.ts
#
# This script orchestrates installs and runs `npm run test` from the harness directory.

EXIT_CODE=0

# ---------------------------------------------------------------------------
# 1) Agent app contract (/app)
# ---------------------------------------------------------------------------
if [ ! -f /app/index.html ]; then
  echo "Error: /app/index.html not found." >&2
  echo 0 > /logs/verifier/reward.txt
  exit 1
fi

# ---------------------------------------------------------------------------
# 2) Verifier test harness
# ---------------------------------------------------------------------------
if [ "$EXIT_CODE" -eq 0 ]; then
  cd "$TEST_DIR"
  npm install --no-fund --no-audit || EXIT_CODE=$?
fi

if [ "$EXIT_CODE" -eq 0 ]; then
  npm run test || EXIT_CODE=$?
fi

(exit "$EXIT_CODE")
if [ $? -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
  exit 0
else
  echo 0 > /logs/verifier/reward.txt
  exit 1
fi
