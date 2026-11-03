#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
exec "${FLUTTER:-flutter}" build web --no-web-resources-cdn "$@"
