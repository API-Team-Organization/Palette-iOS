import SwiftUI
import Kingfisher

struct MessageBubble: View {
    let message: ChatMessageModel
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h:mm"
        return formatter.string(from: message.date)
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isAi {
                messageContent
                timeText
            } else {
                Spacer()
                timeText
                messageContent
            }
        }
        .padding(.vertical, 4)
    }
    
    private var messageContent: some View {
        Group {
            if message.resource == .IMAGE {
                KFImage(URL(string: message.message))
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 200, maxHeight: 200)
                    .cornerRadius(10)
            } else {
                Text(message.message)
                    .padding(10)
            }
        }
        .background(message.isAi ? Color.gray.opacity(0.2) : Color("AccentColor"))
        .foregroundColor(message.isAi ? .black : .white)
        .cornerRadius(10)
    }
    
    private var timeText: some View {
        Text(formattedTime)
            .font(.caption2)
            .foregroundColor(.gray)
    }
}
