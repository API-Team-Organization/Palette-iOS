//
//  StartView.swift
//  Palette
//
//  Created by 4rNe5 on 5/7/24.
//

import SwiftUI

struct StartView: View {
    
    // 사용자 안내 온보딩 페이지를 앱 설치 후 최초 실행할 때만 띄우도록 하는 변수.
    // @AppStorage에 저장되어 앱 종료 후에도 유지됨.
    @AppStorage("_isFirstLaunching") var isFirstLaunching: Bool = true
    
    var body: some View {
        Text("StartView!")
    }
}

#Preview {
    StartView()
}
