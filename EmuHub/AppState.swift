//
//  AppState.swift
//  EmuHub
//
//  Created by Munyaradzi Chigangawa on 27/1/2026.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var avds: [AVD] = []
    @Published var running: [RunningEmulator] = []
    @Published var isRefreshing = false
    @Published var lastError: String?

    @AppStorage("sdkPath") var sdkPath: String =  "" // e.g. /Users/you/Library/Android/sdk
    @AppStorage("emulatorExtraArgs") var emulatorExtraArgs: String = "-no-snapshot-load"
    @AppStorage("autoRefreshSeconds") var autoRefreshSeconds: Double = 10

    let emulatorService = EmulatorService()
    let adbService = AdbService()

    private var refreshTask: Task<Void, Never>?

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
        defer { isRefreshing = false }

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

    func stop(running: RunningEmulator) async {
        do {
            ensureSdkPath()
            let toolchain = try AndroidToolchain(sdkPath: sdkPath)
            try await adbService.stopEmulator(adbPath: toolchain.adbPath, serial: running.serial)
            await refreshAll()
        } catch {
            lastError = error.localizedDescription
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
}
