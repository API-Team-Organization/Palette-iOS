//
//  EmailInputView.swift
//  Palette
//
//  Created by 4rNe5 on 5/9/24.
//

import SwiftUI
import FlowKit

struct EmailInputView: View {
    
    @State var email: String = ""
    @State private var showingBlankAlert = false
    @State private var showingInvalidEmailAlert = false
    @Environment(\.presentationMode) var presentationMode
    @Flow var flow
    
    var emailPattern = /^[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*.[a-zA-Z]{2,3}$/
    
    private func isValidEmail(_ email: String) -> Bool {
        return email.wholeMatch(of: emailPattern) != nil
    }

    var body: some View {
        ZStack {
            Color(.white).ignoresSafeArea()
            VStack {
                HStack {
                    Text("이메일 주소를 알려주세요!")
                        .font(.custom("Pretendard-ExtraBold", size: 27))
                        .padding(.leading, 15)
                        .foregroundStyle(.black)
                    Spacer()
                }
                .padding(.bottom, 2)
                .padding(.top, 50)
                HStack {
                    Text(verbatim: "이메일은 example@domain.com 의 형식이어야 해요.")
                        .autocapitalization(.none)
                        .environment(\.textCase, nil)
                        .font(.custom("SUIT-Bold", size: 15))
                        .padding(.leading, 17)
                        .foregroundStyle(Color("DescText"))
                    Spacer()
                }
                .padding(.bottom, 30)
                HStack {
                    TextField("email",text: $email, prompt: Text("이메일").foregroundStyle(Color("DescText")))
                        .textInputAutocapitalization(.never)
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
                    if email.isEmpty {
                        self.showingBlankAlert = true
                    } else if !isValidEmail(email) {
                        self.showingInvalidEmailAlert = true
                    } else {
                        flow.push(PWInputView(email: email))
                    }
                }) {
                    Text("다음으로")
                        .font(.custom("Pretendard-ExtraBold", size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 363, height: 55)
                        .background(Color("AccentColor"))
                        .cornerRadius(12)
                        .padding(.bottom, 30)
                }
            }
            .alert("이메일이 비어있어요!", isPresented: $showingBlankAlert) {
                Button("확인", role: .cancel) { }
            } message: {
                Text("이메일을 입력해주세요.")
            }
            .alert("유효하지 않은 이메일 형식", isPresented: $showingInvalidEmailAlert) {
                Button("확인", role: .cancel) { }
            } message: {
                Text("이메일은 example@domain.com 형식으로 이루어져야 합니다. 영문, 숫자, 일부 특수문자(.-_)만 사용 가능합니다.")
            }
            .onTapGesture {
                self.endTextEditing()
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: BackButton())
        }
    }
}

#Preview {
    EmailInputView()
}
