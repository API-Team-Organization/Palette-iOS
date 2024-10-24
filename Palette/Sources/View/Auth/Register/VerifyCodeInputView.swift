//
//  VerifyCodeInputView.swift
//  Palette
//
//  Created by 4rNe5 on 5/16/24.
//

import SwiftUI
import FlowKit

struct VerifyCodeInputView: View {
    
    var email: String
    var userName: String
    @State var verifyCode: String = ""
    @State private var showingBlankAlert = false
    @Environment(\.presentationMode) var presentationMode
    @Flow var flow
    
    let fail_alert = Alert(title: "앗! 인증에 실패했어요!",
                      message: "다시 시도해주세요.",
                      dismissButton: .default("확인"))
    let resend_notif = Alert(title: "코드를 다시 전송했어요!",
                      message: "메일함을 확인해주세요.",
                      dismissButton: .default("확인"))
    
    func handleVerifyCode() async {
        let credentials = VerifyCodeModel(code: verifyCode)
        
        
        guard let tokenData = KeychainManager.load(key: "accessToken"), let tokenOld = String(data: tokenData, encoding: .utf8) else {return}
        
        let res = await PaletteNetworking.post("/auth/verify", parameters: credentials, res: EmptyResModel.self)
        switch res {
        case .success(_):
            if let newData = KeychainManager.load(key: "accessToken"), let tokenNew = String(data: newData, encoding: .utf8) {
                if tokenOld != tokenNew { // token updated!
                    flow.replace([RegisterFinView()], animated: true)
                }
            }
            
        case .failure(let error):
            flow.alert(fail_alert)
            
        }
    }
    
    func handleResendVerifyCode() async {
        let res = await PaletteNetworking.post("/auth/resend", res: EmptyResModel.self)
        switch res {
        case .success(_):
            flow.alert(resend_notif)
        case .failure(let error):
            flow.alert(fail_alert)
        }
    }
    
    
    var body: some View {
        ZStack {
            Color(.white).ignoresSafeArea()
            VStack {
                HStack {
                    Text("이메일 인증을 시작할깨요!")
                        .font(.custom("Pretendard-ExtraBold", size: 27))
                        .padding(.leading, 15)
                        .foregroundStyle(.black)
                    Spacer()
                }
                .padding(.bottom, 2)
                .padding(.top, 50)
                HStack {
                    Text("이메일로 전송된 인증번호를 입력해주세요!")
                        .font(.custom("SUIT-Bold", size: 15))
                        .padding(.leading, 17)
                        .foregroundStyle(Color("DescText"))
                    Spacer()
                }
                .padding(.bottom, 30)
            
                HStack {
                    TextField("verifycode",text: $verifyCode, prompt: Text("인증번호").foregroundStyle(Color("DescText")))
                        .keyboardType(.numberPad)
                        .padding(.leading, 10)
                        .frame(width:363, height: 55)
                        .background(Color("TextFieldBack"))
                        .cornerRadius(15.0)
                        .foregroundStyle(.black)
                        .font(.custom("SUIT-SemiBold", size: 18))
                        .padding(.leading, 15)
                        .padding(.bottom, 22)
                
                    Spacer()
                }
                HStack {
                    Button(action: {
                        Task { await handleResendVerifyCode() }
                    }) {
                        Text("코드 다시 전송하기")
                            .font(.custom("Pretendard-Bold", size: 15))
                            .fontWeight(.bold)
                            .foregroundColor(Color("AccentColor"))
                            .padding(.leading, 20)
                    }
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
                        Task { await handleVerifyCode() }
                    }
                }) {
                    Text("인증하기")
                        .font(.custom("Pretendard-ExtraBold", size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 363, height: 55)
                        .background(Color("AccentColor"))
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
