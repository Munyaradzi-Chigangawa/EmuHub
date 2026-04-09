//
//  AndroidToolchain.swift
//  EmuHub
//
//  Created by Munyaradzi Chigangawa on 27/1/2026.

import Foundation

enum ToolchainError: LocalizedError {
    case sdkNotFound
    case toolNotFound(String)

    var errorDescription: String? {
        switch self {
        case .sdkNotFound:
            return "Android SDK not found. Set SDK path in Settings (example: ~/Library/Android/sdk)."
        case .toolNotFound(let tool):
            return "Could not find \(tool) inside the Android SDK. Check your SDK path."
        }
    }
}

struct AndroidToolchain {
    let sdkPath: String

    var emulatorPath: String { "\(sdkPath)/emulator/emulator" }
    var adbPath: String { "\(sdkPath)/platform-tools/adb" }

    /// Resolves `avdmanager` from cmdline-tools (any installed version) or the legacy tools dir.
    var avdmanagerPath: String? {
        let fm = FileManager.default
        let cmdlineBase = "\(sdkPath)/cmdline-tools"
        if let versions = try? fm.contentsOfDirectory(atPath: cmdlineBase) {
            let ordered = versions.sorted {
                if $0 == "latest" { return true }
                if $1 == "latest" { return false }
                return $0 > $1
            }
            for v in ordered {
                let candidate = "\(cmdlineBase)/\(v)/bin/avdmanager"
                if fm.fileExists(atPath: candidate) { return candidate }
            }
        }
        let legacy = "\(sdkPath)/tools/bin/avdmanager"
        return fm.fileExists(atPath: legacy) ? legacy : nil
    }

    init(sdkPath userProvided: String) throws {
        guard let resolved = Self.resolveSdkPath(preferred: userProvided) else {
            throw ToolchainError.sdkNotFound
        }

        self.sdkPath = resolved

        if !FileManager.default.fileExists(atPath: emulatorPath) {
            throw ToolchainError.toolNotFound("emulator")
        }
        if !FileManager.default.fileExists(atPath: adbPath) {
            throw ToolchainError.toolNotFound("adb")
        }
    }
    
    private static func resolveSdkPath(preferred: String) -> String? {
        let fm = FileManager.default

        func norm(_ p: String) -> String {
            (p.trimmingCharacters(in: .whitespacesAndNewlines) as NSString).expandingTildeInPath
        }

        func isValidSdk(_ path: String) -> Bool {
            fm.fileExists(atPath: path + "/platform-tools/adb") &&
            fm.fileExists(atPath: path + "/emulator/emulator")
        }

        // 1) User-provided (if any)
        let p = norm(preferred)
        if !p.isEmpty, isValidSdk(p) { return p }

        // 2) Env vars (sometimes present)
        let env = ProcessInfo.processInfo.environment
        if let e = env["ANDROID_SDK_ROOT"].map(norm), isValidSdk(e) { return e }
        if let e = env["ANDROID_HOME"].map(norm), isValidSdk(e) { return e }

        // 3) Common macOS default (dynamic per-user)
        let def = defaultMacSdkPath()
        if isValidSdk(def) { return def }

        return nil
    }

    static func defaultMacSdkPath() -> String {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Android/sdk")
            .path
    }

}
