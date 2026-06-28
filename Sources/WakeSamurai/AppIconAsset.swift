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
        let image = NSImage(size: size)

        image.lockFocus()
        NSColor.black.setFill()

        let head = NSBezierPath(ovalIn: NSRect(x: 6.2, y: 10.6, width: 5.6, height: 5.6))
        head.fill()

        let helmet = NSBezierPath()
        helmet.move(to: NSPoint(x: 3.2, y: 9.8))
        helmet.curve(to: NSPoint(x: 9, y: 15.8), controlPoint1: NSPoint(x: 3.8, y: 13.4), controlPoint2: NSPoint(x: 5.8, y: 15.8))
        helmet.curve(to: NSPoint(x: 14.8, y: 9.8), controlPoint1: NSPoint(x: 12.2, y: 15.8), controlPoint2: NSPoint(x: 14.2, y: 13.4))
        helmet.line(to: NSPoint(x: 12.2, y: 9.8))
        helmet.curve(to: NSPoint(x: 9, y: 12.4), controlPoint1: NSPoint(x: 11.7, y: 11.3), controlPoint2: NSPoint(x: 10.5, y: 12.4))
        helmet.curve(to: NSPoint(x: 5.8, y: 9.8), controlPoint1: NSPoint(x: 7.5, y: 12.4), controlPoint2: NSPoint(x: 6.3, y: 11.3))
        helmet.close()
        helmet.fill()

        let shoulders = NSBezierPath()
        shoulders.move(to: NSPoint(x: 2.4, y: 1.8))
        shoulders.curve(to: NSPoint(x: 9, y: 6.6), controlPoint1: NSPoint(x: 3.3, y: 5), controlPoint2: NSPoint(x: 5.9, y: 6.6))
        shoulders.curve(to: NSPoint(x: 15.6, y: 1.8), controlPoint1: NSPoint(x: 12.1, y: 6.6), controlPoint2: NSPoint(x: 14.7, y: 5))
        shoulders.close()
        shoulders.fill()

        let topKnot = NSBezierPath(roundedRect: NSRect(x: 8, y: 15.1, width: 2, height: 2.3), xRadius: 0.7, yRadius: 0.7)
        topKnot.fill()

        image.unlockFocus()
        image.isTemplate = true
        return image
    }
}
