//
//  MainView.swift
//  Palette
//
//  Created by 4rNe5 on 6/27/24.
//

import SwiftUI
import RiveRuntime

struct MainView: View {
    @State private var selectedTab: Tab = .home
    @StateObject private var tabbar: RiveTabbarVM
    
    init() {
        _tabbar = StateObject(wrappedValue: RiveTabbarVM(selectedTab: .home))
    }
    
    var body: some View {
        ZStack {
            Color(.white).ignoresSafeArea()
            
            switch selectedTab {
            case .search:
                Text("search").foregroundStyle(.black)
            case .home:
                ChatListView()
            case .setting:
                Text("The setting Tab").foregroundStyle(.black)
            }
            
            VStack {
                ForEach(0..<85) { _ in
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
