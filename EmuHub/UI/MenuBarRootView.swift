//
//  MenuBarRootView.swift
//  EmuHub
//
//  Created by Munyaradzi Chigangawa on 27/1/2026.
//

//import SwiftUI
//
//struct MenuBarRootView: View {
//    @EnvironmentObject var state: AppState
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            header
//
//            if let err = state.lastError {
//                Text(err)
//                    .font(.caption)
//                    .foregroundStyle(.red)
//                    .fixedSize(horizontal: false, vertical: true)
//            }
//
//            GroupBox("Running") {
//                if state.running.isEmpty {
//                    Text("No running emulators.")
//                        .foregroundStyle(.secondary)
//                } else {
//                    ForEach(state.running) { emu in
//                        HStack {
//                            VStack(alignment: .leading) {
//                                Text(emu.serial).font(.body)
//                                Text(emu.state).font(.caption).foregroundStyle(.secondary)
//                            }
//                            Spacer()
//                            Button("Stop") {
//                                Task { await state.stop(running: emu) }
//                            }
//                        }
//                        .padding(.vertical, 4)
//                    }
//                }
//            }
//
//            GroupBox("Available AVDs") {
//                if state.avds.isEmpty {
//                    Text("No AVDs found.")
//                        .foregroundStyle(.secondary)
//                } else {
//                    ForEach(state.avds) { avd in
//                        HStack {
//                            Text(avd.name)
//                            Spacer()
//                            Button("Start") {
//                                Task { await state.start(avd: avd) }
//                            }
//                        }
//                        .padding(.vertical, 2)
//                    }
//                }
//            }
//
//            Divider()
//
//            HStack {
//                Button(state.isRefreshing ? "Refreshing…" : "Refresh") {
//                    Task { await state.refreshAll() }
//                }
//                .disabled(state.isRefreshing)
//
//                Spacer()
//
//                Button("Quit") { NSApplication.shared.terminate(nil) }
//            }
//        }
//        .padding(12)
//        .frame(width: 360)
//        .task {
//            await state.refreshAll()
//            state.startAutoRefresh()
//        }
//        .onDisappear {
//            state.stopAutoRefresh()
//        }
//    }
//
//    private var header: some View {
//        HStack {
//            VStack(alignment: .leading) {
//                Text("EmuBar").font(.headline)
//                Text("Android Emulator Manager").font(.caption).foregroundStyle(.secondary)
//            }
//            Spacer()
//            Image(systemName: "dot.radiowaves.left.and.right")
//                .foregroundStyle(.secondary)
//        }
//    }
//}



//  MenuBarRootView.swift
//  EmuHub
//
//  Created by Munyaradzi Chigangawa on 27/1/2026.
//  Redesigned for clean, minimalistic, elegant professional aesthetic


import SwiftUI

struct MenuBarRootView: View {
    @EnvironmentObject var state: AppState
    @State private var hoveredEmulator: String?
    @State private var hoveredAVD: String?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            header
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)
            
            Divider()
                .opacity(0.1)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Error Banner
                    if let errorMessage = state.lastError {
                        errorBanner(message: errorMessage)
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .opacity
                            ))
                    }
                    
                    // Running Section
                    sectionContainer(
                        title: "Running",
                        systemImage: "bolt.circle.fill",
                        accentColor: .green
                    ) {
                        runningContent
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, state.lastError != nil ? 0 : 16)
                    
                    // Available AVDs Section
                    sectionContainer(
                        title: "Available",
                        systemImage: "square.stack.3d.up.fill",
                        accentColor: .blue
                    ) {
                        avdsContent
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }
            }
            
            Divider()
                .opacity(0.1)
            
            // Footer Actions
            footer
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
        }
        .frame(width: 380)
        .background(backgroundGradient)
        .task {
            await state.refreshAll()
            state.startAutoRefresh()
        }
        .onDisappear {
            state.stopAutoRefresh()
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)
                
                Image(systemName: "cpu")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("EmuBar")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text("Emulator Manager")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Status Indicator
            HStack(spacing: 4) {
                Circle()
                    .fill(state.running.isEmpty ? Color.secondary.opacity(0.3) : Color.green)
                    .frame(width: 6, height: 6)
                    .shadow(color: state.running.isEmpty ? .clear : .green.opacity(0.5), radius: 3)
                
                Text("\(state.running.count)")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color.secondary.opacity(0.08))
            )
        }
    }
    
    // MARK: - Error Banner
    
    private func errorBanner(message: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 13))
                .foregroundStyle(.red)
            
            Text(message)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.red.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.red.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(Color.red.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Section Container
    
    private func sectionContainer<Content: View>(
        title: String,
        systemImage: String,
        accentColor: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(accentColor)
                
                Text(title)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                
                Spacer()
            }
            
            content()
        }
    }
    
    // MARK: - Running Content
    
    @ViewBuilder
    private var runningContent: some View {
        if state.running.isEmpty {
            emptyState(
                icon: "moon.zzz.fill",
                message: "No active emulators"
            )
        } else {
            VStack(spacing: 8) {
                ForEach(state.running) { emu in
                    emulatorCard(emu: emu)
                }
            }
        }
    }
    
    private func emulatorCard(emu: RunningEmulator) -> some View {
        HStack(spacing: 12) {
            // Status Indicator
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 32, height: 32)
                
                Image(systemName: "play.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.green)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(emu.serial)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.primary)
                
                Text(emu.state)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button {
                Task { await state.stop(running: emu) }
            } label: {
                Image(systemName: "stop.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(
                                hoveredEmulator == emu.serial
                                    ? Color.red
                                    : Color.secondary.opacity(0.5)
                            )
                    )
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    hoveredEmulator = hovering ? emu.serial : nil
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.primary.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
                )
        )
    }
    
    // MARK: - AVDs Content
    
    @ViewBuilder
    private var avdsContent: some View {
        if state.avds.isEmpty {
            emptyState(
                icon: "tray.fill",
                message: "No AVDs configured"
            )
        } else {
            VStack(spacing: 8) {
                ForEach(state.avds) { avd in
                    avdCard(avd: avd)
                }
            }
        }
    }
    
    private func avdCard(avd: AVD) -> some View {
        HStack(spacing: 12) {
            // Device Icon
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 32, height: 32)
                
                Image(systemName: "iphone")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.blue)
            }
            
            Text(avd.name)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.primary)
                .lineLimit(1)
            
            Spacer()
            
            Button {
                Task { await state.start(avd: avd) }
            } label: {
                Image(systemName: "play.fill")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(
                                hoveredAVD == avd.name
                                    ? LinearGradient(
                                        colors: [.blue, .blue.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    : LinearGradient(
                                        colors: [.blue.opacity(0.7), .blue.opacity(0.6)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                            )
                    )
                    .shadow(
                        color: hoveredAVD == avd.name ? .blue.opacity(0.3) : .clear,
                        radius: 4,
                        y: 2
                    )
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    hoveredAVD = hovering ? avd.name : nil
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.primary.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Empty State
    
    private func emptyState(icon: String, message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.tertiary)
            
            Text(message)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.secondary.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(Color.secondary.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                )
        )
    }
    
    // MARK: - Footer
    
    private var footer: some View {
        HStack(spacing: 10) {
            Button {
                Task { await state.refreshAll() }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: state.isRefreshing ? "arrow.circlepath" : "arrow.clockwise")
                        .font(.system(size: 11, weight: .semibold))
                        .rotationEffect(.degrees(state.isRefreshing ? 360 : 0))
                        .animation(
                            state.isRefreshing
                                ? Animation.linear(duration: 1).repeatForever(autoreverses: false)
                                : .default,
                            value: state.isRefreshing
                        )
                    
                    Text(state.isRefreshing ? "Refreshing" : "Refresh")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundStyle(.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(Color.primary.opacity(0.06))
                        .overlay(
                            Capsule()
                                .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
            .disabled(state.isRefreshing)
            .opacity(state.isRefreshing ? 0.6 : 1)
            
            Spacer()
            
            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                HStack(spacing: 6) {
                    Text("Quit")
                        .font(.system(size: 12, weight: .medium))
                    
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .semibold))
                }
                .foregroundStyle(.secondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(Color.secondary.opacity(0.08))
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(NSColor.windowBackgroundColor),
                Color(NSColor.windowBackgroundColor).opacity(0.95)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Preview

#Preview {
    MenuBarRootView()
        .environmentObject(AppState())
}
