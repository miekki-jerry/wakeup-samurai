import AppKit
import Combine
import SwiftUI

@main
enum WakeSamuraiMain {
    @MainActor
    private static var retainedModel: AppModel?
    @MainActor
    private static var retainedStatusBarController: StatusBarController?

    @MainActor
    static func main() {
        let model = AppModel()
        retainedModel = model
        model.start()

        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)
        retainedStatusBarController = StatusBarController(model: model)

        app.run()
    }
}

@MainActor
private final class StatusBarController {
    private let model: AppModel
    private let statusItem: NSStatusItem
    private let popover: NSPopover
    private var cancellables: Set<AnyCancellable> = []

    init(model: AppModel) {
        self.model = model
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        popover = NSPopover()
        popover.behavior = .transient
        popover.contentSize = NSSize(width: 390, height: 250)
        popover.contentViewController = NSHostingController(rootView: StatusMenuView(model: model))

        statusItem.button?.target = self
        statusItem.button?.action = #selector(togglePopover)

        model.objectWillChange
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.updateStatusItem()
                }
            }
            .store(in: &cancellables)

        updateStatusItem()
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    private func updateStatusItem() {
        guard let button = statusItem.button else { return }
        button.image = AppIconAsset.statusBarImage()
        button.toolTip = model.statusTitle
        button.imagePosition = .imageOnly
    }
}
