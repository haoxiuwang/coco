import SwiftUI

@main
struct FloatingAvatarApp: App {
    @StateObject private var model = AvatarModel()

    var body: some Scene {
        WindowGroup {
            AvatarView(model: model)
                .onAppear {
                    FloatingWindowManager.shared.setupWindow(rootView: AvatarView(model: model),
                                                             alwaysOnTop: model.alwaysOnTop)
                }
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}
