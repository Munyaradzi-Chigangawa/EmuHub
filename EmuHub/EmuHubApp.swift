//
//  EmuHubApp.swift
//  EmuHub
//
//  Created by Munyaradzi Chigangawa on 27/1/2026.
//

import SwiftUI
import SwiftData

@main
struct EmuHubApp: App {
    @StateObject private var state = AppState()

        var body: some Scene {
            MenuBarExtra {
                MenuBarRootView()
                    .environmentObject(state)
            } label: {
                Image(systemName: "cpu")
            }
            .menuBarExtraStyle(.window)

            Settings {
                SettingsView()
                    .environmentObject(state)
            }
        }
    }
