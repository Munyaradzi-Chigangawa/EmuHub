# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and this project adheres to [Semantic Versioning](https://semver.org/).

---

## [Unreleased]
### Planned
- Developer ID signing and macOS notarization
- Homebrew cask installation
- Advanced emulator controls (cold boot, wipe data)
- Automatic update mechanism
- Grouped display of emulators and physical devices
- In-app help for USB debugging authorization
- Improved diagnostics and logging

---

## [1.1.3] - 2026-02-05
### Added
- Added an **About** section in Settings with:
  - App identity text
  - Runtime version/build display
  - Quick links to repository, changelog, and license

### Changed
- Updated menu header branding to **EmuHub**.
- Added compact header counts for emulator and physical device totals.
- Updated Running section empty-state message to **"No connected devices"** for clearer wording.
- Added footer refresh recency text (`Updated ...`) backed by tracked refresh timestamps.

### Fixed
- Improved physical-device status pill labeling to correctly show **Authorize**, **Offline**, or **Connected** instead of overly generic state wording.

## [1.1.2] - 2026-02-05
### Added
- Automated macOS CI build using GitHub Actions
- Automatic version tagging based on app version
- Automated GitHub Releases with downloadable `.app` archive
- CONTRIBUTING guidelines for open-source contributors
- Pull Request template
- CODEOWNERS file for repository governance

### Changed
- Introduced `dev → main` workflow for releases
- Enforced branch protection rules on `main`
- Improved open-source readiness and repository structure

### Fixed
- CI build failures caused by macOS signing requirements
- Release workflow not triggering on version tags

---

## [1.1.0] - 2026-02-05
### Added
- Display of connected physical Android devices alongside emulators
- Clear differentiation between Android emulators and physical devices
- Device state handling for physical devices (`device`, `unauthorized`, `offline`)
- Informative UI messaging for unauthorized devices (USB debugging not yet approved)

### Changed
- Running section now represents **all connected devices**, not just emulators
- Emulator-only actions are restricted to emulators
- Improved UX messaging instead of generic command failure errors

### Fixed
- Prevented `adb emu kill` from being executed on physical devices
- Eliminated misleading `Command failed (exit 1)` errors when phones are connected
- Improved safety checks around emulator stop actions

---

## [1.0.0] - 2026-01-29
### Added
- Initial public release of EmuHub
- macOS menu bar application for managing Android Emulators (AVDs)
- Detection of available Android Virtual Devices
- Ability to start emulators with configurable launch arguments
- Detection of running emulators via `adb`
- Clean shutdown of running emulators using `adb emu kill`
- Settings panel for Android SDK path and emulator options
- Automatic periodic refresh of emulator state

### Notes
- This release is signed with an Apple Personal Team and is not notarized
- macOS may prompt for security approval on first launch
- Designed for local developer use
