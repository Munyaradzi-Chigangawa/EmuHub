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
        }
        .padding()
        .frame(width: 520)
    }
}
