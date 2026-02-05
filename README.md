# EmuHub

EmuHub is a lightweight macOS **menu bar utility** for managing Android Emulators (AVDs) and viewing connected Android devices.

It allows you to start, monitor, and stop Android emulators directly from the macOS menu bar — without touching the Terminal — while also showing the status of any connected physical Android devices.

---

## Screenshots

![Menu Bar](docs/screenshots/EmuHub.png)

## ✨ Features

- macOS menu bar–only application
- List available Android Virtual Devices (AVDs)
- Start emulators with configurable launch arguments
- Detect **running Android emulators** using `adb`
- Detect **connected physical Android devices**
- Stop emulators cleanly using `adb emu kill`
- Display physical device states:
  - `device`
  - `unauthorized`
  - `offline`
- Helpful messaging when USB debugging has not been authorized
- Settings panel for Android SDK path and emulator options
- Optional automatic refresh of emulator and device state
- Launch at login support

---

## 📦 Installation

### macOS (Manual Install)

1. Download the latest release from **GitHub Releases**
2. Unzip `EmuHub-macOS.zip`
3. Drag **EmuHub.app** into the **Applications** folder
4. First launch:
   - Right-click **EmuHub.app** → **Open** → **Open**
   - Or go to **System Settings → Privacy & Security → Open Anyway**

> **Note:** The app is currently signed with an Apple Personal Team and is **not notarized**.  
> macOS may display a security warning on first launch — this is expected.

---

## 🖥️ System Requirements

- macOS 13.0 (Ventura) or newer
- Android SDK installed  
  - Default location: `~/Library/Android/sdk`
- Android Emulator & `adb` available
- USB debugging enabled on physical devices (optional)

---

## ⚙️ Configuration

### Android SDK

EmuHub automatically attempts to locate the Android SDK.

If detection fails, you can manually set the SDK path in **Settings**:


### Emulator Launch Arguments

You can customize emulator startup behavior using additional arguments, for example:

```bash
/Library/Android/sdk
```

---

## 🚀 Usage

- Click the **EmuHub** icon in the macOS menu bar
- The **Running** section displays:
  - Active emulators (with a Stop action)
  - Connected physical devices (read-only)
- If a physical device is marked **unauthorized**:
  1. Unlock the device
  2. Accept the USB debugging prompt on the device
- Start new emulators from the **Available** section
- Open **Settings** to configure SDK path, refresh interval, and startup behavior

---

## 🔌 Physical Devices

EmuHub intentionally treats physical devices as **read-only**.

- Physical devices are shown for visibility only
- Emulator-only actions (such as Stop) are not available for phones or tablets
- Physical devices cannot be stopped or controlled through EmuHub

To remove a physical device from the list:
- Unplug the USB cable, or
- Disable USB debugging on the device

This design prevents accidental or unsafe actions on real hardware.

---

## 🛠️ Development

### Built With

- Swift
- SwiftUI
- macOS MenuBarExtra API
- Android `adb` and Emulator CLI tools

### Run Locally

```bash
git clone https://github.com/Munyaradzi-Chigangawa/EmuHub.git
cd EmuHub
open EmuHub.xcodeproj
```
