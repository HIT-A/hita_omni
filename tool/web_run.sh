#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
exec "${FLUTTER:-flutter}" run -d chrome --no-web-resources-cdn "$@"
