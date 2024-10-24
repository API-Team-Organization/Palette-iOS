import SwiftUI
import RiveRuntime
import FlowKit

struct MainView: View {
    @State private var selectedTab: Tab = .home
    @StateObject private var tabbar: RiveTabbarVM
    @State private var isFullScreenImagePresented = false
    
    init() {
        _tabbar = StateObject(wrappedValue: RiveTabbarVM(selectedTab: .home))
    }
    
    var body: some View {
        ZStack {
            Color(Color("BackgroundColor")).ignoresSafeArea()
            
            switch selectedTab {
            case .search:
                MyWorkGalleryView(isFullScreenPresented: $isFullScreenImagePresented)
            case .home:
                ChatListView()
            case .setting:
                SettingView()
            }
            
            VStack {
                ForEach(0..<83) { _ in
                    Spacer()
                }
                if !isFullScreenImagePresented {
                    tabbar.view()
                }
            }
            .onChange(of: tabbar.selectedTab) { old, newValue in
                selectedTab = newValue
            }
        }
        .onAppear {
            tabbar.selectedTab = selectedTab
        }
    }
}

#Preview {
    MainView()
}
