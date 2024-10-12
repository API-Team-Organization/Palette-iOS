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
    
    @State private var inputType: InputType = .text
    
    enum InputType {
        case text
        case qna(QnAResponseModel)
    }
    
    init(roomTitleprop: String?, roomID: Int, isNewRoom: Bool) {
        self.roomTitleprop = roomTitleprop
        self.roomID = roomID
        self.isNewRoom = isNewRoom
        _websocket = StateObject(wrappedValue: Websocket(roomID: roomID))
    }
    
    var body: some View {
        ZStack {
            VStack {
                headerView
                chatListView
                inputView
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .navigationBarHidden(true)
            
            fullScreenImageView
        }
        .onTapGesture {
            isInputFocused = false
        }
        .onAppear(perform: handleOnAppear)
        .alert("채팅방 이름 입력", isPresented: $showingRoomTitleAlert, actions: {
            TextField("채팅방 이름", text: $roomTitle)
            Button("확인") {
                Task {
                    await updateRoomTitle()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        loadChatMessages()
                    }
                }
            }
        }, message: {
            Text("새로운 채팅방의 이름을 입력해주세요.")
        })
        .onReceive(websocket.$messages, perform: handleNewMessages)
    }
    
    private var headerView: some View {
        HStack {
            backButton
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
    }
    
    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.black)
                .font(.system(size: 15))
        }
        .padding(.leading)
    }
    
    private var chatListView: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(messages + websocket.messages) { message in
                        messageBubble(for: message)
                    }
                    if isLoadingResponse {
                        loadingView
                    }
                }
                .padding()
                .onChange(of: messages) { _ in scrollToBottom(proxy: scrollViewProxy) }
                .onChange(of: websocket.messages) { _ in scrollToBottom(proxy: scrollViewProxy) }
            }
            .onAppear { scrollToBottom(proxy: scrollViewProxy) }
        }
    }
    
    private func messageBubble(for message: ChatMessageModel) -> some View {
        MessageBubble(message: message, onImageTap: { image in
            self.fullscreenImage = image
            self.isFullscreenPresented = true
        })
        .id(message.id)
    }
    
    private var loadingView: some View {
        HStack {
            ProgressView()
                .frame(maxWidth: 200, maxHeight: 200)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(13)
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation {
            proxy.scrollTo(messages.last?.id ?? websocket.messages.last?.id, anchor: .bottom)
        }
    }
    
    private var inputView: some View {
        switch inputType {
        case .text:
            return AnyView(textInputView)
        case .qna(let qnaResponse):
            if let qnaData = qnaResponse.data.first {
                return AnyView(QnAInputView(qna: qnaData, onSubmit: submitAnswer))
            } else {
                return AnyView(Text("No QnA data available").foregroundColor(.red))
            }
        }
    }
    
    private var textInputView: some View {
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
    
    private var fullScreenImageView: some View {
        Group {
            if isFullscreenPresented, let image = fullscreenImage {
                FullScreenImageView(image: image, isPresented: $isFullscreenPresented)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
            }
        }
    }
    
    private func handleOnAppear() {
        if isNewRoom {
            showingRoomTitleAlert = true
        } else {
            roomTitle = roomTitleprop ?? "새 채팅방 이름"
            loadChatMessages()
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
        let url = "https://api.paletteapp.xyz/room/\(roomID)/title"
        let parameters = ChatroomNameFetchModel(title: roomTitle)
        
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
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let chatHistory = try JSONDecoder().decode(ChatHistoryResponse.self, from: data)
                        DispatchQueue.main.async {
                            self.messages = chatHistory.data.reversed()
                            if let lastMessage = self.messages.last, lastMessage.resource == .PROMPT {
                                self.loadQnAResponse(roomId: self.roomID)
                            } else {
                                self.inputType = .text
                            }
                        }
                    } catch {
                        print("Error decoding chat history: \(error)")
                        if let decodingError = error as? DecodingError {
                            switch decodingError {
                            case .dataCorrupted(let context):
                                print("Data corrupted: \(context)")
                            case .keyNotFound(let key, let context):
                                print("Key '\(key)' not found: \(context.debugDescription)")
                            case .typeMismatch(let type, let context):
                                print("Type mismatch for type \(type): \(context.debugDescription)")
                            case .valueNotFound(let type, let context):
                                print("Value of type \(type) not found: \(context.debugDescription)")
                            @unknown default:
                                print("Unknown decoding error: \(decodingError)")
                            }
                        }
                        if let str = String(data: data, encoding: .utf8) {
                            print("Received data: \(str)")
                        }
                    }
                case .failure(let error):
                    print("Error loading chat history: \(error.localizedDescription)")
                }
            }
    }
    
    private func handleNewMessages(_ newMessages: [ChatMessageModel]) {
        for message in newMessages {
            if message.resource == .PROMPT {
                loadQnAResponse(roomId: roomID)
            } else {
                messages.append(message)
            }
        }
    }
    
    private func loadQnAResponse(roomId: Int) {
            AF.request("https://api.paletteapp.xyz/room/\(roomId)/qna",
                       method: .get,
                       headers: getHeaders())
                .responseDecodable(of: QnAResponseModel.self) { response in
                    switch response.result {
                    case .success(let qnaResponse):
                        DispatchQueue.main.async {
                            self.inputType = .qna(qnaResponse)  // 전체 QnAResponseModel을 전달
                        }
                    case .failure(let error):
                        print("Error loading QnA: \(error.localizedDescription)")
                        if let data = response.data, let str = String(data: data, encoding: .utf8) {
                            print("Received data: \(str)")
                        }
                    }
                }
        }
    
    private func submitAnswer(_ answer: AnswerDto) {
        let requestData = ChatRequestData(
                type: answer.type,
                choiceId: answer.choiceId,
                input: answer.input,
                choice: answer.choice
            )
            let requestBody = ChatRequestBody(data: requestData)
            
            // 디버깅을 위해 요청 데이터를 출력
            do {
                let jsonData = try JSONEncoder().encode(requestBody)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("Request body: \(jsonString)")
                }
            } catch {
                print("Error encoding request body: \(error)")
            }
            
            AF.request("https://api.paletteapp.xyz/chat?roomId=\(roomID)",
                       method: .post,
                       parameters: requestBody,
                       encoder: JSONParameterEncoder.default,
                       headers: getHeaders())
                .responseData { response in
                    DispatchQueue.main.async {
                        switch response.result {
                        case .success(let data):
                            if let str = String(data: data, encoding: .utf8) {
                                print("Response data: \(str)")
                            }
                            self.inputType = .text
                            self.loadChatMessages()
                        case .failure(let error):
                            print("Error submitting answer: \(error)")
                            if let data = response.data, let str = String(data: data, encoding: .utf8) {
                                print("Error response data: \(str)")
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
