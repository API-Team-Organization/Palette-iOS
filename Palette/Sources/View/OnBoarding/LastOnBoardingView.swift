//
//  LastOnBoardingView.swift
//  Palette
//
//  Created by 4rNe5 on 5/7/24.
//

import SwiftUI
import RiveRuntime

struct LastOnBoardingView: View {
    @Binding var isFirstLaunching: Bool
    
    let rivename: String
    let riveboardname: String
    let Title: String
    let DescFirst: String
    let DescSecond: String
    
    var body: some View {
        ZStack {
            Color(.white).ignoresSafeArea()
            VStack {
                RiveViewRepresentable(viewModel: RiveViewModel(fileName: rivename, artboardName: riveboardname))
                    .padding(.bottom, -40)
                Text(Title)
                    .font(.custom("Pretendard-Bold", size: 27))
                    .foregroundStyle(Color.black)
                    .fontWeight(.bold)
                    .padding(.bottom, 3)
                Text(DescFirst)
                    .font(.custom("Pretendard-Light", size: 19))
                    .foregroundStyle(Color.black)
                    .frame(alignment: .center)
                Text(DescSecond)
                    .font(.custom("Pretendard-Light", size: 19))
                    .foregroundStyle(Color.black)
                    .frame(alignment: .center)
                    .padding(.bottom, 65)
                
                Button {
                   isFirstLaunching.toggle()
                } label: {
                    
                  Text("시작하기")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 330, height: 50)
                    .background(Color.accentColor)
                    .cornerRadius(12)
                    
                }
                .padding(.bottom, 100)
            }
        }
    }
}
