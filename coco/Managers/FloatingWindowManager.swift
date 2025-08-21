import SwiftUI
import AppKit

class FloatingWindowManager {
    static let shared = FloatingWindowManager()
    private weak var window: NSWindow?

    func setupWindow<Content: View>(rootView: Content, alwaysOnTop: Bool) {
        if let win = NSApp.windows.first {
            self.window = win
            configure(win, alwaysOnTop: alwaysOnTop)
        }
    }

    func updateLevel(alwaysOnTop: Bool) {
        window?.level = alwaysOnTop ? .floating : .normal
    }

    private func configure(_ window: NSWindow, alwaysOnTop: Bool) {
        window.setContentSize(NSSize(width: 100, height: 100))
        window.styleMask = [.borderless]
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = alwaysOnTop ? .floating : .normal
        window.hasShadow = true
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    }
}
