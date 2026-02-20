//
//  HelpView.swift
//  EmuHub
//
//  Created by Munyaradzi Chigangawa on 27/1/2026.
//

import SwiftUI

// MARK: - Data Model

private struct HelpItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

private struct HelpSection: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let items: [HelpItem]
}

private let helpSections: [HelpSection] = [
    HelpSection(
        icon: "play.circle",
        title: "Getting Started",
        items: [
            HelpItem(
                question: "How do I start an emulator?",
                answer: "Click the EmuHub icon in your macOS menu bar. Under the Available section, you'll see a list of your Android Virtual Devices (AVDs). Click on any AVD name to launch it. The emulator will appear in the Running section once it's active."
            ),
            HelpItem(
                question: "How do I stop a running emulator?",
                answer: "In the Running section of the menu, click Stop next to the emulator you want to shut down. EmuHub sends an adb emu kill command to cleanly terminate it."
            ),
            HelpItem(
                question: "Why don't I see any AVDs in the menu?",
                answer: "EmuHub needs a valid Android SDK path to detect your AVDs. Open Settings and verify the SDK Path is set correctly. The default location is ~/Library/Android/sdk. After updating it, use Refresh Now or wait for the next auto-refresh."
            ),
        ]
    ),
    HelpSection(
        icon: "wrench.and.screwdriver",
        title: "Troubleshooting",
        items: [
            HelpItem(
                question: "EmuHub can't find my Android SDK",
                answer: "EmuHub tries to auto-detect your SDK at ~/Library/Android/sdk. If you installed Android Studio to a custom location, open Settings → Android SDK and enter the correct path manually. The path should point to the root sdk folder that contains platform-tools, emulator, and avd subdirectories."
            ),
            HelpItem(
                question: "My physical device shows as 'unauthorized'",
                answer: "This means USB debugging hasn't been approved for this Mac. Unlock your device, look for the 'Allow USB Debugging?' prompt on screen, and tap Allow. If the prompt doesn't appear, try unplugging and replugging the cable. Make sure USB debugging is enabled in Developer Options on your device."
            ),
            HelpItem(
                question: "My physical device shows as 'offline'",
                answer: "The device is connected but adb can't communicate with it. Try unplugging and replugging the cable, or run adb kill-server && adb start-server in Terminal to reset the adb daemon. Also check that your USB cable supports data transfer (not just charging)."
            ),
            HelpItem(
                question: "The emulator list isn't updating",
                answer: "Use the Refresh Now button in Settings to force an immediate update. You can also lower the auto-refresh interval in Settings → Refresh. If the issue persists, check that adb is accessible — EmuHub uses the adb binary inside your SDK's platform-tools folder."
            ),
            HelpItem(
                question: "macOS says EmuHub can't be opened because it's from an unidentified developer",
                answer: "EmuHub is signed with an Apple Personal Team certificate and is not notarized. To open it: right-click EmuHub.app → Open → Open. Alternatively, go to System Settings → Privacy & Security and click Open Anyway. You only need to do this once."
            ),
        ]
    ),
    HelpSection(
        icon: "gearshape",
        title: "Configuration",
        items: [
            HelpItem(
                question: "What are Extra Args for the emulator?",
                answer: "Extra Args are additional command-line flags passed to the emulator at launch. Common examples include -no-snapshot-load to always do a cold boot, and -gpu host to use your Mac's GPU for rendering. You can combine multiple flags separated by spaces."
            ),
            HelpItem(
                question: "How does auto-refresh work?",
                answer: "EmuHub polls adb at a regular interval to detect changes in emulator and device state. You can configure the interval between 3 and 60 seconds in Settings → Refresh. A shorter interval means faster updates but slightly more CPU usage."
            ),
            HelpItem(
                question: "Can I control physical Android devices through EmuHub?",
                answer: "No — physical devices are shown for visibility only. EmuHub intentionally treats them as read-only to prevent accidental actions on real hardware. You can see their connection state, but start and stop actions are only available for emulators."
            ),
        ]
    ),
]

// MARK: - Main View

struct HelpView: View {

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ForEach(helpSections) { section in
                    HelpSectionView(section: section)
                }

                SupportLinksView()
            }
            .padding(16)
        }
    }
}

// MARK: - Section

private struct HelpSectionView: View {
    let section: HelpSection

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            HStack(spacing: 6) {
                Image(systemName: section.icon)
                    .font(.caption)
                    .foregroundStyle(.tint)
                Text(section.title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .kerning(0.4)
            }

            // Items
            VStack(spacing: 1) {
                ForEach(section.items) { item in
                    HelpAccordionRow(item: item)
                }
            }
            .background(.background.secondary, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Accordion Row

private struct HelpAccordionRow: View {
    let item: HelpItem
    @State private var isExpanded = false
    @State private var isHovered = false

    var body: some View {
        VStack(spacing: 0) {
            // Question row
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(alignment: .center, spacing: 10) {
                    Text(item.question)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 8)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.tertiary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isExpanded)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
                .background(isHovered && !isExpanded ? Color.primary.opacity(0.04) : Color.clear)
            }
            .buttonStyle(.plain)
            .onHover { isHovered = $0 }

            // Answer
            if isExpanded {
                Divider()
                    .padding(.horizontal, 16)

                Text(item.answer)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(3)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

// MARK: - Support Links

private struct SupportLinksView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "ellipsis.bubble")
                    .font(.caption)
                    .foregroundStyle(.tint)
                Text("Still need help?")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .kerning(0.4)
            }

            VStack(spacing: 1) {
                SupportLinkRow(
                    icon: "ladybug",
                    label: "Report a Bug",
                    subtitle: "Open a GitHub issue",
                    url: "https://github.com/Munyaradzi-Chigangawa/EmuHub/issues/new"
                )
                Divider().padding(.leading, 44)
                SupportLinkRow(
                    icon: "lightbulb",
                    label: "Request a Feature",
                    subtitle: "Share your ideas on GitHub",
                    url: "https://github.com/Munyaradzi-Chigangawa/EmuHub/issues/new"
                )
                Divider().padding(.leading, 44)
                SupportLinkRow(
                    icon: "doc.text",
                    label: "View Changelog",
                    subtitle: "See what's new in each release",
                    url: "https://github.com/Munyaradzi-Chigangawa/EmuHub/blob/main/CHANGELOG.md"
                )
            }
            .background(.background.secondary, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct SupportLinkRow: View {
    let icon: String
    let label: String
    let subtitle: String
    let url: String
    @State private var isHovered = false

    var body: some View {
        Link(destination: URL(string: url)!) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundStyle(.tint)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 1) {
                    Text(label)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
            .background(isHovered ? Color.primary.opacity(0.06) : Color.clear)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}
