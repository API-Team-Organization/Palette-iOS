import SwiftUI
import Kingfisher
import FlowKit

struct MessageBubble: View {
    let message: ChatMessageModel
    let onImageTap: (UIImage) -> Void
    @State private var image: UIImage?
    @Flow var flow
    let success_alert = Alert(title: Text("이미지 저장 완료!"),
                              message: Text("이미지가 사진첩에 저장되었어요!"),
                              dismissButton: .default(Text("확인")))
    
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
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 240)
                    .clipped()
                    .cornerRadius(13)
                    .onTapGesture {
                        if let image = self.image {
                            onImageTap(image)
                        }
                    }
                    .onAppear {
                        KingfisherManager.shared.retrieveImage(with: URL(string: message.message)!) { result in
                            switch result {
                            case .success(let value):
                                DispatchQueue.main.async {
                                    self.image = value.image
                                }
                            case .failure:
                                break
                            }
                        }
                    }
                    .contextMenu {
                        Button(action: {
                            if let image = self.image {
                                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//                                flow.alert(success_alert, animated: true)
                            }
                        }) {
                            Text("갤러리에 저장하기")
                            Image(systemName: "square.and.arrow.down")
                        }
                        Button(action: {
                            if let image = self.image {
                                let activityViewController = UIActivityViewController(
                                    activityItems: [image],
                                    applicationActivities: nil
                                )
                                
                                // Optional: Exclude certain activity types
                                activityViewController.excludedActivityTypes = [
                                    .addToReadingList,
                                    .assignToContact,
                                    .print
                                ]
                                
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let rootViewController = windowScene.windows.first?.rootViewController {
                                    rootViewController.present(activityViewController, animated: true, completion: nil)
                                }
                            }
                        }) {
                            Text("이미지 공유하기")
                            Image(systemName: "square.and.arrow.up")
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
                            Text("텍스트 복사하기")
                            Image(systemName: "doc.on.doc")
                        }
                    }
            }
        }
        .background(message.isAi ? Color.gray.opacity(0.2) : Color("AccentColor"))
        .foregroundColor(message.isAi ? .black : .white)
        .cornerRadius(13)
    }
    
//    private var regenerateButton: some View {
//        if isRegenerateButtonVisible {
//            Button(action: {
//                debugPrint("Hi")
//            }) {
//                Text("홍보물 재생성하기")
//                    .font(.custom("SUIT-Bold", size: 16)) // 버튼 텍스트 크기
//                    .foregroundColor(.white)
//                    .padding(.vertical, 12) // 세로 패딩 설정
//                    .padding(.horizontal, 24) // 가로 패딩 설정
//                    .background(Color("AccentColor"))
//                    .cornerRadius(10) // 버튼의 cornerRadius
//            }
//            .frame(maxWidth: .infinity, alignment: .center) // 버튼을 부모의 너비에 맞추어 중앙 정렬
//            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2) // 약간의 그림자 효과 추가
//        }
//        else {
//            EmptyView()
//        }
//    }
    
    private var timeText: some View {
        Text(formattedTime)
            .font(.custom("SUIT-Regular", size: 11))
            .foregroundColor(.gray)
    }
}
