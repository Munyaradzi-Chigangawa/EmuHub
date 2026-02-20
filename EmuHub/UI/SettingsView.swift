//
//  SettingsView.swift
//  EmuHub
//
//  Created by Munyaradzi Chigangawa on 27/1/2026.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var state: AppState
    var preferredWidth: CGFloat? = 560

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // MARK: General
                SettingsSection(title: "General") {
                    VStack(alignment: .leading, spacing: 4) {
                        Toggle("Launch at Login", isOn: launchAtLoginBinding)
                        Text("Automatically start EmuHub when you log in to macOS.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.leading, 2)

                        if let launchAtLoginError = state.launchAtLoginError {
                            Text(launchAtLoginError)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .padding(.leading, 2)
                        }
                    }
                }

                // MARK: Android SDK
                SettingsSection(title: "Android SDK") {
                    VStack(alignment: .leading, spacing: 6) {
                        TextField("SDK Path", text: $state.sdkPath)
                            .textFieldStyle(.roundedBorder)
                        Text("Example: ~/Library/Android/sdk")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // MARK: Emulator
                SettingsSection(title: "Emulator") {
                    VStack(alignment: .leading, spacing: 6) {
                        TextField("Extra Args", text: $state.emulatorExtraArgs)
                            .textFieldStyle(.roundedBorder)
                        Text("Example: -no-snapshot-load -gpu host")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // MARK: Refresh
                SettingsSection(title: "Refresh") {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Auto-refresh interval")
                                .font(.subheadline)
                            Spacer()
                            Text("Every \(Int(state.autoRefreshSeconds))s")
                                .font(.subheadline.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $state.autoRefreshSeconds, in: 3...60, step: 1)

                        Button("Refresh Now") {
                            Task { await state.refreshAll() }
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
            }
            .padding(24)
        }
        .frame(width: preferredWidth)
        .onAppear {
            state.refreshLaunchAtLoginState()
        }
    }

    private var launchAtLoginBinding: Binding<Bool> {
        Binding(
            get: { state.launchAtLoginEnabled },
            set: { state.setLaunchAtLogin($0) }
        )
    }

    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "-"
        return "\(version)"
    }
}

// MARK: - Reusable Section Container

private struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .kerning(0.5)

            content()
                .padding(16)
                .background(.background.secondary, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
