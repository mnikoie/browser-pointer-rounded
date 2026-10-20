# Browser Pointer Rounded

A compact dark pointer with rounded corners, a white border and a fine blue edge. Includes Windows and macOS versions of the same approved design.

![Cursor preview](Preview.png)

## Download

Use the files in [Releases](../../releases/latest).

- **Windows:** extract `Browser-Pointer-Rounded-Windows.zip` and run `Install.cmd`. Use `Restore.cmd` to restore your previous configuration.
- **macOS 14+:** extract `Browser-Pointer-Rounded-macOS.zip`, then double-click `Install.command`. It downloads Mousecape from its upstream release, verifies the SHA-256, and opens the cape. Select **Browser Pointer Rounded → Apply** in Mousecape.
- **macOS PKG:** install the PKG, then open **Browser Pointer Rounded** in Applications to run the setup above. A DMG contains the same PKG.

For persistence on macOS, enable **Launch at Login** in Mousecape settings. To reset, use Mousecape's **File → Reset System Cursor** and turn off the login option if no longer needed. `Restore.command` opens the app and explains these steps; it does not silently delete other themes.

The macOS installer uses [Mousecape SwiftUI](https://github.com/sdmj76/Mousecape-swiftUI), downloaded separately rather than redistributed. It keeps normal macOS security checks enabled. The PKG is not Developer ID signed or notarized; the launcher bundle has an ad-hoc integrity signature. No Apple credentials are included.

## Contents and validation

Windows contains 15 CUR roles (32, 48, 64 and 96 pixel resources) plus two animated ANI alternatives. The Windows assets were accepted by the native Windows cursor loader.

macOS contains 14 corresponding roles mapped to 39 cursor identifiers, including ArrowS/IBeamS aliases. PNG strips provide 1x, 2x and 3x representations, and 12 frames for busy/working animations. macOS has no corresponding general-purpose Windows handwriting role; Copy, Alias, grab hands and other specialized Mac roles keep their defaults.

`tools/validate_macos.py` verifies plist contents, PNG dimensions and alpha, hotspot bounds and animation diversity. GitHub Actions validates the cape and shell syntax on a macOS runner and builds the PKG/DMG. These checks do not replace interactive testing of cursor appearance in applications; actual activation has not been tested on a personal Mac.

## Rebuild the macOS cape

```sh
python -m pip install Pillow==12.3.0
python tools/build_macos.py
python tools/validate_macos.py
```

The geometry source is `tools/artwork.py`. Mousecape format and cursor identifiers were checked against upstream `MCDefs.m` and `apply.m`. No third-party Mousecape source or executable is bundled here.

راهنمای فارسی نصب در فایل `macOS/README-fa.txt` موجود است.
