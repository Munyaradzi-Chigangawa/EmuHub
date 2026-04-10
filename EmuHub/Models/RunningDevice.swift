//
//  RunningDevice.swift
//  EmuHub
//
//  Created by Munyaradzi Chigangawa on 5/2/2026.
//

import Foundation

struct RunningDevice: Identifiable, Hashable {
    var id: String { serial }
    let serial: String
    let state: String

    /// For emulators: the resolved AVD name (e.g. "Pixel_7_API_34"), populated after launch.
    var avdName: String? = nil

    /// For physical devices: model name from `ro.product.model` (e.g. "Pixel 8 Pro").
    var model: String? = nil

    /// For physical devices: Android version from `ro.build.version.release` (e.g. "14").
    var androidVersion: String? = nil

    enum Kind: String {
        case emulator
        case physical
    }

    var kind: Kind { serial.hasPrefix("emulator-") ? .emulator : .physical }

    var isEmulator: Bool { kind == .emulator }
    var isUnauthorized: Bool { state == "unauthorized" }
    var isOffline: Bool { state == "offline" }

    enum ConnectionType {
        case usb
        case wifi
    }

    /// Detects USB vs Wi-Fi based on the ADB serial format.
    /// Covers three Wi-Fi serial formats:
    ///   - Android 11+ TLS wireless debugging: `adb-<id>-<hash>._adb-tls-connect._tcp`
    ///   - Legacy `adb connect` IPv4: `192.168.x.x:5555`
    ///   - Legacy `adb connect` IPv6: `[::1]:5555`
    var connectionType: ConnectionType {
        guard !isEmulator else { return .usb }
        if serial.contains("._adb-tls-connect._tcp") { return .wifi }
        if serial.range(of: #"^\d{1,3}(\.\d{1,3}){3}:\d+$"#, options: .regularExpression) != nil { return .wifi }
        if serial.range(of: #"^\[.*\]:\d+$"#, options: .regularExpression) != nil { return .wifi }
        return .usb
    }

    /// Heuristic: consider it a tablet if the model name contains known tablet keywords.
    var isTablet: Bool {
        guard let model else { return false }
        let lower = model.lowercased()
        return lower.contains("tab") || lower.contains("pad") || lower.contains("slate")
    }
}
