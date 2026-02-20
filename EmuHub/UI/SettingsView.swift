//
//  SettingsView.swift
//  EmuHub
//
//  Created by Munyaradzi Chigangawa on 27/1/2026.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        Form {
            Section("General") {
                Toggle("Launch at Login", isOn: launchAtLoginBinding)
                Text("Automatically start EmuHub when you log in to macOS.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let launchAtLoginError = state.launchAtLoginError {
                    Text(launchAtLoginError)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            Section("Android SDK") {
                TextField("SDK Path", text: $state.sdkPath)
                    .textFieldStyle(.roundedBorder)
                Text("Example: ~/Library/Android/sdk")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Emulator") {
                TextField("Extra Args", text: $state.emulatorExtraArgs)
                    .textFieldStyle(.roundedBorder)
                Text("Example: -no-snapshot-load -gpu host")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Refresh") {
                Slider(value: $state.autoRefreshSeconds, in: 3...60, step: 1) {
                    Text("Auto refresh")
                }
                Text("Every \(Int(state.autoRefreshSeconds)) seconds")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section {
                Button("Refresh Now") {
                    Task { await state.refreshAll() }
                }
            }

            Section("About") {
                VStack(alignment: .leading, spacing: 6) {
                    Text("EmuHub")
                        .font(.headline)
                    Text("Android emulator and device manager for macOS menu bar.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("Version \(appVersion)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 2)

                Link("Project Repository", destination: URL(string: "https://github.com/Munyaradzi-Chigangawa/EmuHub")!)
                Link("Release Notes / Changelog", destination: URL(string: "https://github.com/Munyaradzi-Chigangawa/EmuHub/blob/main/CHANGELOG.md")!)
                Link("License (MIT)", destination: URL(string: "https://github.com/Munyaradzi-Chigangawa/EmuHub/blob/main/LICENSE")!)
            }
        }
        .padding()
        .frame(width: 520)
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
        let short = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "-"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "-"
        return "\(short) (\(build))"
    }
}
