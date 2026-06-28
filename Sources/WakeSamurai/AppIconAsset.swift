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

    static func statusBarImage() -> NSImage {
        let size = NSSize(width: 18, height: 18)

        if let image = NSImage(systemSymbolName: "figure.fencing", accessibilityDescription: "Wake Samurai") {
            image.size = size
            image.isTemplate = true
            return image
        }

        let image = NSImage(size: size)

        image.lockFocus()
        NSColor.black.setFill()

        let helmet = NSBezierPath()
        helmet.move(to: NSPoint(x: 2.4, y: 7.1))
        helmet.curve(to: NSPoint(x: 9, y: 15.3), controlPoint1: NSPoint(x: 2.8, y: 12), controlPoint2: NSPoint(x: 5.6, y: 15.3))
        helmet.curve(to: NSPoint(x: 15.6, y: 7.1), controlPoint1: NSPoint(x: 12.4, y: 15.3), controlPoint2: NSPoint(x: 15.2, y: 12))
        helmet.line(to: NSPoint(x: 13.2, y: 6.1))
        helmet.line(to: NSPoint(x: 11.8, y: 2.1))
        helmet.curve(to: NSPoint(x: 6.2, y: 2.1), controlPoint1: NSPoint(x: 10.1, y: 1.2), controlPoint2: NSPoint(x: 7.9, y: 1.2))
        helmet.line(to: NSPoint(x: 4.8, y: 6.1))
        helmet.close()
        helmet.fill()

        let crest = NSBezierPath()
        crest.move(to: NSPoint(x: 9, y: 16.4))
        crest.line(to: NSPoint(x: 10.1, y: 13.6))
        crest.line(to: NSPoint(x: 7.9, y: 13.6))
        crest.close()
        crest.fill()

        image.unlockFocus()
        image.isTemplate = true
        return image
    }
}
