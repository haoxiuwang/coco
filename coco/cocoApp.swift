import SwiftUI

@main
struct FloatingAvatarApp: App {
    @StateObject private var model = AvatarModel()

    var body: some Scene {
        WindowGroup {
            AvatarView(model: model)
                .onAppear {
                    // 配置窗口（无边框、透明、置顶等）
                    FloatingWindowManager.shared.setupWindow(alwaysOnTop: model.alwaysOnTop)
                }
        }
        .windowStyle(HiddenTitleBarWindowStyle()) // 去标题栏
    }
}
