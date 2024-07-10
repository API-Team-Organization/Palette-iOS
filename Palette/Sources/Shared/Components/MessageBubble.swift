import SwiftUI
import Kingfisher
import FlowKit

struct MessageBubble: View {
    let message: ChatMessageModel
    @State private var image: UIImage?
    @Flow var flow
    let success_alert = Alert(title: "이미지 저장 완료!",
                      message: "이미지가 사진첩에 저장되었어요!",
                      dismissButton: .default("확인"))

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
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
                    .cornerRadius(13)
                    .contextMenu {
                        Button(action: {
                            if let image = self.image {
                                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                                flow.alert(success_alert, animated: true)
                            }
                        }) {
                            Text("사진첩에 저장")
                            Image(systemName: "square.and.arrow.down")
                        }
                    }
                    .onAppear {
                        KingfisherManager.shared.retrieveImage(with: URL(string: message.message)!) { result in
                            switch result {
                            case .success(let value):
                                self.image = value.image
                            case .failure:
                                break
                            }
                        }
                    }
            } else {
                Text(message.message)
                    .font(.custom("SUIT-Medium", size: 14))
                    .padding(10)
                    .contextMenu {
                        Button(action: {
                            UIPasteboard.general.string = message.message
                        }) {
                            Text("복사")
                            Image(systemName: "doc.on.doc")
                        }
                    }
            }
        }
        .background(message.isAi ? Color.gray.opacity(0.2) : Color("AccentColor"))
        .foregroundColor(message.isAi ? .black : .white)
        .cornerRadius(13)
    }

    private var timeText: some View {
        Text(formattedTime)
            .font(.custom("SUIT-Regular", size: 11))
            .foregroundColor(.gray)
    }
}
