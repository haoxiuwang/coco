import SwiftUI
import AppKit

/// 覆盖在头像上的透明 NSView，用来处理鼠标拖动移动 NSWindow
struct DragCaptureView: NSViewRepresentable {
    func makeNSView(context: Context) -> DragNSView {
        let v = DragNSView(frame: .zero)
        return v
    }
    func updateNSView(_ nsView: DragNSView, context: Context) {}
}

final class DragNSView: NSView {
    private var dragStartLocationInWindow: NSPoint?
    private var initialWindowOrigin: NSPoint?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }

    override var acceptsFirstResponder: Bool { true }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
    override func hitTest(_ point: NSPoint) -> NSView? { self } // 捕获事件

    override func mouseDown(with event: NSEvent) {
        guard let window = self.window else { return }
        dragStartLocationInWindow = event.locationInWindow
        initialWindowOrigin = window.frame.origin
    }

    override func mouseDragged(with event: NSEvent) {
        guard let window = self.window,
              let start = dragStartLocationInWindow,
              let origin = initialWindowOrigin else { return }
        let current = event.locationInWindow
        let dx = current.x - start.x
        let dy = current.y - start.y
        let newOrigin = NSPoint(x: origin.x + dx, y: origin.y + dy)
        window.setFrameOrigin(newOrigin)
    }
}
