import SwiftUI
import AppKit

struct AvatarView: View {
    @ObservedObject var model: AvatarModel

    var body: some View {
        ZStack {
            Image(nsImage: model.currentImage)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .shadow(radius: 10)

            // 捕获拖动（把鼠标拖动事件交给 NSWindow 移动）
            DragCaptureView()
                .frame(width: 100, height: 100)
                .allowsHitTesting(true)
                .contentShape(Circle())
                .onTapGesture {
                    model.currentIndex = (model.currentIndex + 1) % 4
                }
        }
        .frame(width: 100, height: 100)
        .contextMenu {
            Section("显示头像") {
                ForEach(0..<4, id: \.self) { i in
                    Button(model.currentIndex == i ? "头像 \(i+1) ✓" : "头像 \(i+1)") {
                        model.currentIndex = i
                    }
                }
            }
            Divider()
            ForEach(0..<4, id: \.self) { i in
                Button("设置头像 \(i+1)…") {
                    pickImage { url, image in
                        if let url, let image {
                            model.setAvatar(index: i, image: image)
                        }
                    }
                }
            }
            Divider()
            Button(model.alwaysOnTop ? "取消置顶" : "始终置顶") {
                model.alwaysOnTop.toggle()
            }
            Divider()
            Button("退出") { NSApp.terminate(nil) }
        }
    }

    private func pickImage(completion: @escaping (URL?, NSImage?) -> Void) {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.png, .jpeg, .tiff, .bmp, .gif, .heic]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.begin { resp in
            if resp == .OK, let url = panel.url, let img = NSImage(contentsOf: url) {
                completion(url, img)
            }
        }
    }
}
