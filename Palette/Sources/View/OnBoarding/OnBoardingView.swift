
//
//  OnBoardingView.swift
//  Palette
//
//  Created by 4rNe5 on 5/7/24.
//

import SwiftUI
import RiveRuntime

struct OnBoardingView: View {
    
    let rivename: String
    let riveboardname: String
    let Title: String
    let DescFirst: String
    let DescSecond: String
    
    var body: some View {
        ZStack {
            Color(.white).ignoresSafeArea()
            VStack {
                Spacer()
                RiveViewRepresentable(viewModel: RiveViewModel(fileName: rivename, artboardName: riveboardname))
                    .padding(.bottom, -22)
                Text(Title)
                    .font(.custom("Pretendard-Bold", size: 27))
                    .padding(.bottom, 3)
                    .foregroundStyle(Color.black)
                Text(DescFirst)
                    .font(.custom("SUIT-Light", size: 19))
                    .frame(alignment: .center)
                    .foregroundStyle(Color.black)
                Text(DescSecond)
                    .font(.custom("SUIT-Light", size: 19))
                    .frame(alignment: .center)
                    .padding(.bottom, 170)
                    .foregroundStyle(Color.black)
            }
            .padding(.bottom, 54)
        }
    }
    
}

#Preview {
    OnBoardingView(rivename: "load", riveboardname: "Simple_loader", Title:"\"어케 만들었냐?\"" , DescFirst: "나만의 홍보물,", DescSecond: "AI를 활용해 쉽게 만들어보세요!")
}
