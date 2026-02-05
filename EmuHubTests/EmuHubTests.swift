//
//  EmuHubTests.swift
//  EmuHubTests
//
//  Created by Munyaradzi Chigangawa on 27/1/2026.
//

import Testing
@testable import EmuHub

struct EmuHubTests {

    @Test("RunningDevice classifies emulators by serial prefix")
    func runningDeviceClassifiesKindsCorrectly() {
        let emulator = RunningDevice(serial: "emulator-5554", state: "device")
        let phone = RunningDevice(serial: "R58M123456", state: "device")

        #expect(emulator.kind == .emulator)
        #expect(emulator.isEmulator)
        #expect(phone.kind == .physical)
        #expect(!phone.isEmulator)
    }

    @Test("RunningDevice exposes unauthorized and offline states")
    func runningDeviceStateFlags() {
        let unauthorized = RunningDevice(serial: "ABC123", state: "unauthorized")
        let offline = RunningDevice(serial: "ABC123", state: "offline")
        let connected = RunningDevice(serial: "ABC123", state: "device")

        #expect(unauthorized.isUnauthorized)
        #expect(!unauthorized.isOffline)

        #expect(offline.isOffline)
        #expect(!offline.isUnauthorized)

        #expect(!connected.isUnauthorized)
        #expect(!connected.isOffline)
    }

    @Test("AndroidToolchain.defaultMacSdkPath points under user Library")
    func defaultSdkPathLooksReasonable() {
        let path = AndroidToolchain.defaultMacSdkPath()
        #expect(path.hasSuffix("/Library/Android/sdk"))
    }
}
