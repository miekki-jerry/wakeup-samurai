import WakeSamuraiCore
import SwiftUI

struct StatusMenuView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header

            Divider()

            Toggle("Keep Mac awake while agents run", isOn: $model.isProtectionEnabled)
            Toggle("Open Wake Samurai at login", isOn: $model.startsAtLogin)

            Divider()

            agentsSection

            Divider()

            HStack {
                Button("Refresh") {
                    model.refresh()
                }
                .keyboardShortcut("r")

                Spacer()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q")
            }
        }
        .padding(16)
        .frame(width: 340)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(nsImage: AppIconAsset.image())
                .resizable()
                .interpolation(.high)
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(model.statusTitle)
                    .font(.headline)
                Text(updatedText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }

    @ViewBuilder
    private var agentsSection: some View {
        if model.detectedAgents.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                Text("Watching for Codex and Claude")
                    .font(.subheadline.weight(.semibold))
                Text("Wake Samurai will prevent idle sleep as soon as a supported coding agent is detected.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text("Detected agents")
                    .font(.subheadline.weight(.semibold))

                ForEach(model.detectedAgents) { agent in
                    AgentRow(agent: agent)
                }
            }
        }
    }

    private var updatedText: String {
        guard let lastUpdated = model.lastUpdated else {
            return "Waiting for first scan"
        }

        return "Updated \(lastUpdated.formatted(date: .omitted, time: .shortened))"
    }
}

private struct AgentRow: View {
    let agent: DetectedAgent

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: agent.provider == .codex ? "terminal" : "sparkle")
                .foregroundStyle(.secondary)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: 2) {
                Text(agent.provider.displayName)
                    .font(.subheadline.weight(.medium))
                Text("\(agent.title) · pid \(agent.id)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    StatusMenuView(model: AppModel())
}
