import AppKit
import WakeSamuraiCore
import SwiftUI

struct StatusMenuView: View {
    @ObservedObject var model: AppModel

    private var activeAgent: DetectedAgent? {
        model.detectedAgents.first
    }

    private var statusText: String {
        guard let activeAgent else {
            return "No agent coding"
        }

        return "\(activeAgent.provider.displayName) is coding"
    }

    private var badgeText: String {
        if model.isKeepingAwake {
            return "ACTIVE"
        }

        if model.detectedAgents.isEmpty {
            return "IDLE"
        }

        return "PAUSED"
    }

    var body: some View {
        ZStack {
            CyberGrid()

            VStack(alignment: .leading, spacing: 0) {
                header
                Divider().overlay(Color.white.opacity(0.08))
                statusRows
                Divider().overlay(Color.white.opacity(0.08))
                controls
                Divider().overlay(Color.white.opacity(0.08))
                agents
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
        }
        .frame(width: 430, height: 320)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(red: 0.04, green: 0.045, blue: 0.045).opacity(0.98))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.13), lineWidth: 1)
        )
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(nsImage: AppIconAsset.statusBarImage())
                .resizable()
                .frame(width: 18, height: 18)
                .foregroundStyle(.white)
                .accessibilityHidden(true)

            Text("Wake Samurai")
                .font(.system(size: 15, weight: .semibold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.9))

            Spacer()

            Label(model.isKeepingAwake ? "awake" : "watching", systemImage: "cup.and.saucer")
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundStyle(model.isKeepingAwake ? CyberColor.yellow : .secondary)

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Image(systemName: "power")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            .help("Quit Wake Samurai")
            .keyboardShortcut("q")
        }
        .padding(.bottom, 14)
    }

    private var statusRows: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 12) {
                Circle()
                    .fill(model.detectedAgents.isEmpty ? Color.secondary.opacity(0.45) : CyberColor.yellow.opacity(0.65))
                    .frame(width: 10, height: 10)

                Text(statusText)
                    .font(.system(size: 19, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.92))

                Spacer()

                Text(badgeText)
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundStyle(model.isKeepingAwake ? CyberColor.yellow : .secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill((model.isKeepingAwake ? CyberColor.yellow : Color.secondary).opacity(0.08))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .stroke((model.isKeepingAwake ? CyberColor.yellow : Color.secondary).opacity(0.5), lineWidth: 1)
                    )
            }

            HStack(spacing: 12) {
                Image(systemName: "cup.and.saucer")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(CyberColor.cyan)
                    .frame(width: 24)

                Text(model.isKeepingAwake ? "Keeping Mac awake" : "Watching agents")
                    .font(.system(size: 18, weight: .medium, design: .monospaced))
                    .foregroundStyle(CyberColor.cyan)
            }
        }
        .padding(.vertical, 18)
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 10) {
            Toggle("Keep Mac awake while agents run", isOn: $model.isProtectionEnabled)
            Toggle("Open Wake Samurai at login", isOn: $model.startsAtLogin)
        }
        .toggleStyle(CyberCheckboxStyle())
        .font(.system(size: 13, weight: .medium, design: .monospaced))
        .foregroundStyle(.white.opacity(0.82))
        .padding(.vertical, 14)
    }

    private var agents: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DETECTED AGENTS")
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .tracking(4)
                .foregroundStyle(.white.opacity(0.45))

            HStack(spacing: 10) {
                ForEach(AgentProvider.allCases, id: \.self) { provider in
                    AgentChip(
                        title: provider == .claude ? "Claude Code" : provider.displayName,
                        isActive: model.detectedAgents.contains { $0.provider == provider }
                    )
                }
            }
        }
        .padding(.top, 16)
    }
}

private enum CyberColor {
    static let cyan = Color(red: 0.0, green: 0.92, blue: 0.95)
    static let yellow = Color(red: 1.0, green: 0.88, blue: 0.0)
}

private struct CyberCheckboxStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(configuration.isOn ? CyberColor.yellow.opacity(0.16) : Color.white.opacity(0.07))
                    .frame(width: 18, height: 18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .stroke(configuration.isOn ? CyberColor.yellow.opacity(0.75) : Color.white.opacity(0.18), lineWidth: 1)
                    )
                    .overlay {
                        if configuration.isOn {
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(CyberColor.yellow)
                        }
                    }

                configuration.label
            }
        }
        .buttonStyle(.plain)
    }
}

private struct AgentChip: View {
    let title: String
    let isActive: Bool

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(isActive ? CyberColor.yellow : Color.white.opacity(0.25))
                .frame(width: 8, height: 8)

            Text(title)
                .font(.system(size: 15, weight: .medium, design: .monospaced))
        }
        .foregroundStyle(isActive ? CyberColor.yellow : Color.white.opacity(0.5))
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(isActive ? CyberColor.yellow.opacity(0.08) : Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .stroke(isActive ? CyberColor.yellow.opacity(0.55) : Color.white.opacity(0.14), lineWidth: 1)
        )
    }
}

private struct CyberGrid: View {
    var body: some View {
        GeometryReader { proxy in
            Path { path in
                let spacing: CGFloat = 52
                var x: CGFloat = 0
                while x <= proxy.size.width {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: proxy.size.height))
                    x += spacing
                }

                var y: CGFloat = 0
                while y <= proxy.size.height {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: proxy.size.width, y: y))
                    y += spacing
                }
            }
            .stroke(CyberColor.cyan.opacity(0.055), lineWidth: 1)
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    StatusMenuView(model: AppModel())
}
