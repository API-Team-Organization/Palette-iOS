import SwiftUI
import FlowKit

struct LoginView: View {
    @State var email: String = ""
    @State var password: String = ""
    @State private var isLoginWorking = false
    @State private var showingfailAlert = false
    @State private var showinginputAlert = false
    @State private var keyboardHeight: CGFloat = 0
    @Environment(\.presentationMode) var presentationMode
    
    @FocusState private var isEmailFocused: Bool
    @FocusState private var isPasswordFocused: Bool
    
    @Flow var flow
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // 커스텀 네비게이션 바
                HStack {
                    BackButton()
                    Spacer()
                }
                .padding()
                .background(Color.white)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        logoSection
                            .padding(.bottom, -3)
                        titleSection
                        inputSection
                    
                        VStack {
                            loginButton
                            signUpLink
                        }
                    }
                    .padding(.horizontal, 16)
                    .animation(.easeOut(duration: 0.25), value: keyboardHeight)
                }
                .ignoresSafeArea(.keyboard)
            }
        }
        .onTapGesture { self.endTextEditing() }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                keyboardHeight = keyboardRectangle.height
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardHeight = 0
        }
        .navigationBarHidden(true)
        .alert("로그인 실패", isPresented: $showingfailAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("로그인에 실패했습니다.")
        }
        .alert("입력정보 오류", isPresented: $showinginputAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("비밀번호나 아이디를 확인해주세요.")
        }
    }
    
    private var logoSection: some View {
        HStack {
            Image("PaletteLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 55, height: 55)
            Spacer()
        }
        .padding(.top, 16)
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Palette에 로그인하기")
                .font(.custom("SUIT-ExtraBold", size: 28))
                .foregroundColor(.black)
            
            Text("로그인할 이메일과 비밀번호를 입력해주세요!")
                .font(.custom("SUIT-Medium", size: 16))
                .foregroundColor(Color("DescText"))
        }
        .padding(.top, 20)
        .padding(.bottom, 32)
    }
    
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 7) {
                Text("이메일")
                    .font(.custom("SUIT-Medium", size: 14))
                    .foregroundColor(.gray)
                    .padding(.leading, 4)
                TextField("", text: $email)
                    .font(.custom("SUIT-Medium", size: 18))
                    .padding(.vertical, 8)
                    .foregroundStyle(.black)
                    .background(
                        VStack {
                            Spacer()
                            Color(isEmailFocused ? "AccentColor" : "SuBlack" ).frame(height: 1)
                        }
                    )
                    .padding(.leading, -2)
                    .padding(.horizontal, 7)
                    .focused($isEmailFocused)
            }
            
            VStack(alignment: .leading, spacing: 7) {
                Text("비밀번호")
                    .font(.custom("SUIT-Medium", size: 14))
                    .foregroundColor(.gray)
                    .padding(.leading, 4)
                SecureField("", text: $password)
                    .font(.custom("SUIT-Medium", size: 18))
                    .padding(.vertical, 8)
                    .foregroundStyle(.black)
                    .background(
                        VStack {
                            Spacer()
                            Color(isPasswordFocused ? "AccentColor" : "SuBlack" ).frame(height: 1)
                        }
                    )
                    .padding(.leading, -2)
                    .padding(.horizontal, 7)
                    .focused($isPasswordFocused)
            }
        }
    }
    
    private var loginButton: some View {
        Button(action: {
            if email.isEmpty || password.isEmpty {
                showinginputAlert = true
            } else {
                isLoginWorking = true
                Task { await handleLogin() }
            }
        }) {
            Text("로그인")
                .font(.custom("SUIT-Bold", size: 16))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color("AccentColor"))
                .cornerRadius(12)
        }
        .disabled(isLoginWorking)
        .padding(.top, 260)
    }

    private var signUpLink: some View {
        HStack {
            Spacer()
            Text("계정이 없으신가요? ")
                .foregroundColor(.black)
                .font(.custom("Pretendard-Medium", size: 14))
                .padding(.trailing, -5)
            Button(action: {
                flow.push(EmailInputView())
            }) {
                Text("회원가입")
                    .foregroundColor(Color("AccentColor"))
                    .font(.custom("Pretendard-SemiBold", size: 14))
            }
            Spacer()
        }
        .padding(.top, 16)
    }
    
    func handleLogin() async {
        let post = await PaletteNetworking.post("/auth/login", parameters: LoginRequestModel(email: email, password: password), res: EmptyResModel.self)
        
        if let tokenData = KeychainManager.load(key: "accessToken"), let _ = String(data: tokenData, encoding: .utf8) {
            await MainActor.run {
                flow.replace([MainView()]) // accessToken exists check
            }
            return
        }
    
        await MainActor.run {
            failHandler()
        }
    }
    
    @MainActor
    func failHandler() {
        isLoginWorking = false
        showingfailAlert = true
    }
}


extension View {
    func endTextEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    LoginView(email: "", password: "")
}
