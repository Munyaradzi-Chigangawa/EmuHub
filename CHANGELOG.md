# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and this project adheres to [Semantic Versioning](https://semver.org/).

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
- Emulator advanced controls (cold boot, wipe data)
- Automatic update mechanism
- Improved emulator–AVD mapping and diagnostics

