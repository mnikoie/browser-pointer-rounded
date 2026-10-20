#!/bin/bash
set -euo pipefail
cd -- "$(dirname -- "$0")"
if [[ "$(uname -s)" != Darwin ]]; then echo 'This installer requires macOS.' >&2; exit 1; fi
major="$(/usr/bin/sw_vers -productVersion | /usr/bin/cut -d. -f1)"
if (( major < 14 )); then echo 'This installer requires macOS 14 or later.' >&2; exit 1; fi

APP="$HOME/Applications/Mousecape.app"
if [[ ! -d "$APP" && -d /Applications/Mousecape.app ]]; then APP=/Applications/Mousecape.app; fi
if [[ ! -d "$APP" ]]; then
  echo 'Downloading Mousecape SwiftUI 1.2.0 from its upstream GitHub release...'
  tmp="$(/usr/bin/mktemp -d)"
  trap '/bin/rm -rf -- "$tmp"' EXIT
  /usr/bin/curl --fail --location --proto '=https' --tlsv1.2 --retry 3 \
    'https://github.com/sdmj76/Mousecape-swiftUI/releases/download/Swift_v1.2.0/Mousecape_swiftUI_v1.2.0.zip' \
    --output "$tmp/Mousecape.zip"
  echo '79dc0c46a8c10d44ec0e23259d26da2eeb2ab949249d3127ef72fcb6a66d6079  Mousecape.zip' > "$tmp/checksum"
  (cd "$tmp" && /usr/bin/shasum -a 256 -c checksum)
  /usr/bin/ditto -x -k "$tmp/Mousecape.zip" "$tmp/extracted"
  [[ -d "$tmp/extracted/Mousecape.app" ]] || { echo 'Missing upstream app.' >&2; exit 1; }
  /bin/mkdir -p "$HOME/Applications"
  /usr/bin/ditto "$tmp/extracted/Mousecape.app" "$APP"
fi

dest="$HOME/Library/Application Support/Browser Pointer Rounded"
/bin/mkdir -p "$dest"
/bin/cp -f './Browser-Pointer-Rounded.cape' "$dest/Browser-Pointer-Rounded.cape"
/bin/cp -f './Restore.command' "$dest/Restore.command"
/bin/chmod +x "$dest/Restore.command"
# Let macOS perform its normal app security checks; do not remove quarantine.
if ! /usr/bin/open -a "$APP" "$dest/Browser-Pointer-Rounded.cape"; then
  echo 'Open Mousecape from Applications, approve it in macOS if prompted, and run this installer again.' >&2
  exit 1
fi
echo 'The cape is now open in Mousecape. Select Browser Pointer Rounded and click Apply.'
echo 'For persistence, enable Launch at Login in Mousecape settings.'
echo 'To restore Apple cursors, run Restore.command.'
/usr/bin/osascript -e 'display dialog "Browser Pointer Rounded is ready in Mousecape. Select it and click Apply. To keep it after login, enable Launch at Login in Mousecape settings." buttons {"OK"} default button "OK" with title "Browser Pointer Rounded"' >/dev/null
