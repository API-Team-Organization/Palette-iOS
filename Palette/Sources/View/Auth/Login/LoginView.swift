//
//  LoginView.swift
//  Palette
//
//  Created by 4rNe5 on 5/9/24.
//

import SwiftUI

struct LoginView: View {
    var body: some View {
        ZStack {
            Color(.white).ignoresSafeArea()
            VStack {
                Spacer()
                HStack {
                    Image("PaletteLogo")
                        .resizable()
                        .frame(width: 55, height: 55)
                        .padding(.leading, 25)
                    Spacer()
                }
                .padding(.bottom, 10)
                HStack {
                    Text("\(Text("Palette").font(.custom("SUIT-ExtraBold", size: 27)))에 로그인하기")
                        .font(.custom("SUIT-ExtraBold", size: 27))
                        .padding(.leading, 15)
                    Spacer()
                }
                .padding(.bottom, 2)
                HStack {
                    Text("로그인할 이메일과 비밀번호를 입력해주세요!")
                        .font(.custom("SUIT-Bold", size: 15))
                        .padding(.leading, 15)
                        .foregroundStyle(Color("DescText"))
                    Spacer()
                }
            }
        }
    }
}
                                  

#Preview {
    LoginView()
}
