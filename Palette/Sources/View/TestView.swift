import SwiftUI
import RiveRuntime

struct TestView: View {
    @State private var selectedTab: Tab = .home
    @StateObject private var tabbar: RiveTabbarVM
    
    init() {
        _tabbar = StateObject(wrappedValue: RiveTabbarVM(selectedTab: .home))
    }
    
    var body: some View {
        ZStack {
            Color(.white).ignoresSafeArea()
            VStack {
                ForEach(0..<81) { _ in
                    Spacer()
                }
                tabbar.view()
            }
            .onChange(of: tabbar.selectedTab) { newValue in
                selectedTab = newValue
            }
            
            switch selectedTab {
            case .search:
                Text("search").foregroundStyle(.black)
            case .home:
                Text("The home Tab").foregroundStyle(.black)
            case .setting:
                Text("The setting Tab").foregroundStyle(.black)
            }
        }
        .onAppear {
            tabbar.selectedTab = selectedTab
        }
    }
}
