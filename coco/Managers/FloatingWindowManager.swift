import SwiftUI
import AppKit

final class FloatingWindowManager {
    static let shared = FloatingWindowManager()
    private weak var window: NSWindow?

    /// 在 SwiftUI 窗口创建后进行一次配置
    func setupWindow(alwaysOnTop: Bool) {
        DispatchQueue.main.async {
            guard let win = NSApp.windows.first else { return }
            self.window = win
            self.configure(win, alwaysOnTop: alwaysOnTop)
        }
    }

    func updateLevel(alwaysOnTop: Bool) {
        window?.level = alwaysOnTop ? .floating : .normal
    }

    private func configure(_ window: NSWindow, alwaysOnTop: Bool) {
        window.setContentSize(NSSize(width: 100, height: 100))
        window.styleMask = [.borderless]              // 无边框
        window.isOpaque = false
        window.backgroundColor = .clear               // 让圆形裁剪真正透明
        window.hasShadow = true
        window.level = alwaysOnTop ? .floating : .normal
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        // 让点击能直接作用到我们的无边框窗口
        window.ignoresMouseEvents = false
    }
}
