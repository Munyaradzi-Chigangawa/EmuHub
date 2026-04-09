//
//  AdbService.swift
//  EmuHub
//
//  Created by Munyaradzi Chigangawa on 27/1/2026.
//

import Foundation

struct AdbService {

    // MARK: - Device Listing

    func listRunning(adbPath: String) async throws -> [RunningDevice] {
        _ = try? await Shell.run(adbPath, ["start-server"])

        let res = try await Shell.run(adbPath, ["devices"])
        let lines = res.stdout.split(whereSeparator: \.isNewline).map(String.init)

        return lines
            .dropFirst()
            .compactMap { line -> RunningDevice? in
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return nil }

                let parts = trimmed.split(whereSeparator: \.isWhitespace).map(String.init)
                guard parts.count >= 2 else { return nil }

                return RunningDevice(serial: parts[0], state: parts[1])
            }
    }

    // MARK: - Emulator Control

    func stopEmulator(adbPath: String, serial: String) async throws {
        _ = try? await Shell.run(adbPath, ["start-server"])
        _ = try await Shell.run(adbPath, ["-s", serial, "emu", "kill"])
    }

    // MARK: - Device Property Queries

    /// Returns the AVD name for a running emulator via `adb emu avd name`.
    /// Output is typically "AVD_Name\nOK" — we return the first non-empty, non-"OK" line.
    func getEmulatorAVDName(adbPath: String, serial: String) async throws -> String? {
        let res = try await Shell.run(adbPath, ["-s", serial, "emu", "avd", "name"])
        return res.stdout
            .split(whereSeparator: \.isNewline)
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty && $0 != "OK" }
    }

    /// Reads a single system property from a connected device.
    func getDeviceProperty(adbPath: String, serial: String, prop: String) async throws -> String? {
        let res = try await Shell.run(adbPath, ["-s", serial, "shell", "getprop", prop])
        let value = res.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }

    // MARK: - Screenshot

    /// Captures a screenshot from the device and saves it to the Mac Desktop.
    /// Returns the saved file URL.
    func captureScreenshot(adbPath: String, serial: String) async throws -> URL {
        let timestamp = Int(Date().timeIntervalSince1970)
        let devicePath = "/sdcard/emuhub_ss_\(timestamp).png"
        let desktopURL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Desktop")
            .appendingPathComponent("EmuHub_Screenshot_\(timestamp).png")

        // Capture to device storage
        _ = try await Shell.run(adbPath, ["-s", serial, "shell", "screencap", "-p", devicePath])

        // Pull the PNG to Desktop
        _ = try await Shell.run(adbPath, ["-s", serial, "pull", devicePath, desktopURL.path])

        // Clean up from device (best effort)
        _ = try? await Shell.run(adbPath, ["-s", serial, "shell", "rm", devicePath])

        return desktopURL
    }

    // MARK: - APK Installation

    /// Installs an APK onto a connected device or emulator.
    /// Uses `-r` to allow reinstalling over an existing package.
    func installAPK(adbPath: String, serial: String, apkURL: URL) async throws {
        _ = try await Shell.run(adbPath, ["-s", serial, "install", "-r", apkURL.path])
    }
}
