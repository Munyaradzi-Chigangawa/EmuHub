//
//  AdbService.swift
//  EmuHub
//
//  Created by Munyaradzi Chigangawa on 27/1/2026.
//

import Foundation

struct AdbService {
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

    func stopEmulator(adbPath: String, serial: String) async throws {
        _ = try? await Shell.run(adbPath, ["start-server"])
        _ = try await Shell.run(adbPath, ["-s", serial, "emu", "kill"])
    }
}
