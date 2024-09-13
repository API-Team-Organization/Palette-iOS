import SwiftUI
import Alamofire
import FlowKit

struct PaletteChatView: View {
    let roomTitleprop: String?
    let roomID: Int
    let isNewRoom: Bool
    
    @State private var messageText = ""
    @State var roomTitle = "새 채팅방 이름"
    @State private var messages: [ChatMessageModel] = []
    @State private var textEditorHeight: CGFloat = 40
    @State private var showingRoomTitleAlert = false
    @State private var isLoadingResponse = false
    @State private var isMessageValid = false
    @Environment(\.presentationMode) var presentationMode
    let update_alert = Alert(title: Text("방 제목 설정 실패"),
                             message: Text("채팅방 제목 설정에 실패했습니다."),
                             dismissButton: .default(Text("확인")))
    let chatblank_alert = Alert(title: Text("메시지 전송 실패"),
                                message: Text("메시지 내용을 입력해주세요."),
                                dismissButton: .default(Text("확인")))
    @Flow var flow
    
    @StateObject private var websocket: Websocket
    
    @State private var fullscreenImage: UIImage?
    @State private var isFullscreenPresented = false
    
    @FocusState private var isInputFocused: Bool

    init(roomTitleprop: String?, roomID: Int, isNewRoom: Bool) {
        self.roomTitleprop = roomTitleprop
        self.roomID = roomID
        self.isNewRoom = isNewRoom
        _websocket = StateObject(wrappedValue: Websocket(roomID: roomID))
    }
    
    var body: some View {
        ZStack {
            VStack {
                // 헤더
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .font(.system(size: 15))
                    }
                    .padding(.leading)
                    
                    Image("PaletteLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 28)
                    
                    Text(roomTitle)
                        .font(.custom("SUIT-Bold", size: 20))
                        .foregroundStyle(Color.black)
                        .lineLimit(1)
                    
                    Spacer()
                }
                .padding()
                
                ScrollViewReader { scrollViewProxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 10) {
                            ForEach(messages + websocket.messages) { message in
                                MessageBubble(message: message, onImageTap: { image in
                                    self.fullscreenImage = image
                                    self.isFullscreenPresented = true
                                })
                                .id(message.id)
                            }
                            if isLoadingResponse {
                                HStack {
                                    ProgressView()
                                        .frame(maxWidth: 200, maxHeight: 200)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(13)
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .padding()
                        .onChange(of: messages) { _ in
                            withAnimation {
                                scrollViewProxy.scrollTo(messages.last?.id, anchor: .bottom)
                            }
                        }
                        .onChange(of: websocket.messages) { _ in
                            withAnimation {
                                scrollViewProxy.scrollTo(websocket.messages.last?.id, anchor: .bottom)
                            }
                        }
                    }
                    .onAppear {
                        withAnimation {
                            scrollViewProxy.scrollTo(messages.last?.id, anchor: .bottom)
                        }
                    }
                }

                
                // 메시지 입력 영역
                VStack(spacing: 0) {
                                    HStack(alignment: .bottom, spacing: 10) {
                                        ZStack(alignment: .leading) {
                                            TextEditor(text: $messageText)
                                                .font(.custom("SUIT-Medium", size: 15))
                                                .foregroundStyle(Color.black)
                                                .padding(.horizontal, 15)
                                                .padding(.vertical, 10)
                                                .frame(height: max(40, textEditorHeight))
                                                .scrollContentBackground(.hidden)
                                                .background(Color.clear)
                                                .onChange(of: messageText) { _ in
                                                    withAnimation {
                                                        updateTextEditorHeight()
                                                    }
                                                }
                                                .focused($isInputFocused)
                                            
                                            if messageText.isEmpty {
                                                Text("당신의 Palette를 그려보세요")
                                                    .foregroundColor(.gray)
                                                    .padding(.horizontal, 20)
                                                    .padding(.vertical, 12)
                                                    .font(.custom("SUIT-Medium", size: 15))
                                            }
                                        }
                                        .background(Color("ChatTextFieldBack"))
                                        .cornerRadius(20)
                                        
                                        Button(action: sendMessage) {
                                            Image(systemName: "paperplane.fill")
                                                .foregroundColor(isMessageValid ? Color("AccentColor") : Color.gray)
                                                .padding(10)
                                                .background(Color("ChatTextFieldBack"))
                                                .clipShape(Circle())
                                        }
                                        .disabled(!isMessageValid)
                                    }
                                    .padding(.horizontal)
                                    .padding(.top, 10)
                                    .padding(.bottom, 20)
                                    .background(Color.white)
                                    .cornerRadius(20, corners: [.topLeft, .topRight])
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.white)
                            .navigationBarHidden(true)
            
            if isFullscreenPresented, let image = fullscreenImage {
                FullScreenImageView(image: image, isPresented: $isFullscreenPresented)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
            }
        }
        .onTapGesture {
            isInputFocused = false
        }
        .onAppear {
            if isNewRoom {
                showingRoomTitleAlert = true
            } else {
                roomTitle = roomTitleprop ?? "새 채팅방 이름"
            }
            loadChatMessages()
        }
        .alert("채팅방 이름 입력", isPresented: $showingRoomTitleAlert) {
            TextField("채팅방 이름", text: $roomTitle)
            Button("확인") {
                Task { await updateRoomTitle() }
            }
        } message: {
            Text("새로운 채팅방의 이름을 입력해주세요.")
        }
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
    
    private func updateTextEditorHeight() {
        let newSize = CGSize(width: UIScreen.main.bounds.width - 100, height: .infinity)
        let newHeight = messageText.heightWithConstrainedWidth(width: newSize.width, font: UIFont(name: "SUIT-Medium", size: 15) ?? .systemFont(ofSize: 15))
        textEditorHeight = min(max(40, newHeight + 20), 120) // 최소 40, 최대 120
        
        // 메시지 유효성 검사
        isMessageValid = !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func sendMessage() {
        guard isMessageValid else { return }
        
        let requestModel = SendMessageRequestModel(message: messageText)
        
        isLoadingResponse = true

        AF.request("https://api.paletteapp.xyz/chat?roomId=\(roomID)",
                   method: .post,
                   parameters: requestModel,
                   encoder: JSONParameterEncoder.default,
                   headers: getHeaders())
            .responseDecodable(of: ChatMessageResponseModel.self) { response in
                DispatchQueue.main.async {
                    switch response.result {
                    case .success(let chatResponse):
                        print("Message sent successfully: \(chatResponse)")
                    case .failure(let error):
                        print("Error sending message: \(error.localizedDescription)")
                        if let data = response.data, let str = String(data: data, encoding: .utf8) {
                            print("Received data: \(str)")
                        }
                    }
                    self.isLoadingResponse = false
                }
            }
        
        messageText = ""
        textEditorHeight = 40
        isMessageValid = false
    }
    
    private func updateRoomTitle() async {
        let url = "https://api.paletteapp.xyz/room/title"
        let parameters = ChatroomNameFetchModel(id: roomID, title: roomTitle)
        
        AF.request(url, method: .patch, parameters: parameters, encoder: JSONParameterEncoder.default, headers: getHeaders())
            .responseData { response in
                switch response.result {
                case .success(_):
                    print("Change Success")
                    print(parameters)
                    
                    if let data = response.data {
                        PrintJSON(from: data)
                    }
                    
                case .failure(let error):
                    print("오류:", error.localizedDescription)
                }
            }
    }
    
    private func loadChatMessages() {
        AF.request("https://api.paletteapp.xyz/chat/\(roomID)", method: .get, headers: getHeaders())
            .responseDecodable(of: ChatHistoryResponse.self) { response in
                switch response.result {
                case .success(let chatHistory):
                    DispatchQueue.main.async {
                        self.messages = chatHistory.data.reversed()
                    }
                case .failure(let error):
                    print("Error loading chat history: \(error.localizedDescription)")
                    if let data = response.data, let str = String(data: data, encoding: .utf8) {
                        print("Received data: \(str)")
                        // 수동으로 디코딩 시도
                        if let jsonData = str.data(using: .utf8) {
                            do {
                                let chatHistory = try JSONDecoder().decode(ChatHistoryResponse.self, from: jsonData)
                                DispatchQueue.main.async {
                                    self.messages = chatHistory.data.reversed()
                                }
                            } catch {
                                print("Manual decoding failed: \(error)")
                            }
                        }
                    }
                }
            }
    }
}

extension String {
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(boundingBox.height)
    }
}
