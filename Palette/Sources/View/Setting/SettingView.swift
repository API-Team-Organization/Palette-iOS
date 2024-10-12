import SwiftUI
import FlowKit

struct SettingView: View {
    @Flow var flow
    @State var uName: String = "유저"
    @State var isUserNameLoaded: Bool = false
    @State private var refreshID = UUID()
    @State private var showingLogoutAlert = false
    
    let fail_alert = Alert(title: "로그아웃 실패",
                      message: "로그아웃에 실패했습니다.",
                      dismissButton: .default("확인"))
    let success_alert = Alert(title: "로그아웃 성공",
                      message: "성공적으로 로그아웃하였습니다.",
                      dismissButton: .default("확인"))
    
    func getProfileData() async {
        let result = await PaletteNetworking.get("/info/me", res: DataResModel<ProfileDataModel>.self)
        switch result {
        case .success(let profileResponse):
            await MainActor.run {
                uName = profileResponse.data.name
            }
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    
    func userLogout() async {
        let _ = await PaletteNetworking.post("/auth/logout", res: EmptyResModel.self)
        let _ = KeychainManager.delete(key: "accessToken") // 아니이러지마세요제발
        
        await MainActor.run {
            flow.replace([StartView()], animated: true)
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
                    flow.push(ProfileEditView(), animated: true)
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
                    showingLogoutAlert = true
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
                .alert(isPresented: $showingLogoutAlert) {
                    Alert(
                        title: Text("로그아웃"),
                        message: Text("정말 로그아웃하시겠습니까?"),
                        primaryButton: .destructive(Text("예")) {
                            Task{await userLogout()}
                        },
                        secondaryButton: .cancel(Text("아니요"))
                    )
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
            .id(refreshID)  // View를 강제로 새로고침하기 위한 id
            .onAppear {
                Task {
                    await getProfileData()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                Task {
                    await getProfileData()
                    await MainActor.run {
                        refreshID = UUID()  // View를 강제로 새로고침
                    }
                }
            }
    }
}
