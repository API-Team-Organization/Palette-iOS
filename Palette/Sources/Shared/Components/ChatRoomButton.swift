import SwiftUI
import FlowKit

struct ChatRoomButton: View {
    @Flow var flow
    var roomTitle: String
    var roomID: Int
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
                        .frame(width: 58, height: 58)
                        .padding(.leading, 20)
                    
                    VStack(alignment: .leading) {
                        Text("\(Text("Palette").font(.custom("SUIT-Regular", size: 19))) 어시스턴트")
                            .font(.custom("Pretendard-Regular", size: 19))
                            .foregroundStyle(Color("LightDark"))
                            .padding(.bottom, -6)
                        
                        MarqueeText(text: roomTitle, font: .custom("Pretendard-Bold", size: 23), startDelay: 1.0)
                            .foregroundStyle(.black)
                            .frame(height: 30)
                    }
                    .padding(.leading, 15)
                    Spacer()
                }
            }
            .frame(width: 340, height: 110)
            .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
        }
        .contextMenu {
            Button(role: .destructive) {
                onDelete(roomID)
                flow.alert(del_alert)
            } label: {
                Label("채팅방 삭제", systemImage: "trash")
            }
        }
    }
}

// 사용 예시
struct ContentView: View {
    var body: some View {
        ChatRoomButton(roomTitle: "Example Room", roomID: 1) { roomID in
            // 삭제 로직
            print("Deleting room with ID: \(roomID)")
        }
    }
}
