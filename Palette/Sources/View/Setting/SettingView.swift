//
//  SettingView.swift
//  Palette
//
//  Created by 4rNe5 on 6/20/24.
//

import SwiftUI
import Alamofire
import FlowKit

struct SettingView: View {
    
    @Flow var flow
    @State var uName: String = "유저"
    @State var isUserNameLoaded: Bool = false
    
    func getHeaders() -> HTTPHeaders {
        let token: String
        if let tokenData = KeychainManager.load(key: "accessToken"),
           let tokenString = String(data: tokenData, encoding: .utf8) {
            token = tokenString
        } else {
            token = ""
        }

        let headers: HTTPHeaders = [
            "x-auth-token": token
        ]
        return headers
    }
    
    func getProfileData() async {
        let url = "https://api.paletteapp.xyz/info/me"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)

        AF.request(url, method: .get, headers: getHeaders())
            .validate(statusCode: 200..<300) // Add validation to ensure the response is valid
            .responseDecodable(of: ProfileResponseModel<ProfileDataModel>.self, decoder: decoder) { response in
                switch response.result {
                case .success(let profileResponse):
                    print(profileResponse.data.name)
                    uName = profileResponse.data.name
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    if let data = response.data, let str = String(data: data, encoding: .utf8) {
                        print("Raw response: \(str)")
                    }
                }
            }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("설정")
                    .font(.custom("SUIT-ExtraBold", size: 25))
                    .foregroundStyle(.black)
                    .padding(.top, 45)
                    .padding(.leading, 20)
                    .padding(.bottom, 30)
                Spacer()
            }
            Button(action: {
                flow.push(Text("My"))
            }) {
                HStack {
                    VStack(alignment: .leading){
                        Text(uName)
                            .font(.custom("SUIT-Bold", size: 18))
                            .foregroundStyle(.black)
                            .padding(.bottom, 5)
                        Text("내 정보")
                            .foregroundStyle(Color("DescText"))
                            .font(.custom("SUIT-SemiBold", size: 14))
                            
                    }
                    .padding(.leading, 20)
                    Spacer()
                    Image("Arrow")
                        .resizable()
                        .frame(width: 7, height: 11)
                        .padding(.trailing, 20)
                }
            }
            .padding(.bottom, 55)
            SettingButton(buttonTitle: "알림", settingPage: .notification)
                .padding(.bottom, 57)
            SettingButton(buttonTitle: "개인정보 처리방침", settingPage: .privacy)
                .padding(.bottom, 56)
            SettingButton(buttonTitle: "Palette Evolved", settingPage: .evolved)
                .padding(.bottom, 32)
            SettingButton(buttonTitle: "앱 정보", settingPage: .appinfo)
                .padding(.bottom, 57)
            Button(action: {
                flow.push(Text("Logout"))
            }) {
                HStack {
                    VStack(alignment: .leading){
                        Text("로그아웃")
                            .foregroundStyle(.black)
                            .font(.custom("SUIT-SemiBold", size: 16))
                            
                    }
                    .padding(.leading, 20)
                    Spacer()
                    Image("Arrow")
                        .resizable()
                        .frame(width: 7, height: 11)
                        .padding(.trailing, 20)
                }
            }
            .padding(.bottom, 32)
            Button(action: {
                flow.push(Text("DeletedUser"))
            }) {
                HStack {
                    VStack(alignment: .leading){
                        Text("회원탈퇴")
                            .foregroundStyle(.red)
                            .font(.custom("SUIT-SemiBold", size: 16))
                            
                    }
                    .padding(.leading, 20)
                    Spacer()
                    Image("Arrow")
                        .resizable()
                        .frame(width: 7, height: 11)
                        .padding(.trailing, 20)
                }
            }
            
            Spacer()
        }
        .onAppear {
            if isUserNameLoaded == false {
                isUserNameLoaded = true
                Task {
                    await getProfileData()
                }
            }
        }
    }
}

#Preview {
    SettingView()
}
