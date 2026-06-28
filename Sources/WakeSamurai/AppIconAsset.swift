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

        let crest = NSBezierPath()
        crest.move(to: NSPoint(x: 3.2, y: 16.2))
        crest.curve(to: NSPoint(x: 6.4, y: 9.4), controlPoint1: NSPoint(x: 4.7, y: 14.2), controlPoint2: NSPoint(x: 5.7, y: 11.8))
        crest.curve(to: NSPoint(x: 9, y: 8.3), controlPoint1: NSPoint(x: 7, y: 8.7), controlPoint2: NSPoint(x: 7.8, y: 8.3))
        crest.curve(to: NSPoint(x: 11.6, y: 9.4), controlPoint1: NSPoint(x: 10.2, y: 8.3), controlPoint2: NSPoint(x: 11, y: 8.7))
        crest.curve(to: NSPoint(x: 14.8, y: 16.2), controlPoint1: NSPoint(x: 12.3, y: 11.8), controlPoint2: NSPoint(x: 13.3, y: 14.2))
        crest.curve(to: NSPoint(x: 11.9, y: 15), controlPoint1: NSPoint(x: 13.6, y: 16.1), controlPoint2: NSPoint(x: 12.8, y: 15.8))
        crest.curve(to: NSPoint(x: 11.8, y: 9.2), controlPoint1: NSPoint(x: 12.5, y: 13), controlPoint2: NSPoint(x: 12.6, y: 11))
        crest.curve(to: NSPoint(x: 9, y: 13.2), controlPoint1: NSPoint(x: 10.6, y: 10.6), controlPoint2: NSPoint(x: 9.8, y: 11.9))
        crest.curve(to: NSPoint(x: 6.2, y: 9.2), controlPoint1: NSPoint(x: 8.2, y: 11.9), controlPoint2: NSPoint(x: 7.4, y: 10.6))
        crest.curve(to: NSPoint(x: 6.1, y: 15), controlPoint1: NSPoint(x: 5.4, y: 11), controlPoint2: NSPoint(x: 5.5, y: 13))
        crest.curve(to: NSPoint(x: 3.2, y: 16.2), controlPoint1: NSPoint(x: 5.2, y: 15.8), controlPoint2: NSPoint(x: 4.4, y: 16.1))
        crest.close()
        crest.fill()

        let shell = NSBezierPath()
        shell.move(to: NSPoint(x: 1.8, y: 6.1))
        shell.curve(to: NSPoint(x: 5.6, y: 9), controlPoint1: NSPoint(x: 2.8, y: 7.9), controlPoint2: NSPoint(x: 4, y: 8.7))
        shell.curve(to: NSPoint(x: 12.4, y: 9), controlPoint1: NSPoint(x: 7.3, y: 9.5), controlPoint2: NSPoint(x: 10.7, y: 9.5))
        shell.curve(to: NSPoint(x: 16.2, y: 6.1), controlPoint1: NSPoint(x: 14, y: 8.7), controlPoint2: NSPoint(x: 15.2, y: 7.9))
        shell.line(to: NSPoint(x: 16.5, y: 4.5))
        shell.line(to: NSPoint(x: 1.5, y: 4.5))
        shell.close()
        shell.fill()

        let faceGuard = NSBezierPath()
        faceGuard.move(to: NSPoint(x: 5.2, y: 3.8))
        faceGuard.line(to: NSPoint(x: 12.8, y: 3.8))
        faceGuard.line(to: NSPoint(x: 11.6, y: 1.7))
        faceGuard.curve(to: NSPoint(x: 6.4, y: 1.7), controlPoint1: NSPoint(x: 9.8, y: 1.1), controlPoint2: NSPoint(x: 8.2, y: 1.1))
        faceGuard.close()
        faceGuard.fill()

        image.unlockFocus()
        image.isTemplate = true
        return image
    }
}
