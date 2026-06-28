import Foundation
import IOKit.pwr_mgt

@MainActor
final class SleepAssertionController {
    private var assertionID: IOPMAssertionID = 0
    private(set) var isActive = false

    func setActive(_ active: Bool, reason: String) {
        if active {
            enable(reason: reason)
        } else {
            disable()
        }
    }

    private func enable(reason: String) {
        guard !isActive else { return }

        let result = IOPMAssertionCreateWithName(
            kIOPMAssertionTypeNoIdleSleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason as CFString,
            &assertionID
        )

        isActive = result == kIOReturnSuccess
        if !isActive {
            NSLog("WakeSamurai sleep assertion failed with IOReturn \(result)")
        }
    }

    private func disable() {
        guard isActive else { return }
        IOPMAssertionRelease(assertionID)
        assertionID = 0
        isActive = false
    }

    deinit {
        if isActive {
            IOPMAssertionRelease(assertionID)
        }
    }
}
