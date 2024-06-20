//
//  TestView.swift
//  Palette
//
//  Created by 4rNe5 on 6/20/24.
//

import SwiftUI
import RiveRuntime

struct TestView: View {
    
    @State var selectedTab: Tab = .home
    @StateObject private var tabbar: RiveTabbarVM

    init() {
        let selectedTabBinding = Binding(get: { Tab.search }, set: { _ in })
        _tabbar = StateObject(wrappedValue: RiveTabbarVM(selectedTab: selectedTabBinding))
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
            switch selectedTab {
                case .search:
                    Text("search")
                case .home:
                    Text("The home Tab")
                case .setting:
                    Text("The setting Tab")
            }
        }
        .onAppear {
            tabbar.selectedTab = $selectedTab.wrappedValue
        }
    }
}

#Preview {
    TestView()
}
