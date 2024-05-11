//
//  StartView.swift
//  Palette
//
//  Created by 4rNe5 on 5/7/24.
//

import SwiftUI
import FlowKit

struct StartView: View {
    
    // 최초실행 저장 변수 | Boolean
    @AppStorage("_isFirstLaunching") var isFirstLaunching: Bool = true
    @Flow var flow
    
    var body: some View {
        ZStack{
            Color(.white).ignoresSafeArea()
            VStack {
                Spacer()
                Image("PaletteLogo")
                Text("\(Text("AI").font(.custom("SUIT-ExtraBold", size: 25)))로 그리다, \(Text("Palette").font(.custom("SUIT-ExtraBold", size: 25)))")
                    .font(.custom("Pretendard-ExtraBold", size: 25))
                    .foregroundStyle(Color.black)
                    .padding(.top, 15)
                    .padding(.bottom, 13)
                
                Text("나만의 홍보물,")
                    .foregroundStyle(Color.black)
                Text("\(Text("AI").font(.custom("SUIT-Medium", size: 17)))를 활용해 쉽게 만들어보세요! ")
                    .foregroundStyle(Color.black)
                Spacer()
                Button {
                    flow.push(EmailInputView())
                } label: {
                    Text("회원가입")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 330, height: 50)
                        .background(Color.accentColor)
                        .cornerRadius(12)
                    
                }
                .padding(.bottom, 15)
                HStack(spacing: 4) {
                    Text("이미 계정이 있으신가요?")
                        .font(.custom("Pretendard-Medium", size: 14))
                        .foregroundStyle(.black)

                    Button(action: {
                        /*flow.replace([StartView()])*/
                        flow.push(LoginView())
                    }) {
                        Text("로그인")
                            .font(.custom("Pretendard-ExtraBold", size: 14))
                            .foregroundStyle(Color.accentColor)
                    }
                }
                .padding(.bottom, 36)
                
            }
            .fullScreenCover(isPresented: $isFirstLaunching) {
                OnBoardingTabView(isFirstLaunching: $isFirstLaunching)
            }
        }
    }
}

#Preview {
    StartView()
}
