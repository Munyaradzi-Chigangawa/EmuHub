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

    enum Kind: String {
        case emulator
        case physical
    }

    var kind: Kind { serial.hasPrefix("emulator-") ? .emulator : .physical }

    var isEmulator: Bool { kind == .emulator }
    var isUnauthorized: Bool { state == "unauthorized" }
    var isOffline: Bool { state == "offline" }
}
