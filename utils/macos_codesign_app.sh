#!/usr/bin/env bash
#
# Codesign a Qt WebEngine .app inside-out (never `codesign --deep` with the
# outer app entitlements).
#
# `codesign --deep --entitlements <app.plist>` stamps the OUTER entitlements
# onto every nested binary. QtWebEngineProcess ships its own JIT entitlements;
# overwriting them blanks the WebEngine view (window opens, UI stays empty).
#
# Usage:
#   macos_codesign_app.sh <Pdc.app> [entitlements.plist]
#
# Environment:
#   SIGN_IDENTITY   codesign identity (default: "-" ad-hoc)
#   SIGN_OPTIONS    extra codesign flags, e.g. "--options runtime --timestamp"
#
set -euo pipefail

die() { echo "ERROR: $*" >&2; exit 1; }
note() { echo "==> $*"; }

APP="${1:?usage: $0 <App.app> [entitlements.plist]}"
ENTITLEMENTS="${2:-}"
[ -d "$APP" ] || die "not a bundle: $APP"

if [ -z "$ENTITLEMENTS" ]; then
  ENTITLEMENTS="$(cd "$(dirname "$0")" && pwd)/macos_entitlements.plist"
fi
[ -f "$ENTITLEMENTS" ] || die "entitlements not found: $ENTITLEMENTS"

SIGN_IDENTITY="${SIGN_IDENTITY:--}"
SIGN_OPTIONS="${SIGN_OPTIONS:-}"

codesign_it() {
  # macOS ships Bash 3.2: empty "${arr[@]}" under `set -u` is an unbound variable.
  # Expand optional flags only when set.
  if [ -n "$SIGN_OPTIONS" ]; then
    # shellcheck disable=SC2086
    codesign --force $SIGN_OPTIONS --sign "$SIGN_IDENTITY" "$@"
  else
    codesign --force --sign "$SIGN_IDENTITY" "$@"
  fi
}

note "clearing extended attributes on $APP"
xattr -cr "$APP" 2>/dev/null || true
find "$APP" -name '.DS_Store' -type f -delete 2>/dev/null || true

# 1. Qt WebEngine helper with the entitlements Qt ships for it.
helper="$(find "$APP/Contents" -type d -name 'QtWebEngineProcess.app' -print 2>/dev/null | head -1 || true)"
if [ -n "$helper" ]; then
  helper_entitlements="$helper/Contents/Resources/QtWebEngineProcess.entitlements"
  [ -f "$helper_entitlements" ] \
    || die "found $helper but not QtWebEngineProcess.entitlements"
  note "signing QtWebEngineProcess with its own entitlements"
  codesign_it --entitlements "$helper_entitlements" "$helper/Contents/MacOS/QtWebEngineProcess"
  codesign_it --entitlements "$helper_entitlements" "$helper"
else
  echo "WARNING: No QtWebEngineProcess.app under $APP/Contents (macdeployqt missing?)" >&2
fi

# 2. Loose libraries, deepest first.
while IFS= read -r item; do
  codesign_it "$item"
done < <(find "$APP/Contents" \( -name '*.dylib' -o -name '*.so' \) -type f | sort -r)

# 3. Frameworks / nested bundles, deepest first (helper already signed).
while IFS= read -r item; do
  case "$item" in
    */QtWebEngineProcess.app) continue ;;
  esac
  codesign_it "$item"
done < <(find "$APP/Contents" -type d \( -name '*.framework' -o -name '*.bundle' -o -name '*.appex' \) | sort -r)

# 4. Auxiliary executables in Contents/MacOS (pdcd, simplewallet, …).
main_executable="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$APP/Contents/Info.plist" 2>/dev/null || echo '')"
for item in "$APP"/Contents/MacOS/*; do
  [ -f "$item" ] || continue
  [ -x "$item" ] || continue
  if [ -n "$main_executable" ] && [ "$(basename "$item")" = "$main_executable" ]; then
    continue
  fi
  note "signing auxiliary $(basename "$item")"
  codesign_it --entitlements "$ENTITLEMENTS" "$item"
done

# 5. Outer bundle last.
note "signing $APP (identity=$SIGN_IDENTITY)"
codesign_it --entitlements "$ENTITLEMENTS" "$APP"

codesign --verify --verbose=2 "$APP" || true
note "codesign complete"
