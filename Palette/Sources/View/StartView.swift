//
//  StartView.swift
//  Palette
//
//  Created by 4rNe5 on 5/7/24.
//

import SwiftUI

struct StartView: View {
    
    // 최초실행 저장 변수 | Boolean
    @AppStorage("_isFirstLaunching") var isFirstLaunching: Bool = true
    
    var body: some View {
        ZStack{
            Color(.white).ignoresSafeArea()
            Text("StartView!")
                .foregroundStyle(Color.black)
                .fullScreenCover(isPresented: $isFirstLaunching) {
                    OnBoardingTabView(isFirstLaunching: $isFirstLaunching)
            }
        }
    }
}

#Preview {
    StartView()
}
