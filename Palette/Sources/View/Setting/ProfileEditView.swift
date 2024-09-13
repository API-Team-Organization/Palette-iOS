//
//  ProfileEditView.swift
//  Palette
//
//  Created by 4rNe5 on 9/13/24.
//


import SwiftUI
import FlowKit
import Alamofire

struct ProfileEditView: View {
    @Flow var flow
    @State private var uName: String = ""
    @State private var uEmail: String = ""
    @State private var uBirthday: Date = Date()
    
    @State private var originalName: String = ""
    @State private var originalBirthday: Date = Date()
    
    @State private var isUserNameLoaded: Bool = false
    
    @State private var editingField: EditingField? = nil
    
    @State private var showingSaveAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    let comp_alert = Alert(title: "수정 성공",
                      message: "내 정보 수정에 성공했습니다.",
                      dismissButton: .default("확인"))
    
    @Environment(\.presentationMode) var presentationMode
    
    enum EditingField {
        case name, email, birthday
    }
    
    var isProfileChanged: Bool {
        return uName != originalName || uBirthday != originalBirthday
    }
    
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
            .validate(statusCode: 200..<300)
            .responseDecodable(of: ProfileResponseModel<ProfileDataModel>.self, decoder: decoder) { response in
                switch response.result {
                case .success(let profileResponse):
                    debugPrint(profileResponse.data)
                    uName = profileResponse.data.name
                    uEmail = profileResponse.data.email
                    uBirthday = profileResponse.data.birthDate
                    originalName = profileResponse.data.name
                    originalBirthday = profileResponse.data.birthDate
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    if let data = response.data, let str = String(data: data, encoding: .utf8) {
                        print("Raw response: \(str)")
                    }
                }
            }
    }
    
    func saveProfileData() {
        let url = "https://api.paletteapp.xyz/info/me"
        let parameters: [String: Any] = [
            "username": uName,
            "birthDate": formatDate(uBirthday)
        ]
        
        AF.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: getHeaders())
            .validate(statusCode: 200..<300)
            .responseDecodable(of: ProfileEditResponseModel.self) { response in
                switch response.result {
                case .success(_):
                    showingSaveAlert = true
                    originalName = uName
                    originalBirthday = uBirthday
                    presentationMode.wrappedValue.dismiss()
                    flow.alert(comp_alert, animated: true)
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    if let data = response.data, let str = String(data: data, encoding: .utf8) {
                        print("Raw response: \(str)")
                    }
                    errorMessage = "프로필 저장에 실패했습니다."
                    showingErrorAlert = true
                }
            }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .bold()
                            .foregroundStyle(Color("LightDark"))
                            .padding(.leading, -4)
                        Text("돌아가기")
                            .font(.custom("SUIT-SemiBold", size: 16))
                            .foregroundStyle(Color("LightDark"))
                    }
                }
                Spacer()
            }
            .padding(.leading, 20)
            .padding(.top, 30)
            HStack {
                Text("내 정보")
                    .font(.custom("SUIT-ExtraBold", size: 25))
                    .foregroundStyle(.black)
                    .padding(.top, 15)
                    .padding(.leading, 20)
                    .padding(.bottom, 30)
                Spacer()
            }
            
            VStack(spacing: 20) {
                profileField(title: "성명", value: uName, field: .name)
                HStack {
                    Text("이메일")
                        .font(.custom("SUIT-Bold", size: 16))
                        .foregroundColor(Color.black)
                    Spacer()
                    Text(uEmail)
                        .font(.custom("SUIT-Regular", size: 16))
                        .foregroundColor(Color("AccentColor"))
                }
                profileField(title: "생년월일", value: formatDate(uBirthday), field: .birthday)
            }
            .padding()
            
            Spacer()
            
            if isProfileChanged {
                Button(action: saveProfileData) {
                    Text("수정하기")
                        .font(.custom("SUIT-ExtraBold", size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 363, height: 55)
                        .background(Color("AccentColor"))
                        .cornerRadius(12)
                        .padding(.bottom, 30)
                }
                .padding()
            }
        }
        .onAppear {
            Task {
                await getProfileData()
            }
        }
        .onTapGesture {
            self.endTextEditing()
        }
        .alert(isPresented: $showingSaveAlert) {
            Alert(title: Text("저장 완료"), message: Text("프로필이 성공적으로 저장되었습니다."), dismissButton: .default(Text("확인")))
        }
        .alert(isPresented: $showingErrorAlert) {
            Alert(title: Text("오류"), message: Text(errorMessage), dismissButton: .default(Text("확인")))
        }
        .background(Color("BackgroundColor"))
        .navigationBarBackButtonHidden(true)
    }
    
    func profileField(title: String, value: String, field: EditingField) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.custom("SUIT-Bold", size: 16))
                    .foregroundColor(Color.black)

                Spacer()
                Text(value)
                    .font(.custom("SUIT-Regular", size: 16))
                    .foregroundColor(Color("AccentColor"))
            }
            .onTapGesture {
                withAnimation(.spring()) {
                    if editingField == field {
                        editingField = nil
                    } else {
                        editingField = field
                    }
                }
            }
            
            if editingField == field {
                VStack {
                    if field == .birthday {
                        DatePicker("", selection: $uBirthday, displayedComponents: .date)
                            .datePickerStyle(WheelDatePickerStyle())
                    } else {
                        TextField(title, text: $uName)
                            .padding(.leading, 10)
                            .frame(width:363, height: 55)
                            .background(Color("TextFieldBack"))
                            .cornerRadius(15.0)
                            .foregroundStyle(.black)
                            .font(.custom("SUIT-SemiBold", size: 15))
                    }
                    HStack {
                        Button("완료") {
                            withAnimation(.spring()) {
                                editingField = nil
                            }
                        }
                        .font(.custom("SUIT-Bold", size: 15))
                        .foregroundColor(.blue)
                        Spacer()
                    }
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

struct EmptyResponse: Codable {}
