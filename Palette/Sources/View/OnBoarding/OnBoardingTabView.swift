//
//  OnBoardingTabView.swift
//  Palette
//
//  Created by 4rNe5 on 5/7/24.
//

import SwiftUI

struct OnBoardingTabView: View {
    @Binding var isFirstLaunching: Bool
    
    var body: some View {
        TabView {
            // 페이지 1
            OnBoardingView(rivename: "message_icon_new", riveboardname: "Artboard", Title:"믿을 수 없이 간편한." , DescFirst: "나만의 홍보물,", DescSecond: "AI를 활용해 쉽게 만들어보세요.")
            
            // 페이지 2
            OnBoardingView(rivename: "document_icon_new", riveboardname: "New Artboard", Title:"다재다능, 적재적소." , DescFirst: "다양한 스타일의 홍보물,", DescSecond: "Palette는 모두 소화 가능합니다.")
            
            // 페이지 3 | 온보딩 완료
            LastOnBoardingView(isFirstLaunching: $isFirstLaunching, rivename: "social_media_machine", riveboardname: "feed the social media machine", Title:"이 모든게, 무료." , DescFirst: "비싼 툴과 외주비 지출,", DescSecond: "이제는 Palette와 무료로 제작하세요.")
        }
        .tabViewStyle(PageTabViewStyle())
        .ignoresSafeArea(.all)
        .backgroundStyle(Color.white)
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    }
}

