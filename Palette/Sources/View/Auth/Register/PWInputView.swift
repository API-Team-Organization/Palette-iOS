//
//  PWInputView.swift
//  Palette
//
//  Created by 4rNe5 on 5/16/24.
//

import SwiftUI
import FlowKit

struct PWInputView: View {
    
    @State var email: String
    @State var verifyCode: String
    @State var pw: String = ""
    @State var pwCheck: String = ""
    @Flow var flow
    
    var body: some View {
        ZStack {
            Color(.white).ignoresSafeArea()
            VStack {
                Spacer()
                HStack {
                    Text("비밀번호를 설정해주세요!")
                        .font(.custom("Pretendard-ExtraBold", size: 27))
                        .padding(.leading, 15)
                        .foregroundStyle(.black)
                    Spacer()
                }
                .padding(.bottom, 2)
                HStack {
                    Text("비밀번호를 잊어버리지 않도록 주의해주세요!")
                        .font(.custom("SUIT-Bold", size: 15))
                        .padding(.leading, 17)
                        .foregroundStyle(Color("DescText"))
                    Spacer()
                }
                .padding(.bottom, 30)
                HStack {
                    TextField("verifycode",text: $pw, prompt: Text("비밀번호").foregroundStyle(Color("DescText")))
                        .padding(.leading, 10)
                        .frame(width:363, height: 55)
                        .background(Color("TextFieldBack"))
                        .cornerRadius(15.0)
                        .foregroundStyle(.black)
                        .font(.custom("SUIT-SemiBold", size: 18))
                        .padding(.leading, 15)
                    Spacer()
                }
                .padding(.bottom, 10)
                HStack {
                    TextField("verifycode",text: $pwCheck, prompt: Text("비밀번호 확인").foregroundStyle(Color("DescText")))
                        .padding(.leading, 10)
                        .frame(width:363, height: 55)
                        .background(Color("TextFieldBack"))
                        .cornerRadius(15.0)
                        .foregroundStyle(.black)
                        .font(.custom("SUIT-SemiBold", size: 18))
                        .padding(.leading, 15)
                    Spacer()
                }
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Button(action: {
                    flow.push(LoginView())
                }) {
                    Text("다음으로")
                        .font(.custom("Pretendard-ExtraBold", size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 363, height: 55)
                        .background(Color.accentColor)
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
    PWInputView(email: "me@4rne5.dev", verifyCode: "000000")
}
