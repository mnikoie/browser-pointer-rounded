#!/bin/bash
set -euo pipefail
if [[ "$(uname -s)" != Darwin ]]; then echo 'This script requires macOS.' >&2; exit 1; fi
APP="$HOME/Applications/Mousecape.app"
[[ -d "$APP" ]] || APP=/Applications/Mousecape.app
if [[ ! -d "$APP" ]]; then echo 'Mousecape was not found.' >&2; exit 1; fi
/usr/bin/open -a "$APP"
/usr/bin/osascript -e 'display dialog "In Mousecape, choose File > Reset System Cursor. If you enabled Launch at Login for this theme, turn it off in Mousecape settings. This leaves Mousecape and your other themes installed." buttons {"OK"} default button "OK" with title "Restore Apple cursors"' >/dev/null
