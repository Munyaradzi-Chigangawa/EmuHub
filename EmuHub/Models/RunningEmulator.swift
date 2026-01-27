//
//  RunningEmulator.swift
//  EmuHub
//
//  Created by Munyaradzi Chigangawa on 27/1/2026.
//

struct RunningEmulator: Identifiable, Hashable {
    var id: String { serial }
    let serial: String
    let state: String
}
