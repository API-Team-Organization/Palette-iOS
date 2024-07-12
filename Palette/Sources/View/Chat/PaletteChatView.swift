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
    @Environment(\.presentationMode) var presentationMode
    let update_alert = Alert(title: "방 제목 설정 실패",
                             message: "채팅방 제목 설정에 실패했습니다.",
                             dismissButton: .default("확인"))
    @Flow var flow
    
    var body: some View {
        VStack {
            // 헤더
            HStack {
                Button(action: {
                    flow.replace([MainView()], animated: true)
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
                        ForEach(messages) { message in
                            MessageBubble(message: message)
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
                }
                .onAppear {
                    withAnimation {
                        scrollViewProxy.scrollTo(messages.last?.id, anchor: .bottom)
                    }
                }
            }
            
            // 메시지 입력 영역
            HStack(alignment: .bottom) {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(height: max(40, textEditorHeight))
                        .foregroundStyle(Color("ChatTextFieldBack"))
                        .overlay {
                            TextEditor(text: $messageText)
                                .font(.custom("SUIT-Medium", size: 15))
                                .foregroundStyle(Color.black)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 10)
                                .scrollContentBackground(.hidden)
                                .onChange(of: messageText) { _ in
                                    withAnimation {
                                        updateTextEditorHeight()
                                    }
                                }
                        }
                    
                    if messageText.isEmpty {
                        Text("당신의 Palette를 그려보세요")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .font(.custom("SUIT-Medium", size: 15))
                    }
                }
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(Color("AccentColor"))
                        .padding(10)
                        .background(Color("ChatTextFieldBack"))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            .padding(.top, 5)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .navigationBarHidden(true)
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
    }

    func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        let userMessage = ChatMessageModel(id: messages.count,
                                           message: messageText,
                                           datetime: ISO8601DateFormatter().string(from: Date()),
                                           roomId: roomID,
                                           userId: 0,
                                           isAi: false,
                                           resource: .CHAT)
        DispatchQueue.main.async {
            self.messages.append(userMessage)
        }
        
        let requestModel = SendMessageRequestModel(message: messageText, roomId: roomID)
        
        isLoadingResponse = true

        AF.request("https://paletteapp.xyz/chat",
                   method: .post,
                   parameters: requestModel,
                   encoder: JSONParameterEncoder.default,
                   headers: getHeaders())
            .responseDecodable(of: ChatMessageResponseModel.self) { response in
                DispatchQueue.main.async {
                    switch response.result {
                    case .success(let chatResponse):
                        self.messages.append(contentsOf: chatResponse.data.received)
                    case .failure(let error):
                        print("Error: \(error.localizedDescription)")
                        if let data = response.data, let str = String(data: data, encoding: .utf8) {
                            print("Received data: \(str)")
                        }
                    }
                    self.isLoadingResponse = false
                }
            }
        
        messageText = ""
        textEditorHeight = 40
    }
    
    private func updateRoomTitle() async {
        let url = "https://paletteapp.xyz/room/title"
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
                    flow.alert(update_alert)
                    print("오류:", error.localizedDescription)
                }
            }
    }
    
    private func loadChatMessages() {
        AF.request("https://paletteapp.xyz/chat/\(roomID)", method: .get, headers: getHeaders())
            .responseDecodable(of: ChatHistoryResponse.self) { response in
                switch response.result {
                case .success(let chatHistory):
                    self.messages = chatHistory.data
                case .failure(let error):
                    print("Error loading chat history: \(error.localizedDescription)")
                    if let data = response.data, let str = String(data: data, encoding: .utf8) {
                        print("Received data: \(str)")
                        // 수동으로 디코딩 시도
                        if let jsonData = str.data(using: .utf8) {
                            do {
                                let chatHistory = try JSONDecoder().decode(ChatHistoryResponse.self, from: jsonData)
                                self.messages = chatHistory.data
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
