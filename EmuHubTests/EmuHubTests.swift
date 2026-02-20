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

    @Test("ReleaseUpdateService normalizes tags and compares semantic versions")
    func releaseVersionComparison() {
        let normalized = ReleaseUpdateService.normalizedVersion(from: "v1.2.3")
        #expect(normalized == "1.2.3")

        #expect(ReleaseUpdateService.compareVersion("1.2.3", "1.2.4") == .orderedAscending)
        #expect(ReleaseUpdateService.compareVersion("1.2.4", "1.2.3") == .orderedDescending)
        #expect(ReleaseUpdateService.compareVersion("1.2.0", "1.2") == .orderedSame)
    }

    @Test("ReleaseUpdateService ignores metadata suffixes for equality checks")
    func releaseVersionMetadataIsIgnored() {
        #expect(ReleaseUpdateService.normalizedVersion(from: "v1.2.3+45") == "1.2.3")
        #expect(ReleaseUpdateService.normalizedVersion(from: "1.2.3-beta") == "1.2.3")
        #expect(ReleaseUpdateService.compareVersion("1.2.3", "1.2.3+45") == .orderedSame)
    }
}
