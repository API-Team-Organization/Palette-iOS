//
//  PWInputView.swift
//  Palette
//
//  Created by 4rNe5 on 5/16/24.
//
import SwiftUI
import FlowKit

enum AlertCase {
    case blank, different, invalid
}

struct PWInputView: View {
    
    var email: String
    @State var pw: String = ""
    @State var pwCheck: String = ""
    @State private var showAlert = false
    @State private var activeAlert: AlertCase? = nil
    @State private var isPwVisible = false
    @State private var isPwCheckVisible = false
    @Environment(\.presentationMode) var presentationMode
    
    let passwordPattern = /[a-zA-Z0-9!@#\$%\^\&\*,.<>~]{8,32}/
    
    @Flow var flow
    
    func validateFields() {
        if pw.isEmpty || pwCheck.isEmpty {
            activeAlert = .blank
            showAlert = true
        } else if !isValidPassword(pw) {
            activeAlert = .invalid
            showAlert = true
        } else if pw != pwCheck {
            activeAlert = .different
            showAlert = true
        } else {
            showAlert = false
            flow.push(BirthdayPickerView(email: email, pw: pw, pwCheck: pwCheck))
        }
    }
    
    func isValidPassword(_ password: String) -> Bool {
        return password.wholeMatch(of: passwordPattern) != nil
    }
    
    var body: some View {
        ZStack {
            Color(.white).ignoresSafeArea()
            VStack {
                HStack {
                    Text("비밀번호를 설정해주세요!")
                        .font(.custom("Pretendard-ExtraBold", size: 27))
                        .padding(.leading, 15)
                        .foregroundStyle(.black)
                    Spacer()
                }
                .padding(.bottom, 3)
                .padding(.top, 50)
                HStack {
                    Text("영문, 숫자, 특수문자로 이루어져야 하며,")
                        .font(.custom("SUIT-Bold", size: 15))
                        .padding(.leading, 17)
                        .foregroundStyle(Color("DescText"))
                    Spacer()
                }
                HStack {
                    Text("8 ~ 32자 사이여야 해요.")
                        .font(.custom("SUIT-Bold", size: 15))
                        .padding(.leading, 17)
                        .foregroundStyle(Color("DescText"))
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
                    Spacer()
                    HStack {
                        Group {
                            if isPwVisible {
                                TextField("비밀번호", text: $pw)
                                    .padding(.leading, 10)
                                    .frame(height: 55)
                                    .background(Color("TextFieldBack"))
                                    .cornerRadius(15.0)
                                    .foregroundStyle(.black)
                                    .font(.custom("SUIT-SemiBold", size: 18))
                                    .colorScheme(.light)
                            } else {
                                SecureField("비밀번호", text: $pw)
                                    .padding(.leading, 10)
                                    .frame(height: 55)
                                    .background(Color("TextFieldBack"))
                                    .cornerRadius(15.0)
                                    .foregroundStyle(.black)
                                    .font(.custom("SUIT-SemiBold", size: 18))
                                    .colorScheme(.light)
                            }
                        }
                        
                        Button(action: {
                            isPwVisible.toggle()
                        }) {
                            Image(systemName: isPwVisible ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 10)
                    }
                    .frame(width: 363)
                    .background(Color("TextFieldBack"))
                    .cornerRadius(15.0)
                    .padding(.bottom, 10)
                    Spacer()
                }
                
                HStack {
                    Spacer()
                    HStack {
                        Group {
                            if isPwCheckVisible {
                                TextField("비밀번호 확인", text: $pwCheck)
                                    .padding(.leading, 10)
                                    .frame(height: 55)
                                    .background(Color("TextFieldBack"))
                                    .cornerRadius(15.0)
                                    .foregroundStyle(.black)
                                    .font(.custom("SUIT-SemiBold", size: 18))
                                    .colorScheme(.light)
                            } else {
                                SecureField("비밀번호 확인", text: $pwCheck)
                                    .padding(.leading, 10)
                                    .frame(height: 55)
                                    .background(Color("TextFieldBack"))
                                    .cornerRadius(15.0)
                                    .foregroundStyle(.black)
                                    .font(.custom("SUIT-SemiBold", size: 18))
                                    .colorScheme(.light)
                                
                            }
                        }
                        
                        Button(action: {
                            isPwCheckVisible.toggle()
                        }) {
                            Image(systemName: isPwCheckVisible ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 10)
                    }
                    .frame(width: 363)
                    .background(Color("TextFieldBack"))
                    .cornerRadius(15.0)
                    Spacer()
                }
                
                Spacer()
                
                Button(action: {
                    validateFields()
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
                .alert(isPresented: $showAlert) {
                    switch activeAlert {
                    case .blank:
                        return Alert(title: Text("앗! 비밀번호가 비어있어요!"), message: Text("비밀번호를 입력해주세요."), dismissButton: .default(Text("확인")))
                    case .different:
                        return Alert(title: Text("앗! 비밀번호가 달라요!"), message: Text("비밀번호를 확인해주세요."), dismissButton: .default(Text("확인")))
                    case .invalid:
                        return Alert(title: Text("유효하지 않은 비밀번호 형식"), message: Text("비밀번호는 영문, 숫자, 특수문자(!@#$%^&*,.<>~)로 이루어져야 하며, 8 ~ 32자 사이여야 해요."), dismissButton: .default(Text("확인")))
                    case .none:
                        return Alert(title: Text("오류"), message: Text("알 수 없는 오류가 발생했습니다."), dismissButton: .default(Text("확인")))
                    }
                }
            }
        }
        .onTapGesture {
            self.endTextEditing()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())
    }
}

#Preview {
    PWInputView(email: "me@4rne5.dev")
}
