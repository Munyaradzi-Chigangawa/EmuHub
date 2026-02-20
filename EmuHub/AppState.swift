//
//  AppState.swift
//  EmuHub
//
//  Created by Munyaradzi Chigangawa on 27/1/2026.
//

import Foundation
import SwiftUI
import Combine
import ServiceManagement

@MainActor
final class AppState: ObservableObject {
    @Published var avds: [AVD] = []
    @Published var running: [RunningDevice] = []
    @Published var isRefreshing = false
    @Published var lastError: String?
    @Published var lastRefreshAt: Date?
    @Published var launchAtLoginEnabled = false
    @Published var launchAtLoginError: String?
    @Published var isCheckingForUpdates = false
    @Published var updateCheckResult: UpdateCheckResult?
    @Published var updateError: String?

    @AppStorage("sdkPath") var sdkPath: String =  "" // e.g. /Users/you/Library/Android/sdk
    @AppStorage("emulatorExtraArgs") var emulatorExtraArgs: String = "-no-snapshot-load"
    @AppStorage("autoRefreshSeconds") var autoRefreshSeconds: Double = 10

    let emulatorService = EmulatorService()
    let adbService = AdbService()
    let releaseUpdateService = ReleaseUpdateService()

    private var refreshTask: Task<Void, Never>?

    init() {
        refreshLaunchAtLoginState()
    }

    func startAutoRefresh() {
        refreshTask?.cancel()
        refreshTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                await self.refreshAll()
                try? await Task.sleep(nanoseconds: UInt64(self.autoRefreshSeconds * 1_000_000_000))
            }
        }
    }

    func stopAutoRefresh() {
        refreshTask?.cancel()
        refreshTask = nil
    }

    func refreshAll() async {
        ensureSdkPath()
        isRefreshing = true
        defer {
            isRefreshing = false
            lastRefreshAt = Date()
        }

        do {
            let toolchain = try AndroidToolchain(sdkPath: sdkPath)

            let avdNames = try await emulatorService.listAVDs(emulatorPath: toolchain.emulatorPath)
            self.avds = avdNames.map { AVD(name: $0) }

            self.running = try await adbService.listRunning(adbPath: toolchain.adbPath)
            self.lastError = nil
        } catch {
            self.lastError = error.localizedDescription
        }
    }

    func start(avd: AVD) async {
        do {
            ensureSdkPath()
            let toolchain = try AndroidToolchain(sdkPath: sdkPath)
            let args = emulatorExtraArgs
                .split(separator: " ")
                .map(String.init)
                .filter { !$0.isEmpty }

            try await emulatorService.startAVD(
                emulatorPath: toolchain.emulatorPath,
                avdName: avd.name,
                extraArgs: args
            )

            // Give it a moment then refresh running list
            try? await Task.sleep(nanoseconds: 800_000_000)
            await refreshAll()
        } catch {
            lastError = error.localizedDescription
        }
    }

    func stop(device: RunningDevice) async {
        guard device.isEmulator else {
            lastError = "This is a physical device. To remove it from the list, unplug USB or disable USB debugging."
            return
        }

        do {
            let toolchain = try AndroidToolchain(sdkPath: sdkPath)
            try await adbService.stopEmulator(adbPath: toolchain.adbPath, serial: device.serial)
            await refreshAll()
        } catch {
            lastError = error.localizedDescription
        }
    }

    func refreshLaunchAtLoginState() {
        guard #available(macOS 13.0, *) else {
            launchAtLoginEnabled = false
            launchAtLoginError = "Launch at Login requires macOS 13 or newer."
            return
        }

        launchAtLoginEnabled = SMAppService.mainApp.status == .enabled
        launchAtLoginError = nil
    }

    func setLaunchAtLogin(_ enabled: Bool) {
        guard #available(macOS 13.0, *) else {
            launchAtLoginEnabled = false
            launchAtLoginError = "Launch at Login requires macOS 13 or newer."
            return
        }

        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }

            launchAtLoginEnabled = SMAppService.mainApp.status == .enabled
            launchAtLoginError = nil
        } catch {
            launchAtLoginEnabled = SMAppService.mainApp.status == .enabled
            launchAtLoginError = "Could not update Launch at Login: \(error.localizedDescription)"
        }
    }

    private func ensureSdkPath() {
        let fm = FileManager.default

        // If empty OR path no longer exists, try auto-detect
        if sdkPath.isEmpty || !fm.fileExists(atPath: sdkPath) {
            let auto = AndroidToolchain.defaultMacSdkPath()
            if fm.fileExists(atPath: auto) {
                sdkPath = auto
            }
        }
    }

    func checkForUpdates() async {
        let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"

        isCheckingForUpdates = true
        updateError = nil
        defer { isCheckingForUpdates = false }

        do {
            updateCheckResult = try await releaseUpdateService.checkForUpdates(currentVersion: currentVersion)
        } catch {
            updateCheckResult = nil
            updateError = error.localizedDescription
        }
    }
}
