//
//  PWInputView.swift
//  Palette
//
//  Created by 4rNe5 on 5/16/24.
//

import SwiftUI
import FlowKit

enum alertcase {
    case blank, different
}

struct PWInputView: View {
    
    var email: String
    var verifyCode: String
    @State var pw: String = ""
    @State var pwCheck: String = ""
    @State private var showAlert = false
    @State private var activeAlert: alertcase? = nil
    @Flow var flow
    
    func validateFields() {
        if pw == "" || pwCheck == "" {
            activeAlert = .blank
            showAlert = true
        } else if pw != pwCheck {
            activeAlert = .different
            showAlert = true
        } else {
            showAlert = false
            flow.push(BirthdayPickerView(email: email, verifyCode: verifyCode, pw: pw, pwCheck: pwCheck))
        }
    }
    
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
                    SecureField("verifycode",text: $pw, prompt: Text("비밀번호").foregroundStyle(Color("DescText")))
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
                    SecureField("verifycode",text: $pwCheck, prompt: Text("비밀번호 확인").foregroundStyle(Color("DescText")))
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
                    validateFields()
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
                .alert(isPresented: $showAlert) {
                        switch activeAlert {
                            case .blank:
                                return Alert(title: Text("앗! 비밀번호가 비어있어요!!"), message: Text("비밀번호를 입력해주세요."), dismissButton: .default(Text("확인")))
                            case .different:
                                return Alert(title: Text("앗! 비밀번호가 달라요!!"), message: Text("비밀번호를 확인해주세요."), dismissButton: .default(Text("확인")))
                            case .none:
                                return Alert(title: Text("오류"), message: Text("알 수 없는 오류가 발생했습니다."), dismissButton: .default(Text("확인")))
                        }
                    }
                }
            }
        .onTapGesture {
            self.endTextEditing()
        }
    }
}



#Preview {
    PWInputView(email: "me@4rne5.dev", verifyCode: "000000")
}
