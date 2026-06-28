#!/usr/bin/env swift

import AppKit
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let sourceURL = root.appendingPathComponent("Resources/AppIconSource.png")
let iconsetURL = root.appendingPathComponent("Resources/WakeSamurai.iconset", isDirectory: true)
let icnsURL = root.appendingPathComponent("Resources/WakeSamurai.icns")

guard let sourceImage = NSImage(contentsOf: sourceURL) else {
    fatalError("Missing icon source at \(sourceURL.path)")
}

try? FileManager.default.removeItem(at: iconsetURL)
try FileManager.default.createDirectory(at: iconsetURL, withIntermediateDirectories: true)

struct IconImage {
    let filename: String
    let pixels: Int
}

let images = [
    IconImage(filename: "icon_16x16.png", pixels: 16),
    IconImage(filename: "icon_16x16@2x.png", pixels: 32),
    IconImage(filename: "icon_32x32.png", pixels: 32),
    IconImage(filename: "icon_32x32@2x.png", pixels: 64),
    IconImage(filename: "icon_128x128.png", pixels: 128),
    IconImage(filename: "icon_128x128@2x.png", pixels: 256),
    IconImage(filename: "icon_256x256.png", pixels: 256),
    IconImage(filename: "icon_256x256@2x.png", pixels: 512),
    IconImage(filename: "icon_512x512.png", pixels: 512),
    IconImage(filename: "icon_512x512@2x.png", pixels: 1024)
]

for image in images {
    let size = NSSize(width: image.pixels, height: image.pixels)
    let rendered = NSImage(size: size)

    rendered.lockFocus()
    NSGraphicsContext.current?.imageInterpolation = .high
    sourceImage.draw(in: NSRect(origin: .zero, size: size), from: .zero, operation: .copy, fraction: 1)
    rendered.unlockFocus()

    guard
        let tiff = rendered.tiffRepresentation,
        let bitmap = NSBitmapImageRep(data: tiff),
        let png = bitmap.representation(using: .png, properties: [:])
    else {
        fatalError("Could not render \(image.filename)")
    }

    try png.write(to: iconsetURL.appendingPathComponent(image.filename))
}

let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
process.arguments = ["-c", "icns", iconsetURL.path, "-o", icnsURL.path]
try process.run()
process.waitUntilExit()

guard process.terminationStatus == 0 else {
    fatalError("iconutil failed")
}

print("Created \(icnsURL.path)")
