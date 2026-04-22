#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE_HTML="$REPO_DIR/index.html"
TARGET_HTML="/app/index.html"

# Stage the reference implementation where the verifier serves the app.
mkdir -p /app
cp "$SOURCE_HTML" "$TARGET_HTML"

# Verify the staged app still contains the required task contract.
grep -Fq "<title>Transport Quote Form</title>" "$TARGET_HTML"
grep -Fq "Transport car pickup and destination." "$TARGET_HTML"
grep -Fq "Destination" "$TARGET_HTML"
grep -Fq "Vehicle" "$TARGET_HTML"
grep -Fq "VEHICLE DETAILS" "$TARGET_HTML"
grep -Fq "SAVE Calculate Cost" "$TARGET_HTML"
grep -Fq 'aria-label="Pickup"' "$TARGET_HTML"
grep -Fq 'aria-label="Delivery"' "$TARGET_HTML"
grep -Fq 'aria-label="Vehicle Year"' "$TARGET_HTML"
grep -Fq 'aria-label="Vehicle Make"' "$TARGET_HTML"
grep -Fq 'aria-label="Vehicle Model"' "$TARGET_HTML"
grep -Eq 'id="vehicle-model"[\s\S]*disabled|disabled[\s\S]*id="vehicle-model"' "$TARGET_HTML"
grep -Fq "Please enter both pickup and delivery locations." "$TARGET_HTML"
grep -Fq 'list="vehicle-year-options"' "$TARGET_HTML"
grep -Fq "for (let year = currentYear; year >= 1980; year -= 1)" "$TARGET_HTML"
grep -Fq "Toyota" "$TARGET_HTML"
grep -Fq "Camry" "$TARGET_HTML"
grep -Fq "Corolla" "$TARGET_HTML"
grep -Fq "RAV4" "$TARGET_HTML"
grep -Fq "Tacoma" "$TARGET_HTML"
grep -Fq "populateModels" "$TARGET_HTML"

# Keep the workspace copy aligned with the staged app for easier inspection.
cp "$TARGET_HTML" /workspace/index.html

echo "Oracle solution staged successfully at $TARGET_HTML"
