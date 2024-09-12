//
//  MainView.swift
//  Palette
//
//  Created by 4rNe5 on 6/27/24.
//

import SwiftUI
import RiveRuntime
import FlowKit

struct MainView: View {
    @State private var selectedTab: Tab = .home
    @StateObject private var tabbar: RiveTabbarVM
    
    init() {
        _tabbar = StateObject(wrappedValue: RiveTabbarVM(selectedTab: .home))
    }
    
    var body: some View {
        ZStack {
            Color(Color("BackgroundColor")).ignoresSafeArea()
            
            switch selectedTab {
            case .search:
                MyWorkGalleryView()
            case .home:
                ChatListView()
            case .setting:
                SettingView()
            }
            
            VStack {
                ForEach(0..<86) { _ in
                    Spacer()
                }
                tabbar.view()
            }
            .onChange(of: tabbar.selectedTab) { newValue in
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
