//
//  NameInputView.swift
//  Palette
//
//  Created by 4rNe5 on 5/23/24.
//

import SwiftUI
import FlowKit
import Alamofire

struct NameInputView: View {
    
    let serverurl = "http://standard.alcl.cloud:24136/auth/register"
    
    var email: String
    var verifyCode: String
    var pw: String
    var pwCheck: String
    var birthday: String
    @State var userName: String = ""
    @Flow var flow
    let input_alert = Alert(title: "앗! 이름이 비어있어요!",
                      message: "이름을 입력해주세요.",
                      dismissButton: .default("확인"))
    
    var body: some View {
        ZStack {
            Color(.white).ignoresSafeArea()
            VStack {
                Spacer()
                HStack {
                    Text("이름을 입력해주세요!")
                        .font(.custom("Pretendard-ExtraBold", size: 27))
                        .padding(.leading, 15)
                        .foregroundStyle(.black)
                    Spacer()
                }
                .padding(.bottom, 2)
                HStack {
                    Text("거의 다 왔습니다…")
                        .font(.custom("SUIT-Bold", size: 15))
                        .padding(.leading, 17)
                        .foregroundStyle(Color("DescText"))
                    Spacer()
                }
                .padding(.bottom, 30)
                HStack {
                    TextField("email", text: $userName, prompt: Text("이름").foregroundStyle(Color("DescText")))
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
    NameInputView(email: "23wdwad@gmail.com", verifyCode: "010101", pw: "23wdwad", pwCheck: "23wdwad", birthday: "2007-04-28")
}

