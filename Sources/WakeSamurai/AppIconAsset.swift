import AppKit

enum AppIconAsset {
    static func image(size: NSSize? = nil) -> NSImage {
        let image: NSImage
        if let url = Bundle.main.url(forResource: "AppIconSource", withExtension: "png"),
           let source = NSImage(contentsOf: url) {
            image = source
        } else {
            image = NSImage(named: NSImage.applicationIconName) ?? NSImage()
        }

        if let size {
            image.size = size
        }
        image.isTemplate = false
        return image
    }
}
