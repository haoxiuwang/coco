import SwiftUI
import AppKit

final class AvatarModel: ObservableObject {
    @Published var avatars: [NSImage?] = Array(repeating: nil, count: 4)

    @Published var currentIndex: Int = UserDefaults.standard.integer(forKey: "floating.currentIndex") {
        didSet { UserDefaults.standard.set(currentIndex, forKey: "floating.currentIndex") }
    }

    @Published var alwaysOnTop: Bool = UserDefaults.standard.bool(forKey: "floating.alwaysOnTop") {
        didSet {
            UserDefaults.standard.set(alwaysOnTop, forKey: "floating.alwaysOnTop")
            FloatingWindowManager.shared.updateLevel(alwaysOnTop: alwaysOnTop)
        }
    }

    private let avatarDir: URL
    private let fm = FileManager.default

    init() {
        // ~/Library/Application Support/FloatingAvatar/avatars
        let appSupport = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appFolder = appSupport.appendingPathComponent("FloatingAvatar", isDirectory: true)
        if !fm.fileExists(atPath: appFolder.path) {
            try? fm.createDirectory(at: appFolder, withIntermediateDirectories: true)
        }
        avatarDir = appFolder.appendingPathComponent("avatars", isDirectory: true)
        if !fm.fileExists(atPath: avatarDir.path) {
            try? fm.createDirectory(at: avatarDir, withIntermediateDirectories: true)
        }

        // 启动时从沙盒加载 4 张头像
        for i in 0..<5 {
            let url = avatarURL(index: i)
            if fm.fileExists(atPath: url.path),
               let img = NSImage(contentsOf: url) {
                avatars[i] = img
            }
        }
    }

    func setAvatar(index: Int, image: NSImage) {
        let target = avatarURL(index: index)
        savePNG(image: image, to: target)
        avatars[index] = image
        if index == currentIndex { objectWillChange.send() }
    }

    var currentImage: NSImage {
        avatars[currentIndex] ?? placeholder(index: currentIndex)
    }

    // MARK: - Helpers

    private func avatarURL(index: Int) -> URL {
        avatarDir.appendingPathComponent("avatar\(index).png")
    }

    private func savePNG(image: NSImage, to url: URL) {
        guard
            let tiff = image.tiffRepresentation,
            let rep = NSBitmapImageRep(data: tiff),
            let data = rep.representation(using: .png, properties: [:])
        else { return }
        try? data.write(to: url, options: .atomic)
    }

    private func placeholder(index: Int) -> NSImage {
        let size = NSSize(width: 100, height: 100)
        let img = NSImage(size: size)
        img.lockFocus()
        NSColor.systemGray.setFill()
        NSBezierPath(ovalIn: NSRect(origin: .zero, size: size)).fill()
        let text = "\(index+1)" as NSString
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.boldSystemFont(ofSize: 32),
            .foregroundColor: NSColor.white
        ]
        let rect = NSRect(x: 0, y: 25, width: 100, height: 50)
        text.draw(in: rect, withAttributes: attrs)
        img.unlockFocus()
        return img
    }
}
