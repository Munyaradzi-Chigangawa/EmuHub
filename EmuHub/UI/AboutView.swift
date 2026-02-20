//
//  AboutView.swift
//  EmuHub
//
//  Created by Munyaradzi Chigangawa on 20/2/2026.
//

import SwiftUI

struct AboutPage: View {
    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "-"
        return "\(version)"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                // MARK: - Hero
                VStack(spacing: 8) {
                    Image(systemName: "iphone.and.arrow.forward")
                        .font(.system(size: 36, weight: .light))
                        .foregroundStyle(.tint)
                        .padding(.bottom, 4)

                    Text("EmuHub")
                        .font(.title2.weight(.semibold))

                    Text("Version \(appVersion)")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 1)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .padding(.horizontal, 20)

                Divider()

                // MARK: - Description
                VStack(alignment: .leading, spacing: 6) {
                    Text("About")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .kerning(0.4)

                    Text("A lightweight macOS menu bar utility for managing Android emulators (AVDs) and connected physical devices — no Terminal required.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

                Divider()

                // MARK: - Details
                VStack(spacing: 0) {
                    AboutRow(label: "Developer", value: "Munyaradzi Chigangawa")
                    Divider().padding(.leading, 20)
                    AboutRow(label: "License", value: "MIT")
                    Divider().padding(.leading, 20)
                    AboutRow(label: "Platform", value: "macOS 13.0+")
                }
                .padding(.vertical, 4)

                Divider()

                // MARK: - Links
                VStack(spacing: 0) {
                    AboutLink(
                        icon: "star",
                        label: "GitHub Repository",
                        url: "https://github.com/Munyaradzi-Chigangawa/EmuHub"
                    )
                    Divider().padding(.leading, 44)
                    AboutLink(
                        icon: "doc.text",
                        label: "Changelog",
                        url: "https://github.com/Munyaradzi-Chigangawa/EmuHub/blob/main/CHANGELOG.md"
                    )
                    Divider().padding(.leading, 44)
                    AboutLink(
                        icon: "hand.raised",
                        label: "License (MIT)",
                        url: "https://github.com/Munyaradzi-Chigangawa/EmuHub/blob/main/LICENSE"
                    )
                    Divider().padding(.leading, 44)
                    AboutLink(
                        icon: "person.2",
                        label: "Contributing",
                        url: "https://github.com/Munyaradzi-Chigangawa/EmuHub/blob/main/CONTRIBUTING.md"
                    )
                }
                .padding(.vertical, 4)

                Divider()

                // MARK: - Footer
                Text("© 2026 Munyaradzi Chigangawa")
                    .font(.caption2)
                    .foregroundStyle(.quaternary)
                    .padding(.vertical, 14)
            }
        }
        .frame(minHeight: 480)
    }
}

// MARK: - Subviews

private struct AboutRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}

private struct AboutLink: View {
    let icon: String
    let label: String
    let url: String

    @State private var isHovered = false

    var body: some View {
        Link(destination: URL(string: url)!) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundStyle(.tint)
                    .frame(width: 24)

                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
            .background(isHovered ? Color.primary.opacity(0.06) : Color.clear)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}
