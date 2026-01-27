//
//  Shell.swift
//  EmuHub
//
//  Created by Munyaradzi Chigangawa on 27/1/2026.
//

import Foundation

enum ShellError: LocalizedError {
    case nonZeroExit(code: Int32, stderr: String)
    case invalidUTF8

    var errorDescription: String? {
        switch self {
        case .nonZeroExit(let code, let stderr):
            return "Command failed (exit \(code)). \(stderr)"
        case .invalidUTF8:
            return "Command output was not valid UTF-8."
        }
    }
}

struct ShellResult {
    let stdout: String
    let stderr: String
    let exitCode: Int32
}

enum Shell {
    static func run(_ launchPath: String, _ arguments: [String]) async throws -> ShellResult {
        try await withCheckedThrowingContinuation { cont in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: launchPath)
            process.arguments = arguments

            let outPipe = Pipe()
            let errPipe = Pipe()
            process.standardOutput = outPipe
            process.standardError = errPipe

            process.terminationHandler = { p in
                let outData = outPipe.fileHandleForReading.readDataToEndOfFile()
                let errData = errPipe.fileHandleForReading.readDataToEndOfFile()

                let stdout = String(data: outData, encoding: .utf8) ?? ""
                let stderr = String(data: errData, encoding: .utf8) ?? ""
                let result = ShellResult(stdout: stdout, stderr: stderr, exitCode: p.terminationStatus)

                if result.exitCode == 0 {
                    cont.resume(returning: result)
                } else {
                    cont.resume(throwing: ShellError.nonZeroExit(code: result.exitCode, stderr: stderr.trimmingCharacters(in: .whitespacesAndNewlines)))
                }
            }

            do {
                try process.run()
            } catch {
                cont.resume(throwing: error)
            }
        }
    }
}
