//
//  VerifyCodeInputView.swift
//  Palette
//
//  Created by 4rNe5 on 5/16/24.
//

import SwiftUI
import FlowKit

struct VerifyCodeInputView: View {
    
    @State var email: String
    @State var verifyCode: String = ""
    @State private var showingBlankAlert = false
    @Flow var flow
    
    var body: some View {
        ZStack {
            Color(.white).ignoresSafeArea()
            VStack {
                Spacer()
                HStack {
                    Text("인증번호를 보내드렸어요!")
                        .font(.custom("Pretendard-ExtraBold", size: 27))
                        .padding(.leading, 15)
                        .foregroundStyle(.black)
                    Spacer()
                }
                .padding(.bottom, 2)
                HStack {
                    Text("이메일로 전송된 인증번호를 입력해주세요!")
                        .font(.custom("SUIT-Bold", size: 15))
                        .padding(.leading, 17)
                        .foregroundStyle(Color("DescText"))
                    Spacer()
                }
                .padding(.bottom, 30)
                HStack {
                    Text(email)
                        .padding(.leading, 10)
                        .frame(width:363, height: 55, alignment: .leading)
                        .background(Color("TextFieldBack"))
                        .cornerRadius(15.0)
                        .foregroundStyle(.black)
                        .font(.custom("SUIT-SemiBold", size: 18))
                        .padding(.leading, 15)
                    Spacer()
                }
                .padding(.bottom, 10)
                HStack {
                    TextField("verifycode",text: $verifyCode, prompt: Text("인증번호").foregroundStyle(Color("DescText")))
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
                    if verifyCode == "" {
                        self.showingBlankAlert = true
                    } else {
                        flow.push(PWInputView(email: email, verifyCode: verifyCode))
                    }
                }) {
                    Text("인증하기")
                        .font(.custom("Pretendard-ExtraBold", size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 363, height: 55)
                        .background(Color.accentColor)
                        .cornerRadius(12)
                        .padding(.bottom, 30)
                }
            }
            .alert(isPresented: $showingBlankAlert) {
                Alert(title: Text("앗! 인증코드가 비어있어요!!"), message: Text("인증코드를 입력해주세요."), dismissButton: .default(Text("확인")))
                }
            }
            .onTapGesture {
                self.endTextEditing()
            }
        }
    }

#Preview {
    VerifyCodeInputView(email: "me@4rne5.dev")
}
