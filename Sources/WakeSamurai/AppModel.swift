import WakeSamuraiCore
import Combine
import Foundation

@MainActor
final class AppModel: ObservableObject {
    @Published var detectedAgents: [DetectedAgent] = []
    @Published var lastUpdated: Date?
    @Published var isProtectionEnabled = true {
        didSet {
            updateSleepAssertion()
        }
    }
    @Published var startsAtLogin = LoginItemController.isEnabled {
        didSet {
            LoginItemController.isEnabled = startsAtLogin
        }
    }

    private let detector = AgentDetector()
    private let sleepAssertion = SleepAssertionController()
    private var timer: Timer?

    var isKeepingAwake: Bool {
        isProtectionEnabled && !detectedAgents.isEmpty && sleepAssertion.isActive
    }

    var statusTitle: String {
        if isKeepingAwake {
            "Keeping Mac awake"
        } else if detectedAgents.isEmpty {
            "No active agents"
        } else {
            "Protection paused"
        }
    }

    func start() {
        guard timer == nil else { return }
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refresh()
            }
        }
    }

    func refresh() {
        do {
            detectedAgents = try detector.detectedAgents()
            lastUpdated = Date()
            updateSleepAssertion()
        } catch {
            NSLog("WakeSamurai detection failed: \(error.localizedDescription)")
        }
    }

    private func updateSleepAssertion() {
        sleepAssertion.setActive(
            isProtectionEnabled && !detectedAgents.isEmpty,
            reason: "Wake Samurai detected an active AI coding agent."
        )
    }
}
