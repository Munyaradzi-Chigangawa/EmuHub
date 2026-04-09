//
//  RunningDevice.swift
//  EmuHub
//
//  Created by Munyaradzi Chigangawa on 5/2/2026.
//

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

    /// Heuristic: consider it a tablet if the model name contains known tablet keywords.
    var isTablet: Bool {
        guard let model else { return false }
        let lower = model.lowercased()
        return lower.contains("tab") || lower.contains("pad") || lower.contains("slate")
    }
}
