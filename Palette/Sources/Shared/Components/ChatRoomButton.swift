import SwiftUI
import FlowKit

struct ChatRoomButton: View {
    @Flow var flow
    var roomTitle: String
    var roomID: Int
    var lastMessage: String?
    var onDelete: (Int) -> Void // 삭제 시 수행할 로직을 전달받는 클로저
    let del_alert = Alert(title: "채팅방 삭제 완료!",
                      message: "채팅방을 성공적으로 삭제했어요!",
                      dismissButton: .default("확인"))
    
    var body: some View {
        Button(action: {
            flow.push(PaletteChatView(roomTitleprop: roomTitle, roomID: roomID, isNewRoom: false))
        }) {
            ZStack {
                Color("ButtonBG")
                HStack {
                    Image("PaletteLogo")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                    
                    VStack {
                        MarqueeText(text: roomTitle, font: .custom("SUIT-Bold", size: 18), startDelay: 1.0)
                            .foregroundStyle(.black)
                            .padding(.bottom, -3)
                        if lastMessage != nil {
                            MarqueeText(text: lastMessage!, font: .custom("SUIT-SemiBold", size: 13), startDelay: 1.5)
                                .foregroundStyle(Color("DescText"))
                        } else {
                            MarqueeText(text: "채팅방에 아무런 메시지가 없어요..", font: .custom("SUIT-SemiBold", size: 13), startDelay: 1.5)
                                .foregroundStyle(Color("DescText"))
                        }
                    }
                    .padding(.vertical, 18)
                    Spacer()
                    Image("Arrow")
                        .resizable()
                        .frame(width: 6, height: 10)
                        .padding(.trailing, 15)
                }
            }
            .frame(width: 350, height: 77)
            .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
        }
        .contextMenu {
            Button(role: .destructive) {
                onDelete(roomID)
                flow.alert(del_alert)
            } label: {
                Label("채팅방 삭제하기", systemImage: "trash")
            }
        }
    }
}
