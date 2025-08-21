import SwiftUI
import AppKit

struct AvatarView: View {
    @ObservedObject var model: AvatarModel

    var body: some View {
        Image(nsImage: model.currentImage)
            .resizable()
            .scaledToFill()
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .onTapGesture {
                // 左键单击切换头像
                model.currentIndex = (model.currentIndex + 1) % 4
            }
            .contextMenu {
                Section("显示头像") {
                    ForEach(0..<4) { i in
                        Button(model.currentIndex == i ? "头像 \(i+1) ✓" : "头像 \(i+1)") {
                            model.currentIndex = i
                        }
                    }
                }
                Divider()
                ForEach(0..<4) { i in
                    Button("设置头像 \(i+1)…") {
                        pickImage { url, image in
                            if let url = url, let image = image {
                                model.setAvatar(index: i, image: image, originalPath: url.path)
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
