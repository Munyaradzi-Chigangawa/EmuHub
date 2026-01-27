//
//  EmulatorService.swift
//  EmuHub
//
//  Created by Munyaradzi Chigangawa on 27/1/2026.
//

import Foundation

struct EmulatorService {
    func listAVDs(emulatorPath: String) async throws -> [String] {
        let res = try await Shell.run(emulatorPath, ["-list-avds"])
        return res.stdout
            .split(whereSeparator: \.isNewline)
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .sorted()
    }

    func startAVD(emulatorPath: String, avdName: String, extraArgs: [String]) async throws {
        // Start and detach: we intentionally don't await termination
        let process = Process()
        process.executableURL = URL(fileURLWithPath: emulatorPath)
        process.arguments = ["-avd", avdName] + extraArgs

        // Optional: prevent it from spamming your app logs
        process.standardOutput = Pipe()
        process.standardError = Pipe()

        try process.run()
    }
}
