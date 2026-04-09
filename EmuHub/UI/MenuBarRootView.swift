//
//  MenuBarRootView.swift
//  EmuHub
//
//  Created by Munyaradzi Chigangawa on 27/1/2026.
//

import SwiftUI
import UniformTypeIdentifiers

// MARK: - Navigation Route

enum AppRoute: Hashable {
    case settings, help, about, updates, createAVD

    /// Routes that appear in the hamburger menu dropdown.
    static let menuItems: [AppRoute] = [.settings, .help, .about, .updates]

    var title: String {
        switch self {
        case .settings:  "Settings"
        case .help:      "Help"
        case .about:     "About EmuHub"
        case .updates:   "Software Update"
        case .createAVD: "New AVD"
        }
    }

    var systemImage: String {
        switch self {
        case .settings:  "gearshape"
        case .help:      "questionmark.circle"
        case .about:     "info.circle"
        case .updates:   "arrow.trianglehead.2.clockwise.rotate.90.circle"
        case .createAVD: "plus.circle.fill"
        }
    }
}

// MARK: - Root

struct MenuBarRootView: View {
    @EnvironmentObject var state: AppState
    @State private var route: AppRoute?
    @State private var menuOpen = false

    var body: some View {
        VStack(spacing: 0) {
            AppNavBar(
                route: route,
                menuOpen: $menuOpen,
                onBack: goBack,
                onNavigate: navigate(to:)
            )

            Divider().opacity(0.07)

            ZStack {
                if route == nil {
                    HomeView(onNavigate: navigate(to:))
                        .environmentObject(state)
                        .transition(.push(from: .leading))
                        .zIndex(0)
                } else {
                    PageView(route: route!)
                        .environmentObject(state)
                        .transition(.push(from: .trailing))
                        .zIndex(1)
                        .id(route)
                }
            }
            .animation(.spring(response: 0.38, dampingFraction: 0.86), value: route)
        }
        .frame(width: 420, height: 620)
        .background(Color(NSColor.windowBackgroundColor))
        .overlay {
            if menuOpen {
                Color.clear
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
                    .onTapGesture { closeMenu() }
                    .zIndex(9)

                AppMenuDropdown(onNavigate: navigate(to:))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(.top, 54)
                    .padding(.trailing, 12)
                    .transition(.scale(scale: 0.9, anchor: .topTrailing).combined(with: .opacity))
                    .zIndex(10)
            }
        }
        .animation(.spring(response: 0.28, dampingFraction: 0.8), value: menuOpen)
        .task {
            await state.refreshAll()
            state.startAutoRefresh()
        }
        .onDisappear {
            state.stopAutoRefresh()
            menuOpen = false
        }
    }

    private func navigate(to destination: AppRoute) {
        closeMenu()
        withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
            route = destination
        }
    }

    private func goBack() {
        withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
            route = nil
        }
    }

    private func closeMenu() {
        withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
            menuOpen = false
        }
    }
}

// MARK: - Navigation Bar

private struct AppNavBar: View {
    @EnvironmentObject var state: AppState
    let route: AppRoute?
    @Binding var menuOpen: Bool
    let onBack: () -> Void
    let onNavigate: (AppRoute) -> Void

    var body: some View {
        ZStack {
            if let route {
                Text(route.title)
                    .font(.system(size: 13, weight: .semibold))
                    .transition(.opacity.combined(with: .scale(scale: 0.92)))
            }

            HStack(spacing: 0) {
                if route != nil {
                    NavBackButton(action: onBack)
                        .transition(.move(edge: .leading).combined(with: .opacity))
                } else {
                    AppIdentity()
                        .transition(.move(edge: .leading).combined(with: .opacity))
                }

                Spacer()

                if route == nil {
                    HStack(spacing: 8) {
                        StatusPill(running: state.running.count)
                        NavMenuButton(open: $menuOpen)
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                } else {
                    Color.clear.frame(width: 52)
                        .transition(.opacity)
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 54)
        .animation(.spring(response: 0.34, dampingFraction: 0.84), value: route == nil)
    }
}

private struct NavBackButton: View {
    let action: () -> Void
    @State private var hovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 3) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 12, weight: .semibold))
                Text("Back")
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundStyle(hovered ? .primary : .secondary)
        }
        .buttonStyle(.plain)
        .onHover { hovered = $0 }
    }
}

private struct AppIdentity: View {
    var body: some View {
        HStack(spacing: 10) {
            AppIconMark()
            VStack(alignment: .leading, spacing: 1) {
                Text("EmuHub")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                Text("Android Device Manager")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

private struct AppIconMark: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(LinearGradient(
                    colors: [.blue.opacity(0.15), .purple.opacity(0.15)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 30, height: 30)

            Image(systemName: "iphone.and.arrow.forward")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
        }
    }
}

private struct StatusPill: View {
    let running: Int

    private var isActive: Bool { running > 0 }

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(isActive ? Color.green : Color.secondary.opacity(0.3))
                .frame(width: 6, height: 6)
                .shadow(color: isActive ? .green.opacity(0.45) : .clear, radius: 3)
            Text(isActive ? "\(running) active" : "idle")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(Capsule().fill(Color.secondary.opacity(0.07)))
        .animation(.spring(response: 0.3), value: running)
    }
}

private struct NavMenuButton: View {
    @Binding var open: Bool
    @State private var hovered = false

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.76)) {
                open.toggle()
            }
        } label: {
            Image(systemName: open ? "xmark" : "line.3.horizontal")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle((hovered || open) ? .primary : .secondary)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill((hovered || open) ? Color.primary.opacity(0.08) : Color.clear)
                )
                .animation(.easeInOut(duration: 0.15), value: open)
        }
        .buttonStyle(.plain)
        .onHover { hovered = $0 }
    }
}

// MARK: - App Menu Dropdown

private struct AppMenuDropdown: View {
    let onNavigate: (AppRoute) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(AppRoute.menuItems, id: \.self) { route in
                MenuRow(icon: route.systemImage, label: route.title) {
                    onNavigate(route)
                }
                if route != AppRoute.menuItems.last {
                    Divider()
                        .padding(.leading, 38)
                        .opacity(0.35)
                }
            }

            Divider().opacity(0.3).padding(.vertical, 2)

            MenuRow(icon: "power", label: "Quit EmuHub", destructive: true) {
                NSApplication.shared.terminate(nil)
            }
        }
        .frame(width: 210)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(NSColor.windowBackgroundColor))
                .shadow(color: .black.opacity(0.14), radius: 20, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.09), lineWidth: 1)
        )
    }
}

private struct MenuRow: View {
    let icon: String
    let label: String
    var destructive: Bool = false
    let action: () -> Void
    @State private var hovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(destructive ? .red : .secondary)
                    .frame(width: 16)
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(destructive ? .red : .primary)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(hovered ? Color.primary.opacity(0.05) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovered = $0 }
    }
}

// MARK: - Page Router

private struct PageView: View {
    @EnvironmentObject var state: AppState
    let route: AppRoute

    var body: some View {
        switch route {
        case .settings:
            SettingsView(preferredWidth: nil)
                .environmentObject(state)
        case .help:
            HelpView()
        case .about:
            AboutPage()
        case .updates:
            CheckForUpdatesPage()
                .environmentObject(state)
        case .createAVD:
            CreateAVDView()
                .environmentObject(state)
        }
    }
}

// MARK: - Home View

private struct HomeView: View {
    @EnvironmentObject var state: AppState
    let onNavigate: (AppRoute) -> Void
    @State private var avdSearch = ""
    @State private var searchActive = false

    private var filteredAVDs: [AVD] {
        guard !avdSearch.isEmpty else { return state.avds }
        return state.avds.filter {
            $0.friendlyName.localizedCaseInsensitiveContains(avdSearch) ||
            $0.name.localizedCaseInsensitiveContains(avdSearch)
        }
    }

    private func toggleSearch() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            searchActive.toggle()
            if !searchActive { avdSearch = "" }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // Action success banner
                    if let action = state.lastAction {
                        ActionBanner(message: action)
                            .padding(.horizontal, 14)
                            .padding(.top, 12)
                            .padding(.bottom, 4)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    // Error banner
                    if let error = state.lastError {
                        ErrorBanner(message: error)
                            .padding(.horizontal, 14)
                            .padding(.top, state.lastAction == nil ? 12 : 4)
                            .padding(.bottom, 4)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    // Running section
                    SectionHeader(
                        icon: "bolt.circle.fill", title: "Running",
                        color: .green, count: state.running.count,
                        buttons: []
                    )
                    .padding(.horizontal, 14)
                    .padding(.top, 14)
                    .padding(.bottom, 8)

                    if state.running.isEmpty {
                        EmptyStateCard(icon: "moon.zzz", message: "No devices connected")
                            .padding(.horizontal, 14)
                    } else {
                        VStack(spacing: 6) {
                            ForEach(state.running) { device in
                                RunningDeviceCard(
                                    device: device,
                                    isInstalling: state.installingAPK.contains(device.serial),
                                    onStop: { Task { await state.stop(device: device) } },
                                    onScreenshot: { Task { await state.captureScreenshot(device: device) } },
                                    onInstallAPK: { url in Task { await state.installAPK(device: device, url: url) } }
                                )
                            }
                        }
                        .padding(.horizontal, 14)
                    }

                    // Divider
                    Rectangle()
                        .fill(Color.primary.opacity(0.06))
                        .frame(height: 1)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)

                    // Available AVDs section
                    SectionHeader(
                        icon: "square.stack.3d.up.fill", title: "Available",
                        color: .blue, count: state.avds.count,
                        buttons: state.avds.isEmpty ? [] : [
                            SectionHeaderButton(
                                id: "search", icon: "magnifyingglass",
                                help: "Search AVDs", active: searchActive,
                                action: toggleSearch
                            ),
                            SectionHeaderButton(
                                id: "create", icon: "plus",
                                help: "New AVD",
                                action: { onNavigate(.createAVD) }
                            )
                        ]
                    )
                    .padding(.horizontal, 14)
                    .padding(.bottom, searchActive ? 6 : 8)

                    // Search field — revealed by icon toggle
                    if searchActive {
                        AVDSearchField(text: $avdSearch, onDismiss: toggleSearch)
                            .padding(.horizontal, 14)
                            .padding(.bottom, 8)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    if state.avds.isEmpty {
                        EmptyStateCard(
                            icon: "square.dashed",
                            message: "No AVDs found",
                            detail: "Set your Android SDK path in Settings",
                            actionLabel: "Open Settings"
                        ) { onNavigate(.settings) }
                        .padding(.horizontal, 14)
                    } else if filteredAVDs.isEmpty {
                        EmptyStateCard(
                            icon: "magnifyingglass",
                            message: "No AVDs match \"\(avdSearch)\""
                        )
                        .padding(.horizontal, 14)
                    } else {
                        VStack(spacing: 6) {
                            ForEach(filteredAVDs) { avd in
                                AVDCard(
                                    avd: avd,
                                    onStart:    { Task { await state.start(avd: avd) } },
                                    onColdBoot: { Task { await state.coldBoot(avd: avd) } },
                                    onWipeBoot: { Task { await state.wipeAndBoot(avd: avd) } }
                                )
                            }
                        }
                        .padding(.horizontal, 14)
                    }

                    Spacer(minLength: 14)
                }
            }
            .animation(.easeOut(duration: 0.2), value: state.lastError != nil)
            .animation(.easeOut(duration: 0.2), value: state.lastAction != nil)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: searchActive)

            Divider().opacity(0.07)

            HomeFooter(
                isRefreshing: state.isRefreshing,
                lastRefresh: state.lastRefreshAt,
                onRefresh: { Task { await state.refreshAll() } }
            )
        }
    }
}

// MARK: - Section Header

private struct SectionHeader: View {
    let icon: String
    let title: String
    let color: Color
    let count: Int
    var buttons: [SectionHeaderButton] = []

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(color)
            Text(title.uppercased())
                .font(.system(size: 10.5, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
                .kerning(0.5)
            Spacer()
            if count > 0 {
                Text("\(count)")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(color.opacity(0.75))
                    .monospacedDigit()
                    .padding(.trailing, buttons.isEmpty ? 0 : 4)
            }
            ForEach(buttons) { btn in
                SectionHeaderIconButton(button: btn, tint: color)
            }
        }
        .animation(.spring(response: 0.3), value: count)
    }
}

struct SectionHeaderButton: Identifiable {
    let id: String
    let icon: String
    let help: String
    var active: Bool = false
    let action: () -> Void
}

private struct SectionHeaderIconButton: View {
    let button: SectionHeaderButton
    let tint: Color
    @State private var hovered = false

    var body: some View {
        Button(action: button.action) {
            Image(systemName: button.icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle((hovered || button.active) ? tint : tint.opacity(0.5))
                .frame(width: 22, height: 22)
                .background(
                    Circle().fill((hovered || button.active) ? tint.opacity(0.12) : Color.clear)
                )
        }
        .buttonStyle(.plain)
        .onHover { hovered = $0 }
        .help(button.help)
    }
}

// MARK: - AVD Search Field

private struct AVDSearchField: View {
    @Binding var text: String
    var onDismiss: (() -> Void)? = nil
    @FocusState private var focused: Bool

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.tertiary)

            TextField("Filter AVDs…", text: $text)
                .textFieldStyle(.plain)
                .font(.system(size: 12))
                .focused($focused)

            Button {
                if text.isEmpty {
                    onDismiss?()
                } else {
                    text = ""
                }
            } label: {
                Image(systemName: text.isEmpty ? "xmark" : "xmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.tertiary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.primary.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(
                            focused ? Color.blue.opacity(0.5) : Color.primary.opacity(0.08),
                            lineWidth: 1
                        )
                )
        )
        .animation(.easeInOut(duration: 0.15), value: focused)
        .onAppear { focused = true }
    }
}

// MARK: - Running Device Card

private struct RunningDeviceCard: View {
    let device: RunningDevice
    let isInstalling: Bool
    let onStop: () -> Void
    let onScreenshot: () -> Void
    let onInstallAPK: (URL) -> Void

    @State private var hovered = false
    @State private var isDropTargeted = false

    var body: some View {
        HStack(spacing: 12) {
            DeviceKindIcon(device: device)

            VStack(alignment: .leading, spacing: 3) {
                Text(device.displayName)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)
                Text(device.statusDescription)
                    .font(.system(size: 11))
                    .foregroundStyle(device.hasIssue ? Color.orange : .secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            trailingControls
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            CardSurface()
                .overlay(
                    isDropTargeted
                        ? RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .strokeBorder(Color.blue, lineWidth: 2)
                        : nil
                )
        )
        // APK drop overlay
        .overlay(
            Group {
                if isDropTargeted {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(NSColor.windowBackgroundColor).opacity(0.9))
                        .overlay(
                            VStack(spacing: 4) {
                                Image(systemName: "arrow.down.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.blue)
                                Text("Drop to Install APK")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.blue)
                            }
                        )
                }
            }
        )
        .onHover { hovered = $0 }
        .onDrop(of: [.fileURL], isTargeted: $isDropTargeted, perform: handleDrop)
        .help(device.isEmulator || device.state == "device"
              ? "Drop an .apk to install"
              : "")
    }

    @ViewBuilder
    private var trailingControls: some View {
        if isInstalling {
            HStack(spacing: 6) {
                ProgressView().controlSize(.small)
                Text("Installing…")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        } else if device.isEmulator {
            HStack(spacing: 4) {
                ScreenshotButton(visible: hovered, action: onScreenshot)
                StopButton(hovered: hovered, action: onStop)
            }
        } else if device.state == "device" {
            // Authorized physical device
            HStack(spacing: 4) {
                ScreenshotButton(visible: hovered, action: onScreenshot)
                DeviceStatusBadge(device: device)
            }
        } else {
            DeviceStatusBadge(device: device)
        }
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }

        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier) { item, _ in
            let url: URL?
            if let data = item as? Data {
                url = URL(dataRepresentation: data, relativeTo: nil)
            } else if let u = item as? URL {
                url = u
            } else {
                url = nil
            }
            guard let fileURL = url, fileURL.pathExtension.lowercased() == "apk" else { return }
            Task { @MainActor in onInstallAPK(fileURL) }
        }
        return true
    }
}

private struct DeviceKindIcon: View {
    let device: RunningDevice

    var body: some View {
        ZStack {
            Circle()
                .fill(iconColor.opacity(0.1))
                .frame(width: 34, height: 34)
            Image(systemName: iconName)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(iconColor)
        }
    }

    private var iconName: String {
        if device.hasIssue { return "exclamationmark.triangle.fill" }
        if device.isEmulator { return "play.fill" }
        return device.isTablet ? "ipad" : "iphone"
    }

    private var iconColor: Color {
        if device.hasIssue { return .orange }
        return device.isEmulator ? .green : .blue
    }
}

private struct ScreenshotButton: View {
    let visible: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "camera.fill")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 28, height: 28)
                .background(Circle().fill(Color.secondary.opacity(visible ? 0.1 : 0)))
        }
        .buttonStyle(.plain)
        .opacity(visible ? 1 : 0)
        .animation(.easeInOut(duration: 0.15), value: visible)
        .help("Take Screenshot")
    }
}

private struct StopButton: View {
    let hovered: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: "stop.fill")
                    .font(.system(size: 10, weight: .semibold))
                if hovered {
                    Text("Stop")
                        .font(.system(size: 11, weight: .semibold))
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, hovered ? 11 : 8)
            .padding(.vertical, 7)
            .background(Capsule().fill(hovered ? Color.red : Color.secondary.opacity(0.4)))
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.22, dampingFraction: 0.78), value: hovered)
    }
}

private struct DeviceStatusBadge: View {
    let device: RunningDevice

    var body: some View {
        Text(label)
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(badgeColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Capsule().fill(badgeColor.opacity(0.1)))
    }

    private var label: String {
        if device.isUnauthorized { return "Unauthorized" }
        if device.isOffline { return "Offline" }
        return "Read-only"
    }

    private var badgeColor: Color {
        device.hasIssue ? .orange : .secondary
    }
}

// MARK: - AVD Card

private struct AVDCard: View {
    let avd: AVD
    let onStart: () -> Void
    let onColdBoot: () -> Void
    let onWipeBoot: () -> Void
    @State private var hovered = false

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(avd.deviceType.color.opacity(0.1))
                    .frame(width: 34, height: 34)
                Image(systemName: avd.deviceType.systemImage)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(avd.deviceType.color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(avd.friendlyName)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)
                Text(avd.subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            LaunchButton(hovered: hovered, color: avd.deviceType.color, action: onStart)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(CardSurface())
        .onHover { hovered = $0 }
        .contextMenu {
            Button {
                onStart()
            } label: {
                Label("Launch", systemImage: "play.fill")
            }

            Button {
                onColdBoot()
            } label: {
                Label("Cold Boot", systemImage: "snowflake")
            }

            Divider()

            Button(role: .destructive) {
                onWipeBoot()
            } label: {
                Label("Wipe Data & Boot", systemImage: "trash")
            }
        }
    }
}

private struct LaunchButton: View {
    let hovered: Bool
    var color: Color = .blue
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: "play.fill")
                    .font(.system(size: 10, weight: .semibold))
                if hovered {
                    Text("Launch")
                        .font(.system(size: 11, weight: .semibold))
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, hovered ? 11 : 8)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(hovered ? color : color.opacity(0.7))
                    .shadow(color: hovered ? color.opacity(0.3) : .clear, radius: 4, y: 2)
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.22, dampingFraction: 0.78), value: hovered)
    }
}

// MARK: - Banners

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
                .fill(Color.red.opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(Color.red.opacity(0.18), lineWidth: 1)
                )
        )
    }
}

private struct ActionBanner: View {
    let message: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 13))
                .foregroundStyle(.green)
            Text(message)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.green.opacity(0.9))
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.green.opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(Color.green.opacity(0.18), lineWidth: 1)
                )
        )
    }
}

// MARK: - Empty State

private struct EmptyStateCard: View {
    let icon: String
    let message: String
    var detail: String? = nil
    var actionLabel: String? = nil
    var onAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .light))
                .foregroundStyle(.tertiary)

            Text(message)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)

            if let detail {
                Text(detail)
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
            }

            if let label = actionLabel, let action = onAction {
                Button(label, action: action)
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.secondary.opacity(0.035))
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

// MARK: - Home Footer

private struct HomeFooter: View {
    let isRefreshing: Bool
    let lastRefresh: Date?
    let onRefresh: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            RefreshButton(isRefreshing: isRefreshing, action: onRefresh)

            Spacer()

            if let last = lastRefresh {
                TimelineView(.periodic(from: .now, by: 10)) { _ in
                    Text(relativeTime(from: last))
                        .font(.system(size: 10.5))
                        .foregroundStyle(.quaternary)
                        .monospacedDigit()
                }
            }

            Spacer()

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Text("Quit")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(Color.secondary.opacity(0.07)))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    private func relativeTime(from date: Date) -> String {
        let secs = Int(-date.timeIntervalSinceNow)
        if secs < 5  { return "just now" }
        if secs < 60 { return "\(secs)s ago" }
        return "\(secs / 60)m ago"
    }
}

private struct RefreshButton: View {
    let isRefreshing: Bool
    let action: () -> Void
    @State private var hovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 11, weight: .semibold))
                    .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                    .animation(
                        isRefreshing
                            ? .linear(duration: 0.9).repeatForever(autoreverses: false)
                            : .default,
                        value: isRefreshing
                    )
                Text(isRefreshing ? "Refreshing…" : "Refresh")
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundStyle(hovered ? .primary : .secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(hovered ? Color.primary.opacity(0.07) : Color.primary.opacity(0.04))
                    .overlay(Capsule().strokeBorder(Color.primary.opacity(0.08), lineWidth: 1))
            )
        }
        .buttonStyle(.plain)
        .disabled(isRefreshing)
        .opacity(isRefreshing ? 0.65 : 1)
        .onHover { hovered = $0 }
    }
}

// MARK: - Shared Card Background

private struct CardSurface: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(Color.primary.opacity(0.03))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.07), lineWidth: 1)
            )
    }
}

// MARK: - Model Extensions

extension RunningDevice {
    var displayName: String {
        if isEmulator {
            if let raw = avdName, !raw.isEmpty {
                var n = raw
                if let r = n.range(of: #"_API_\d+"#, options: .regularExpression) {
                    n = String(n[..<r.lowerBound])
                }
                return n.replacingOccurrences(of: "_", with: " ")
            }
            if let portStr = serial.split(separator: "-").last,
               let port = Int(portStr) {
                let index = (port - 5554) / 2 + 1
                return index > 1 ? "Emulator #\(index)" : "Android Emulator"
            }
            return "Android Emulator"
        }
        return model ?? serial
    }

    var statusDescription: String {
        if isEmulator {
            let portSuffix: String = {
                guard let p = serial.split(separator: "-").last else { return "" }
                return " · port \(p)"
            }()
            switch state {
            case "device":       return "Emulator running\(portSuffix)"
            case "offline":      return "Offline\(portSuffix)"
            case "unauthorized": return "Unauthorized\(portSuffix)"
            default:             return state.capitalized
            }
        }
        if isUnauthorized { return "Tap 'Allow' on your device to authorize USB debugging" }
        if isOffline      { return "Device offline — check USB cable" }
        if state == "device" {
            let ver = androidVersion.map { "Android \($0) · " } ?? ""
            return "\(ver)USB connected · read-only"
        }
        return state.capitalized
    }

    var hasIssue: Bool { isUnauthorized || isOffline }
}

// MARK: - AVD Device Type

enum AVDDeviceType {
    case phone, tablet, tv, wear, automotive, foldable

    var systemImage: String {
        switch self {
        case .phone:      "iphone"
        case .tablet:     "ipad"
        case .tv:         "tv"
        case .wear:       "applewatch"
        case .automotive: "car"
        case .foldable:   "iphone"
        }
    }

    var color: Color {
        switch self {
        case .phone:      .blue
        case .tablet:     .indigo
        case .tv:         .purple
        case .wear:       .pink
        case .automotive: .green
        case .foldable:   .orange
        }
    }
}

extension AVD {
    var deviceType: AVDDeviceType {
        let n = name.lowercased()
        if n.contains("_tv") || n.hasPrefix("tv_") || n.contains("android_tv") { return .tv }
        if n.contains("watch") || n.contains("wear") || n.contains("wearos")   { return .wear }
        if n.contains("automotive") || n.contains("_car_")                      { return .automotive }
        if n.contains("fold") || n.contains("flip")                             { return .foldable }
        if n.contains("tablet") || n.contains("pixel_tablet") ||
           n.contains("tab_")  || n.hasSuffix("_tab")                          { return .tablet }
        return .phone
    }

    var friendlyName: String {
        var n = name
        if let r = n.range(of: #"_API_\d+"#, options: .regularExpression) {
            n = String(n[..<r.lowerBound])
        }
        return n.replacingOccurrences(of: "_", with: " ")
    }

    var subtitle: String {
        let typeName: String
        switch deviceType {
        case .phone:      typeName = "Virtual Device"
        case .tablet:     typeName = "Tablet"
        case .tv:         typeName = "Android TV"
        case .wear:       typeName = "Wear OS"
        case .automotive: typeName = "Automotive"
        case .foldable:   typeName = "Foldable"
        }
        if let r = name.range(of: #"API_(\d+)"#, options: .regularExpression) {
            let level = name[r].replacingOccurrences(of: "API_", with: "")
            return "API \(level) · \(typeName)"
        }
        return typeName
    }
}

// MARK: - Create AVD View

private struct CreateAVDView: View {
    @EnvironmentObject var state: AppState

    @State private var avdName: String = ""
    @State private var systemImages: [SystemImage] = []
    @State private var deviceProfiles: [DeviceProfile] = []
    @State private var selectedImage: SystemImage?
    @State private var selectedDevice: DeviceProfile?
    @State private var isLoading = true
    @State private var loadError: String?

    private var sanitizedName: String {
        avdName.trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: " ", with: "_")
    }

    private var canCreate: Bool {
        !sanitizedName.isEmpty && selectedImage != nil && selectedDevice != nil && !state.isCreatingAVD
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {

                if let err = state.avdCreationError {
                    ErrorBanner(message: err)
                }

                if isLoading {
                    HStack {
                        Spacer()
                        VStack(spacing: 10) {
                            ProgressView()
                            Text("Loading SDK data…")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.top, 40)
                } else if let err = loadError {
                    ErrorBanner(message: err)
                } else {
                    // Name
                    CreateAVDSection(title: "Name", icon: "character.cursor.ibeam") {
                        VStack(alignment: .leading, spacing: 6) {
                            TextField("e.g. Pixel_9_API_35", text: $avdName)
                                .textFieldStyle(.plain)
                                .font(.system(size: 13))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(Color.primary.opacity(0.04))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                                        )
                                )
                            if !avdName.isEmpty && avdName.contains(" ") {
                                Text("Spaces will be replaced with underscores: \(sanitizedName)")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    // System Image
                    CreateAVDSection(title: "System Image", icon: "cpu") {
                        if systemImages.isEmpty {
                            Text("No system images installed. Use SDK Manager to install one.")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                                .padding(.vertical, 4)
                        } else {
                            VStack(spacing: 4) {
                                ForEach(systemImages) { img in
                                    SelectionRow(
                                        label: img.displayName,
                                        detail: img.packageName,
                                        isSelected: selectedImage == img
                                    ) { selectedImage = img }
                                }
                            }
                        }
                    }

                    // Device Profile
                    CreateAVDSection(title: "Hardware Profile", icon: "iphone") {
                        if deviceProfiles.isEmpty {
                            Text("No device profiles found.")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                                .padding(.vertical, 4)
                        } else {
                            // Show a picker since profiles list is long
                            Picker("", selection: $selectedDevice) {
                                Text("Select a device…").tag(Optional<DeviceProfile>.none)
                                ForEach(deviceProfiles) { profile in
                                    Text(profile.name).tag(Optional(profile))
                                }
                            }
                            .labelsHidden()
                            .frame(maxWidth: .infinity)
                        }
                    }

                    // Create button
                    Button {
                        guard let img = selectedImage, let dev = selectedDevice else { return }
                        Task {
                            await state.createAVD(
                                name: sanitizedName,
                                systemImagePackage: img.packageName,
                                deviceId: dev.deviceId
                            )
                        }
                    } label: {
                        HStack(spacing: 8) {
                            if state.isCreatingAVD {
                                ProgressView().controlSize(.small)
                                Text("Creating…")
                            } else {
                                Image(systemName: "plus.circle.fill")
                                Text("Create AVD")
                            }
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(canCreate ? Color.blue : Color.secondary.opacity(0.3))
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(!canCreate)
                    .padding(.top, 4)
                }

                Spacer(minLength: 14)
            }
            .padding(16)
        }
        .task { await loadData() }
        .onChange(of: state.isCreatingAVD) { _, creating in
            // Clear error when a new creation starts
            if creating { state.avdCreationError = nil }
        }
    }

    private func loadData() async {
        isLoading = true
        loadError = nil
        defer { isLoading = false }

        do {
            let sdkPath = state.sdkPath
            // System images: filesystem scan (synchronous, fast)
            systemImages = state.emulatorService.listSystemImages(sdkPath: sdkPath)

            // Device profiles: requires avdmanager
            let toolchain = try AndroidToolchain(sdkPath: sdkPath)
            guard let avdmanagerPath = toolchain.avdmanagerPath else {
                loadError = "avdmanager not found. Install Android Command-line Tools via SDK Manager."
                deviceProfiles = []
                return
            }
            deviceProfiles = try await state.emulatorService.listDeviceProfiles(avdmanagerPath: avdmanagerPath)
            // Pre-select sensible defaults
            selectedImage = systemImages.first
            selectedDevice = deviceProfiles.first { $0.deviceId == "pixel_7" }
                ?? deviceProfiles.first { $0.name.lowercased().contains("pixel") }
                ?? deviceProfiles.first
        } catch {
            loadError = error.localizedDescription
        }
    }
}

private struct CreateAVDSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
                Text(title.uppercased())
                    .font(.system(size: 10.5, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .kerning(0.5)
            }
            content()
        }
    }
}

private struct SelectionRow: View {
    let label: String
    let detail: String
    let isSelected: Bool
    let action: () -> Void
    @State private var hovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? Color.blue : Color.primary.opacity(0.2), lineWidth: 1.5)
                        .frame(width: 16, height: 16)
                    if isSelected {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                    }
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.primary)
                    Text(detail)
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isSelected ? Color.blue.opacity(0.07) : (hovered ? Color.primary.opacity(0.04) : Color.clear))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .strokeBorder(isSelected ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .onHover { hovered = $0 }
        .animation(.easeInOut(duration: 0.12), value: isSelected)
    }
}

// MARK: - Preview

#Preview {
    MenuBarRootView()
        .environmentObject(AppState())
}
