import SwiftUI
import FlowKit

struct PaletteChatView: View {
    let roomTitleprop: String?
    let roomID: Int
    let isNewRoom: Bool
    
    @State private var messageText = ""
    @State var roomTitle = "새 채팅방 이름"
    @State private var messages: [ChatMessageModel] = []
    @State private var qna: [QnAData] = []
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
        case qna(QnAData)
        case unknown
    }
    
    init(roomTitleprop: String?, roomID: Int, isNewRoom: Bool) {
        self.roomTitleprop = roomTitleprop
        self.roomID = roomID
        self.isNewRoom = isNewRoom
        _websocket = StateObject(wrappedValue: Websocket(roomID: roomID))
    }
    
    @MainActor
    private func addChat(_ message: ChatMessageModel) {
        self.messages.append(message)
        print("new Chat! \(message)")
        handleLastMessage(message)
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
                    let (_,_) = await (loadQnA(), loadChatMessages())
                }
            }
        }, message: {
            Text("새로운 채팅방의 이름을 입력해주세요.")
        })
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
                    ForEach(messages) { message in
                        messageBubble(for: message)
                    }
                    if isLoadingResponse {
                        loadingView
                    }
                }
                .padding()
                .onChange(of: messages) { scrollToBottom(proxy: scrollViewProxy) }
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
            proxy.scrollTo(messages.last?.id, anchor: .bottom)
        }
    }
    
    private var inputView: some View {
        return switch inputType {
        case .text:
            AnyView(textInputView)
        case .qna(let data):
            AnyView(QnAInputView(qna: data, onSubmit: submitAnswer))
        case .unknown:
            AnyView(Text("No QnA data available").foregroundColor(.red))
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
                        .onChange(of: messageText) {
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
        websocket.setMessageCallback(onMessage: self.addChat)
        if isNewRoom {
            showingRoomTitleAlert = true
        } else {
            roomTitle = roomTitleprop ?? "새 채팅방 이름"
            Task {
                let (_,_) = await (loadQnA(), loadChatMessages())
            }
        }
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
        messageText = ""
        textEditorHeight = 40
        isMessageValid = false
        
        Task {
            let response = await PaletteNetworking.post(
                "/chat?roomId=\(roomID)",
                parameters: requestModel,
                res: EmptyResModel.self
            )
            
            switch (response) {
            case .success(let response):
                print("Message sent successfully: \(response)")
            case .failure(let error):
                print(error.localizedDescription)
            }
            
            self.isLoadingResponse = false
        }
    }
    
    private func updateRoomTitle() async {
        let data = ChatroomNameFetchModel(title: roomTitle)
        
        Task {
            let res = await PaletteNetworking.patch("/room/\(roomID)/title", parameters: data, res: EmptyResModel.self)
            switch(res) {
            case .success(_):
                print("Change Success")
                print(data)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func loadChatMessages() async {
        let result = await PaletteNetworking.get("/chat/\(roomID)", res: DataResModel<[ChatMessageModel]>.self)
        switch result {
        case .success(let response):
            await MainActor.run {
                setMessages(response.data)
            }
        case .failure(let error):
            print("Error loading chat history: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    private func setMessages(_ msgs: [ChatMessageModel]) {
        self.messages = msgs.reversed()
        if let lastMessage = self.messages.last {
            handleLastMessage(lastMessage)
        }
    }
    
    private func handleLastMessage(_ msg: ChatMessageModel) {
        if msg.resource == .PROMPT {
            if let found = qna.first(where: { elem in elem.id == msg.promptId}) {
                inputType = .qna(found)
            }
        }
    }
    
    private func loadQnA() async {
        let result = await PaletteNetworking.get("/room/\(roomID)/qna", res: DataResModel<[QnAData]>.self)
        switch result {
        case .success(let response):
            DispatchQueue.main.async {
                self.qna = response.data
            }
        case .failure(let error):
            print("QNA thrown error: \(error.localizedDescription)")
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
            return
        }
        
        Task {
            let res = await PaletteNetworking.post("/chat?roomId=\(roomID)", parameters: requestBody, res: EmptyResModel.self)
            switch res {
            case .success(let data):
                print("res! \(data.message)")
                self.inputType = .text // reset?
            case .failure(let error):
                print("Error submitting answer: \(error)")
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
