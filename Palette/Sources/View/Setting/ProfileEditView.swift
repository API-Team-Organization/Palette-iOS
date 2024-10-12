//
//  ProfileEditView.swift
//  Palette
//
//  Created by 4rNe5 on 9/13/24.
//


import SwiftUI
import FlowKit

struct ProfileEditView: View {
    @Flow var flow
    @State private var uName: String = ""
    @State private var uEmail: String = ""
    @State private var uBirthday: Date = Date()
    
    @State private var originalName: String = ""
    @State private var originalBirthday: String = ""
    
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
        return uName != originalName || formatDate(uBirthday) != originalBirthday
    }
    
    var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    func getProfileData() async {
        let result = await PaletteNetworking.get("/info/me", res: DataResModel<ProfileDataModel>.self)
        switch result {
        case .success(let profileResponse):
            await MainActor.run {
                uName = profileResponse.data.name
                uEmail = profileResponse.data.email
                uBirthday = formatter.date(from: profileResponse.data.birthDate) ?? Date()
                originalName = profileResponse.data.name
                originalBirthday = profileResponse.data.birthDate
            }
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    
    func saveProfileData() async {
        let parameters = ProfileEditRequestModel(username: uName, birthDate: formatDate(uBirthday))
        
        let result = await PaletteNetworking.patch("/info/me", parameters: parameters, res: EmptyResModel.self)
        await MainActor.run {
            switch result {
            case .success(_):
                showingSaveAlert = true
                originalName = uName
                originalBirthday = formatDate(uBirthday)
                presentationMode.wrappedValue.dismiss()
                flow.alert(comp_alert, animated: true)
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
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
                Button(action: {
                    Task {
                        await saveProfileData()
                    }
                }) {
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
        return formatter.string(from: date)
    }
}

struct EmptyResponse: Codable {}
