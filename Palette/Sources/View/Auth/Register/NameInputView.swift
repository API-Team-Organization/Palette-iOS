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
    
    let serverurl = "https://api.paletteapp.xyz/auth/register"
    
    var email: String
    var pw: String
    var pwCheck: String
    var birthday: String
    @State var userName: String = ""
    @Environment(\.presentationMode) var presentationMode
    @Flow var flow
    let input_alert = Alert(title: "앗! 이름이 비어있어요!",
                      message: "이름을 입력해주세요.",
                      dismissButton: .default("확인"))
    let networkerr_alert = Alert(title: "앗! 오류가 발생했어요!",
                      message: "다시 시도해주세요.",
                      dismissButton: .default("확인"))
    let fail_alert = Alert(title: "앗! 회원가입에 실패했어요!",
                      message: "다시 시도해주세요.",
                      dismissButton: .default("확인"))
    
    func sendRegisterRequest() async {
        let url = "https://api.paletteapp.xyz/auth/register"
        let credentials = SignUpRequestModel(username: userName, password: pw, birthDate: birthday, email: email)
        
        AF.request(url,
                   method: .post,
                   parameters: credentials,
                   encoder: JSONParameterEncoder.default)
            .responseData { response in
                switch response.result {
                case .success(_):
                    if let headers = response.response?.allHeaderFields,
                       let token = headers["x-auth-token"] as? String {
                        print("Received token: \(token)")
                        
                        // KeyChain에 토큰 저장
                        if let tokenData = token.data(using: .utf8) {
                            let saveStatus = KeychainManager.save(key: "accessToken", data: tokenData)
                            if saveStatus == noErr {
                                print("Token successfully saved to KeyChain")
                                flow.replace([VerifyCodeInputView(email: email, userName: userName)])
                            } else {
                                print("Failed to save token to KeyChain. Status: \(saveStatus)")
                            }
                        } else {
                            print("Failed to convert token to Data")
                        }
                    } else {
                        print("No token found in response headers")
                        print(response)
                        flow.alert(fail_alert)
                    }
                case .failure(let error):
                    print("Error: \(error)")
                    flow.alert(fail_alert)
                }
        }
    }
    
    
    var body: some View {
        ZStack {
            Color(.white).ignoresSafeArea()
            VStack {
                HStack {
                    Text("이름을 입력해주세요!")
                        .font(.custom("Pretendard-ExtraBold", size: 27))
                        .padding(.leading, 15)
                        .foregroundStyle(.black)
                    Spacer()
                }
                .padding(.bottom, 2)
                .padding(.top, 50)
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
                    Task { await sendRegisterRequest() }
                }) {
                    Text("인증하러 가기")
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
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: BackButton())
        }
    }
}

#Preview {
    NameInputView(email: "23wdwad@gmail.com", pw: "23wdwad", pwCheck: "23wdwad", birthday: "2007-04-28")
}

