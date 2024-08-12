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
            Color(.white).ignoresSafeArea()
            
            switch selectedTab {
            case .search:
                Text("준비중이에요!").foregroundStyle(.black)
            case .home:
                ChatListView()
            case .setting:
                Text("준비중이에요!").foregroundStyle(.black)
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
