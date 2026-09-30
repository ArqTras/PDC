#!/usr/bin/env bash
#
# Homebrew's split Qt kegs leave QtWebEngineProcess linked against absolute
# /opt/homebrew/opt/qt*/lib/... paths. On end-user machines those paths are
# missing, so the helper never starts and QWebEngineView stays blank.
#
# Rewrite those load commands to @rpath/<Framework>/Versions/A/<lib>, matching
# the rpath macdeployqt already installs on the helper
# (@loader_path/../../../../../../../ → Contents/Frameworks).
#
# Also drop leftover Homebrew rpaths from the main executable / bundled libs.
#
# Usage:
#   macos_fix_qt_webengine_rpaths.sh <Pdc.app>
#
set -euo pipefail

die() { echo "ERROR: $*" >&2; exit 1; }
note() { echo "==> $*"; }

APP="${1:?usage: $0 <App.app>}"
[ -d "$APP/Contents" ] || die "not a bundle: $APP"

HELPER="$(find "$APP/Contents" -type f -path '*/QtWebEngineProcess.app/Contents/MacOS/QtWebEngineProcess' | head -1 || true)"
[ -n "$HELPER" ] || die "QtWebEngineProcess not found under $APP"

note "fixing absolute Homebrew Qt paths in $HELPER"
while IFS= read -r dep; do
  case "$dep" in
    /opt/homebrew/*|/usr/local/*)
      # /opt/homebrew/opt/qtbase/lib/QtCore.framework/Versions/A/QtCore
      # → @rpath/QtCore.framework/Versions/A/QtCore
      fw="$(printf '%s\n' "$dep" | sed -n 's|.*/\(Qt[^/]*\.framework/Versions/A/[^/]*\)$|\1|p')"
      if [ -z "$fw" ]; then
        echo "WARNING: unhandled absolute dep on helper: $dep" >&2
        continue
      fi
      new="@rpath/$fw"
      note "  $dep"
      note "    -> $new"
      install_name_tool -change "$dep" "$new" "$HELPER"
      ;;
  esac
done < <(otool -L "$HELPER" | awk 'NR>1 {print $1}')

# Ensure Frameworks is on the helper rpath (macdeployqt usually adds this).
if ! otool -l "$HELPER" | awk '/cmd LC_RPATH/{getline; getline; print $2}' | grep -qx '@loader_path/../../../../../../../'; then
  note "adding helper rpath to Contents/Frameworks"
  install_name_tool -add_rpath '@loader_path/../../../../../../../' "$HELPER" || true
fi

note "dropping Homebrew rpaths from bundled Mach-Os"
while IFS= read -r bin; do
  [ -f "$bin" ] || continue
  file "$bin" 2>/dev/null | grep -q 'Mach-O' || continue
  while IFS= read -r rp; do
    case "$rp" in
      /opt/homebrew/*|/usr/local/*|/Users/*)
        note "  -delete_rpath $rp  ($bin)"
        install_name_tool -delete_rpath "$rp" "$bin" 2>/dev/null || true
        ;;
    esac
  done < <(otool -l "$bin" 2>/dev/null | awk '/cmd LC_RPATH/{getline; getline; print $2}')
done < <(find "$APP/Contents" \( -name 'Pdc' -o -name 'QtWebEngineProcess' -o -name '*.dylib' \) -type f)

note "verifying QtWebEngineProcess has no absolute Homebrew deps"
if otool -L "$HELPER" | grep -E '/opt/homebrew/|/usr/local/opt/'; then
  echo "ERROR: QtWebEngineProcess still has absolute Homebrew linkage:" >&2
  otool -L "$HELPER" >&2
  exit 1
fi

note "Qt WebEngine rpaths fixed"
