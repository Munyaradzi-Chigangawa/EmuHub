//
//  README.md
//  EmuHub
//
//  Created by Munyaradzi Chigangawa on 29/1/2026.
//

# EmuHub

EmuHub is a lightweight macOS **menu bar utility** for managing Android Emulators (AVDs).

It allows you to start, monitor, and stop Android emulators directly from the macOS menu bar — without touching the Terminal.

---

## ✨ Features

- macOS menu bar–only application
- List available Android Virtual Devices (AVDs)
- Start emulators with configurable launch arguments
- Detect running emulators using `adb`
- Stop emulators cleanly (`adb emu kill`)
- Settings panel for SDK path and emulator options
- Optional automatic refresh of emulator state
- Launch at login support

---

//## 📸 Preview
//
//> EmuHub runs entirely from the macOS menu bar, similar to developer utilities like IDE toolboxes.
//
//*(Screenshots/GIFs can be added here in future releases)*
//
//---

## 📦 Installation

### macOS (Manual Install)
1. Download the latest release from **GitHub Releases**
2. Unzip `EmuHub-macOS.zip`
3. Drag **EmuHub.app** into the **Applications** folder
4. First launch:
   - Right-click **EmuHub.app** → **Open** → **Open**
   - Or go to **System Settings → Privacy & Security → Open Anyway**

> **Note:** The app is currently not notarized (signed with a Personal Team). macOS may show a warning on first launch — this is expected.

---

## 🖥️ System Requirements

- macOS 13.0 (Ventura) or newer
- Android SDK installed
  - Default location: `~/Library/Android/sdk`
- Android Emulator & `adb` available

---

## ⚙️ Configuration

### Android SDK
EmuHub automatically attempts to locate the Android SDK.
If detection fails, you can manually set the SDK path in **Settings**:

