#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p dist .build/payload
version="$(cat VERSION)"
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo 'Invalid VERSION' >&2; exit 1; }
APP='.build/payload/Browser Pointer Rounded.app'
# A small native AppleScript launcher opens the reviewed installer in Terminal.
cat > .build/launcher.applescript <<'APPLESCRIPT'
on run
  set resourceFolder to (POSIX path of (path to me)) & "Contents/Resources/Pack/"
  do shell script "/usr/bin/open -a Terminal " & quoted form of (resourceFolder & "Install.command")
end run
APPLESCRIPT
osacompile -o "$APP" .build/launcher.applescript
mkdir -p "$APP/Contents/Resources/Pack"
cp macOS/* "$APP/Contents/Resources/Pack/"
chmod +x "$APP/Contents/Resources/Pack/"*.command
# Ad-hoc signing verifies local bundle integrity, without claiming notarization.
codesign --force --deep --sign - "$APP"
pkgbuild --root .build/payload --identifier com.mnikoie.browser-pointer-rounded.installer \
  --version "$version" --install-location /Applications \
  dist/Browser-Pointer-Rounded-macOS.pkg
mkdir -p .build/dmg
cp dist/Browser-Pointer-Rounded-macOS.pkg .build/dmg/
cp macOS/README-fa.txt .build/dmg/
hdiutil create -volname 'Browser Pointer Rounded' -srcfolder .build/dmg \
  -ov -format UDZO dist/Browser-Pointer-Rounded-macOS.dmg
pkgutil --check-signature dist/Browser-Pointer-Rounded-macOS.pkg || true
