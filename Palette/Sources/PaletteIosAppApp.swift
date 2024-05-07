import SwiftUI
import FlowKit

@main
struct PaletteIosAppApp: App {
    var body: some Scene {
        WindowGroup {
            FlowPresenter(rootView: StartView())
                .ignoresSafeArea()
        }
    }
}
