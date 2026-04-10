//
//  ADBParser.swift
//  EmuHub
//
//  parser for `adb devices -l` output.
//
//  ## Why a dedicated parser?
//  The naive approach of splitting each line on whitespace breaks for ADB TLS wireless
//  debugging serials, which contain spaces:
//
//      adb-A1B2C3D4E5F-x7Yz9W (2)._adb-tls-connect._tcp  device  product:m12dd …
//
//  This module solves three problems in one place:
//    1. Parsing  — regex anchored to the known `adb state` tokens, not to whitespace
//    2. Normalization — strips ` (N)` duplicate-session suffixes from TLS serials
//    3. Deduplication — collapses re-normalized duplicates, keeping the most recent
//                       connection by transport_id
//
//  All three operations are pure functions over value types; nothing is mutated in place.

import Foundation

enum ADBParser {

    // MARK: - Parsed result

    /// One successfully parsed line from `adb devices [-l]` output.
    struct ParsedLine: Equatable {
        /// Raw serial exactly as reported by adb — may contain spaces.
        let rawSerial: String
        /// Canonical serial after normalization — safe to use as a stable identity key.
        let serial: String
        /// ADB connection state: "device", "offline", "unauthorized", etc.
        let state: String
        /// Key-value metadata from the `-l` flag (model, product, transport_id, …).
        /// Empty when the line was produced without `-l`.
        let metadata: [String: String]

        var transportID: Int? { metadata["transport_id"].flatMap(Int.init) }
    }

    // MARK: - Compiled regex (built once)

    /// Captures three groups from a trimmed `adb devices -l` line:
    ///   1. serial   — lazy `.+?` allows spaces; stops at the first state token
    ///   2. state    — one of the known adb state keywords
    ///   3. metadata — everything trailing (may be empty)
    ///
    /// `(?!:)` prevents metadata tokens like `device:m12` from being misread as the
    /// adb state, because the real state is never followed by a colon.
    private static let lineRegex: NSRegularExpression = {
        let pattern = #"^(.+?)\s+(device|offline|unauthorized|recovery|sideload|bootloader)(?!:)\s*(.*)$"#
        return try! NSRegularExpression(pattern: pattern) // constant pattern — safe force-try
    }()

    /// Matches the ` (N)` session-counter that ADB TLS can append to a wireless serial
    /// when the same device opens a second connection over the same transport.
    ///
    /// Only matches immediately before `._adb-tls-connect._tcp` (lookahead ensures this),
    /// so it cannot accidentally strip content from other serial formats.
    private static let tlsDuplicateSuffixRegex: NSRegularExpression = {
        return try! NSRegularExpression(pattern: #"\s*\(\d+\)(?=\._adb-tls-connect\._tcp)"#)
    }()

    // MARK: - Parsing

    /// Parses one trimmed line from `adb devices [-l]` output.
    ///
    /// Returns `nil` for:
    /// - The header line (`List of devices attached`)
    /// - Blank / whitespace-only lines
    /// - Lines that do not match the expected `<serial> <state>` structure
    static func parseLine(_ line: String) -> ParsedLine? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !trimmed.hasPrefix("List of devices") else { return nil }

        let fullRange = NSRange(trimmed.startIndex..., in: trimmed)
        guard let match = lineRegex.firstMatch(in: trimmed, range: fullRange),
              match.numberOfRanges == 4
        else { return nil }

        func capture(_ index: Int) -> String {
            guard let swiftRange = Range(match.range(at: index), in: trimmed) else { return "" }
            return String(trimmed[swiftRange])
        }

        let rawSerial = capture(1)
        return ParsedLine(
            rawSerial: rawSerial,
            serial:    normalizeSerial(rawSerial),
            state:     capture(2),
            metadata:  parseMetadata(capture(3))
        )
    }

    /// Parses the complete stdout of `adb devices [-l]`, skipping the header and blanks.
    static func parseOutput(_ output: String) -> [ParsedLine] {
        output.components(separatedBy: .newlines).compactMap { parseLine($0) }
    }

    // MARK: - Normalization

    /// Returns the canonical form of an ADB serial.
    ///
    /// The only transformation applied is stripping the ` (N)` duplicate-session suffix
    /// from ADB TLS wireless serials:
    ///
    /// ```
    /// "adb-XYZ (2)._adb-tls-connect._tcp" → "adb-XYZ._adb-tls-connect._tcp"
    /// "adb-XYZ._adb-tls-connect._tcp"     → unchanged
    /// "emulator-5554"                       → unchanged
    /// "192.168.1.10:5555"                  → unchanged
    /// "A1B2C3D4E5F"                         → unchanged
    /// ```
    static func normalizeSerial(_ serial: String) -> String {
        let fullRange = NSRange(serial.startIndex..., in: serial)
        return tlsDuplicateSuffixRegex.stringByReplacingMatches(
            in: serial, range: fullRange, withTemplate: ""
        )
    }

    // MARK: - Deduplication

    /// Collapses entries that share the same normalized serial into one.
    ///
    /// **Winner selection:** the entry with the highest `transport_id` is kept.
    /// A higher transport_id indicates a more recently established adb connection,
    /// so it is the most likely to be the "live" one.
    /// Lines without a transport_id (e.g., output produced without `-l`) are treated as
    /// transport_id = -1 and lose to any entry that does have one.
    ///
    /// **Ordering:** the output preserves the relative order of the *first occurrence*
    /// of each normalized serial in the input.
    static func deduplicate(_ lines: [ParsedLine]) -> [ParsedLine] {
        // Pass 1: determine the winner for each normalized serial
        var winners: [String: ParsedLine] = [:]
        for line in lines {
            if let existing = winners[line.serial] {
                if (line.transportID ?? -1) > (existing.transportID ?? -1) {
                    winners[line.serial] = line
                }
            } else {
                winners[line.serial] = line
            }
        }

        // Pass 2: emit winners in first-occurrence order
        var emitted = Set<String>()
        return lines.compactMap { line in
            guard !emitted.contains(line.serial), let winner = winners[line.serial] else {
                return nil
            }
            emitted.insert(line.serial)
            return winner
        }
    }

    // MARK: - Private helpers

    private static func parseMetadata(_ raw: String) -> [String: String] {
        var result: [String: String] = [:]
        for token in raw.split(separator: " ") where token.contains(":") {
            let parts = token.split(separator: ":", maxSplits: 1).map(String.init)
            if parts.count == 2 { result[parts[0]] = parts[1] }
        }
        return result
    }
}
