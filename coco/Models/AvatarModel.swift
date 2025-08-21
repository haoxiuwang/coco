import SwiftUI
import AppKit

class AvatarModel: ObservableObject {
    @Published var avatars: [NSImage?] = Array(repeating: nil, count: 4)
    @Published var currentIndex: Int = UserDefaults.standard.integer(forKey: "floating.currentIndex") {
        didSet {
            UserDefaults.standard.set(currentIndex, forKey: "floating.currentIndex")
        }
    }
    @Published var alwaysOnTop: Bool = UserDefaults.standard.bool(forKey: "floating.alwaysOnTop") {
        didSet {
            UserDefaults.standard.set(alwaysOnTop, forKey: "floating.alwaysOnTop")
            FloatingWindowManager.shared.updateLevel(alwaysOnTop: alwaysOnTop)
        }
    }

    private let avatarDir: URL

    init() {
        // 创建 Application Support/FloatingAvatar/avatars
        let fm = FileManager.default
        let appSupport = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appFolder = appSupport.appendingPathComponent("FloatingAvatar", isDirectory: true)
        if !fm.fileExists(atPath: appFolder.path) {
            try? fm.createDirectory(at: appFolder, withIntermediateDirectories: true)
        }
        avatarDir = appFolder.appendingPathComponent("avatars", isDirectory: true)
        if !fm.fileExists(atPath: avatarDir.path) {
            try? fm.createDirectory(at: avatarDir, withIntermediateDirectories: true)
        }

        // 加载本地存储头像
        for i in 0..<4 {
            let fileURL = avatarDir.appendingPathComponent("avatar\(i).png")
            if fm.fileExists(atPath: fileURL.path), let img = NSImage(contentsOf: fileURL) {
                avatars[i] = img
            }
        }
    }

    func setAvatar(index: Int, image: NSImage, originalPath: String) {
        let targetURL = avatarDir.appendingPathComponent("avatar\(index).png")
        saveImage(image: image, url: targetURL)
        avatars[index] = image
    }

    var currentImage: NSImage {
        avatars[currentIndex] ?? placeholder(index: currentIndex)
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

    private func saveImage(image: NSImage, url: URL) {
        guard let tiff = image.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff),
              let data = rep.representation(using: .png, properties: [:]) else { return }
        try? data.write(to: url)
    }
}
