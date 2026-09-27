#!/usr/bin/env bash
# Compatibility wrapper: ad-hoc inside-out codesign for CI/local.
set -euo pipefail
export SIGN_IDENTITY="${SIGN_IDENTITY:--}"
export SIGN_OPTIONS="${SIGN_OPTIONS:-}"
exec "$(cd "$(dirname "$0")" && pwd)/macos_codesign_app.sh" "$@"
