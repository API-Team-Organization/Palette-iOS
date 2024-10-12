//
//  LoginView.swift
//  Palette
//
//  Created by 4rNe5 on 5/9/24.
//

import SwiftUI
import FlowKit

extension View {
    func endTextEditing() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct LoginView: View {
    
    @State var email: String = ""
    @State var password: String = ""
    @State private var isLoginWorking = false
    @State private var showingfailAlert = false
    @State private var showinginputAlert = false
    @Environment(\.presentationMode) var presentationMode
    @Flow var flow
    
    let fail_alert = Alert(title: "로그인 실패",
                      message: "로그인에 실패했습니다.",
                      dismissButton: .default("확인"))
    let input_alert = Alert(title: "입력정보 오류",
                      message: "비밀번호나 아이디를 확인해주세요.",
                      dismissButton: .default("확인"))
    
    
    func handleLogin() async {
        
        let post = await PaletteNetworking.post("/auth/login", parameters: LoginRequestModel(email: email, password: password), res: EmptyResModel.self)
        
        if let tokenData = KeychainManager.load(key: "accessToken"), let _ = String(data: tokenData, encoding: .utf8) {
            await MainActor.run {
                flow.replace([MainView()]) // accessToken exists check
            }
            return
        }
    
        await MainActor.run {
            failHandler();
        }
    }
    
    @MainActor
    func failHandler() {
        isLoginWorking = false
        flow.alert(fail_alert)
    }
    
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
                        .foregroundStyle(.black)
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
                .padding(.bottom, 30)
                HStack {
                    TextField("email",text: $email, prompt: Text("이메일").foregroundStyle(Color("DescText")))
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
                    SecureField("pw",text: $password, prompt: Text("비밀번호").foregroundStyle(Color("DescText")))
                        .padding(.leading, 10)
                        .frame(width:363, height: 55)
                        .background(Color("TextFieldBack"))
                        .cornerRadius(15.0)
                        .foregroundStyle(.black)
                        .font(.custom("SUIT-SemiBold", size: 18))
                        .padding(.leading, 15)
                    Spacer()
                }
                .padding(.bottom, 290)
                Button(action: {
                    if email == "" || password == "" {
                        flow.alert(input_alert)
                        
                    } else {
                        isLoginWorking = true
                        Task { await handleLogin() }
                    }
                }) {
                    Text("로그인")
                        .disabled(isLoginWorking)
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
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())
    }
}
                       
#Preview {
    LoginView(email: "", password: "")
}
