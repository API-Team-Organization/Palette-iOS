//
//  RegisterFinView.swift
//  Palette
//
//  Created by 4rNe5 on 5/30/24.
//

import SwiftUI

struct RegisterFinView: View {
    var body: some View {
        ZStack {
            Color(.white).ignoresSafeArea()
            VStack {
                Spacer()
                HStack {
                    Text("(>_<)b")
                        .font(.custom("SUIT-ExtraBold", size: 55))
                        .foregroundStyle(.black)
                        .padding(.bottom, 30)
                }
                HStack {
                    Text("좋아요!")
                        .font(.custom("SUIT-ExtraBold", size: 27))
                        .foregroundStyle(Color("AccentColor"))
                        .padding(.bottom, 5)
                }
                HStack {
                    Text("이제 \(Text("Palette").font(.custom("SUIT-Bold", size: 19)))를 이용하실 수 있어요.")
                        .font(.custom("Pretendard-Medium", size: 19))
                        .foregroundStyle(.black)
                        .padding(.bottom, 5)
                }
                Spacer()
                Button(action: {
                   
                }) {
                    Text("완료하기")
                        .font(.custom("Pretendard-ExtraBold", size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 363, height: 55)
                        .background(Color("AccentColor"))
                        .cornerRadius(12)
                        .padding(.bottom, 30)
                }
            }
            .onTapGesture {
                self.endTextEditing()
            }
        }
    }
}

#Preview {
    RegisterFinView()
}
