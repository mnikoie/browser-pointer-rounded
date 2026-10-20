# Changelog

## 1.2.1

- Widen the purple halo with a smoother, more transparent falloff.
- Soften the inner glow and fade before canvas edges to avoid clipping.

## 1.2.0

- Add a soft purple halo to all Windows and macOS cursor roles and animation frames.
- Preserve rounded geometry, white borders, hotspots and resource sizes.
- Add a reproducible Windows asset builder using the shared artwork source.
- Link the project introduction on DEV.

## 1.1.1

- Validate the complete Windows cursor manifest and required files before writing settings.
- Copy cursor files individually so reinstalling cannot create nested cursor folders.
- Refresh the restore backup after switching to another theme, while retaining the original backup during updates.
- Roll back cursor registry values if installation or refresh fails.
- Add `-WhatIf` support to the Windows PowerShell installer and restore scripts.
- Validate restored backup roles before changing cursor settings.
- Add Windows registry round-trip tests under an isolated test key and automatic asset checks on pushes and pull requests.
- Read the macOS PKG version from `VERSION` instead of a hardcoded value.

## 1.1.0

- Rounded cursor artwork for Windows and macOS.
- Windows CUR/ANI resources and per-user install/restore scripts.
- Retina cape, macOS installer launcher, PKG and DMG.
