#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

mkdir -p /app
cp "$SCRIPT_DIR/index.html" /app/index.html
