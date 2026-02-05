# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and this project adheres to [Semantic Versioning](https://semver.org/).

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
