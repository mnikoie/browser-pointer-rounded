# Contributing

Reports and suggestions in English or Persian are welcome. Use [Issues](https://github.com/mnikoie/browser-pointer-rounded/issues) and include the operating system version and display scaling. For installation problems, include the installer format and error message. Do not include account tokens or private file contents.

To change the artwork, edit `tools/artwork.py`. Generate and validate the macOS cape:

```sh
python -m pip install Pillow==12.3.0
python tools/build_macos.py
python tools/validate_macos.py
```

For a pull request, describe the changed cursor roles and include before/after images at normal and enlarged sizes. Check transparent edges, click hotspots and readability on light and dark backgrounds. State which operating systems you actually tested. For installer changes, check install and restore behavior on the target system.

The packaging workflow can build a macOS PKG/DMG for an existing release. It does not establish interactive compatibility with every Mac application.
