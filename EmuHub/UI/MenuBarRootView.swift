//
//  MenuBarRootView.swift
//  EmuHub
//
//  Created by Munyaradzi Chigangawa on 27/1/2026.
//

import SwiftUI

struct MenuBarRootView: View {
    @EnvironmentObject var state: AppState
    @State private var hoveredEmulator: String?
    @State private var hoveredAVD: String?
    @State private var isShowingQuickActions = false
    @State private var selectedQuickAction: QuickActionDestination?
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(
                runningCount: state.running.count,
                emulatorCount: state.running.filter(\.isEmulator).count,
                physicalCount: state.running.filter { !$0.isEmulator }.count,
                onOpenQuickActions: {
                    selectedQuickAction = nil
                    isShowingQuickActions = true
                }
            )
            
            Divider().opacity(0.1)
            
            ScrollView {
                VStack(spacing: 20) {
                    if let errorMessage = state.lastError {
                        ErrorBanner(message: errorMessage)
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .opacity
                            ))
                    }
                    
                    RunningSectionView(
                        devices: state.running,
                        hoveredDevice: $hoveredEmulator,
                        onStop: { device in
                            Task { await state.stop(device: device) }
                        }
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, state.lastError != nil ? 0 : 16)
                    
                    AVDSectionView(
                        avds: state.avds,
                        hoveredAVD: $hoveredAVD,
                        onStart: { avd in
                            Task { await state.start(avd: avd) }
                        }
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }
            }
            
            Divider().opacity(0.1)
            
            FooterView(
                isRefreshing: state.isRefreshing,
                onRefresh: {
                    Task { await state.refreshAll() }
                }
            )
        }
        .frame(width: 380)
        .background(AppBackground())
        .task {
            await state.refreshAll()
            state.startAutoRefresh()
        }
        .onDisappear {
            state.stopAutoRefresh()
        }
        .overlay {
            if isShowingQuickActions {
                QuickActionsOverlay(
                    selectedDestination: $selectedQuickAction,
                    isPresented: $isShowingQuickActions
                )
                .environmentObject(state)
            }
        }
    }
}

// MARK: - Header Component

private struct HeaderView: View {
    let runningCount: Int
    let emulatorCount: Int
    let physicalCount: Int
    let onOpenQuickActions: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            AppIconView()
            
            VStack(alignment: .leading, spacing: 2) {
                Text("EmuHub")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                
                Text("Android Device Manager")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()

            HStack(spacing: 8) {
                VStack(alignment: .trailing, spacing: 2) {
                    StatusBadge(count: runningCount)

                    Text("\(emulatorCount) emu • \(physicalCount) phone")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                }

                Button(action: onOpenQuickActions) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 24, height: 24)
                        .background(Circle().fill(Color.secondary.opacity(0.08)))
                }
                .buttonStyle(.plain)
                .help("Settings")
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }
}

private struct AppIconView: View {
    var body: some View {
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
    }
}

private struct StatusBadge: View {
    let count: Int
    
    private var isActive: Bool { count > 0 }
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(isActive ? Color.green : Color.secondary.opacity(0.3))
                .frame(width: 6, height: 6)
                .shadow(color: isActive ? .green.opacity(0.5) : .clear, radius: 3)
            
            Text("\(count)")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(Color.secondary.opacity(0.08)))
    }
}

// MARK: - Error Banner

private struct ErrorBanner: View {
    let message: String
    
    var body: some View {
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
}

// MARK: - Running Section

private struct RunningSectionView: View {
    let devices: [RunningDevice]
    @Binding var hoveredDevice: String?
    let onStop: (RunningDevice) -> Void
    
    var body: some View {
        SectionContainer(
            title: "Running",
            systemImage: "bolt.circle.fill",
            accentColor: .green
        ) {
            if devices.isEmpty {
                EmptyStateView(
                    icon: "moon.zzz.fill",
                    message: "No connected devices"
                )
            } else {
                VStack(spacing: 8) {
                    ForEach(devices) { device in
                        DeviceCard(
                            device: device,
                            isHovered: hoveredDevice == device.serial,
                            onHover: { hovering in
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    hoveredDevice = hovering ? device.serial : nil
                                }
                            },
                            onStop: { onStop(device) }
                        )
                    }
                }
            }
        }
    }
}

// MARK: - AVD Section

private struct AVDSectionView: View {
    let avds: [AVD]
    @Binding var hoveredAVD: String?
    let onStart: (AVD) -> Void
    
    var body: some View {
        SectionContainer(
            title: "Available",
            systemImage: "square.stack.3d.up.fill",
            accentColor: .blue
        ) {
            if avds.isEmpty {
                EmptyStateView(
                    icon: "tray.fill",
                    message: "No AVDs configured"
                )
            } else {
                VStack(spacing: 8) {
                    ForEach(avds) { avd in
                        AVDCard(
                            avd: avd,
                            isHovered: hoveredAVD == avd.name,
                            onHover: { hovering in
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    hoveredAVD = hovering ? avd.name : nil
                                }
                            },
                            onStart: { onStart(avd) }
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Section Container

private struct SectionContainer<Content: View>: View {
    let title: String
    let systemImage: String
    let accentColor: Color
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(
                title: title,
                systemImage: systemImage,
                accentColor: accentColor
            )
            
            content
        }
    }
}

private struct SectionHeader: View {
    let title: String
    let systemImage: String
    let accentColor: Color
    
    var body: some View {
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
    }
}

// MARK: - Device Card

private struct DeviceCard: View {
    let device: RunningDevice
    let isHovered: Bool
    let onHover: (Bool) -> Void
    let onStop: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            DeviceIcon(
                systemImage: device.isEmulator ? "play.fill" : "iphone",
                color: device.isEmulator ? .green : .orange
            )
            
            DeviceInfo(device: device)
            
            Spacer()
            
            if device.isEmulator {
                StopButton(
                    isHovered: isHovered,
                    onHover: onHover,
                    onStop: onStop
                )
            } else {
                DeviceStatusLabel(device: device)
            }
        }
        .padding(12)
        .background(CardBackground())
    }
}

private struct DeviceIcon: View {
    let systemImage: String
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: 32, height: 32)
            
            Image(systemName: systemImage)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(color)
        }
    }
}

private struct DeviceInfo: View {
    let device: RunningDevice
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(device.serial)
                .font(.system(size: 13, weight: .medium))
            
            Text(statusText)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
    }
    
    private var statusText: String {
        if device.isEmulator {
            return device.state
        }
        
        if device.isUnauthorized {
            return "USB debugging not authorized"
        }
        if device.isOffline {
            return "Device offline"
        }
        if device.state == "device" {
            return "Connected (USB debugging enabled)"
        }
        return device.state
    }
}

private struct StopButton: View {
    let isHovered: Bool
    let onHover: (Bool) -> Void
    let onStop: () -> Void
    
    var body: some View {
        Button(action: onStop) {
            Image(systemName: "stop.fill")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(
                    Circle().fill(
                        isHovered ? Color.red : Color.secondary.opacity(0.5)
                    )
                )
        }
        .buttonStyle(.plain)
        .onHover(perform: onHover)
    }
}

private struct DeviceStatusLabel: View {
    let device: RunningDevice
    
    var body: some View {
        Text(labelText)
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(device.isUnauthorized ? .orange : .secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color.secondary.opacity(0.08)))
    }
    
    private var labelText: String {
        if device.isUnauthorized { return "Authorize" }
        if device.isOffline { return "Offline" }
        return "Connected"
    }
}

// MARK: - AVD Card

private struct AVDCard: View {
    let avd: AVD
    let isHovered: Bool
    let onHover: (Bool) -> Void
    let onStart: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            DeviceIcon(systemImage: "iphone", color: .blue)
            
            Text(avd.name)
                .font(.system(size: 13, weight: .medium))
                .lineLimit(1)
            
            Spacer()
            
            StartButton(
                isHovered: isHovered,
                onHover: onHover,
                onStart: onStart
            )
        }
        .padding(12)
        .background(CardBackground())
    }
}

private struct StartButton: View {
    let isHovered: Bool
    let onHover: (Bool) -> Void
    let onStart: () -> Void
    
    var body: some View {
        Button(action: onStart) {
            Image(systemName: "play.fill")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(
                    Circle().fill(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                )
                .shadow(
                    color: isHovered ? .blue.opacity(0.3) : .clear,
                    radius: 4,
                    y: 2
                )
        }
        .buttonStyle(.plain)
        .onHover(perform: onHover)
    }
    
    private var gradientColors: [Color] {
        isHovered
            ? [.blue, .blue.opacity(0.8)]
            : [.blue.opacity(0.7), .blue.opacity(0.6)]
    }
}

// MARK: - Empty State

private struct EmptyStateView: View {
    let icon: String
    let message: String
    
    var body: some View {
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
                        .strokeBorder(
                            Color.secondary.opacity(0.1),
                            style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                        )
                )
        )
    }
}

// MARK: - Footer

private struct FooterView: View {
    let isRefreshing: Bool
    let onRefresh: () -> Void
    
    var body: some View {
        HStack(spacing: 10) {
            RefreshButton(
                isRefreshing: isRefreshing,
                onRefresh: onRefresh
            )

            Spacer()
            
            QuitButton()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

private struct RefreshButton: View {
    let isRefreshing: Bool
    let onRefresh: () -> Void
    
    var body: some View {
        Button(action: onRefresh) {
            HStack(spacing: 6) {
                Image(systemName: isRefreshing ? "arrow.circlepath" : "arrow.clockwise")
                    .font(.system(size: 11, weight: .semibold))
                    .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                    .animation(
                        isRefreshing
                            ? Animation.linear(duration: 1).repeatForever(autoreverses: false)
                            : .default,
                        value: isRefreshing
                    )
                
                Text(isRefreshing ? "Refreshing" : "Refresh")
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
        .disabled(isRefreshing)
        .opacity(isRefreshing ? 0.6 : 1)
    }
}

private struct QuitButton: View {
    var body: some View {
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
            .background(Capsule().fill(Color.secondary.opacity(0.08)))
        }
        .buttonStyle(.plain)
    }
}



private enum QuickActionDestination: String, CaseIterable, Identifiable, Hashable {
    case checkForUpdates
    case settings
    case help
    case about

    var id: String { rawValue }

    var title: String {
        switch self {
        case .checkForUpdates: return "Check for Updates"
        case .settings: return "Settings"
        case .help: return "Help"
        case .about: return "About"
        }
    }

    var icon: String {
        switch self {
        case .checkForUpdates: return "arrow.triangle.2.circlepath.circle"
        case .settings: return "gearshape"
        case .help: return "questionmark.circle"
        case .about: return "info.circle"
        }
    }
}

private struct QuickActionsOverlay: View {
    @EnvironmentObject var state: AppState
    @Binding var selectedDestination: QuickActionDestination?
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }

            VStack(spacing: 0) {
                QuickActionsHeader(
                    title: selectedDestination?.title ?? "EmuHub",
                    canGoBack: selectedDestination != nil,
                    onBack: { selectedDestination = nil },
                    onClose: { isPresented = false }
                )

                Divider()

                Group {
                    if let selectedDestination {
                        QuickActionDetailView(destination: selectedDestination)
                            .environmentObject(state)
                    } else {
                        QuickActionsMenuView(selectedDestination: $selectedDestination)
                    }
                }
            }
            .frame(width: 360, height: 500)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(NSColor.windowBackgroundColor))
                    .shadow(color: .black.opacity(0.2), radius: 16, y: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
            )
            .padding(12)
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.16), value: isPresented)
    }
}

private struct QuickActionsHeader: View {
    let title: String
    let canGoBack: Bool
    let onBack: () -> Void
    let onClose: () -> Void

    var body: some View {
        HStack {
            if canGoBack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 11, weight: .semibold))
                        .frame(width: 22, height: 22)
                }
                .buttonStyle(.plain)
            } else {
                Color.clear.frame(width: 22, height: 22)
            }

            Spacer()

            Text(title)
                .font(.system(size: 13, weight: .semibold))

            Spacer()

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .semibold))
                    .frame(width: 22, height: 22)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }
}

private struct QuickActionsMenuView: View {
    @Binding var selectedDestination: QuickActionDestination?

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(QuickActionDestination.allCases) { item in
                    Button {
                        selectedDestination = item
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: item.icon)
                                .font(.system(size: 13, weight: .semibold))
                                .frame(width: 20)
                                .foregroundStyle(.secondary)

                            Text(item.title)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.primary)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color.primary.opacity(0.04))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(12)
        }
    }
}

private struct QuickActionDetailView: View {
    @EnvironmentObject var state: AppState
    let destination: QuickActionDestination
    @Environment(\.openURL) private var openURL

    var body: some View {
        Group {
            switch destination {
            case .checkForUpdates:
                QuickActionInfoPage(
                    title: "Check for Updates",
                    description: "Keep EmuHub up to date with the latest improvements and fixes.",
                    primaryButtonTitle: "Open Releases",
                    primaryAction: {
                        openURL(URL(string: "https://github.com/Munyaradzi-Chigangawa/EmuHub/releases")!)
                    }
                )
            case .settings:
                SettingsView(preferredWidth: nil)
                    .environmentObject(state)
            case .help:
                QuickActionInfoPage(
                    title: "Help",
                    description: "Need guidance? Open the project docs and contribution guides.",
                    primaryButtonTitle: "Open Documentation",
                    primaryAction: {
                        openURL(URL(string: "https://github.com/Munyaradzi-Chigangawa/EmuHub#readme")!)
                    }
                )
            case .about:
                QuickActionAboutPage()
            }
        }
    }
}

private struct QuickActionInfoPage: View {
    let title: String
    let description: String
    let primaryButtonTitle: String
    let primaryAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.title3.weight(.semibold))

            Text(description)
                .font(.callout)
                .foregroundStyle(.secondary)

            Button(primaryButtonTitle, action: primaryAction)
                .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding(20)
    }
}

private struct QuickActionAboutPage: View {
    private var appVersion: String {
        let short = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "-"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "-"
        return "\(short) (\(build))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("EmuHub")
                .font(.title3.weight(.semibold))

            Text("Android emulator and device manager for macOS menu bar.")
                .foregroundStyle(.secondary)

            Text("Version \(appVersion)")
                .font(.callout)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(20)
    }
}

// MARK: - Reusable Components

private struct CardBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(Color.primary.opacity(0.03))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
            )
    }
}

private struct AppBackground: View {
    var body: some View {
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
