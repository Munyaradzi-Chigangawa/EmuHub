//
//  CheckForUpdatesPageView.swift
//  EmuHub
//
//  Created by Munyaradzi Chigangawa on 20/2/2026.
//

import SwiftUI

struct CheckForUpdatesPage: View {
    @EnvironmentObject var state: AppState
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // MARK: - Header Card
                VStack(spacing: 12) {
                    Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.tint)

                    VStack(spacing: 4) {
                        Text("Check for Updates")
                            .font(.title2.weight(.bold))

                        Text("EmuHub compares your current version with the latest release to ensure you're up to date.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(cardBackground)

                // MARK: - Error
                if let updateError = state.updateError {
                    HStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                        Text(updateError)
                            .font(.subheadline)
                            .foregroundStyle(.red)
                        Spacer()
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.red.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(Color.red.opacity(0.2), lineWidth: 1)
                            )
                    )
                }

                // MARK: - Update Result
                if let result = state.updateCheckResult {
                    VStack(spacing: 0) {
                        // Version rows
                        versionRow(
                            label: "Installed",
                            value: result.currentVersion,
                            icon: "checkmark.seal.fill",
                            iconColor: .secondary
                        )

                        Divider().padding(.leading, 44)

                        versionRow(
                            label: "Latest",
                            value: result.latestVersion,
                            icon: "tag.fill",
                            iconColor: result.hasUpdate ? .orange : .green
                        )

                        Divider().padding(.leading, 44)

                        // Status row
                        HStack(spacing: 12) {
                            Image(systemName: result.hasUpdate ? "arrow.down.circle.fill" : "checkmark.circle.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(result.hasUpdate ? .orange : .green)
                                .frame(width: 24)

                            Text(result.hasUpdate ? "A new version is available" : "You're up to date")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(result.hasUpdate ? .orange : .green)

                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }
                    .background(cardBackground)

                    // Action buttons
                    HStack(spacing: 10) {
                        Button {
                            openURL(result.releaseNotesURL)
                        } label: {
                            Label("Release Notes", systemImage: "doc.text")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)

                        if result.hasUpdate, let downloadURL = result.downloadURL {
                            Button {
                                openURL(downloadURL)
                            } label: {
                                Label("Download", systemImage: "arrow.down.circle.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                        }
                    }
                }

                // MARK: - Check Button
                Button {
                    Task { await state.checkForUpdates() }
                } label: {
                    HStack(spacing: 8) {
                        if state.isCheckingForUpdates {
                            ProgressView()
                                .controlSize(.small)
                                .tint(.white)
                        }
                        Text(state.isCheckingForUpdates ? "Checking…" : "Check Now")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(state.isCheckingForUpdates)

            }
            .padding(20)
        }
    }

    // MARK: - Helpers

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(Color.primary.opacity(0.04))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
            )
    }

    @ViewBuilder
    private func versionRow(label: String, value: String, icon: String, iconColor: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(iconColor)
                .frame(width: 24)

            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline.weight(.medium))
                .monospacedDigit()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }
}
