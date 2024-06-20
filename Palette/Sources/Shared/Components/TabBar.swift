import SwiftUI
import RiveRuntime

enum Tab {
    case search
    case home
    case setting
}

class RiveTabbarVM: RiveViewModel {

    @Binding var selectedTab: Tab

    init(selectedTab: Binding<Tab>) {
        self._selectedTab = selectedTab
        super.init(fileName: "api_bottom_bar")
    }
    
    func view() -> some View {
        return super.view()
    }

    // Subscribe to Rive events and this delegate will be invoked
    @objc func onRiveEventReceived(onRiveEvent riveEvent: RiveEvent) {
        debugPrint("Event Name: \(riveEvent.name())")
        if riveEvent.name() == "click_search" {
            selectedTab = .search
            debugPrint("search Clicked")
        } else if riveEvent.name() == "click_home" {
            selectedTab = .home
            debugPrint("home Clicked")
        } else if riveEvent.name() == "click_setting" {
            selectedTab = .setting
            debugPrint("setting Clicked")
        }
    }
}
