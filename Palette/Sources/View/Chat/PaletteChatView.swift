import SwiftUI
import Alamofire
import FlowKit

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
}

struct PaletteChatView: View {
    let roomTitle: String
    let roomID: Int
    
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    @State private var textEditorHeight: CGFloat = 40
    @Environment(\.presentationMode) var presentationMode
    @Flow var flow
    
    var body: some View {
        VStack {
            // 헤더
            HStack {
                Button(action: {
                    flow.push(MainView())
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
                .padding(.leading)
                
                Image("PaletteLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 28)
                
                Text(roomTitle)
                    .font(.headline)
                    .foregroundStyle(Color.black)
                    .lineLimit(1)
                
                Spacer()
            }
            .padding()
            
            // 메시지 목록
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(messages) { message in
                        MessageBubble(message: message)
                    }
                }
                .padding()
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
            .padding(.bottom, 10)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .navigationBarHidden(true)
    }
    
    struct MessageBubble: View {
        let message: ChatMessage
        
        var body: some View {
            HStack {
                if message.isUser { Spacer() }
                Text(message.content)
                    .padding(10)
                    .background(message.isUser ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                if !message.isUser { Spacer() }
            }
        }
    }

    private func updateTextEditorHeight() {
        let newSize = CGSize(width: UIScreen.main.bounds.width - 100, height: .infinity)
        let newHeight = messageText.heightWithConstrainedWidth(width: newSize.width, font: UIFont(name: "SUIT-Medium", size: 15) ?? .systemFont(ofSize: 15))
        textEditorHeight = min(max(40, newHeight + 20), 120) // 최소 40, 최대 120
    }

    func sendMessage() {
        guard !messageText.isEmpty else { return }
        let newMessage = ChatMessage(content: messageText, isUser: true)
        messages.append(newMessage)
        messageText = ""
        textEditorHeight = 40 // 메시지 전송 후 높이 초기화
        
        // TODO: 서버로 메시지 전송 로직 구현
    }
}

extension String {
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(boundingBox.height)
    }
}

#Preview {
    PaletteChatView(roomTitle: "테스트 채팅방", roomID: 1)
}
