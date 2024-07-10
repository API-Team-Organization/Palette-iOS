import SwiftUI

struct MessageBubble: View {
    let message: ChatMessageModel
    
    var body: some View {
        HStack {
            if message.isAi { Spacer() }
            Text(message.message)
                .padding(10)
                .background(message.isAi ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
            if !message.isAi { Spacer() }
        }
    }
}
